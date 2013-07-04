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
 *	Přepravka.
 */
class Request
{

	/**
	 * Uživatel, který posílá požadavek.
	 */
	private $user;

	/**
	 * Originální přžíkaz. O co se pokouší.
	 */
	private $command;


	public function setUser($value)
	{
		$this->user = $value;
		return $this;
	}


	public function getUser()
	{
		return $this->user;
	}


	public function setCommand($value)
	{
		$this->command = $value;
		return $this;
	}



	public function getCommand()
	{
		return $this->command;
	}


}

