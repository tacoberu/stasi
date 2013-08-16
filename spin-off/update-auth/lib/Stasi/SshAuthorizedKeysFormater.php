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
 * Vytváří záznam.
 */
class SshAuthorizedKeysFormater
{

	private $command = '/home/cia/bin/stasi';
	private $attribs = 'no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty';



	function __construct($command = Null, $attribs = Null)
	{
		if ($command) {
			$this->command = $command;
		}

		if ($attribs) {
			$this->attribs = $attribs;
		}
	}


	/**
	 * Rádek do authorized_keys
	 */
	function format(AuthorizedKeysUser $entry)
	{
		$command = $this->command . ' shell --user ' . $entry->user;
		$attribs = $this->attribs;
		return "command=\"$command\",$attribs {$entry->sshtype} {$entry->publicKey} {$entry->email}";
	}


}

