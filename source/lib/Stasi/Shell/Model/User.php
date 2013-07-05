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
class User
{

	private $ident;
	

	private $firstname;
	

	private $lastname;
	

	private $email;
	

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



}

