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
