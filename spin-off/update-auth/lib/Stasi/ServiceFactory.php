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



class ServiceFactory
{

	private $bank;


	private $config;
	
	
	private $command = '/usr/bin/stasi';
	
	
	
	function __construct(ConfigReaderInterface $config, $command = Null)
	{
		$this->config = $config;
		if ($command) {
			$this->command = $command;
		}
	}



	/**
	 *	Banka uživatelů.
	 */
	function getBank()
	{
		if (empty($this->bank)) {
			$this->bank = $this->createBank();
		}
		return $this->bank;
	}
	
	
	/**
	 *	Banka uživatelů.
	 */
	function getParser()
	{
		$parser = new SshAuthorizedKeysParser();
		return $parser;
	}
	
	
	/**
	 *	
	 */
	function getFormater()
	{
		$formater = new SshAuthorizedKeysFormater($this->command);
		return $formater;
	}



	/**
	 *	Banka uživatelů.
	 */
	function createBank()
	{
		$bank = new UserBank();

		foreach ($this->config->getUserList() as $user) {
			foreach ($user->ssh as $ssh) {
				try {
					$entry = new AuthorizedKeysUser($user->ident, $ssh->type, $ssh->key, $user->email);
				}
				catch (\InvalidArgumentException $e) {
					throw new \RuntimeException('Fill bank failed, because: ' . $e->getMessage(), 2, $e);
				}
				$bank->add($entry);
			}
		}

		return $bank;
	}


}


