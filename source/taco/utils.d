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
 * Různé.
 */
module taco.utils;


/**
 * Třída reprezentující adresář.
 */
class Dir
{

	private string _path;
	
	
	this(string path)
	{
		//	lomítko na konci
		if (! path.length) {
			this._path = "";
		}
		else if (path[path.length - 1 .. $] == "/") {
			this._path = path;
		}
		else {
			this._path = path ~ "/";
		}
	}
	
	
	@property string path() const
	{
		return this._path;
	}



	string toString()
	{
		return this.path;
	}

}
unittest {
	Dir dir = new Dir("foo/too");
	assert("foo/too/" == dir.path);
}
unittest {
	Dir dir = new Dir("foo/too/");
	assert("foo/too/" == dir.path);
}
unittest {
	Dir dir = new Dir("");
	assert("" == dir.path);
}
unittest {
	Dir dir = new Dir("/");
	assert("/" == dir.path);
}
