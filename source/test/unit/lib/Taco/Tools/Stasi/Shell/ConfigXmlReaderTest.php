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


require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/ConfigReaderInterface.php';
require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/ConfigXmlReader.php';


use Taco\Tools\Stasi\Shell;


/**
 * @call phpunit ConfigXmlReaderTest.php tests_libs_taco_tools_Stasi_Shell_ConfigXmlReaderTest
 */
class tests_libs_taco_tools_Stasi_Shell_ConfigXmlReaderTest extends PHPUnit_Framework_TestCase
{


	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testFail()
	{
		try {
			$pom = new Shell\ConfigXmlReader(__dir__ . '/test-data/not-found.xml');
			$this->fail('prosla chyba');
		}
		catch (\InvalidArgumentException $e) {
			$this->assertEquals($e->getMessage(), 'File [' . __dir__ . '/test-data/not-found.xml] not found.');
		}
	}



	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testUsers()
	{
		$pom = new Shell\ConfigXmlReader(__dir__ . '/test-data/access.xml');
		$this->assertEquals(array(
				(object) array('ident' => 'taco', 'firstname' => 'Martin', 'lastname' => 'Takáč', 'email' => 'mt@darkmay.cz', 'permission' => array('read', 'write', 'remove', 'sign-in', )),
				(object) array('ident' => 'mira', 'firstname' => Null, 'lastname' => Null, 'email' => 'mf@darkmay.cz', 'permission' => array('read', 'write', 'remove', )),
				(object) array('ident' => 'fean', 'firstname' => 'Andreaw', 'lastname' => 'Fean', 'email' => 'mt@darkmay.cz', 'permission' => array('read')),
				), $pom->getUserList());
	}



}
