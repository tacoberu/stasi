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

import stasi.config;
import stasi.request;
import stasi.routing;
import stasi.dispatcher;
import stasi.model;
import stasi.responses;
import auth = stasi.authentification;

import git = stasi.adapters.git;
import mercurial = stasi.adapters.mercurial;

import taco.logging;

import std.stdio;
import std.string;
import std.process;


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
	Request request;

	//	Inicializace
	try {
		request = new Request(args, environment.toAA());

		//setenv("STASI_VERSION", "0.0.1", true); 
		// environment["STASI_VERSION"] = "0.0.1";
		config = new Config(request);
		//config.addParser(new ConfigXmlReader());

		logger = new Logger();
		//logger.addListener(new OutputWriter(), new CommonFilter(Level.TRACE));
		logger.addListener(
				new FileWriter(File((config.logsPath.path ~ "stasi.log"), "a")),
				new CommonFilter(Level.TRACE)
				);
	}
	catch (Exception e) {
		stderr.writefln("[fatal] (Staci): cannot initialize - %s", e.msg);
		return 1;
	}

	//	Process
	try {
		logger.info("== start ==");
		int ret = (new Dispatcher(config, new ModelBuilder(config, logger)))
				.addRoute(new stasi.routing.Router())
				.addRoute(new git.Router())
				.addRoute(new mercurial.Router())
				.logger(logger)
				.dispatch(request)
				.fetch();
		return ret;
	}
	catch (auth.UserException e) {
		stderr.writefln("[fatal] (Staci): %s", e.msg ? e.msg : e.classinfo.name);
		logger.warn((e.msg ? e.msg : e.classinfo.name),	"auth");
		return 2;
	}
	catch (Exception e) {
		stderr.writefln("[fatal] (Staci): %s", e.msg ? e.msg : e.classinfo.name);
		logger.warn(std.string.format("MSG: %s\nFILE: %s\nLINE: %d\nTRACE:\n%s\n--------------------------------\n", 
						(e.msg ? e.msg : e.classinfo.name), 
						e.file, 
						e.line, 
						e.info.toString()),
				"fail");
		return 3;
	}

	return 4;
}


