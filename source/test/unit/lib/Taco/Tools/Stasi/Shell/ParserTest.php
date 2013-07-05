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


require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/Model/Acl.php';
require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/Parser.php';
require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/ParserGit.php';
require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/ParserMercurial.php';
require_once __dir__ . '/../../../../../../../lib/Stasi/Shell/Request.php';


use Taco\Tools\Stasi\Shell;


/**
 * @call phpunit ParserTest.php tests_libs_taco_tools_Stasi_Shell_ParserTest
 */
class tests_libs_taco_tools_Stasi_Shell_ParserTest extends PHPUnit_Framework_TestCase
{


	private $parser;
	
	

	/**
	 * @param 
	 * @return ...
	 */
	public function setUp()
	{
		$this->parser = new Shell\Parser();
		$this->parser->add(new Shell\ParserGit());
		$this->parser->add(new Shell\ParserMercurial());
	}



	/**
	 *	Komunikace s existujícím repozitáře mercurialu.
	 *	hg -R projects/test.hg serve --stdio
	 */
	public function testAny()
	{
		$request = new Shell\Request();
		$request->setUser('foo');
		$request->setCommand("ls -la");
		
		$adapter = $this->parser->parse($request);
		$this->assertNull($adapter);
	}



	/**
	 *	
	 */
	public function testGitUploadPack()
	{
		$request = new Shell\Request();
		$request->setUser('foo');
		$request->setCommand("git-upload-pack 'projects/stasi.git'");
		
		$adapter = $this->parser->parse($request);

		$this->assertInstanceOf('Taco\Tools\Stasi\Shell\ParserGit', $adapter);
		$this->assertEquals(Shell\Model\Acl::PERM_READ, $adapter->getAccess());
	}



	/**
	 *	
	 */
	public function testGitArchivePack()
	{
		$request = new Shell\Request();
		$request->setUser('foo');
		$request->setCommand("git-upload-archive 'projects/stasi.git'");
		
		$adapter = $this->parser->parse($request);

		$this->assertInstanceOf('Taco\Tools\Stasi\Shell\ParserGit', $adapter);
		$this->assertEquals(Shell\Model\Acl::PERM_READ, $adapter->getAccess());
	}



	/**
	 *	
	 */
	public function testGitReceivePack()
	{
		$request = new Shell\Request();
		$request->setUser('foo');
		$request->setCommand("git-receive-pack 'projects/stasi.git'");
		
		$adapter = $this->parser->parse($request);

		$this->assertInstanceOf('Taco\Tools\Stasi\Shell\ParserGit', $adapter);
		$this->assertEquals(Shell\Model\Acl::PERM_WRITE, $adapter->getAccess());
	}



	/**
	 *	Vytvoření repozitáře mercurialu.
	 *	hg init projects/test.hg
	 */
	public function testMercurialInit()
	{
		$request = new Shell\Request();
		$request->setUser('foo');
		$request->setCommand("hg init projects/test.hg");
		
		$adapter = $this->parser->parse($request);

		$this->assertInstanceOf('Taco\Tools\Stasi\Shell\ParserMercurial', $adapter);
		$this->assertEquals(Shell\Model\Acl::PERM_INIT, $adapter->getAccess());
	}



	/**
	 *	Komunikace s existujícím repozitáře mercurialu.
	 *	hg -R projects/test.hg serve --stdio
	 */
	public function testMercurialServe()
	{
		$request = new Shell\Request();
		$request->setUser('foo');
		$request->setCommand("hg -R projects/test.hg serve --stdio");
		
		$adapter = $this->parser->parse($request);

		$this->assertInstanceOf('Taco\Tools\Stasi\Shell\ParserMercurial', $adapter);
		$this->assertEquals(Shell\Model\Acl::PERM_EXISTS, $adapter->getAccess());
	}


}
