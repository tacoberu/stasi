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


module stasi.model;

import taco.logging;
import taco.utils;

import stasi.config;

import std.stdio;
import std.file;
import std.string;


/**
 *	Továrna na modely.
 */
class ModelBuilder
{

	const VERSION = "0.0.3";
	
	
	/**
	 * Nastavení aplikace, práv, uživatelů, repozitářů.
	 */
	private Config config;
	
	
	/**
	 * Podrobné zaznamenávávní toho, co se děje.
	 */
	private Logger logger;


	/**
	 * Kořenový model aplikace.
	 */
	private Application _application;


	/**
	 * @param model, config
	 */
	this(Config config, Logger logger)
	{
		this.config = config;
		this.logger = logger;
	}



	/**
	 * Getted or Created Application
	 */
	@property Application application() // const
	{
		if (! this._application) {
			this._application = this.createApplication();
		}
		return this._application;
	}



	/**
	 * Create new Application
	 */
	Application createApplication()
	{
		string s = cast(string)std.file.read(this.config.configFile);
		this.logger.info(format("load file: [%s]", this.config.configFile), "configuration");
		
		IConfigReader reader = new ConfigXmlReader(s);
		this.config = reader.fill(this.config);

		Application app = (new Application())
			.setLogger(this.logger)
			.setHomePath(this.config.homePath)
			.setDefaultRepositoryPath(this.config.defaultRepositoryPath)
			.setDefaultWorkingPath(this.config.defaultWorkingPath);

		this.logger.log(format("home path: [%s]", this.config.homePath), "configuration");
		this.logger.log(format("default repository path path: [%s]", this.config.defaultRepositoryPath), "configuration");
		this.logger.log(format("default working path: [%s]", this.config.defaultWorkingPath), "configuration");

		foreach (u; this.config.users) {
			app.users ~= u;
			this.logger.log(format("user: [%s]", u.name), "configuration");
		}

		foreach (r; this.config.repositories) {
			app.repositories ~= r;
			this.logger.log(format("repository: [%s]", r.name), "configuration");
		}

		return app;
	}



}



/**
 *	Kořenový model aplikace.
 */
class Application
{

	/**
	 * Seznam oprávnění.
	 */
	Acl[] acls;


	/**
	 * Cesta k defaultnímu umístění repozitářů.
	 */
	private string repositoryPath;
	
	
	/**
	 * Cesta k defaultnímu umístění pískoviště repozitářů.
	 */
	private string defaultWorkingPath;
	

	/**
	 * Cesta k domácímu adresáři.
	 */
	private string homePath;


	/**
	 * Všechny uživatelé, kteří jsou k dispozici.
	 */
	User[] users;


	/**
	 * Seznam repozitářů.
	 */
	Repository[] repositories;


	/**
	 * Loggovadlo.
	 */
	private Logger logger;


	/**
	 * Přiřazení logovadla.
	 */
	Application setLogger(Logger m)
	{
		this.logger = m;
		return this;
	}


	/**
	 * Cesta k úložišti repozitářů.
	 */
	Application setHomePath(string path)
	{
		this.homePath = path;
		return this;
	}


