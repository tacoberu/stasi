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

import stasi.config;

import std.stdio;
import std.file;


/**
 *	Model.
 */
class ModelBuilder
{

	private Config config;


	private Application _application;


	/**
	 * @param model, config
	 */
	this(Config config)
	{
		this.config = config;
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
		Application app = new Application();
		app.setHomePath(this.config.getHomePath());
		//app.setRepositoryPath(this.config.getRepoPath());

		string s = cast(string)std.file.read(this.config.getAclFile());
		IConfigReader reader = new ConfigXmlReader(s);
		this.config = reader.fill(this.config);

		foreach (u; this.config.users) {
			app.users ~= u;
		}

		foreach (r; this.config.repositories) {
			app.repositories ~= r;
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
	 * Cesta k úložišti repozitářů.
	 * @return string
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
				//writefln("user: %s", u.name);
				//	Najdem repozitář
				foreach (r; u.repositories) {
					if ((r.name == repository.name) && (r.type == repository.type)) {
						//writefln("  repo: %s", r.name);
						//	Zkontrolujem oprávnění.
						if (perm & r.permission) {
							//writefln("    povoleno");
							return true;
						}
						//writefln("    odmíntuto");
						return false;
					}
				}
			}
		}
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
