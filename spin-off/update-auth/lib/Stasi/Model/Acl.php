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
	 * Může vytvářet nové repozitáře.
	 */
	const PERM_INIT = 32;


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
