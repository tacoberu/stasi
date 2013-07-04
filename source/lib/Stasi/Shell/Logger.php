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
 *	Logování komunikace po stoosmé.
 */
interface LoggerInterface
{

	function trace($name, $content);
	function export();

}




/**
 *	Logování komunikace po stoosmé.
 */
class Logger implements LoggerInterface
{

	private $dir;



	/**
	 * @param $model, $config
	 */
	public function __construct($dir)
	{
		if (! is_writable($dir)) {
			throw new \InvalidArgumentException("Cannot writable path [$dir].", 3);
		}

		$this->dir = rtrim($dir, '/\\');
	}



	public function trace($name, $content)
	{
		file_put_contents($this->formatFilename($name), $this->formatContent($content),  FILE_APPEND );
		return $this;
	}



	public function export()
	{
		return $this->trace;
	}



	private function formatFilename($name)
	{
		$name = strtr($name, '/\\', '..');
		return $this->dir . DIRECTORY_SEPARATOR . $name . '.log';
	}



	private function formatContent($content)
	{
		if (! is_string($content)) {
			$content = print_r($content, True)
				. "\n------------------------------------------------------------";
		}
		return '[' . date('Y-m-d H:i:s') . '] ' . $content . PHP_EOL;
	}

}



/**
 *	Logování komunikace po stoosmé.
 */
class NullLogger implements LoggerInterface
{

	public function trace($name, $content)
	{
	}



	public function export()
	{
		return Null;
	}

}


