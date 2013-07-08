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

import stasi.routing;
import stasi.model;
import stasi.commands;
import stasi.responses;

import std.array;


/**
 * Možnost zpracovávání git příkazů.
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



	/**
	 * Jaký příkaz bude zpracvovávat tento request?
	 */
	ICommand getAction(ModelBuilder model)
	{
		return new Command(model);
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



	/**
	 *	Obálka na data.
	 */
	IResponse createResponse(Request request)
	{
		return new ExecResponse();
	}



	/**
	 * @return Model
	 */
	ModelBuilder getModel()
	{
		return this.model;
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		//response = cast(ExecResponse) response;
		ExecResponse response2 = cast(ExecResponse) response;
		//acl = this.getModel().getApplication().getAcl();
		//acl.setUser(new Model\User(request.getUser()));
		//this.getLogger().trace('request', request);
		//this.getLogger().trace('command', request.getCommand());
		//if (acl.isAllowed(acl::PERM_SIGNIN)) {
			response2.setCommand(request.getCommand());
			return response2;
		//}
		//throw new AccessDeniedException("Access Denied for [{request.getUser()}]. User cannot sign-in.", 5);
	}



}




