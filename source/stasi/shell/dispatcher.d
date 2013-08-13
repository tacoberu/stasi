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

import stasi.request;
import stasi.config;
import stasi.model;
import stasi.routing;
import stasi.commands;
import stasi.responses;

import std.string;



/**
 *	Výběr akcí.
 */
class Dispatcher
{


	/**
	 * Manipulace s daty.
	 */
	private ModelBuilder modelBuilder;


	/**
	 * Konfigurace.
	 */
	private Config config;


	/**
	 * Konfigurace.
	 */
	private ILogger _logger;


	/**
	 * Seznam rout, které zpracovávají vstup.
	 */
	private IRoute[] routers;


	/**
	 * @param model, config
	 */
	this(Config config, ModelBuilder model)
	{
		this.modelBuilder = model;
		this.config = config;
	}



	/**
	 * @param logovadlo.
	 * @return Dispatcher
	 */
	@property Dispatcher logger(ILogger logger)
	{
		this._logger = logger;
		return this;
	}



	/**
	 * @param logovadlo.
	 * @return Dispatcher
	 */
	Dispatcher addRoute(IRoute route)
	{
		this.routers ~= route;
		return this;
	}



	/**
	 * Získání loggeru, nového, nebo oposledně vytvořeneého.
	 * @return Logger
	 */
	@property ILogger logger()
	{
		if (! this._logger) {
			this._logger = this.createLogger();
		}
		return this._logger;
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
		this.logger.trace(request.toString(), "request");

		//	Rozřazuje, zda se jedná o příkazy pro git, nebo pro mercurial,
		//	nebo nějaké předdefinované, a nebo přihlášení na server.
		foreach (r; this.routers) {
			if (r.match(request)) {
				this.logger.trace(format("route.class: %s", r.className), "route");
				action = r.getAction(request, this.modelBuilder);
				break;
			}
		}

		if (! action) {
			action = new OriginalCommand(this.modelBuilder.application);
		}

		this.logger.trace(format("action=[%s]", action.className), "dispatch");
		action.logger = this.logger;

		IResponse response = this.fireAction(request, action);
		this.logger.trace(response.toString(), "response");

		return response;
	}



	/**
	 * @param ActionInterface action
	 * @return IResponse
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




