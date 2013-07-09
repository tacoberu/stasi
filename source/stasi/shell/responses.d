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


module stasi.responses;

import std.stdio;
import std.process;
import std.string;


/**
 * Odpověď.
 */
interface IResponse
{

	/**
	 *	Zobrazení výsledku na výstup.
	 */
	int fetch();


	string toString();

}




/**
 *	V odpověd vykonáme původní request.
 */
class ExecResponse : IResponse
{


	/**
	 * Příkaz pro vykonání.
	 */
	private string command;



	/**
	 *	Poslání na výstup.
	 */
	int fetch()
	{
		if (this.command) {
			std.process.system(this.command);
		}
		return 0;
	}



	/**
	 *	Nastavení příkazu.
	 */
	ExecResponse setCommand(string command)
	{
		this.command = command;
		return this;
	}



	string toString()
	{
		return format("cmd:[%s]", this.command);
	}


}

