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
class Acl
{

	private $user;
	

	private $userList = array();
	

	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function isAllowed()
	{
		return in_array($this->getUser()->getIdent(), array(
				'taco', 'fean',
				));
	}


	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function setUser(User $user)
	{
		$this->user = $user;
		return $this;
	}



	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function getUser()
	{
		return $this->user;
	}



	/**
	 * @param 
	 * @return ...
	 */
	public function allowUser(User $user)
	{
		$this->userList[] = $user->getIdent();
	}

}

