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
 *	Request pro obrázek. Povoluje, validuje a dále funguje jako přepravka.
 */
class Config
{


	private $server;

	/**
	 * @param array $server Nastavení prostředí z $_SERVER
	 */
	public function __construct(array $server)
	{
		$this->server = $server;
	}



	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function getAclFile()
	{
		if (isset($this->server['HOME'])) {
			$pwd = rtrim($this->server['HOME'], '/\\');
		}
		return $pwd . '/.config/stasi/access.xml';
	}



	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function getEnvFile()
	{
		if (isset($this->server['HOME'])) {
			$pwd = rtrim($this->server['HOME'], '/\\');
		}
		return $pwd . '/.config/stasi/env.xml';
	}



	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	public function getLogsPath()
	{
		return '/var/log/stasi';
	}



	/**
	 * Cesta ke kořeni domovského adresáře.
	 *
	 * @return string
	 */
	public function getHomePath()
	{
		if (isset($this->server['HOME'])) {
			$pwd = rtrim($this->server['HOME'], '/\\');
		}
		return $pwd;
	}




}
