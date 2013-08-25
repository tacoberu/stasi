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


namespace Taco\Tools\Stasi\Shell\Model;




/**
 *	Zpracovává příkazy na request.
 */
class Application
{

	private $acl;


	private $repositoryPath;


	private $homePath;


	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function getAcl()
	{
		return $this->acl;
	}


	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function setAcl(Acl $acl)
	{
		$this->acl = $acl;
		return $this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 * @return string
	 */
	function setHomePath($path)
	{
		if (empty($path)) {
			throw new \InvalidArgumentException('Empty home path.');
		}
		$this->homePath = $path;
		return $this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 * @return string
	 */
	function setRepositoryPath($path)
	{
		if (empty($path)) {
			throw new \InvalidArgumentException('Empty repository path.');
		}
		$this->repositoryPath = $path;
		return $this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 * @return string
	 */
	function getRepositoryPath()
	{
		return $this->repositoryPath;
	}



	/**
	 * Ověření konzistence repozitáře. To znamená, zda
	 * - je bare
	 * - má nastavené defaultní hooky
	 * - ...
	 * @param string
	 */
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
	 */
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

}
