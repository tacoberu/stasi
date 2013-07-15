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
		if (request.getCommand()) {
			auto a = split(request.getCommand());
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
/*
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("ls -la");
		assert(r.match(req) == false);
	}
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("git-upload-pack 'projects/stasi.git'");
		assert(r.match(req) == true);
	}
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("git-upload-archive 'projects/stasi.git'");
		assert(r.match(req) == true);
	}
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("git-receive-pack 'projects/stasi.git'");
		assert(r.match(req) == true);
	}
*/


	/**
	 * Jaký příkaz bude zpracvovávat tento request?
	 */
	ICommand getAction(ModelBuilder model)
	{
		return new Command(model);
	}



	@property string className()
	{
		return this.classinfo.name;
	}


}



/**
 *	Akce zpracovávající příkazy gitu.
 */
class Command : AbstractCommand
{

	private ModelBuilder model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(ModelBuilder model)
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
		//	Ověření přístupů.
		this.assertAccess(request);

		//	Ověření konzistence repozitáře. To znamená, zda
		//	- je bare
		//	- má nastavené defaultní hooky
		//	- ...
//		this.model.application.doNormalizeRepository(this.prepareRepository(request.getCommand()), "git");

		//	Výstup
		ExecResponse response2 = cast(ExecResponse) response;
		string masked;
		response2.setCommand(
			masked = this.maskedRepository(
				request.getCommand()));
		this.logger.log(format("masked command [%s] to [%s]", request.getCommand(), masked));
		return response2;
	}


	/**
	 * Ověření oprávnění.
	 */
	private void assertAccess(Request request)
	{
		string original = this.prepareRepository(request.getCommand());
		string cmd = this.maskedRepository(request.getCommand());
		//Repository repo = this.makeRepository(cmd);
		Repository repo = new Repository(original, RepositoryType.GIT);
		Permission perm = this.makePermission(cmd);

		if (! this.model.application.hasRepository(original)) {
			throw new RepositoryNotFoundException(format("Repository: [%s] not defined.", original));
		}

		if (! this.model.application.isAllowed(new User(request.getUser()), repo, perm)) {
			final switch (perm) {
				case Permission.INIT:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot creating git repository: [%s].", request.getUser(), original));
				case Permission.READ:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot read from git repository: [%s].", request.getUser(), original));
				case Permission.WRITE:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot write to git repository: [%s].", request.getUser(), original));
				case Permission.REMOVE:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot remove in git repository: [%s].", request.getUser(), original));
				case Permission.DENY:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot access to git repository: [%s].", request.getUser(), original));
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
	private string maskedRepository(string cmd)
	{
		string prefix = this.model.application.getDefaultRepositoryPath();
		return replace(cmd, regex(`([\w-]+\s+')([^']+)('.*)`), "$1" ~ prefix ~ "$2$3");
	}

}





