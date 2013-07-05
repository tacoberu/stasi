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
 *	Rozřazuje, zda se jedná o příkazy pro git, nebo pro mercurial, nebo nějaké předdefinované, a nebo obecné.
 */
class ParserGit
{

	/**
	 *	Poznačenej request.
	 */
	private $request;


	/**
	 * Příkazy pro git.
	 */
	private static $commands = array(
			'git-upload-pack' => Model\Acl::PERM_READ, 
			'git-receive-pack' => Model\Acl::PERM_WRITE, 
			'git-upload-archive' => Model\Acl::PERM_READ, 
			);

	/**
	 * Matchne podle prvního parametru, zda je to naše.
	 *
	 * @return string
	 */
	public function match($key)
	{
		$pair = explode(' ', $key, 2);
		return (array_key_exists($pair[0], self::$commands));
	}



	/**
	 * Matchne podle prvního parametru, zda je to naše.
	 *
	 * @return string
	 */
	public function getAccess()
	{
		$command = $this->request->getCommand();
		$pair = explode(' ', $command, 2);
		return self::$commands[$pair[0]];
	}



	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function setRequest(Request $request)
	{
		$this->request = $request;
		return $this;
	}



	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function getActionClassName()
	{
		return __namespace__ . '\\GitCommand';
	}


}

