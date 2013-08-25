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

		//	Rozřazuje, zda se jedná o příkazy pro git, nebo pro mercurial, nebo nějaké předdefinované, a nebo přihlášení na server.
		$parser = new Parser();
		$parser->add(new ParserGit());
		$parser->add(new ParserMercurial());
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
