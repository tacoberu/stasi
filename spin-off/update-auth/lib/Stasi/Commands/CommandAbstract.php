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
 *	Bázová třída, vracející formát json.
 */
abstract class CommandAbstract implements CommandInterface
{

	private $logger;


	/**
	 * @param logovadlo.
	 * @return fluent
	 */
	public function setLogger(LoggerInterface $logger)
	{
		$this->logger = $logger;
		return $this;
	}



	/**
	 * Získání loggeru, nového, nebo oposledně vytvořeneého.
	 * @return Logger
	 */
	public function getLogger()
	{
		if (empty($this->logger)) {
			$this->logger = $this->createLogger();
		}
		return $this->logger;
	}



	/**
	 * Vytvoření nového loggeru.
	 * @return Logger
	 */
	protected function createLogger()
	{
		return new NullLogger();
	}


}

