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


module stasi.adapters.git;

import stasi.request;
import stasi.routing;
import stasi.model;
import stasi.commands;
import stasi.responses;
import stasi.authentification;

import taco.utils;

import std.stdio;
import std.array;
import std.regex;
import std.string;


/**
 * Rozlišení git příkazů.
 */
class Router : IRoute
{


	/**
	 * Rozhoduje, zda se jedná o příkaz gitu.
	 */
	bool match(Request request)
	{
		if (request.command) {
			auto a = split(request.command);
			if (! a.length) {
				return false;
			}
			switch (a[0]) {
				case "git-upload-pack":
				case "git-upload-archive":
				case "git-receive-pack":
					return true;
				default:
					return false;
			}
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
	env["SSH_ORIGINAL_COMMAND"] = "ls";
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
 * Příkaz pro zápis do repozitáře.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "git-upload-pack 'projects/stasi.git'";
	Router r = new Router();
	Request req = new Request(["stasi", "shell", "--user fean"], env);
	assert(r.match(req) == true);
}
/**
 * Příkaz pro zápis do repozitáře.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "git-upload-archive 'projects/stasi.git'";
	Router r = new Router();
	Request req = new Request(["stasi", "shell", "--user fean"], env);
	assert(r.match(req) == true);
}
/**
 * Příkaz pro čtení z repozitáře.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "git-receive-pack 'projects/stasi.git'";
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
		//writefln("maskedCommand: %s", maskedCommand);

		//	Ověření přístupů.
		this.assertAccess(request, repo, maskedCommand);

		//return response;
		//	Ověření konzistence repozitáře. To znamená, zda
		//	- neexistuje, vytvořit
		//	- je bare
		//	- má nastavené defaultní hooky
		//	- ...
		/*
		this.model.application.doNormalizeRepository(this.prepareRepository(request.command), RepositoryType.GIT);
		*/

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
			final switch (perm) {
				case Permission.INIT:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot creating git repository: [%s].", request.user, repo.name));
				case Permission.READ:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot read from git repository: [%s].", request.user, repo.name));
				case Permission.WRITE:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot write to git repository: [%s].", request.user, repo.name));
				case Permission.REMOVE:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot remove in git repository: [%s].", request.user, repo.name));
				case Permission.DENY:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot access to git repository: [%s].", request.user, repo.name));
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
		auto a = split(cmd);
		switch (a[0]) {
			case "git-upload-pack":
			case "git-upload-archive":
				return Permission.READ;
			case "git-receive-pack":
				return Permission.WRITE;
			default:
				return Permission.DENY;
		}
	}



	/**
	 * Z requestu vytvořit instanci repozitáře.
	 */
	private Repository makeRepository(string cmd)
	{
		return new Repository(
			this.prepareRepository(cmd), RepositoryType.GIT);
	}



	/**
	 * Z commandu rozpoznat jméno repozitáře.
	 */
	private string prepareRepository(string cmd)
	{
		auto m = match(cmd, regex(`([\w-]+\s+')([^']+)('.*)`));
		return m.captures[2];
	}



	/**
	 * Nahradit jméno repozitáře v commandu.
	 */
	private string maskedRepository(Repository repository, string cmd)
	{
		return replace(cmd, regex(`([\w-]+\s+')([^']+)('.*)`), "$1" ~ repository.path.path ~ "$2$3");
	}

}
/**
 * Scénář, kdy repozitář neexistuje.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "git-receive-pack 'stasi.git'";
	Request request = new Request(["stasi", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	Application model = new Application();
	Command cmd = new Command(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.adapters.git.Command");
	try {
		response = cmd.fetch(request, response);
	}
	catch (RepositoryNotFoundException e) {
		assert("Repository: [stasi.git] not defined." == e.msg);
	}
}
/**
 * Scénář, kdy uživatel neexistuje.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "git-receive-pack 'stasi.git'";
	Request request = new Request(["stasi", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	Application model = new Application();
	Repository repo = new Repository("stasi.git", RepositoryType.GIT);
	repo.path = new Dir("foo/doo");
	model.repositories ~= repo;
	
	Command cmd = new Command(model);
	IResponse response = cmd.createResponse(request);
	try {
		response = cmd.fetch(request, response);
	}
	catch (AccessDeniedException e) {
		assert("Access Denied for [franta]. User cannot write to git repository: [stasi.git]." == e.msg);
	}
}
/**
 * Scénář úspěšného příštupu k repozitáři.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "git-receive-pack 'stasi.git'";
	Request request = new Request(["stasi.git", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	Application model = new Application();

	//	Repozitář
	Repository repo = new Repository("stasi.git", RepositoryType.GIT);
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
	assert(response.toString() == "cmd:[git-receive-pack 'foo/doo/stasi.git']");
}
