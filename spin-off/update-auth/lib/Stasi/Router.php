<?php
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
