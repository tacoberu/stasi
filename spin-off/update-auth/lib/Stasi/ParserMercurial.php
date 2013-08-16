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

