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

		//	Ověření přístupů.
		$this->assertAccess($request);

		//	Ověření konzistence repozitáře. To znamená, zda
		//	- je bare
		//	- má nastavené defaultní hooky
		//	- ...
		$this->getModel()->getApplication()->doNormalizeRepository($this->prepareRepository($request->getCommand()), 'git');

		return $response->setCommand($command);
	}



	/**
	 * @param int $mask
	 */
	private function assertAccess($request)
	{
		$acl = $this->getModel()->getApplication()->getAcl();
		if (! $acl->isAllowed($request->getAccess())) {
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
	}



	/**
	 * Nahrazuje repozitář. "git-upload-pack 'projects/stasi.git'"
	 *
	 * @param string $command
	 * @return string
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



	/**
	 * From command prepare repository
	 *
	 * @param string $command
	 * @return string
	 */
	private function prepareRepository($command)
	{
		$model = $this->getModel()->getApplication();
		if (preg_match('~([\w-]+\s+\')([^\']+)(\'.*)~',	$command, $matches)) {
			return $model->getRepositoryPath() . '/' .  trim($matches[2], ' \\/');
		}
		throw new \RuntimeException('V příkazu není uvedena cesta k repozitáři.');
	}

}
