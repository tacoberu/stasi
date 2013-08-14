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




interface IModel
{


	/**
	 * Zda se uživatel může skrze shell přihlašovat na server.
	 * @todo
	 */
	bool isAllowedSignin(User user);


	/**
	 * Zda uživatel může přistupovat k repozitáři.
	 */
	bool isAllowed(User user, Repository repository, Permission perm);


	/**
	 * Získání repozitáře podle jména.
	 */
	Repository getRepositoryByName(string name);


	/**
	 * Existence repozitáře.
	 */
	bool hasRepository(string name);


}



interface IModelBuilder
{

	/**
	 * Getted or Created Application
	 */
	@property Application application();


	/**
	 * Getted Condif
	 */
	@property Config config();// const

}



/**
 *	Továrna na modely.
 */
class ModelBuilder : IModelBuilder 
{

	/**
	 * Nastavení aplikace, práv, uživatelů, repozitářů.
	 */
	private Config _config;
	
	
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
		this._config = config;
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
	 * Getted Condif
	 */
	@property Config config() // const
	{
		return this._config;
	}



	/**
	 * Create new Application
	 */
	Application createApplication()
	{
		string s = cast(string)std.file.read(this.config.configFile);
		this.logger.info(format("load file: [%s]", this.config.configFile), "configuration");
		
		IConfigReader reader = new ConfigXmlReader(s);
		this._config = reader.fill(this.config);

		Application app = new Application(this.config.homePath);
		app.logger = this.logger;
		app.defaultRepositoryPath = this.config.defaultRepositoryPath;
		app.defaultWorkingPath = this.config.defaultWorkingPath;

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
class Application : IModel
{

	const VERSION = "0.0.4";


	/**
	 * Seznam oprávnění.
	 */
	Acl[] acls;


	/**
	 * Cesta k defaultnímu umístění repozitářů.
	 */
	Dir defaultRepositoryPath;
	
	
	/**
	 * Cesta k defaultnímu umístění pískoviště repozitářů.
	 */
	Dir defaultWorkingPath;
	

	/**
	 * Cesta k domácímu adresáři.
	 */
	Dir homePath;


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
	private ILogger _logger;


	/**
	 *	
	 */
	this(Dir homePath)
	{
		this.homePath = homePath;
	}



	/**
	 * Přiřazení logovadla.
	 */
	@property Application logger(Logger m)
	{
		this._logger = m;
		return this;
	}



	/**
	 * Získání loggeru, nového, nebo oposledně vytvořeneého.
	 */
	@property ILogger logger()
	{
		if (! this._logger) {
			this._logger = this.createLogger();
		}
		return this._logger;
	}



	/**
	 * Vytvoření nového loggeru.
	 */
	ILogger createLogger()
	{
		return new Logger();
	}



	/**
	 * Cesta k úložišti repozitářů.
	 */
	Application setHomePath(Dir path)
	{
		this.homePath = path;
		return this;
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
	//	Žádní uživatele, zádné repozitáře - nemůže přistupovat.
	unittest {
		Application app = new Application(new Dir("."));
		assert(false == app.isAllowed(new User("foo"), new Repository("pokus.git", RepositoryType.GIT), Permission.READ));
	}
	unittest {
		Application app = new Application(new Dir("."));
		User user = new User("foo");
		user.repositories["pokus.git"] = new AccessRepository("pokus.git", RepositoryType.GIT, Permission.READ);
		user.repositories["druhej.hg"] = new AccessRepository("druhej.hg", RepositoryType.MERCURIAL, Permission.READ | Permission.WRITE | Permission.REMOVE);
		app.users ~= user;
		assert(2 == user.repositories.length);
		//assert(true == app.isAllowed(new User("foo"), new Repository("pokus.git", RepositoryType.GIT), Permission.READ));
		//assert(false == app.isAllowed(new User("foo"), new Repository("pokus.git", RepositoryType.GIT), Permission.WRITE));
		//assert(app.isAllowed(new User("foo"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.WRITE));
		//assert(app.isAllowed(new User("foo"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.READ));
		//assert(! app.isAllowed(new User("foo"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.INIT));
		//assert(! app.isAllowed(new User("too"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.WRITE));
		//assert(! app.isAllowed(new User("too"), new Repository("druhej.hg", RepositoryType.MERCURIAL), Permission.READ));
	}



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
	 * Pokud repozitář neexistuje, tak jej vytvoří.
	 */
	void doExistRepository(Repository repo, RepositoryType type)
	{
		string dest = this.homePath.path ~ repo.full;
		
		//	Existence souboru
		if (! std.file.exists(dest)) {
			this.getAdapterModel(repo, type).doCreateRepository(repo);
		}
	}



	/**
	 * Ověření konzistence repozitáře. To znamená, zda
	 * - je bare
	 * - má nastavené defaultní hooky
	 * - ...
	 */
	void doNormalizeRepository(Repository repo, RepositoryType type)
	{
		this.getAdapterModel(repo, type).doNormalizeRepository(repo);
	}



	/**
	 * Získání adapteru pro práci s konkrétním typem repozitáře.
	 */
	private IAdapterModel getAdapterModel(Repository repo, RepositoryType type)
	{
		final switch(type) {
			case RepositoryType.GIT:
				return new stasi.adapters.git.Model(this.homePath);
			case RepositoryType.MERCURIAL:
				return new stasi.adapters.mercurial.Model(this.homePath);
			case RepositoryType.UNKNOW:
				throw new Exception(format("Unknow type repository and not exists: [%s]", repo));
		}
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
 * Přístup k repozitáři. Komu se tento objekt přiřadí, ten má taková prava 
 * k takovému repozitáři.
 */
class AccessRepository
{
	RepositoryType type;

	string name;

	Permission permission;

	/**
	 * @param string name Jméno repozitáře, například: stasi.git
	 * @param type Typ repozitáře, například: git
	 * @param perm Povolené přístupy. Čtení, nebo i zápis.
	 */
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







/**
 * Práce s git repozitářem.
 */
interface IAdapterModel
{

	/**
	 * Vytvoření repozitáře.
	 * Git křičí, když je vytvořený prázdný repozitář. Proto tam hodíme první komit.
	 * Také je potřeba nastavit git, aby přijímal příchozí commity.
	 * 
	 * Ono to také může bejt tak, že chceme přiřadit již exustující repozitář. To pak musím udělat jinak. @TODO
	 */
	void doCreateRepository(Repository repo);



	/**
	 * Zohlední změněné hooky v repozitáři.
	 */
	void doNormalizeRepository(Repository repo);


}
