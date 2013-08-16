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


require_once __dir__ . '/../../../../../../lib/Stasi/Model/Acl.php';
require_once __dir__ . '/../../../../../../lib/Stasi/Model/User.php';


use Taco\Tools\Stasi\Shell\Model;


/**
 * @call phpunit AclTest.php tests_libs_taco_tools_Stasi_Shell_Model_AclTest
 */
class tests_libs_taco_tools_Stasi_Shell_Model_AclTest extends PHPUnit_Framework_TestCase
{


	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testAclYes()
	{
		$acl = $this->getAcl();
		$acl->setUser(new Model\User('taco'));

		$this->assertTrue($acl->isAllowed());

		$this->assertTrue($acl->isAllowed());
		$this->assertTrue($acl->isAllowed($acl::PERM_EXISTS));
		$this->assertTrue($acl->isAllowed($acl::PERM_EXISTS | $acl::PERM_READ | $acl::PERM_WRITE | $acl::PERM_REMOVE | $acl::PERM_SIGNIN));
	}



	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testAclNo()
	{
		$acl = $this->getAcl();
		$acl->setUser(new Model\User('tacox'));

		$this->assertFalse($acl->isAllowed());
	}



	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testMira()
	{
		$acl = $this->getAcl();
		$acl->setUser(new Model\User('mira'));

		$this->assertTrue($acl->isAllowed());
		$this->assertTrue($acl->isAllowed($acl::PERM_EXISTS));
		$this->assertTrue($acl->isAllowed($acl::PERM_EXISTS | $acl::PERM_READ));
		$this->assertFalse($acl->isAllowed($acl::PERM_EXISTS | $acl::PERM_READ | $acl::PERM_SIGNIN));
	}



	/**
	 *	
	 */
	private function getAcl()
	{
		$acl = new Model\Acl();

		$user = new Model\User('mira');
		$user->setFirstName('m');
		$user->setLastName('d');
		$user->setEmail(null);
		$user->setPermission(Model\Acl::PERM_READ | Model\Acl::PERM_WRITE | Model\Acl::PERM_REMOVE);
		$acl->allowUser($user);

		$user = new Model\User('taco');
		$user->setFirstName('md');
		$user->setLastName('dd');
		$user->setEmail(null);
		$user->setPermission(Model\Acl::PERM_READ | Model\Acl::PERM_WRITE | Model\Acl::PERM_REMOVE | Model\Acl::PERM_SIGNIN);
		$acl->allowUser($user);

		return $acl;
	}



}
