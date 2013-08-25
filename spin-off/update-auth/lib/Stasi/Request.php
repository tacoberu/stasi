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


	/**
	 * Čteme, zapišujeme, ...
	 */
	private $access;


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


	public function setAccess($value)
	{
		$this->access = $value;
		return $this;
	}



	public function getAccess()
	{
		return $this->access;
	}


}
