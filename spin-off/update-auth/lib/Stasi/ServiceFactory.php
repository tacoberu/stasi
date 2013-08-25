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
