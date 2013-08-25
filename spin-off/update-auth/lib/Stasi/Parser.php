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
		foreach ($this->adapters as $adapter) {
			if ($adapter->match($command)) {
				return $adapter->setRequest($request);
			}
		}
	}


}
