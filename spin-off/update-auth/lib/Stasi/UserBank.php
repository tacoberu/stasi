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


class UserBank
{

	const CHECK_CORRECT = 1;
	const CHECK_DIFFERENT = 2;
	const CHECK_EMPTY = 3;


	private $users = array();



	/**
	 *	Zda je v banku.
	 */
	function check(AuthorizedKeysUser $entry)
	{
		if (!isset($this->users[$entry->getId()])) {
			return self::CHECK_EMPTY;
		}
		else if ($this->users[$entry->getId()]->sshtype == $entry->sshtype
				&& $this->users[$entry->getId()]->publicKey == $entry->publicKey
				&& $this->users[$entry->getId()]->email == $entry->email
				) {
			return self::CHECK_CORRECT;
		}
		else {
			return self::CHECK_DIFFERENT;
		}
	}



	/**
	 *	Přidat nový
	 */
	function add(AuthorizedKeysUser $entry)
	{
		$this->users[$entry->getId()] = $entry;
		return $this;
	}



	/**
	 *	Získat podle názvu.
	 */
	function getByEntry(AuthorizedKeysUser $entry)
	{
		return $this->users[$entry->getId()];
	}



	/**
	 *	Vrátí seznam názvů uživatelů, které nejsou v seznamu.
	 */
	function missing(array $list)
	{
		$map = array();
		foreach ($list as $entry) {
			$map[] = $entry->getId();
		}

		$result = array();
		foreach ($this->users as $name => $entry) {
			if (! in_array($name, $map)) {
				$result[] = $entry;
			}
		}

		return $result;
	}


}
