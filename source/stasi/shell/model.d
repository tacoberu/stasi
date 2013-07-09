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

import stasi.config;

import std.stdio;
import std.file;
import std.string;


/**
 *	Model.
 */
class ModelBuilder
{

	private Config config;
	
	
	private Logger logger;


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
		string s = cast(string)std.file.read(this.config.getAclFile());
		this.logger.info(format("configure load from file: [%s]", this.config.getAclFile()), "configuration");
		
		IConfigReader reader = new ConfigXmlReader(s);
		this.config = reader.fill(this.config);

		Application app = (new Application())
			.setLogger(this.logger)
			.setHomePath(this.config.getHomePath())
			.setDefaultRepositoryPath(this.config.defaultRepositoryPath)
			.setDefaultWorkingPath(this.config.defaultWorkingPath);

		this.logger.log(format("configure: home path: [%s]", this.config.getHomePath()), "configuration");
		this.logger.log(format("configure: default repository path path: [%s]", this.config.defaultRepositoryPath), "configuration");
		this.logger.log(format("configure: default working path: [%s]", this.config.defaultWorkingPath), "configuration");

		foreach (u; this.config.users) {
			app.users ~= u;
			this.logger.log(format("configure: user: [%s]", u.name), "configuration");
		}

		foreach (r; this.config.repositories) {
			app.repositories ~= r;
			this.logger.log(format("configure: repository: [%s]", r.name), "configuration");
		}

		return app;
	}



}



/**
 *	Zpracovává příkazy na request.
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
	unittest {
		Application app = (new Application()).setDefaultRepositoryPath("repos");
		assert("repos", app.getDefaultRepositoryPath());
	}



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
	 * @param string
	 * /
	function doNormalizeRepository(repo, type)
	{
		full = this->homePath . '/' . repo;

		//	Existence souboru
		if (! is_writable(full)) {
			throw new \RuntimeException("Repo [repo] is not exists.");
		}

		switch(type) {
			case 'git':
				this->doNormalizeAssignHooksGit(full);
				break;
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
}



/**
 *	Uživatel.
 */
class User
{
	private string _name;
	string firstname;
	string lastname;
	string email;
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
		assert("fean", (new User("fean")).name);
	}

}
unittest {
	User u = new User("taco");
	assert("taco", u.name);
	assert("taco", u.email);
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
	RepositoryType type;

	string name;

	string path = "";

	this(string name, RepositoryType type)
	{
		this.name = name;
		this.type = type;
	}

	@property string full()
	{
		return this.path ~ this.name;
	}
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


enum Permission
{
	/**
	 * Možnost zakládat repozitář.
	 */
	DENY = 0,
	INIT = 1,
	READ = 2,
	WRITE = 4,
	REMOVE = 8
	
}


/**
 *	Oprvánění.
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