	/**
	 * Cesta k defaultnímu úložišti repozitářů.
	 */
	Application setDefaultRepositoryPath(string path)
	{
		this.repositoryPath = path;
		return this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 */
	string getDefaultRepositoryPath()
	{
		return this.repositoryPath;
	}
	/*
	unittest {
		Application app = (new Application()).setDefaultRepositoryPath("repos");
		assert("repos", app.getDefaultRepositoryPath());
	}
	* */



	/**
	 * Cesta k defaultnímu úložišti repozitářů.
	 */
	Application setDefaultWorkingPath(string path)
	{
		this.defaultWorkingPath = path;
		return this;
	}



	/**
	 * Cesta k úložišti repozitářů.
	 */
	string getDefaultWorkingPath()
	{
		return this.defaultWorkingPath;
	}
	unittest {
		Application app = (new Application()).setDefaultWorkingPath("woriks");
		assert("woriks", app.getDefaultWorkingPath());
	}
	


	/**
	 * Zda se uživatel může skrze shell přihlašovat na server.
	 * @todo
	 */
	bool isAllowedSignin(User user)
	{
		return true;
	}



	/**
	 * Zda uživatel může přistupovat k repozitáři.
	 */
	bool isAllowed(User user, Repository repository, Permission perm)
	{
		//	Najdem uživatele
		foreach (u; this.users) {
			if (u.name == user.name) {
				//	Najdem repozitář
				foreach (r; u.repositories) {
					if ((r.name == repository.name) && (r.type == repository.type)) {
						//	Zkontrolujem oprávnění.
						if (perm & r.permission) {
							this.logger.log(format("allow(%s, %s, %d)", user.name, repository.name, perm), "auth");
							return true;
						}
						this.logger.log(format("deny(%s, %s, %d)", user.name, repository.name, perm), "auth");
						return false;
					}
				}
			}
		}
		this.logger.log(format("not match(%s, %s, %d)", user.name, repository.name, perm), "auth");
		return false;
	}
	/*
	unittest {
		Application app = new Application();
		User user = new User("foo");
		user.repositories["pokus.git"] = new AccessRepository("pokus.git", RepositoryType.GIT, Permission.READ);
		user.repositories["druhej.hg"] = new AccessRepository("druhej.hg", RepositoryType.MERCURIAL, Permission.READ | Permission.WRITE | Permission.REMOVE);
		app.users ~= user;
		assert(2 == user.repositories.length);
		assert(true == app.isAllowed(new User("foo"), new Repository("pokus.git", RepositoryType.GIT), Permission.READ));
		assert(false == app.isAllowed(new User("foo"), new Repository("pokus.git", RepositoryType.GIT), Permission.WRITE));
		assert(app.isAllowed(new User("foo"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.WRITE));
		assert(app.isAllowed(new User("foo"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.READ));
		assert(! app.isAllowed(new User("foo"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.INIT));
		assert(! app.isAllowed(new User("too"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.WRITE));
		assert(! app.isAllowed(new User("too"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.READ));
	}
	*/



	/**
	 * Získání repozitáře podle jména.
	 */
	Repository getRepositoryByName(string name)
	{
		foreach (repo; this.repositories) {
			if (repo.name == name) {
				return repo;
			}
		}
		return null;
	}



	/**
	 * Existence repozitáře.
	 */
	bool hasRepository(string name)
	{
		foreach (repo; this.repositories) {
			if (repo.name == name) {
				return true;
			}
		}
		return false;
	}



	/**
	 * Ověření konzistence repozitáře. To znamená, zda
	 * - je bare
	 * - má nastavené defaultní hooky
	 * - ...
	 */
	void doNormalizeRepository(string repo, RepositoryType type)
	{
		Repository repository = this.getRepositoryByName(repo);
		string full = this.homePath ~ "/" ~ repository.full;
		
		//	Existence souboru
		if (! std.file.exists(full)) {
			final switch(type) {
				case RepositoryType.GIT:
					this.doCreateRepositoryGit(repository);
					break;
				case RepositoryType.MERCURIAL:
//					this.doCreateRepositoryMercurial(repository);
					break;
				case RepositoryType.UNKNOW:
					throw new Exception(format("Unknow type repository and not exists: [%s]", repo));
			}
		}

		final switch(type) {
			case RepositoryType.GIT:
//				this.doNormalizeAssignHooksGit(full);
				break;
			case RepositoryType.MERCURIAL:
//				this.doNormalizeAssignHooksGit(full);
				break;
			case RepositoryType.UNKNOW:
				throw new Exception(format("Unknow type repository: [%s]", repo));
		}
	}



	/**
	 * @param fullrepo
	 * @return boolean
	 * /
	private function doNormalizeAssignHooksGit(fullrepo)
	{
		//	Post Receive
		postReceive = fullrepo . '/hooks/post-receive';
		postReceiveTo = realpath(__dir__ . '/../../../../bin/git-hooks/post-receive');
		if (file_exists(postReceive) && (! is_link(postReceive) || readlink(postReceive) != postReceiveTo)) {
			rename(postReceive, postReceive . '-original');
		}

		if (! file_exists(postReceive)) {
			symlink(postReceiveTo, postReceive);
		}

		//	Post Update
		postUpdate = fullrepo . '/hooks/post-update';
		postUpdateTo = realpath(__dir__ . '/../../../../bin/git-hooks/post-update');
		if (file_exists(postUpdate) && (! is_link(postUpdate) || readlink(postUpdate) != postUpdateTo)) {
			rename(postUpdate, postUpdate . '-original');
		}

		if (! file_exists(postUpdate)) {
			symlink(postUpdateTo, postUpdate);
		}
	}


	//*/



	/**
	 * Vytvoření repozitáře.
	 * Git křičí, když je vytvořený prázdný repozitář. Proto tam hodíme první komit.
	 * Také je potřeba nastavit git, aby přijímal příchozí commity.
	 */
	private void doCreateRepositoryGit(Repository repository)
	{
		string oldcwd = getcwd();
		
		string full = this.homePath ~ "/" ~ repository.full;
		std.process.system(format("mkdir -p %s", full));
		
		chdir(full);
		
		std.process.system("git init > /dev/null");
		std.process.system("echo 'empty' > README");
		std.process.system("echo '[receive]' >> .git/config");
		std.process.system("echo '	denyCurrentBranch = ignore' >> .git/config");
		std.process.system("git add README > /dev/null");
		std.process.system("git commit -m 'Initialize commit.' > /dev/null");

		chdir(oldcwd);
	}

}



/**
 *	Uživatel.
 */
class User
{
	private string _name;
	string firstname;
	string lastname;
	string[] emails;
	AccessRepository[string] repositories;


