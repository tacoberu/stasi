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

/**
 * Logování.
 */
module taco.logging;

import std.stdio;
import std.regex;
import std.datetime;
import std.string;
import std.file;


enum Level
{
	FATAL = 1,
	ERROR,
	WARN,
	INFO,
	LOG,
	DEBUG,
	TRACE
}


/**
 *	Nejen mi umíme logovat.
 */
interface ILogger
{
	/**
	 *	Zaloguje pro level LOG. Jedná se o obecný logger a je možné jím logovat všechno.
	 *
	 *	@return ILogger
	 */
	ILogger log(string message, string type = "*", Level level = Level.LOG);


	/**
	 *	Zaloguje pro level TRACE
	 *
	 *	@return ILogger
	 */
	ILogger trace(string message, string type = "*");


	/**
	 *	Zaloguje pro level DEBUG
	 *
	 *	@return ILogger
	 */
	ILogger _debug(string message, string type = "*");



	/**
	 *	Zaloguje pro level INFO
	 *
	 *	@return ILogger
	 */
	ILogger info(string message, string type = "*");



	/**
	 *	Zaloguje pro level WARN
	 *
	 *	@return ILogger
	 */
	ILogger warn(string message, string type = "*");


	/**
	 *	Zaloguje pro level ERROR
	 *
	 *	@return ILogger
	 */
	ILogger error(string message, string type = "*");


	/**
	 *	Zaloguje pro level FATAL
	 *
	 *	@return ILogger
	 */
	ILogger fatal(string message, string type = "*");


	/**
	 *	Přiřadí writer, do kterého se bude zapisovat.
	 *
	 *	@return ILogger
	 */
	Logger addListener(IWriter writer, IFilter filter);
}





/**
 *	Uložiště, do kterého se budou zapisovat logy.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
interface IWriter
{


	/**
	 *	Zaloguje zprávu.
	 *
	 *	@return IWriter
	 */
	IWriter write(string message, Level level = Level.INFO, string type = "*");


}






/**
 *	Filter, který určuje, zda se bude zadaná informace logovat.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
interface IFilter
{


	/**
	 * Rozhoduje, zda tuto informaci budeme logovat.
	 *
	 * @return boolean
	 */
	bool filter(Level level, string type = "*");


}




/**
 *	Vlastní logger.
 *
 *	@author	 Martin Takáč <taco@taco-beru.name>
 */
class Logger : ILogger
{

	private class Pair
	{
		/**
		 * Odběratelé logů.
		 */
		public IWriter writer;

		/**
		 * Filtry logů.
		 */
		public IFilter filter;


		this (IWriter writer, IFilter filter)
		{
			this.writer = writer;
			this.filter = filter;
		}

	}



	/**
	 * Odpěratelé logů a filtr v jednom objektu.
	 */
	private Pair[] listener;



	/**
	 *	Přiřadí writer, do kterého se bude zapisovat.
	 */
	Logger addListener(IWriter writer, IFilter filter)
	{
		listener ~= new Pair(writer, filter);
		return this;
	}



	/**
	 *	Zda toto bude do něčeho logováno.
	 */
	bool canLogged(string type = "*", Level level = Level.LOG)
	{
		foreach(pair; this.listener) {
			if (pair.filter.filter(level, type)) {
				return true;
			}
		}

		return false;
	}



	/**
	 *	Zaloguje pro level LOG
	 */
	ILogger log(string message, string type = "*", Level level = Level.LOG)
	{
		foreach(pair; this.listener) {
			if (pair.filter.filter(level, type)) {
				pair.writer.write(message, level, type);
			}
		}

		return this;
	}



	/**
	 *	Zaloguje pro level TRACE
	 */
	ILogger trace(string message, string type = "*")
	{
		return this.log(message, type, Level.TRACE);
	}



	/**
	 *	Zaloguje pro level DEBUG
	 */
	ILogger _debug(string message, string type = "*")
	{
		return this.log(message, type, Level.DEBUG);
	}



	/**
	 *	Zaloguje pro level INFO
	 */
	ILogger info(string message, string type = "*")
	{
		return this.log(message, type, Level.INFO);
	}



	/**
	 *	Zaloguje pro level WARN
	 */
	ILogger warn(string message, string type = "*")
	{
		return this.log(message, type, Level.WARN);
	}



	/**
	 *	Zaloguje pro level ERROR
	 */
	ILogger error(string message, string type = "*")
	{
		return this.log(message, type, Level.ERROR);
	}



