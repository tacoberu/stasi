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
