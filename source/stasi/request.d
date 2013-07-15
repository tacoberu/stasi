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


module stasi.request;


import std.stdio;
import std.process;
import std.string;



enum Action {
	SHELL,
	VERIFY_CONFIG,
	VERSION,
	AUTH
}



/**
 * Konfigurace programu. Obsahuje informace převzaté z příkazové řádky, 
 * a některé informace prostředí.
 */
class Request
{

	/**
	 * Možné akce.
	 */
	Action action;


	/**
	 * Uživatel, který posílá požadavek.
	 */
	string user;


	/**
	 * Umístění domovského adresáře.
	 */
	string homePath;


	/**
	 * Originální přžíkaz. O co se pokouší.
	 */
	string command;


	/**
	 * Soubor, ze kterého načítáme konfiguraci.
	 */
	string configFile;


	/**
	 * Vytvoření objektu na základě cli.
	 */
	this(string[] args, string[string] env)
	{
		this.parseArgs(args);
		this.parseEnv(env);
	}



	private void parseArgs(string[] args)
	{
		if (args.length < 2) {
			throw new Exception("Action not found.");
		}

		//	Zpracování prvního parametru, kterýžto je akcí.
		switch (args[1]) {
			case "shell":
				this.action = Action.SHELL;
				break;
			case "verify-config":
				this.action = Action.VERIFY_CONFIG;
				break;
			case "version":
				this.action = Action.VERSION;
				break;
			case "auth":
				this.action = Action.AUTH;
				break;
			default:
				throw new Exception(format("Invalid action [%s].", args[1]));
		}

		//	Zpracování options
		string opt;
		foreach (m; args) {
			if (opt == null) {
				switch (m) {
					case "--config":
					case "--user":
						opt = m[2..$];
						break;
					default:
						break;
				}
			}
			else {
				switch (opt) {
					case "config":
						this.configFile = m;
						break;
					case "user":
						this.user = m;
						break;
					default:
						throw new Exception(format("Invalid option [%s]", opt));
				}
				opt = null;
			}
		}
	}
	
	
	
	private void parseEnv(string[string] env)
	{
		if ("SSH_ORIGINAL_COMMAND" in env) {
			this.command = env["SSH_ORIGINAL_COMMAND"];
		}
		if ("HOME" in env) {
			this.homePath = env["HOME"];
		}
	}



	/**
	 * Název akce.
	 */
	Action getAction()
	{
		return this.action;
	}



	/**
	 * Jméno uživatele.
	 */
	string getUser()
	{
		return this.user;
	}



	string getCommand()
	{
		return this.command;
	}

	
	
	string toString()
	{
		return format("request: action=[%s], user=[%s], command=[%s], home=[%s], config=[%s]", 
				formatAction(this.action),
				this.user,
				this.command,
				this.homePath,
				this.configFile
				);
	}



	string formatAction(Action action)
	{
		final switch(action)
		{
			case Action.SHELL:
				return "shell";
			case Action.VERIFY_CONFIG:
				return "verify-config";
			case Action.VERSION:
				return "version";
			case Action.AUTH:
				return "auth";
		}
	}


}
unittest {
	string[string] env;
	env["pokus"] = "pokus";
	try {
		Request request = new Request(["stasi"], env);
	}
	catch (Exception e) {
		assert("Action not found.", e.msg);
	}
	
}
