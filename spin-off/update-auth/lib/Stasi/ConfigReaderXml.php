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


/**
 * Čistě čtení xml souboru s uloženou konfigurací. Nijak nezohlednuje nastavení
 * předané skrze příkazovou řádku, nebo tak něco.
 */
class ConfigReaderXml implements ConfigReaderInterface
{

	/**
	 *	Xml instance.
	 */
	private $source;


	/**
	 *	Kde soubor s definicí konfigurace.
	 */
	private $location;


	/**
	 *	Instance readeru obaluje soubor.
	 */
	public function __construct($location)
	{
		if (!file_exists($location)) {
			throw new \InvalidArgumentException('File [' . $location . '] not found.');
		}
		$this->location = $location;
	}



	/**
	 *	Verze schematu xmlka.
	 *	@return string
	 */
	public function getUserList()
	{
		$source = $this->getSource();
		$response = array();
		foreach ($source->xpath('stasi:user') as $node) {
			$node->registerXPathNamespace('stasi', 'urn:nermal/stasi');
			$node->registerXPathNamespace('contact', 'urn:nermal/contact');

			$entry = (object) array (
					'ident' => trim((string)$node['name']),
					'firstname' => trim(self::xmlContent($node, 'contact:firstname')),
					'lastname' => trim(self::xmlContent($node, 'contact:lastname')),
					'email' => trim(self::xmlContent($node, 'contact:email')),
					'permission' => array(),
					'ssh' => array(),
					);

			foreach ($node->xpath('stasi:access/stasi:permission') as $perm) {
				$entry->permission[] = (string)$perm;
			}

			foreach ($node->xpath('stasi:ssh') as $ssh) {
				$entry->ssh[] = self::buildSsh($ssh);
			}

			$response[] = $entry;
		}

		return $response;
	}



	/**
	 * @return ...
	 */
	public function getRepoPath()
	{
		$source = $this->getSource();
		$path = $source->xpath('stasi:setting/stasi:repo-path');
		if (isset($path[0])) {
			return trim((string)$path[0]);
		}
		throw new \RuntimeException('repo-path not setting');
	}


	/**
	 *	Lazy loading configurace.
	 */
	private function getSource()
	{
		if (empty($this->source)) {
			$source = \simplexml_load_file($this->location);
			$source->registerXPathNamespace('stasi', 'urn:nermal/stasi');
			$source->registerXPathNamespace('contact', 'urn:nermal/contact');
			$this->source = $source;
		}

		return $this->source;
	}



	/**
	 * @param SimpleXmlElement xml uzel, ve kterém vyhledáváme.
	 * @param stirng xpath Cesta.
	 *
	 * @return string
	 */
	private static function xmlContent($node, $xpath)
	{
		$el = $node->xpath($xpath);
		if (isset($el[0])) {
			return (string)$el[0];
		}
	}



	/**
	 * @param SimpleXmlElement xml uzel, ve kterém vyhledáváme.
	 * @param stirng xpath Cesta.
	 *
	 * @return string
	 */
	private static function buildSsh($node)
	{
		return (object) array(
				'type' => trim((string)$node['type']),
				'key' => trim((string)$node),
				);
	}






}
