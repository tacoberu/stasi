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
import stasi.model;
import stasi.routing;
import stasi.responses;


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

}





/**
 *	Bázová třída, vracející formát json.
 */
abstract class AbstractCommand : ICommand
{

	private ILogger logger;


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
 *	Bázová třída, vracející formát json.
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


