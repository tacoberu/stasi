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



class AccessDeniedException extends \RuntimeException
{}



/**
 *	Bázová třída, vracející formát json.
 */
class OriginalCommand extends CommandAbstract implements CommandInterface
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
		$this->getLogger()->trace('command', $request->getCommand());
		if ($acl->isAllowed($acl::PERM_SIGNIN)) {
			$response->setCommand($request->getCommand());
			return $response;
		}
		throw new AccessDeniedException("Access Denied for [{$request->getUser()}]. User cannot sign-in.", 5);
	}



}

