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
	function getByName(AuthorizedKeysUser $entry)
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

