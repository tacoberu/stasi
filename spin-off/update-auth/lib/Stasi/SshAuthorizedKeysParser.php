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
