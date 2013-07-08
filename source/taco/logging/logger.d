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

/**
 * Logování.
 */
module taco.logging;

import io = std.stdio;


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
		 * Odpěratelé logů.
		 */
		public IWriter writer;

		/**
		 * Odpěratelé logů.
		 */
		public IFilter filter;

		this (IWriter writer, IFilter filter)
		{
			this.writer = writer;
			this.filter = filter;
		}

	}



	/**
	 * Odpěratelé logů.
	 */
	private Pair[] listener;



	/**
	 *	Přiřadí writer, do kterého se bude zapisovat.
	 *
	 *	@return ILogger
	 */
	Logger addListener(IWriter writer, IFilter filter)
	{
		listener ~= new Pair(writer, filter);
		return this;
	}



	/**
	 *	Zda toto bude do něčeho logováno.
	 *
	 *	@return bool
	 * /
	public function canLogged($type = Null, $level = self::LOG)
	{
		foreach ($this->listener as $node) {
			if ($node->filter->filter($level, $type)) {
				return true;
			}
		}
		return false;
	}



	/**
	 *	Zaloguje pro level LOG
	 *
	 *	@return ILogger
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
	 *
	 *	@return ILogger
	 */
	ILogger trace(string message, string type = "*")
	{
		return this.log(message, type, Level.TRACE);
	}



	/**
	 *	Zaloguje pro level DEBUG
	 *
	 *	@return ILogger
	 */
	ILogger _debug(string message, string type = "*")
	{
		return this.log(message, type, Level.DEBUG);
	}



	/**
	 *	Zaloguje pro level INFO
	 *
	 *	@return ILogger
	 */
	ILogger info(string message, string type = "*")
	{
		return this.log(message, type, Level.INFO);
	}



	/**
	 *	Zaloguje pro level WARN
	 *
	 *	@return ILogger
	 */
	ILogger warn(string message, string type = "*")
	{
		return this.log(message, type, Level.WARN);
	}



	/**
	 *	Zaloguje pro level ERROR
	 *
	 *	@return ILogger
	 */
	ILogger error(string message, string type = "*")
	{
		return this.log(message, type, Level.ERROR);
	}



	/**
	 *	Zaloguje pro level FATAL
	 *
	 *	@return ILogger
	 */
	ILogger fatal(string message, string type = "*")
	{
		return this.log(message, type, Level.FATAL);
	}



	/**
	 *	Vrátí sub logger za účelem zanoření.
	 *
	 *	@return
	 * /
	public function getSubLog($name)
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

	/**
	 * Překladová maska.
	 * /
	private static levelNames = array(
			Log::TRACE => "TRACE",
			Log::DEBUG => "DEBUG',
			Log::LOG =>   "LOG  ',
			Log::INFO =>  "INFO ',
			Log::WARN =>  "WARN ',
			Log::ERROR => 'ERROR',
			Log::FATAL => 'FATAL',
			);


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
	public this(string formating = "%message%", string sepparator = "\n")
	{
		this.formating = formating;
		this.sepparator = sepparator;
	}



	/**
	 *	Naformátuje zprávu.
	 *
	 *	@return self
	 */
	protected string format(string message, Level level = Level.INFO, string type = "*")
	{
		/*
		// Pokud takovouto informaci požadujeme.
		if ((strpos($this->formating, '%class%') !== False)
				|| (strpos($this->formating, '%method%') !== False)
				|| (strpos($this->formating, '%line%') !== False)) {
			if (PHP_MAJOR_VERSION >= 5 && PHP_MINOR_VERSION >= 4) {
				$trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 4);
			}
			elseif (PHP_MAJOR_VERSION >= 5 && PHP_MINOR_VERSION >= 3 && PHP_RELEASE_VERSION >= 6) {
				$trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS);
			}
			else {
				$trace = debug_backtrace();
			}

			$class = $trace[3]['class'];
			$method = $trace[3]['function'];
			$line = $trace[2]['line'];
			$trace = Null; unset($trace);

			$placeholders = array(
					'%message%' => $message,
					'%level%' => self::formatLevel($level),
					'%type%' => $type,
					'%datetime%' => date('Y-m-d H:i:s'),
					'%class%' => $class,
					'%method%' => $method,
					'%line%' => $line,
					);
		}
		else {
			$placeholders = array(
					'%message%' => $message,
					'%level%' => self::formatLevel($level),
					'%type%' => $type,
					'%datetime%' => date('Y-m-d H:i:s')
					);
		}

		return strtr($this->formating, $placeholders) . $this->sepparator;
		* */
		return message;
	}



	/**
	 *	int to string
	 * /
	private static function formatLevel($level)
	{
		return self::$levelNames[$level];
	}
	*/

}





/**
 *	Logy budem vypisovat rovnou na výstup.
 *
 *	@author     Martin Takáč <taco@taco-beru.name>
 */
class OutputWriter : AbstractWriter
{

	/**
	 *	Zaloguje zprávu.
	 *
	 *	@return self
	 */
	public OutputWriter write(string message, Level level = Level.INFO, string type = "*")
	{
		io.write(this.format(message, level, type));
		return this;
	}


}
