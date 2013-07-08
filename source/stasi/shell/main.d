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


import taco.logging;
import stasi.config;
import stasi.routing;
import stasi.dispatcher;
import stasi.model;
import stasi.responses;

import git = stasi.adapters.git;
import mercurial = stasi.adapters.mercurial;


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
		stderr.write("[fatal] (Staci): cannot initialize - %s", e.msg);
		return 1;
	}

	//	Process
	try {
		Request request = (new Router())
				.createRequest(args);
		(new Dispatcher(config, new ModelBuilder(config)))
				.addRoute(new git.Router())
				.addRoute(new mercurial.Router())
				.setLogger(logger)
				.dispatch(request)
				.fetch();
	}
	catch (Exception e) {
		stderr.write("[fatal] (Staci): %s", e.msg);
		//logger.trace('failed', e.msg);
		return 2;
	}

	return 0;
}


