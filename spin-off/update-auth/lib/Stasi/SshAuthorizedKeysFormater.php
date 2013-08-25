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
