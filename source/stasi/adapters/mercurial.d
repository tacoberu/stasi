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

import std.stdio;
import std.string;



private const CMD_INIT = "hg init";
private const CMD_SERVER_START = "hg -R";
private const CMD_SERVER_END = "serve --stdio";




/**
 * Rozlišení mercurial příkazů.
 */
class Router : IRoute
{

	bool match(Request request)
	{
		string cmd = request.getCommand();
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
	/*
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("ls -la");
		assert(r.match(req) == false);
	}
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("hg init projects/test.hg");
		assert(r.match(req) == true);
	}
	unittest {
		Router r = new Router();
		Request req = (new Request()).setUser("fean").setCommand("hg -R projects/test.hg serve --stdio");
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
		this.logger.log("before assert");

		//	Ověření přístupů.
		this.assertAccess(request);

		this.logger.log("after assert");

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
		Repository repo = new Repository(original, RepositoryType.MERCURIAL);
		Permission perm = this.makePermission(cmd);

		if (! this.model.application.hasRepository(original)) {
			throw new RepositoryNotFoundException(format("Repository: [%s] not defined.", original));
		}

		if (! this.model.application.isAllowed(new User(request.getUser()), repo, perm)) {
			//	Rozlišujeme tu jen vytváření, možností přístupu. Read nebo 
			//	Write musí řešit hooky. Jinak to neumím.
			switch (perm) {
				case Permission.INIT:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot creating mercurial repository: [%s].", request.getUser(), original));
				default:
					throw new AccessDeniedException(format("Access Denied for [%s]. User cannot access to mercurial repository: [%s].", request.getUser(), original));
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
	private string maskedRepository(string cmd)
	{
		if (! cmd) {
			return cmd;
		}

		string prefix = this.model.application.getDefaultRepositoryPath();
		string s;

		if (0 == indexOf(cmd, CMD_INIT)) {
			s = cmd[CMD_INIT.length .. $];
			s = s.strip();
			return format("%s %s%s", CMD_INIT, prefix, s);
		}
		long i;
		if ((0 == indexOf(cmd, CMD_SERVER_START))
				&& ((i = lastIndexOf(cmd, CMD_SERVER_END)) + CMD_SERVER_END.length) == cmd.length) {
			s = cmd[CMD_SERVER_START.length .. i];
			s = s.strip();
			return format("%s %s%s %s", CMD_SERVER_START, prefix, s, CMD_SERVER_END);
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
