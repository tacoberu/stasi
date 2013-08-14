/**
 * Copyright (c) 2004, 2011 Martin Takáč
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * @author     Martin Takáč <taco@taco-beru.name>
 */


module stasi.adapters.mercurial;

import stasi.request;
import stasi.routing;
import stasi.model;
import stasi.commands;
import stasi.responses;
import stasi.authentification;

import taco.utils;

import std.stdio;
import std.string;
import std.file;



private const CMD_INIT = "hg init";
private const CMD_SERVER_START = "hg -R";
private const CMD_SERVER_END = "serve --stdio";




/**
 * Rozlišení mercurial příkazů.
 */
class Router : IRoute
{

	/**
	 * Zda se jedná o příkaz mercurialu.
	 */
	bool match(Request request)
	{
		string cmd = request.command;
		if (! cmd) {
			return false;
		}
		if (0 == indexOf(cmd, CMD_INIT)) {
			return true;
		}
		if ((0 == indexOf(cmd, CMD_SERVER_START))
				&& (lastIndexOf(cmd, CMD_SERVER_END) + CMD_SERVER_END.length) == cmd.length) {
			return true;
		}
		return false;
	}



	/**
	 * Jaký příkaz bude zpracvovávat tento request?
	 */
	ICommand getAction(Request request, IModelBuilder model)
	{
		return new Command(model.application);
	}



	@property string className()
	{
		return this.classinfo.name;
	}

}
/**
 * Prázdný příkaz.
 */
unittest {
	string[string] env;
	Router r = new Router();
	Request req = new Request(["stasi", "shell", "--user fean"], env);
	assert(r.match(req) == false);
}
/**
 * Mě se netýkající příkaz.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "ls -la";
	Router r = new Router();
	Request req = new Request(["stasi", "shell", "--user fean"], env);
	assert(r.match(req) == false);
}
/**
 * Příkaz pro vytvoření repozitáře.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "hg init projects/test.hg";
	Router r = new Router();
	Request req = new Request(["stasi", "shell", "--user fean"], env);
	assert(r.match(req) == true);
}
/**
 * Příkaz pro komunikaci s repozitářem.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "hg -R projects/test.hg serve --stdio";
	Router r = new Router();
	Request req = new Request(["stasi", "shell", "--user fean"], env);
	assert(r.match(req) == true);
}




/**
 *	Akce zpracovávající příkazy gitu.
 */
class Command : AbstractCommand
{

	private Application model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(Application model)
	{
		this.model = model;
	}



	@property string className()
	{
		return this.classinfo.name;
	}



	/**
	 *	Obálka na data.
	 */
	IResponse createResponse(Request request)
	{
		return new ExecResponse();
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		string repoName = this.prepareRepository(request.command);
		Repository repo = this.model.getRepositoryByName(repoName);
		if (! repo) {
			throw new RepositoryNotFoundException(format("Repository: [%s] not defined.", repoName));
		}

		string maskedCommand = this.maskedRepository(repo, request.command);

		//	Ověření přístupů.
		this.assertAccess(request, repo, maskedCommand);

		//	Ověření konzistence repozitáře. To znamená, zda
		//	- neexistuje, vytvořit
		//	- je bare
		//	- má nastavené defaultní hooky
		//	- ...
//		this.model.doExistRepository(repo, RepositoryType.MERCURIAL);
		this.model.doNormalizeRepository(repo, RepositoryType.MERCURIAL);

		//	Výstup
		ExecResponse response2 = cast(ExecResponse) response;
		response2.setCommand(maskedCommand);
		this.logger.log(format("masked command [%s] to [%s]", request.command, maskedCommand), "action");
		return response2;
	}




	/**
	 * Ověření oprávnění.
	 */
	private void assertAccess(Request request, Repository repo, string cmd)
	{
		Permission perm = this.makePermission(cmd);
		if (! this.model.isAllowed(new User(request.user), repo, perm)) {
			//	Rozlišujeme tu jen vytváření, možností přístupu. Read nebo 
			//	Write musí řešit hooky. Jinak to neumím.
			switch (perm) {
				case Permission.INIT:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot creating mercurial repository: [%s].", request.user, repo.name));
				default:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot access to mercurial repository: [%s].", request.user, repo.name));
			}
		}
	}



	/**
	 * Jaká oprávnění vyžadujem?
	 */
	private Permission makePermission(string cmd)
	{
		if (! cmd) {
			return Permission.DENY;
		}

		if (0 == indexOf(cmd, CMD_INIT)) {
			return Permission.INIT;
		}
		
		//	Nejnižší je čtení.
		return Permission.READ;
	}



	/**
	 * Nahradit jméno repozitáře v commandu.
	 */
	private string maskedRepository(Repository repository, string cmd)
	{
		if (! cmd) {
			return cmd;
		}

		string s;

		if (0 == indexOf(cmd, CMD_INIT)) {
			s = cmd[CMD_INIT.length .. $];
			s = s.strip();
			return format("%s %s%s", CMD_INIT, repository.path.path, s);
		}
		long i;
		if ((0 == indexOf(cmd, CMD_SERVER_START))
				&& ((i = lastIndexOf(cmd, CMD_SERVER_END)) + CMD_SERVER_END.length) == cmd.length) {
			s = cmd[CMD_SERVER_START.length .. i];
			s = s.strip();
			return format("%s %s%s %s", CMD_SERVER_START, repository.path.path, s, CMD_SERVER_END);
		}
		return cmd;
	}



