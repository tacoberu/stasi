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
 *	Odpověď jako JSON.
 */
class ExecResponse implements ResponseInterface
{


	private $command;



	/**
	 *	Poslání na výstup.
	 */
	function fetch()
	{
		if ($this->command) {
			passthru($this->command);
		}
	}



	/**
	 *	Poslání na výstup.
	 */
	function setCommand($command)
	{
		$this->command = $command;
		return $this;
	}




}
