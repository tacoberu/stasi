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

	/**
	 * Stačí, když uživatel existuje.
	 */
	const PERM_EXISTS = 1;
	
	
	/**
	 * Uživatel může číst.
	 */
	const PERM_READ = 2;
	
	
	/**
	 * Může zapisovat
	 */
	const PERM_WRITE = 4;
	
	
	/**
	 * Mazání
	 */
	const PERM_REMOVE = 8;
	
	
	/**
	 * Může se přihlásit.
	 */
	const PERM_SIGNIN = 16;

	
	/**
	 * Přávě přihlášený uživatel.
	 */
	private $user;
	

	/**
	 * Seznam uživatelů s jejich právy.
	 */
	private $userList = array();
	

	/**
	 * Oprávnění.
	 * @return Acl
	 */
	public function isAllowed($perm = self::PERM_EXISTS)
	{
		if (! array_key_exists($this->getUser()->getIdent(), $this->userList)) {
			return False;
		}
		if ($perm == self::PERM_EXISTS) {
			return True;
		}
		$user = $this->userList[$this->getUser()->getIdent()];

		if (($perm & self::PERM_READ) && !($user->getPermission() & self::PERM_READ)) {
			return False;
		}
		if (($perm & self::PERM_WRITE) && !($user->getPermission() & self::PERM_WRITE)) {
			return False;
		}
		if (($perm & self::PERM_REMOVE) && !($user->getPermission() & self::PERM_REMOVE)) {
			return False;
		}
		if (($perm & self::PERM_SIGNIN) && !($user->getPermission() & self::PERM_SIGNIN)) {
			return False;
		}
		
		return True;
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
		$this->userList[$user->getIdent()] = $user;
	}

}

