<?php
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


namespace Taco\Tools\Stasi\Shell;



/**
 *	Mapování GET na request.
 */
class Router
{

	/**
	 *	Vytvoření instance requestu.
	 */
	public function createRequest(array $server)
	{
		$request = new Request();
		$request->setUser(isset($server['argv'], $server['argv'][1]) ? $server['argv'][1] : Null);
		$request->setCommand(isset($server['SSH_ORIGINAL_COMMAND']) ? $server['SSH_ORIGINAL_COMMAND'] : Null);

		return $request;
	}


}

