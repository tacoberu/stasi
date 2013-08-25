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


require_once __dir__ . '/../../../../../../lib/Stasi/Model/Acl.php';
require_once __dir__ . '/../../../../../../lib/Stasi/Parser.php';
require_once __dir__ . '/../../../../../../lib/Stasi/ParserGit.php';
require_once __dir__ . '/../../../../../../lib/Stasi/ParserMercurial.php';
require_once __dir__ . '/../../../../../../lib/Stasi/Request.php';


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
