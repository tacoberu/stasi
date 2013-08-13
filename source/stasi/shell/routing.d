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
	ICommand getAction(Request request, IModelBuilder model);


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
	ICommand getAction(Request request, IModelBuilder model)
	{
		switch (request.action) {
			case Action.VERIFY_CONFIG:
				return new VerifyConfigCommand(cast(Application)model.application);
			case Action.AUTH:
				return new AuthCommand(cast(Application)model.application);
			case Action.VERSION:
				return new VersionCommand(cast(Application)model.application);
			default:
				return null;
		}
	}



	@property string className()
	{
		return this.classinfo.name;
	}


}
unittest {
	Router r = new Router();
	string[string] env;
	Request req = new Request(["stasi", "auth", "--user", "fean"], env);
	//Request req = (((new Request()).user = "fean").action = Action.AUTH);
	assert(r.match(req) == true);
}