	/**
	 * Z commandu rozpoznat jméno repozitáře.
	 */
	private string prepareRepository(string cmd)
	{
		string s;
		if (0 == indexOf(cmd, CMD_INIT)) {
			s = cmd[CMD_INIT.length .. $];
			return s.strip();
		}
		long i;
		if ((0 == indexOf(cmd, CMD_SERVER_START))
				&& ((i = lastIndexOf(cmd, CMD_SERVER_END)) + CMD_SERVER_END.length) == cmd.length) {
			s = cmd[CMD_SERVER_START.length .. i];
			return s.strip();
		}

		return null;
	}


}
/**
 * Scénář, kdy repozitář neexistuje.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "hg -R stasi.hg serve --stdio";
	Request request = new Request(["stasi", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	Application model = new Application(new Dir("."));
	Command cmd = new Command(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.adapters.mercurial.Command", "Spatný typ commandu");
	try {
		response = cmd.fetch(request, response);
	}
	catch (RepositoryNotFoundException e) {
		assert("Repository: [stasi.hg] not defined." == e.msg);
	}
}
/**
 * Scénář, kdy uživatel neexistuje.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "hg -R stasi.hg serve --stdio";
	Request request = new Request(["stasi", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	Application model = new Application(new Dir("."));
	Repository repo = new Repository("stasi.hg", RepositoryType.MERCURIAL);
	repo.path = new Dir("foo/doo");
	model.repositories ~= repo;
	
	Command cmd = new Command(model);
	IResponse response = cmd.createResponse(request);
	try {
		response = cmd.fetch(request, response);
	}
	catch (AccessDeniedException e) {
		assert("Access Denied for [franta]. User cannot access to mercurial repository: [stasi.hg]." == e.msg, e.msg);
	}
}
/**
 * Scénář úspěšného příštupu k repozitáři.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "hg -R stasi.hg serve --stdio";
	Request request = new Request(["stasi.git", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	Application model = new Application(new Dir("temp"));

	//	Repozitář
	Repository repo = new Repository("stasi.hg", RepositoryType.MERCURIAL);
	repo.path = new Dir("foo/doo");
	model.repositories ~= repo;

	//	Uživatel
	User user = new User("franta");
	model.users ~= user;
	
	//	ACL
	Permission perm = Permission.DENY | Permission.READ | Permission.WRITE;
	user.repositories[repo.name] = new AccessRepository(
			repo.name,
			repo.type, 
			perm);
	
	//	Příkaz
	Command cmd = new Command(model);
	IResponse response = cmd.createResponse(request);
	response = cmd.fetch(request, response);
	assert(response.toString() == "cmd:[hg -R foo/doo/stasi.hg serve --stdio]", response.toString());
}



/**
 * Práce s hg repozitářem.
 */
class Model : IAdapterModel
{


	/**
	 * Cesta k domácímu adresáři.
	 */
	Dir homePath;


	/**
	 *	
	 */
	this(Dir homePath)
	{
		this.homePath = homePath;
	}


	/**
	 * Vytvoření repozitáře.
	 */
	void doCreateRepository(Repository repository)
	{
		string oldcwd = getcwd();
		
		Dir dest = new Dir(this.homePath.path ~ repository.full);
		std.process.system(format("mkdir -p %s", dest.path));
		chdir(dest.path);
		
		//	Vytvoření a inicializace.
		std.process.system("hg init > /dev/null");
		this.doCreateDefaultHgrc();

		//	První commit
		std.process.system("echo 'empty' > README");
		std.process.system("hg add README > /dev/null");
		std.process.system("hg commit -m 'Initialize commit.' > /dev/null");

		chdir(oldcwd);
	}



	/**
	 * Zohlední změněné hooky v repozitáři.
	 */
	void doNormalizeRepository(Repository repository)
	{
		string oldcwd = getcwd();
		Dir dest = new Dir(this.homePath.path ~ repository.full);
		chdir(dest.path);

		//	Pokud soubor vůbec neexistuje, tak to je snadná práce.
		if (! std.file.exists(getcwd() ~ "/.hg/hgrc")) {
			this.doCreateDefaultHgrc();
		}
		else {
			// @TODO
		}

		/*
		//	Post Receive
		postReceive = fullrepo . '/hooks/post-receive';
		postReceiveTo = realpath(__dir__ . '/../../../../bin/git-hooks/post-receive');
		if (file_exists(postReceive) && (! is_link(postReceive) || readlink(postReceive) != postReceiveTo)) {
			rename(postReceive, postReceive . '-original');
		}

		if (! file_exists(postReceive)) {
			symlink(postReceiveTo, postReceive);
		}

		//	Post Update
		postUpdate = fullrepo . '/hooks/post-update';
		postUpdateTo = realpath(__dir__ . '/../../../../bin/git-hooks/post-update');
		if (file_exists(postUpdate) && (! is_link(postUpdate) || readlink(postUpdate) != postUpdateTo)) {
			rename(postUpdate, postUpdate . '-original');
		}

		if (! file_exists(postUpdate)) {
			symlink(postUpdateTo, postUpdate);
		}
		//*/
		chdir(oldcwd);
	}



	/**
	 * Vytvoření defaultního hgrc
	 */
	private void doCreateDefaultHgrc()
	{
		std.process.system("echo '[ui]' >> .hg/hgrc");
		std.process.system("echo 'username = Stasi' >> .hg/hgrc");
		std.process.system("echo '[hooks]' >> .hg/hgrc");
		std.process.system("echo 'changegroup.update = hg update' >> .hg/hgrc");
	}

}
