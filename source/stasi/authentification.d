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

module stasi.authentification;


/**
 * Přístup odmítnut.
 */
class AccessDeniedException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}


class NotFoundException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}



class RepositoryNotFoundException : NotFoundException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}
