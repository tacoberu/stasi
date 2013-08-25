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
