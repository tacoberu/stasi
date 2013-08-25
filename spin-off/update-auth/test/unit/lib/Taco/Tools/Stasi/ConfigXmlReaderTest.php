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


require_once __dir__ . '/../../../../../../lib/Stasi/ConfigReaderInterface.php';
require_once __dir__ . '/../../../../../../lib/Stasi/ConfigReaderXml.php';


use Taco\Tools\Stasi\Shell;


/**
 * @call phpunit ConfigXmlReaderTest.php tests_libs_taco_tools_Stasi_Shell_ConfigXmlReaderTest
 */
class tests_libs_taco_tools_Stasi_Shell_ConfigXmlReaderTest extends PHPUnit_Framework_TestCase
{


	/**
	 *	Neplatný soubor.
	 */
	public function testFail()
	{
		try {
			$pom = new Shell\ConfigReaderXml(__dir__ . '/test-data/not-found.xml');
			$this->fail('prosla chyba');
		}
		catch (\InvalidArgumentException $e) {
			$this->assertEquals($e->getMessage(), 'File [' . __dir__ . '/test-data/not-found.xml] not found.');
		}
	}



	/**
	 *	Seznam uživatelů.
	 */
	public function testUsers()
	{
		$pom = new Shell\ConfigReaderXml(__dir__ . '/test-data/access.xml');
		$this->assertEquals(array(
				(object) array(
						'ident' => 'taco',
						'firstname' => 'Martin',
						'lastname' => 'Takáč',
						'email' => 'mt@darkmay.cz',
						'permission' => array('init', 'read', 'write', 'remove', 'sign-in', ),
						'ssh' => array(
								(object) array(
										'type' => 'ssh-dss',
										'key' => 'AAAAB3NzaC1kc3MAAACBAIX...PCoEtM6WGJWo5vxA==',
										),
								),
						),
				(object) array(
						'ident' => 'mira',
						'firstname' => '',
						'lastname' => '',
						'email' => 'mf@darkmay.cz',
						'permission' => array('read', 'write', 'remove', ),
						'ssh' => array(
								(object) array(
										'type' => 'ssh-dsa',
										'key' => 'AAAAB3NzaC1kc3MAAA9P+LORiZUed+0EVjgIPwzt/bLAsXk+Y...Q66tl5l6yXMPCoEtM6WGJWo5vxA==',
										),
								),
						),
				(object) array(
						'ident' => 'fean',
						'firstname' => 'Andreaw',
						'lastname' => 'Fean',
						'email' => 'mt@darkmay.cz',
						'permission' => array('read'),
						'ssh' => array(
								(object) array(
										'type' => 'ssh-dsa',
										'key' => 'AAAAB3NzaC1kc3MAAACBAIXclzahWltq96N5cz3Rftt2ZnsRi...Q66tl5l6yXMPCoEtM6WGJWo5vxA==',
										),
								),
						),
				), $pom->getUserList());
	}



	/**
	 *	Umístění repozitáře.
	 */
	public function testRepoPath()
	{
		$pom = new Shell\ConfigReaderXml(__dir__ . '/test-data/access.xml');
		$this->assertEquals('Development/lab/stasi', $pom->getRepoPath());
	}



}
