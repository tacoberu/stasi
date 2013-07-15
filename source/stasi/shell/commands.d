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


module stasi.commands;

import taco.logging;


import stasi.request;
import stasi.authentification;
import stasi.model;
import stasi.routing;
import stasi.responses;
import stasi.authentification;


/**
 *	Bázová třída, vracející formát json.
 */
interface ICommand
{

	/**
	 *	Podoba výstupu.
	 */
	IResponse createResponse(Request request);



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response);


	/**
	 * @param logovadlo.
	 * @return Dispatcher
	 */
	ICommand setLogger(ILogger logger);


	@property string className();

}





/**
 *	Bázová třída, vracející formát json.
 */
abstract class AbstractCommand : ICommand
{

	protected ILogger logger;


	/**
	 * Přiřazení logovadla.
	 */
	ICommand setLogger(ILogger logger)
	{
		this.logger = logger;
		return this;
	}



	/**
	 * Získání loggeru, nového, nebo oposledně vytvořeneého.
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
	 */
	ILogger createLogger()
	{
		return new Logger();
	}


}




/**
 *	Propouští nezměněné příkazy, které nespravujeme.
 */
class OriginalCommand : AbstractCommand
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
		ExecResponse response2 = cast(ExecResponse) response;
		//this.getLogger().trace('request', request);
		//this.getLogger().trace('command', request.getCommand());
		if (this.model.application.isAllowedSignin(new User(request.getUser()))) {
			response2.setCommand(request.getCommand());
			return response2;
		}
		throw new AccessDeniedException("Access Denied for [{request.getUser()}]. User cannot sign-in.");
	}



}


