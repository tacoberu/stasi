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
 * Reprezentace jednoho řádku.
 */
class AuthorizedKeysUser
{
	public $command;
	public $attribs;
	public $sshtype;
	public $publicKey;
	public $email;
	public $user;


	/**
	 *	Povinné hodnoty.
	 */
	function __construct($user, $sshtype, $publicKey, $email)
	{
		$this->user = trim($user);
		$this->sshtype = trim($sshtype);
		$this->publicKey = trim($publicKey);
		$this->email = trim($email);

		if (! preg_match('~^[\w\+\-\=\/]+$~i', $this->publicKey)) {
			throw new \InvalidArgumentException('Invalid format of publicKey: [' . $this->publicKey . '].');
		}
	}


	/**
	 * Co budem používat jako Id.
	 * @return string
	 */
	public function getId()
	{
		return $this->sshtype . '|' . $this->publicKey;
	}

}
