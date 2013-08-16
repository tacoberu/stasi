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

