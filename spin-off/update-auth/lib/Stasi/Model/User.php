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
class User
{

	private $ident;


	private $firstname;


	private $lastname;


	private $email;


	private $permission = 0;


	/**
	 */
	public function __construct($ident)
	{
		$this->ident = $ident;
	}


	/**
	 */
	public function getIdent()
	{
		return $this->ident;
	}


	/**
	 */
	public function getFirstName()
	{
		return $this->firstname;
	}


	/**
	 */
	public function getLastName()
	{
		return $this->lastname;
	}


	/**
	 */
	public function getEmail()
	{
		return $this->email;
	}



	/**
	 */
	public function setFirstName($val)
	{
		$this->firstname = $val;
		return $this;
	}


	/**
	 */
	public function setLastName($val)
	{
		$this->lastname = $val;
		return $this;
	}


	/**
	 */
	public function setEmail($val)
	{
		$this->email = $val;
		return $this;
	}


	/**
	 * @param int $mask
	 * @return fluent
	 */
	public function setPermission($mask)
	{
		$this->permission = (int)$mask;
		return $this;
	}


	/**
	 * @param int $mask
	 * @return fluent
	 */
	public function getPermission()
	{
		return $this->permission;
	}


}
