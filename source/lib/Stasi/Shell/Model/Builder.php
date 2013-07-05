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
 *	Zpracovává příkazy na request.
 */
class ModelBuilder
{


	private $config;


	private $application;
	

	/**
	 * @param $model, $config
	 */
	public function __construct(Config $config)
	{
		if (empty($config)) {
			throw new \InvalidArgumentException('config', 2);
		}

		$this->config = $config;
	}



	/**
	 * @return App
	 */
	public function getApplication()
	{
		if (empty($this->application)) {
			$this->application = $this->createApplication();
		}
		return $this->application;
	}



	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function createApplication()
	{
		$app = new Model\Application();
		$app->setAcl($this->createAcl());
		return $app;
	}



	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function createAcl()
	{
		$acl = new Model\Acl();

		$configReader = $this->createAccessConfigurate();
		foreach ($configReader->getUserList() as $user) {
			$user = new Model\User($user->ident);
			$acl->allowUser($user);
		}
		return $acl;
	}



	/**
	 * @return ConfigReaderInterface
	 */
	private function createAccessConfigurate()
	{
		$file = $this->config->getAclFile();
		if (! file_exists($file)) {
			throw new \InvalidArgumentException("File [$file] not found.");
		}
		return new ConfigXmlReader($file);
	}


}

