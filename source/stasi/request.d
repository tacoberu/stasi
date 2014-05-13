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



module stasi.request;


import std.stdio;
import std.process;
import std.string;

import taco.utils;



enum Action
{
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
	 * Akce programu - shell, auth, verify-config
	 */
	private Action _action;


	/**
	 * Uživatel, který posílá požadavek.
	 */
	private string _user;


	/**
	 * Umístění domovského adresáře.
	 */
	private Dir _homePath;


	/**
	 * Originální příkaz. O co se pokouší.
	 */
	private string _command = "";


	/**
	 * Soubor, ze kterého načítáme konfiguraci.
	 */
	private string _configFile;


	/**
	 * Vytvoření objektu na základě cli.
	 */
	this(string[] args, string[string] env)
	{
		this.parseArgs(args);
		this.parseEnv(env);
	}



	/**
	 * Název akce.
	 */
	@property Action action()
	{
		return this._action;
	}



	/**
	 * Jméno uživatele.
	 */
	@property string user()
	{
		return this._user;
	}



	@property Dir homePath()
	{
		return this._homePath;
	}



	@property string command()
	{
		return this._command;
	}



	@property string configFile()
	{
		return this._configFile;
	}



	override string toString()
	{
		return format("request: action=[%s], user=[%s], command=[%s], home=[%s], config=[%s]",
				formatAction(this.action),
				this.user,
				this.command,
				this.homePath,
				this.configFile
				);
	}



	/**
	 * Argumenty z příkazového řádku.
	 */
	private void parseArgs(string[] args)
	{
		if (args.length < 2) {
			throw new Exception("Action not found.");
		}

		//	Zpracování prvního parametru, kterýžto je akcí.
		switch (args[1]) {
			case "shell":
				this._action = Action.SHELL;
				break;
			case "verify-config":
				this._action = Action.VERIFY_CONFIG;
				break;
			case "version":
				this._action = Action.VERSION;
				break;
			case "auth":
				this._action = Action.AUTH;
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
						this._configFile = m;
						break;
					case "user":
						this._user = m;
						break;
					default:
						throw new Exception(format("Invalid option [%s]", opt));
				}
				opt = null;
			}
		}
	}



	/**
	 * naplnění zajímavých údajů z prostředí.
	 */
	private void parseEnv(string[string] env)
	{
		if ("SSH_ORIGINAL_COMMAND" in env) {
			this._command = env["SSH_ORIGINAL_COMMAND"];
		}

		if ("HOME" in env) {
			this._homePath = new Dir(env["HOME"]);
		}
		else {
			this._homePath = new Dir("");
		}
	}



	private string formatAction(Action action)
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
//	Neplatný request.
unittest {
	string[string] env;
	env["pokus"] = "pokus";
	try {
		Request request = new Request(["stasi"], env);
	}
	catch (Exception e) {
		assert("Action not found." == e.msg);
	}
}
//	Prázdné prvky
unittest {
	string[string] env;
	env["pokus"] = "pokus";
	Request request = new Request(["stasi", "shell"], env);
	assert(request.action == Action.SHELL);
	assert(request.command == "");
	assert(request.configFile == "");
	assert(request.homePath.path == "");
	assert(request.user == "");
}
// Naplnění všech prvků
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "ls -la";
	env["pokus"] = "pokus";
	env["HOME"] = "foo/goo";
	Request request = new Request(["stasi", "shell", "--config", "./build/sample.xml", "--user", "franta"], env);
	assert(request.action == Action.SHELL);
	assert(request.command == "ls -la");
	assert(request.configFile == "./build/sample.xml");
	assert(request.homePath.path == "foo/goo/");
	assert(request.user == "franta");
}
