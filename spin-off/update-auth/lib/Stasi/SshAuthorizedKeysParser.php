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
 * Zpracovává zdrojový rádek.
 */
class SshAuthorizedKeysParser
{


	function parse($s)
	{
		if (preg_match('~command=\"([^\"]+)\",([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)~', $s, $out)) {
			$command = $out[1];
			$attribs = $out[2];
			$sshtype = $out[3];
			$publicKey = $out[4];
			$email = $out[5];
			if (preg_match('~--user\s+([^\s]+)~', $command, $out)) {
				$user = $out[1];
			}
			try {
				$user = new AuthorizedKeysUser($user, $sshtype, $publicKey, $email);
				$user->command = $command;
				$user->attribs = $attribs;
			}
			catch (\InvalidArgumentException $e) {
				throw new \RuntimeException('Parse failed, because: ' . $e->getMessage(), 1, $e);
			}

			return $user;
		}
	}


}

