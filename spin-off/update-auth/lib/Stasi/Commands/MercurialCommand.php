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
 *
 */
class MercurialCommand extends CommandAbstract implements CommandInterface
{

	private $model;


	/**
	 *	Vytvoření objektu na základě parametrů z getu.
	 */
	public function __construct(ModelBuilder $model)
	{
		$this->model = $model;
	}



	/**
	 *	Obálka na data.
	 */
	public function createResponse(Request $request)
	{
		return new ExecResponse();
	}



	/**
	 * @return Model
	 */
	public function getModel()
	{
		return $this->model;
	}



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	public function fetch(Request $request, ResponseInterface $response)
	{
		$acl = $this->getModel()->getApplication()->getAcl();
		$acl->setUser(new Model\User($request->getUser()));
		$this->getLogger()->trace('request', $request);
		$command = $this->maskedCommand($request->getCommand());
		$this->getLogger()->trace('command', $request->getCommand() . ' -> ' . $command);
		if ($acl->isAllowed($request->getAccess())) {
			$response->setCommand($command);
			return $response;
		}
		switch ($request->getAccess()) {
			case Model\Acl::PERM_INIT:
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot creating mercurial repository.", 5);
			default:
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot access to mercurial repository.", 8);
		}
	}



	/**
	 * Nahrazuje repozitář:
	 *	hg init projects/test.hg
	 *	hg -R projects/test.hg serve --stdio
	 *
	 * @param string $command
	 * @return string
	 */
	private function maskedCommand($command)
	{
		$model = $this->getModel()->getApplication();
		if (preg_match('~(hg\s+init\s+)([^\s]+)(.*)~', $command)) {
			$command = preg_replace_callback(
					'~(hg\s+init\s+)([^\s]+)(.*)~',
					function ($matches) use ($model) {
						return $matches[1] . $model->getRepositoryPath() . '/' .  trim($matches[2], ' \\/') . $matches[3];
					},
					$command);
		}
		else if (preg_match('~(hg\s+\-R\s+)([^\s]+)(.*)~', $command)) {
			$command = preg_replace_callback(
				'~(hg\s+\-R\s+)([^\s]+)(.*)~',
				function ($matches) use ($model) {
					return $matches[1] . $model->getRepositoryPath() . '/' .  trim($matches[2], ' \\/') . $matches[3];
				},
				$command);
		}

		return $command;
	}



}
