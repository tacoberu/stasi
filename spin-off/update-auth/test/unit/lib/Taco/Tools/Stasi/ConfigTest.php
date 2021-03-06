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


require_once __dir__ . '/../../../../../../lib/Stasi/Config.php';


use Taco\Tools\Stasi\Shell;


/**
 * @call phpunit ConfigTest.php tests_libs_taco_tools_Stasi_Shell_ConfigTest
 */
class tests_libs_taco_tools_Stasi_Shell_ConfigTest extends PHPUnit_Framework_TestCase
{


	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testAclFile()
	{
		$config = new Shell\Config($this->getServer());
		$this->assertEquals('/home/cia/.config/stasi/access.xml', $config->getAclFile());
	}



	/**
	 *	I prázdné hodnoty jsou validní.
	 */
	public function testLogsPath()
	{
		$config = new Shell\Config($this->getServer());
		$this->assertEquals('/var/log/stasi', $config->getLogsPath());
	}



	/**
	 * @param
	 * @return ...
	 */
	private function getServer(array $master = array())
	{
		return array_merge($master, array(
				'SELINUX_ROLE_REQUESTED' => Null,
				'SHELL' => '/bin/bash',
				'SSH_CLIENT' => '10.0.0.104 33649 22',
				'SELINUX_USE_CURRENT_RANGE' => Null,
				'USER' => 'cia',
				'MAIL' => '/var/mail/cia',
				'PATH' => '/usr/local/bin:/bin:/usr/bin',
				'PWD' => '/home/cia',
				'XMODIFIERS' => '@im=none',
				'LANG' => 'en_US.utf8',
				'SELINUX_LEVEL_REQUESTED' => Null,
				'SHLVL' => 1,
				'HOME' => '/home/cia',
				'SSH_ORIGINAL_COMMAND' => "git-receive-pack 'projects/stasi.git'",
				'LOGNAME' => 'cia',
				'CVS_RSH' => 'ssh',
				'SSH_CONNECTION' => '10.0.0.104 33649 10.0.0.2 22',
				'LESSOPEN' => '|/usr/bin/lesspipe.sh %s',
				'G_BROKEN_FILENAMES' => 1,
				'_' => '/home/cia/bin/stasi-shell',
				'PHP_SELF' => '/home/cia/bin/stasi-shell',
				'SCRIPT_NAME' => '/home/cia/bin/stasi-shell',
				'SCRIPT_FILENAME' => '/home/cia/bin/stasi-shell',
				'PATH_TRANSLATED' => '/home/cia/bin/stasi-shell',
				'DOCUMENT_ROOT' => Null,
				'REQUEST_TIME' => 1372966882,
				'argv' => array (
						'/home/cia/bin/stasi-shell',
						'taco',
					),

				'argc' => 2,
				));
	}



}
