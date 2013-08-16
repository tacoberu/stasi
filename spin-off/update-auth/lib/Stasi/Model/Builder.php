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


	private $configReader;


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
		$app->setHomePath($this->config->getHomePath());
		$app->setAcl($this->createAcl());
		$app->setRepositoryPath($this->getConfigReader()->getRepoPath());
		return $app;
	}



	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function createAcl()
	{
		$acl = new Model\Acl();
		foreach ($this->getConfigReader()->getUserList() as $entry) {
			$user = new Model\User($entry->ident);
			$user->setFirstName($entry->firstname);
			$user->setLastName($entry->lastname);
			$user->setEmail($entry->email);
			$user->setPermission(self::formatPermission($entry->permission));

			$acl->allowUser($user);
		}
		return $acl;
	}



	/**
	 * @return ConfigReaderInterface
	 */
	private function getConfigReader()
	{
		if (empty($this->configReader)) {
			$this->configReader = $this->createConfigReader();
		}
		return $this->configReader;
	}



	/**
	 * @return ConfigReaderInterface
	 */
	private function createConfigReader()
	{
		$file = $this->config->getAclFile();
		if (! file_exists($file)) {
			throw new \InvalidArgumentException("File [$file] not found.");
		}
		return new ConfigXmlReader($file);
	}



	/**
	 * @param array $perms
	 * @return int
	 */
	private static function formatPermission(array $perms)
	{
		$mask = Model\Acl::PERM_EXISTS;
		foreach ($perms as $perm) {
			switch (strtolower($perm)) {
				case 'read':
				case 'reads':
					$mask |= Model\Acl::PERM_READ;
					break;
				case 'write':
					$mask |= Model\Acl::PERM_WRITE;
					break;
				case 'remove':
				case 'delete':
					$mask |= Model\Acl::PERM_REMOVE;
					break;
				case 'shell':
				case 'sign-in':
					$mask |= Model\Acl::PERM_SIGNIN;
					break;
			}
		}
		return $mask;
	}

}

