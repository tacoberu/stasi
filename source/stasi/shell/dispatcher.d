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


module stasi.dispatcher;

import taco.logging;
import stasi.config;
import stasi.model;
import stasi.routing;
import stasi.commands;
import stasi.responses;




/**
 *	Výběr akcí.
 */
class Dispatcher
{


	/**
	 * Manipulace s daty.
	 */
	private ModelBuilder model;


	/**
	 * Konfigurace.
	 */
	private Config config;


	/**
	 * Konfigurace.
	 */
	private ILogger logger;


	/**
	 * @param model, config
	 */
	this(Config config, ModelBuilder model)
	{
		this.model = model;
		this.config = config;
	}



	/**
	 * @param logovadlo.
	 * @return Dispatcher
	 */
	Dispatcher setLogger(ILogger logger)
	{
		this.logger = logger;
		return this;
	}



	/**
	 * Získání loggeru, nového, nebo oposledně vytvořeneého.
	 * @return Logger
	 */
	ILogger getLogger()
	{
		if (! this.logger) {
			this.logger = this.createLogger();
		}
		return this.logger;
	}



	/**
	 * Vytvoření nového loggeru.
	 * @return Logger
	 */
	ILogger createLogger()
	{
		return new Logger();
	}



	/**
	 * Vytvoření odpovědi. Předpokládáme jen náhled.
	 * @return Response
	 */
	IResponse dispatch(Request request)
	{
		ICommand action;
		//this.getLogger().trace('globals', GLOBALS);

		//	Rozřazuje, zda se jedná o příkazy pro git, nebo pro mercurial, nebo nějaké předdefinované, a nebo přihlášení na server.
		//parser = new Parser();
		//parser.add(new ParserGit());
		//parser.add(new ParserMercurial());
		//if (adapter = parser.parse(request)) {
			//actionClassName = adapter.getActionClassName();
			//action = new actionClassName(this.model);
			//request.setAccess(adapter.getAccess());
		//}
		//else {
			action = new OriginalCommand(this.model);
		//}

		action.setLogger(this.getLogger());

		IResponse response = this.fireAction(request, action);

		return response;
	}



	/**
	 * @param ActionInterface action
	 * @return Response
	 */
	private IResponse fireAction(Request request, ICommand action)
	{
		//	Vytvoříme odpověď.
		IResponse response = action.createResponse(request);

		//	Odpověď naplníme daty.
		response = action.fetch(request, response);

		return response;
	}

}




