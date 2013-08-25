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
