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


module stasi.model;

import stasi.config;




/**
 *	Model.
 */
class ModelBuilder
{

	private Config config;

	private Application application;

	/**
	 * @param $model, $config
	 */
	this(Config config)
	{
		this.config = config;
	}



	/**
	 * @return Application
	 */
	Application getApplication()
	{
		if (! this.application) {
			this.application = this.createApplication();
		}
		return this.application;
	}



	/**
	 * @return Application
	 */
	Application createApplication()
	{
		Application app = new Application();
		app.setHomePath(this.config.getHomePath());
		//app.setAcl(this.createAcl());
		//app.setRepositoryPath(this.config.getRepoPath());
		return app;
	}



}



/**
 *	Zpracovává příkazy na request.
 */
class Application
{

	//private acl;


	private string repositoryPath;


	private string homePath;


	/**
	 * Oprávnění.
	 * @return Acl
	 * /
	public function getAcl()
	{
		return $this->acl;
	}


	/**
	 * Oprávnění.
	 * @return Acl
	 * /
	public function setAcl(Acl $acl)
	{
		$this->acl = $acl;
		return $this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 * @return string
	 */
	Application setHomePath(string path)
	{
		this.homePath = path;
		return this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 * @return string
	 */
	Application setRepositoryPath(string path)
	{
		this.repositoryPath = path;
		return this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 * @return string
	 */
	string getRepositoryPath()
	{
		return this.repositoryPath;
	}



	/**
	 * Ověření konzistence repozitáře. To znamená, zda
	 * - je bare
	 * - má nastavené defaultní hooky
	 * - ...
	 * @param string
	 * /
	function doNormalizeRepository($repo, $type)
	{
		$full = $this->homePath . '/' . $repo;

		//	Existence souboru
		if (! is_writable($full)) {
			throw new \RuntimeException("Repo [$repo] is not exists.");
		}

		switch($type) {
			case 'git':
				$this->doNormalizeAssignHooksGit($full);
				break;
		}
	}



	/**
	 * @param $fullrepo
	 * @return boolean
	 * /
	private function doNormalizeAssignHooksGit($fullrepo)
	{
		//	Post Receive
		$postReceive = $fullrepo . '/hooks/post-receive';
		$postReceiveTo = realpath(__dir__ . '/../../../../bin/git-hooks/post-receive');
		if (file_exists($postReceive) && (! is_link($postReceive) || readlink($postReceive) != $postReceiveTo)) {
			rename($postReceive, $postReceive . '-original');
		}

		if (! file_exists($postReceive)) {
			symlink($postReceiveTo, $postReceive);
		}

		//	Post Update
		$postUpdate = $fullrepo . '/hooks/post-update';
		$postUpdateTo = realpath(__dir__ . '/../../../../bin/git-hooks/post-update');
		if (file_exists($postUpdate) && (! is_link($postUpdate) || readlink($postUpdate) != $postUpdateTo)) {
			rename($postUpdate, $postUpdate . '-original');
		}

		if (! file_exists($postUpdate)) {
			symlink($postUpdateTo, $postUpdate);
		}
	}


	//*/
}

