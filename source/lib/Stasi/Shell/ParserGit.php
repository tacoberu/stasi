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
	 *	Poznačenej fragment commandu Bez parametrů.
	 */
	private $command;



	/**
	 * Příkazy pro git.
	 */
	private static $commands = array(
			'git-upload-pack' => Model\Acl::PERM_WRITE, 
			'git-receive-pack' => Model\Acl::PERM_READ, 
			'git-upload-archive' => Model\Acl::PERM_WRITE, 
			);

	/**
	 * Matchne podle prvního parametru, zda je to naše.
	 *
	 * @return string
	 */
	public function match($key)
	{
		return (array_key_exists($key, self::$commands));
	}



	/**
	 * Matchne podle prvního parametru, zda je to naše.
	 *
	 * @return string
	 */
	public function getAccess()
	{
		return self::$commands[$this->command];
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
	 * @param 
	 * @return ...
	 */
	public function setCommand($str)
	{
		$this->command = $str;
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

