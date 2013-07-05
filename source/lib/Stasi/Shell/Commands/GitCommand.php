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
class GitCommand extends CommandAbstract implements CommandInterface
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
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot creating git repository.", 5);
			case Model\Acl::PERM_READ:
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot read from git repository.", 5);
			case Model\Acl::PERM_WRITE:
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot write to git repository.", 6);
			case Model\Acl::PERM_REMOVE:
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot remove in git repository.", 7);
			default:
				throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot access to git repository.", 8);
		}
	}



	/**
	 * Nahrazuje repozitář. "git-upload-pack 'projects/stasi.git'"
	 *
	 * @param 
	 * @return ...
	 */
	private function maskedCommand($command)
	{
		$model = $this->getModel()->getApplication();
		if ($res = preg_replace_callback(
				'~([\w-]+\s+\')([^\']+)(\'.*)~',
				function ($matches) use ($model) {
					return $matches[1] . $model->getRepositoryPath() . '/' .  trim($matches[2], ' \\/') . $matches[3]; 
				},
				$command)) {
			return $res;
		}
		return $command;
	}

}

