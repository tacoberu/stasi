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

