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


require_once __dir__ . '/../../../../../../lib/Stasi/AuthorizedKeysUser.php';


use Taco\Tools\Stasi\Shell;


/**
 * @call phpunit AuthorizedKeysUserTest.php tests_libs_taco_tools_Stasi_Shell_AuthorizedKeysUserTest
 */
class tests_libs_taco_tools_Stasi_Shell_AuthorizedKeysUserTest extends PHPUnit_Framework_TestCase
{


	/**
	 *	Komunikace s existujícím repozitáře mercurialu.
	 */
	public function testCorrect()
	{
		$entry = new Shell\AuthorizedKeysUser('user', 'ssh-dsa', 'AAAAB3Nun/AsSzaC1kc3MAAACBA---l6yXMPCoEtM6WGJWo5vxA==', 'user@example.com');
		$this->assertEquals('user', $entry->user);
		$this->assertEquals('ssh-dsa', $entry->sshtype);
		$this->assertEquals('AAAAB3Nun/AsSzaC1kc3MAAACBA---l6yXMPCoEtM6WGJWo5vxA==', $entry->publicKey);
		$this->assertEquals('user@example.com', $entry->email);
	}



	/**
	 *	
	 */
	public function _testInCorrect()
	{
		$entry = new Shell\AuthorizedKeysUser('user', 'ssh-dsa', 'ssh-dsa AAAAB3NzaC1kc3MAAACBA...l6yXMPCoEtM6WGJWo5vxA==', 'user@example.com');
	}



}
