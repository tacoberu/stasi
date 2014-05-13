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


module stasi.commands;

import stasi.request;
import stasi.model;
import stasi.routing;
import stasi.responses;
import stasi.authentification;
import stasi.config;

import taco.logging;
import taco.utils;

import std.string;



/**
 * Neplatný formát configuračního souboru.
 */
class NullException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}




/**
 *	Rozhraní příkazu.
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


	@property ICommand logger(ILogger logger);


	@property ILogger logger();


	@property string className();

}





/**
 *	Bázová třída, vracející formát json.
 */
abstract class AbstractCommand : ICommand
{

	private ILogger _logger;


	/**
	 * Přiřazení logovadla.
	 */
	@property ICommand logger(ILogger logger)
	{
		if (! logger) {
			throw new NullException("Instance of logger is empty.");
		}
		this._logger = logger;
		return this;
	}



	/**
	 * Získání loggeru, nového, nebo oposledně vytvořeneého.
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

	private IModel _model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(IModel model)
	{
		this._model = model;
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
	 * Model aplikace
	 */
	@property IModel model()
	{
		return this._model;
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 * @TODO isAllowedSignin zatím není implementována.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		ExecResponse response2 = cast(ExecResponse) response;
		//this.getLogger().trace('request', request);
		//this.getLogger().trace('command', request.getCommand());
		if (this.model.isAllowedSignin(new User(request.user))) {
			response2.setCommand(request.command);
			return response2;
		}
		throw new AccessDeniedException(format("Access Denied for [%s]. User cannot sign-in.", request.user));
	}



}
/**
 * Korektní získání verze stasi.
 */
