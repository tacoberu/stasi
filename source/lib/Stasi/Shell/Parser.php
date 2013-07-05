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
class Parser
{

	private $adapters = array();
	

	/**
	 * Příkazy pro git.
	 */
	private static $git = array(
			'git-upload-pack', 
			'git-receive-pack',
			'git-upload-archive',
			);


	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function add($parser)
	{
		$this->adapters[] = $parser;
		return $this;
	}


	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function parse(Request $request)
	{
		$command = $request->getCommand();
		$command = ltrim($command);
		$pair = explode(' ', $command, 2);
		foreach ($this->adapters as $adapter) {
			if ($adapter->match($pair[0])) {
				return $adapter->setRequest($request)->setCommand($pair[0]);
			}
		}
	}


}

