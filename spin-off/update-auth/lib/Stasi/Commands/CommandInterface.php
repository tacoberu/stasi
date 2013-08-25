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
interface CommandInterface
{

	/**
	 *	Podoba výstupu.
	 */
	function createResponse(Request $request);



	/**
	 *	Vytvoření odpovědi. Předpokládáme jen náhled.
	 */
	function fetch(Request $request, ResponseInterface $response);

}