unittest {
	string[string] env;
	env["SSH_ORIGINAL_COMMAND"] = "ls -la";
	Request request = new Request(["stasi", "shell"], env);
	Application model = new Application(new Dir("."));
	OriginalCommand cmd = new OriginalCommand(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.OriginalCommand", "Invalid type of command");
	response = cmd.fetch(request, response);
	assert(response.toString() == "cmd:[ls -la]", "[" ~ response.toString() ~ ']');
}





/**
 *	Vypíše verzi aplikace.
 */
class VersionCommand : AbstractCommand
{

	private ApplicationInfo _model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(ApplicationInfo model)
	{
		this._model = model;
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
		return new EchoResponse();
	}



	/**
	 * Model aplikace
	 */
	@property ApplicationInfo model()
	{
		return this._model;
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		EchoResponse response2 = cast(EchoResponse) response;
		response2.content = this.model.VERSION ~ "\n";
		return response2;
	}


}
/**
 * Korektní získání verze stasi.
 */
unittest {
	string[string] env;
	Request request = new Request(["stasi", "version"], env);
//	Application model = new Application(new Dir("."));
	ApplicationInfo model = new ApplicationInfo();
	VersionCommand cmd = new VersionCommand(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.VersionCommand", "Invalid type of command");
	response = cmd.fetch(request, response);
	assert(response.toString() == "0.0.5\n", "[" ~ response.toString() ~ ']');
}
/**
 * Korektní získání verze stasi. Více zbytečných parametrů.
 */
unittest {
	string[string] env;
	Request request = new Request(["stasi", "version", "--config", "./build/sample.xml", "--user", "franta"], env);
	//~ Application model = new Application(new Dir("."));
	ApplicationInfo model = new ApplicationInfo();
	VersionCommand cmd = new VersionCommand(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.VersionCommand", "Invalid type of command");
	response = cmd.fetch(request, response);
	assert(response.toString() == "0.0.5\n", "[" ~ response.toString() ~ ']');
}



/**
 * Action for show more information about use.
 */
class HelpCommand : AbstractCommand
{

	private ApplicationInfo _model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(ApplicationInfo model)
	{
		this._model = model;
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
		return new EchoResponse();
	}


	/**
	 * Model aplikace
	 */
	@property ApplicationInfo model()
	{
		return this._model;
	}


	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		EchoResponse response2 = cast(EchoResponse) response;
		response2.content = "Stasi host Git and Mercurial repositories

Version: " ~ this.model.VERSION ~ "

Usage:
  command [arguments]

Available commands:
  help           this
  version        print version of stasi
  verify-config  check syntax of configuration
  auth           athorization of user's permission: access allowed or denied
  shell          running command from SSH_ORIGINAL_COMMAND

Author:
  Martin Takáč <taco@taco-beru.name>
";

		return response2;
	}

}
/**
 * Korektní získání verze stasi.
 */
unittest {
	string[string] env;
	Request request = new Request(["stasi", "help"], env);
	HelpCommand cmd = new HelpCommand(new ApplicationInfo());
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.HelpCommand", "Invalid type of command");
	response = cmd.fetch(request, response);
	assert(response.toString()[0..41] == "Stasi host Git and Mercurial repositories", "[" ~ response.toString()[0..41] ~ ']');
}



/**
 * Zkontroluje, zda config neobsahuje nějaké problémy, díky kterým by
 * nebylo možné jej načíst.
 */
class VerifyConfigCommand : AbstractCommand
{

	private IModelBuilder _model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(IModelBuilder modelBuilder)
	{
		this._model = modelBuilder;
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
		return new EchoResponse();
	}



	/**
	 * Model aplikace
	 */
	@property IModelBuilder model()
	{
		return this._model;
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		EchoResponse response2 = cast(EchoResponse) response;
		response2.content = "Verifing config [" ~ this.model.config.configFile ~ "]: ";
		this.model.application.hasRepository("any");
		response2.content ~= "OK\n";

		return response2;
	}



}
/**
 * Soubor neexistuje.
 */
unittest {
	string[string] env;
	Request request = new Request(["stasi", "version"], env);
	Config config = new Config(request);
	ModelBuilder model = new ModelBuilder(config, new Logger());
	VerifyConfigCommand cmd = new VerifyConfigCommand(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.VerifyConfigCommand", "Invalid type of command");
	try {
		response = cmd.fetch(request, response);
	}
	catch (std.file.FileException e) {
		assert(".config/stasi/config.xml: No such file or directory" == e.msg, e.msg);
	}
}
/**
 * Pošahaný soubor.
 */
unittest {
	string[string] env;
	Request request = new Request(["stasi", "version", "--config", "tests_data/corrupted.xml"], env);
	Config config = new Config(request);
	ModelBuilder model = new ModelBuilder(config, new Logger());
	VerifyConfigCommand cmd = new VerifyConfigCommand(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.VerifyConfigCommand", "Invalid type of command");
	try {
		response = cmd.fetch(request, response);
	}
	catch (stasi.config.InvalidConfigException e) {
		assert("Invalid xml format: [\"Line 38, column 2: end tag name \\\"s:settingx\\\" differs from start tag name \\\"s:setting\\\"\", \"Line 10, column 2: Element\", \"Line 10, column 2: Content\", \"Line 2, column 1: Element\", \"Line 1, column 1: Document\", \"\"]." == e.msg, e.msg);
	}
}
/**
 * Konfigurace je v pořádku.
 */
unittest {
	string[string] env;
	Request request = new Request(["stasi", "version", "--config", "tests_data/correct.xml"], env);
	Config config = new Config(request);
	ModelBuilder model = new ModelBuilder(config, new Logger());
	VerifyConfigCommand cmd = new VerifyConfigCommand(model);
	IResponse response = cmd.createResponse(request);
	assert(cmd.className == "stasi.commands.VerifyConfigCommand", "Invalid type of command");
	response = cmd.fetch(request, response);
	assert(response.toString() == "Verifing config [tests_data/correct.xml]: OK\n", "[" ~ response.toString() ~ ']');
}




/**
 * Ověří, zda má uživatel daná oprávnění do daného repozitáře. Použité například
 * pro hook v mercurialu.
 */
class AuthCommand : AbstractCommand
{

	private IModel _model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	this(IModel model)
	{
		this._model = model;
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
		return new EchoResponse();
	}



	/**
	 * Model aplikace
	 */
	@property IModel model()
	{
		return this._model;
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	IResponse fetch(Request request, IResponse response)
	{
		EchoResponse response2 = cast(EchoResponse) response;
		response2.content = "~~auth~~";
		return response2;
	}



}