	this(string name)
	{
		this._name = name;
	}


	/**
	 * Name read-only
	 */
	@property string name() // const
	{
		return this._name;
	}
	unittest {
		assert("fean" == (new User("fean")).name);
	}

}
unittest {
	User u = new User("taco");
	assert("taco" == u.name);
	assert([] == u.emails);
}




/**
 *	Typ repozitáře.
 */
enum RepositoryType
{
	UNKNOW = 0,
	GIT = 1,
	MERCURIAL
}



/**
 *	Repozitář.
 */
class Repository
{

	/**
	 * Type of repository - read-only.
	 */
	private RepositoryType _type;


	/**
	 * Name of repository without path - read-only.
	 */
	private string _name;


	/**
	 * Real path with repository.
	 */
	Dir path;


	/**
	 * Real path with repository.
	 */
	Dir working;


	this(string name, RepositoryType type)
	{
		this._name = name;
		this._type = type;
		this.path = new Dir("");
		this.working = new Dir("");
	}



	/**
	 * Name read-only
	 */
	@property string name() const
	{
		return this._name;
	}
	unittest {
		assert("fean" == (new Repository("fean", RepositoryType.GIT)).name);
	}



	/**
	 * Type read-only
	 */
	@property RepositoryType type() const
	{
		return this._type;
	}
	unittest {
		assert(RepositoryType.MERCURIAL == (new Repository("fean", RepositoryType.MERCURIAL)).type);
	}



	@property string full()
	{
		if (this.path && this.path.path.length) {
			return this.path.path ~ this.name;
		}
		return this.name;
	}
	
	
	string toString()
	{
		return format("%s, %s, full:[%s]", this.name, this.type, this.full);
	}


}
unittest {
	Repository repo = new Repository("huggies.git", RepositoryType.GIT);
	assert("huggies.git" == repo.name);
	assert("" == repo.path.path);
	assert("huggies.git" == repo.full);
}
unittest {
	Repository repo = new Repository("huggies.git", RepositoryType.GIT);
	repo.path = new Dir("foo/too");
	assert("huggies.git" == repo.name);
	assert("foo/too/" == repo.path.path);
	assert("foo/too/huggies.git" == repo.full);
}
unittest {
	Repository repo = new Repository("huggies.git", RepositoryType.GIT);
	repo.path = new Dir("foo/too/");
	assert("huggies.git" == repo.name);
	assert("foo/too/" == repo.path.path);
	assert("foo/too/huggies.git" == repo.full);
}



/**
 * Přístup k repozitáři.
 */
class AccessRepository
{
	RepositoryType type;

	string name;

	Permission permission;

	this(string name, RepositoryType type, Permission perm)
	{
		this.name = name;
		this.type = type;
		this.permission = perm;
	}
}



/**
 *	Oprávnění.
 */
enum Permission
{
	/**
	 * Možnost zakládat repozitář.
	 */
	DENY = 0,
	INIT = 1, // může repozitáře vytvářet
	READ = 2,
	WRITE = 4,
	REMOVE = 8
	
}



/**
 *	Přiřazení oprávnění uživatelům.
 */
class Access
{
	Permission permission;
	User[] users;
}



/**
 *	Přiřazení oprávnění, repozitářů, skupin uživatelů a uživatelů.
 */
class Acl
{
	/**
	 * Ke kterým repozitářům se to vztahuje.
	 */
	Repository[] repositories;

	/**
	 * Seskupené oprávnění pro uživatele.
	 */
	Access[] access;
}
