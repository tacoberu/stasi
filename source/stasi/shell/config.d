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

module stasi.config;

import std.process;



/**
 * Nastavení programu.
 */
class Config
{

	/**
	 * Zpracovaný seznam akcí.
	 */
	private string[] actions;



	/**
	 * Konstruktorem předám parametry z CLI.
	 */
	this (string[] args)
	{
		foreach(int i, string arg; args) {
			if (i == 0) {
				continue;
			}
			this.actions ~= arg;
		}
	}



	/**
	 * Cesta ke kořeni domovského adresáře.
	 *
	 * @return string
	 */
	string getHomePath()
	{
		string ret = environment.get("HOME");
		//ret = rtrim(ret, '/\\');
		return ret;
	}



	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	string getAclFile()
	{
		return this.getHomePath() ~ "/.config/stasi/access.xml";
	}



}
unittest
{
	string[] args = ["main", "build", "install"];
	//Request foo = new Request(args);
//
	//assert(foo.getActions() == ["build", "install"], "this assert passes");
}







