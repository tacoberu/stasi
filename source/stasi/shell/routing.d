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


module stasi.routing;


import stasi.request;
import stasi.model;
import stasi.commands;
import stasi.responses;

import std.stdio;
import std.process;
import std.string;


/**
 *	Rozlišování modulů.
 */
interface IRoute
{

	/**
	 * Rozhoduje, zda umíme zpracovat tento příkaz.
	 */
	bool match(Request request);

	/**
	 * Jaký příkaz bude zpracvovávat tento request?
	 */
	ICommand getAction(Request request, ModelBuilder model);


	/**
	 * Jméno této třídy.
	 */
	@property string className();

}



/**
 *	Nějaké ty základní akce.
 */
class Router : IRoute
{


	/**
	 * Rozhoduje, zda se jedná o speciální příkazy stasi.
	 */
	bool match(Request request)
	{
		if (request.action) {
			switch (request.action) {
				case Action.VERIFY_CONFIG:
				case Action.AUTH:
				case Action.VERSION:
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
	ICommand getAction(Request request, ModelBuilder model)
	{
		switch (request.action) {
			case Action.VERIFY_CONFIG:
				return new VerifyConfigCommand(model);
			case Action.AUTH:
				return new AuthCommand(model);
			case Action.VERSION:
				return new VersionCommand(model);
			default:
				return null;
		}
	}



	@property string className()
	{
		return this.classinfo.name;
	}




	/**
	 * Vytvoření instance requestu.
	 * @param array args Seznam parametrů s CLI.
	 * /
	Request createRequest(string[] args)
	{
		Request request = new Request();
		if (args.length > 2) {
			switch (args[1]) {
				case "shell":
					request.action = Action.SHELL;
					break;
				case "verify-config":
					request.action = Action.VERIFY_CONFIG;
					break;
				case "version":
					request.action = Action.VERSION;
					break;
				default:
					throw new Exception(format("Invalid action [%s].", args[1]));
			}
			request.user = args[2];
		}
//		request.setCommand(environment.get("SSH_ORIGINAL_COMMAND"));

		return request;
	}
*/

}

unittest {
	Router r = new Router();
	string[string] env;
	Request req = new Request(["stasi", "auth", "--user", "fean"], env);
	//Request req = (((new Request()).user = "fean").action = Action.AUTH);
	assert(r.match(req) == true);
}



