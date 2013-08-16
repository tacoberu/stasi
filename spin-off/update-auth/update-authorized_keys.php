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

require_once __dir__ . '/lib/Stasi/ConfigReaderInterface.php';
require_once __dir__ . '/lib/Stasi/ConfigReaderXml.php';
require_once __dir__ . '/lib/Stasi/AuthorizedKeysUser.php';
require_once __dir__ . '/lib/Stasi/SshAuthorizedKeysParser.php';
require_once __dir__ . '/lib/Stasi/SshAuthorizedKeysFormater.php';
require_once __dir__ . '/lib/Stasi/UserBank.php';
require_once __dir__ . '/lib/Stasi/ServiceFactory.php';



use Taco\Tools\Stasi\Shell;



/**
 * @call php update-authorized_keys.php authorized_keys config.xml
 */
try {
	if (count($argv) <= 2) {
		throw new \RuntimeException('Invalid args - first arg is dest of authorized_keys, and second arg is dest of config.xml.');
	}

	if (! file_exists($argv[1])) {
		throw new \RuntimeException('Invalid first args - [' . $argv[1] . '] not found.');
	}

	if (! file_exists($argv[2])) {
		throw new \RuntimeException('Invalid second args - [' . $argv[2] . '] not found.');
	}

	$config = new Shell\ConfigReaderXml($argv[2]);
	$factory = new Shell\ServiceFactory($config);


	//	Načíst ze souboru
	$content = file_get_contents($argv[1]);
	$content = explode(PHP_EOL, $content);


	//	Zpracovat
	$missing = array();

	//	Tohle si odkládáme jen kůli konstantám
	$bank = $factory->getBank();
	foreach ($content as $line => $row) {
		//	White chars
		$row = trim($row);
	
		//	Comments line
		if (!strlen($row) || $row{0} == '#') {
			continue;
		}
	
		//	start with command 
		if (substr($row, 0, 7) == 'command') {
			try {
				$entry = $factory->getParser()->parse($row);
				switch($bank->check($entry)) {
					case $bank::CHECK_CORRECT:
						$missing[] = $entry;
						break;
					case $bank::CHECK_DIFFERENT:
						$content[$line] = $factory->getFormater()->format($bank->getByEntry($entry));
						$missing[] = $entry;
						break;
					case $bank::CHECK_EMPTY:
						unset($content[$line]);
						break;
					default:
						throw \LogicException('Unkow key of checkin');
				}
			}
			catch (\RuntimeException $e) {
				throw new \RuntimeException('Invalid file [' . $argv[1] . '] in line: ' . $line . ', ' . $e->getMessage(), 3, $e);
			}
		}
	}


	//	Doplnit nové.
	foreach ($bank->missing($missing) as $entry) {
		$content[] = $factory->getFormater()->format($entry);
	}


	//	Uložit do souboru
	$content = implode(PHP_EOL, $content);
	file_put_contents($argv[1], $content);


	exit(0);
}
catch (\Exception $e) {
	echo 'ERROR: ' . $e->getMessage() . PHP_EOL;
	exit(1);
}
