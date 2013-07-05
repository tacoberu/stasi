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
 *	Dispatcher dostupnosti.
 */
class Dispatcher
{

	/**
	 * Manipulace s daty.
	 */
	private $model;


	/**
	 * Konfigurace.
	 */
	private $config;


	/**
	 * Konfigurace.
	 */
	private $logger;


	/**
	 * @param $model, $config
	 */
	public function __construct(Config $config, ModelBuilder $model)
	{
		if (empty($config)) {
			throw new \InvalidArgumentException('config', 2);
		}
		if (empty($model)) {
			throw new \InvalidArgumentException('model', 3);
		}

		$this->model = $model;
		$this->config = $config;
	}



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



	/**
	 * Vytvoření odpovědi. Předpokládáme jen náhled.
	 * @return Response
	 */
	public function dispatch(Request $request)
	{
		$this->getLogger()->trace('globals', $GLOBALS);
		
		//	Rozřazuje, zda se jedná o příkazy pro git, nebo pro mercurial, nebo nějaké předdefinované, a nebo obecné.
		$parser = new Parser();
		$parser->add(new ParserGit());
		if ($adapter = $parser->parse($request)) {
			$actionClassName = $adapter->getActionClassName();
			$action = new $actionClassName($this->model);
			$request->setAccess($adapter->getAccess());
		}
		else {
			$action = new OriginalCommand($this->model);
		}
		
		$action->setLogger($this->getLogger());

		$response = $this->fireAction($request, $action);
		
		return $response;
	}



	/**
	 * @param ActionInterface $action
	 * @return Response
	 */
	private function fireAction(Request $request, CommandInterface $action)
	{
		//	Vytvoříme odpověď.
		$response = $action->createResponse($request);
	
		//	Odpověď naplníme daty.
		$response = $action->fetch($request, $response);
		
		return $response;
	}

}
