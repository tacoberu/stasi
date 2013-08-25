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
		//auto s = std.process.execute("dmd", "myapp.d");

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



/**
 *	Výpis nějakého textu na stdout.
 */
class EchoResponse : IResponse
{


	/**
	 * Obsah výstupu.
	 */
	string content;



	/**
	 *	Poslání na výstup.
	 */
	int fetch()
	{
		if (this.content) {
			std.stdio.write(this.content);
		}
		return 0;
	}



	string toString()
	{
		return this.content;
	}


}
