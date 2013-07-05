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


namespace Taco\Tools\Stasi\Shell\Model;




/**
 *	Zpracovává příkazy na request.
 */
class Application
{

	private $acl;
	

	private $repositoryPath;
	

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


}

