/**
 * This file is part of the Taco Projects.
 *
 * Copyright (c) 2004, 2013 Martin Takáč (http://martin.takac.name)
 *
 * For the full copyright and license information, please view
 * the file LICENCE that was distributed with this source code.
 *
 * PHP version 5.3
 *
 * @author     Martin Takáč (martin@takac.name)
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
				case Action.HELP:
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
				return new VerifyConfigCommand(model);
			case Action.AUTH:
				return new AuthCommand(cast(Application)model.application);
			case Action.VERSION:
				return new VersionCommand(cast(Application)model.application);
			case Action.HELP:
				return new HelpCommand();
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
