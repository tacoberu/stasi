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
class ParserMercurial
{

	/**
	 *	Poznačenej request.
	 */
	private $request;


	/**
	 * Matchne podle prvního parametru, zda je to naše.
	 *
	 * @return string
	 */
	public function match($key)
	{
		if (strncmp($key, 'hg init', 7) === 0) {
			return True;
		}
		//	hg -R projects/test.hg serve --stdio
		elseif (strncmp($key, 'hg -R', 5) === 0
				&&	substr($key, -13) == 'serve --stdio' ) {
			return True;
		}
		return False;
	}



	/**
	 * Matchne podle prvního parametru, zda je to naše.
	 *
	 * @return string
	 */
	public function getAccess()
	{
		if (strncmp($this->request->getCommand(), 'hg init', 7) === 0) {
			return Model\Acl::PERM_INIT;
		}
		return Model\Acl::PERM_EXISTS;
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
		return __namespace__ . '\\MercurialCommand';
	}


}
