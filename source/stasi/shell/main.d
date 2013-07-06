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

import std.stdio;
import std.process;


import taco.logging;
import stasi.config;
import stasi.routing;
import stasi.dispatcher;
import stasi.model;



/**
 * Stasi-shell, invoked from ~/.ssh/authorized_keys
 *
 * Wraper of ssh comunication.
 * This is logging only.
 */
int main(string[] args)
{
	Config config;
	Logger logger;

	//	Inicializace
	try {
		config = new Config(args);
		logger = new Logger();
		//logger.addListener(new FileWriter(config.getLogsPath()), new CommonFilter());
	}
	catch (Exception e) {
		//file_put_contents('php://stderr', '[fatal] (Staci): cannot initialize - ' . $e->getMessage() . PHP_EOL);
		//exit($e->getCode() > 0 ? $e->getCode() : 254);
		writefln("catch %s", e.msg);
		return 1;
	}

	//	Process
	try {
		Router router = new Router();
		Request request = router.createRequest(args);
		writefln(request.getUser());
		ModelBuilder modelBuilder = new ModelBuilder(config);
		Dispatcher dispatcher = new Dispatcher(config, modelBuilder);
		//dispatcher.setLogger(logger);
		//Response response = dispatcher.dispatch(request);
		//response->fetch();
	}
	catch (Exception e) {
		//file_put_contents('php://stderr', '[fatal] (Staci): ' . $e->getMessage() . PHP_EOL);
		//logger->trace('failed', $e->getMessage());
		return 2;
	}

	return 0;
}