	/**
	 *	Zaloguje pro level FATAL
	 */
	ILogger fatal(string message, string type = "*")
	{
		return this.log(message, type, Level.FATAL);
	}



	/**
	 *	Vrátí sub logger za účelem zanoření.
	 * /
	Logger getSubLog(string name)
	{
	}
	//*/


}
unittest {
	ILogger logger = new Logger();
	logger.addListener(new OutputWriter(), new CommonFilter());
	logger.log("Example");
}






/**
 *	Filter, který určuje, zda se bude zadaná informace logovat.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
class CommonFilter : IFilter
{


	/**
	 *	Uroven logování.
	 */
	private Level level;


	/**
	 *	Typ logu. Maska.
	 */
	private string type;


	/**
	 * Definice podmínky.
	 *
	 * @param enum Uroveň závažnosti informace.
	 * @param string Značka skupiny. Typ logu. Maska
	 */
	this(Level level = Level.INFO, string type = "*")
	{
		this.level = level;
		this.type = type;
	}



	/**
	 * Rozhoduje, zda tuto informaci budeme logovat.
	 *
	 * @return boolean
	 */
	public bool filter(Level level, string type = "*")
	{
		if (this.type == "*" || this.type == type) {
			if (level <= this.level) {
				return true;
			}
		}
		return false;
	}


}






/**
 *	Logy budem vypisovat rovnou na výstup.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
abstract class AbstractWriter : IWriter
{

	static const PLACE_MESSAGE = "%message%";
	static const PLACE_LEVEL = "%level%";
	static const PLACE_TYPE = "%type%";
	static const PLACE_DATETIME = "%datetime%";


	/**
	 * Maska výstupu.
	 */
	private string formating;


	/**
	 * Oddělovač řádek.
	 */
	private string sepparator;


	/**
	 * Definice podmínky.
	 */
	this(string formating = this.PLACE_MESSAGE, string sepparator = "\n")
	{
		this.formating = formating;
		this.sepparator = sepparator;
	}



	/**
	 *	Naformátuje zprávu.
	 */
	protected string format(string message, Level level = Level.INFO, string type = "*")
	{
		string s = this.formating;
		s = replace(s, regex(r"" ~ this.PLACE_MESSAGE,"g"), message);
		s = replace(s, regex(r"" ~ this.PLACE_LEVEL,"g"), this.formatLevel(level));
		s = replace(s, regex(r"" ~ this.PLACE_TYPE, "g"), std.string.format("%10.10s", type));
		s = replace(s, regex(r"" ~ this.PLACE_DATETIME, "g"), std.string.format("%-27s", Clock.currTime().toISOExtString()));
		s ~= this.sepparator;

		return s;
	}



	/**
	 *	int to string
	 */
	private string formatLevel(Level level)
	{
		final switch (level) {
			case Level.TRACE:
				return "TRACE";
			case Level.DEBUG:
				return "DEBUG";
			case Level.LOG:
				return "LOG  ";
			case Level.INFO:
				return "INFO ";
			case Level.WARN:
				return "WARN ";
			case Level.ERROR:
				return "ERROR";
			case Level.FATAL:
				return "FATAL";
		}
	}

}





/**
 *	Logy budem vypisovat rovnou na výstup.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
class OutputWriter : AbstractWriter
{

	static const DEFAULT_FORMAT = this.PLACE_LEVEL ~ " [" ~ this.PLACE_TYPE ~ "] " ~ this.PLACE_MESSAGE;


	/**
	 * Definice podmínky.
	 */
	this(string formating = this.DEFAULT_FORMAT, string sepparator = "\n")
	{
		super(formating, sepparator);
	}



	/**
	 *	Zaloguje zprávu.
	 */
	IWriter write(string message, Level level = Level.INFO, string type = "*")
	{
		std.stdio.write(this.format(message, level, type));
		return this;
	}


}




/**
 *	Logy budem vypisovat do souboru.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
class FileWriter : AbstractWriter
{

	static const DEFAULT_FORMAT = "[" ~ this.PLACE_DATETIME ~ "] [" ~ this.PLACE_LEVEL ~ "] " ~ this.PLACE_MESSAGE;


	private File file;


	/**
	 * Definice podmínky.
	 */
	this(File f, string formating = this.DEFAULT_FORMAT, string sepparator = "\n")
	{
		super(formating, sepparator);
		this.file = f;
	}



	/**
	 *	Zaloguje zprávu.
	 */
	IWriter write(string message, Level level = Level.INFO, string type = "*")
	{
		this.file.write(this.format(message, level, type));
		return this;
	}


}
