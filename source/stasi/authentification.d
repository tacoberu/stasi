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

module stasi.authentification;


/**
 * Přístup odmítnut.
 */
class UserException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}


/**
 * Přístup odmítnut.
 */
class AccessDeniedException : UserException
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}


class NotFoundException : UserException
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
