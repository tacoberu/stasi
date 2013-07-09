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
	ICommand getAction(ModelBuilder model);

}



/**
 *	Mapování GET na request.
 */
class Router
{

	/**
	 * Vytvoření instance requestu.
	 * @param array args Seznam parametrů s CLI.
	 */
	Request createRequest(string[] args)
	{
		Request request = new Request();
		if (args.length > 1) {
			request.setUser(args[1]);
		}
		request.setCommand(environment.get("SSH_ORIGINAL_COMMAND"));

		return request;
	}


}



/**
 *	Přepravka.
 */
class Request
{

	/**
	 * Uživatel, který posílá požadavek.
	 */
	private string user;

	/**
	 * Originální přžíkaz. O co se pokouší.
	 */
	private string command;


	/**
	 * Čteme, zapišujeme, ...
	 * /
	private $access;


	/**
	 * Jméno uživatele.
	 */
	Request setUser(string value)
	{
		this.user = value;
		return this;
	}


	/**
	 * Jméno uživatele.
	 */
	string getUser()
	{
		return this.user;
	}


	Request setCommand(string value)
	{
		this.command = value;
		return this;
	}



	string getCommand()
	{
		return this.command;
	}
	
	
	string toString()
	{
		return format("user:[%s] - cmd:[%s]", this.user, this.command);
	}


/*
	public function setAccess($value)
	{
		$this->access = $value;
		return $this;
	}



	public function getAccess()
	{
		return $this->access;
	}

*/

}

