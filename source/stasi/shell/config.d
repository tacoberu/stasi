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

module stasi.config;

import stasi.model;

import std.process;
import std.xml;
//import std.conv;
import std.stdio;
import std.array;
import std.string;



/**
 * Neplatný formát configuračního souboru.
 */
class InvalidConfigException : Exception
{
	this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}



/**
 * Nastavení programu.
 */
class Config
{

	/**
	 * Zpracovaný seznam akcí.
	 */
	private string home;



	/**
	 * Seznam uživatelů. Uživatel je jedinečnej podle svého jména.
	 */
	public User[string] users;



	/**
	 * Seznam repositářů. Repozitář je jedinečnej podle svého jména.
	 */
	public Repository[string] repositories;



	/**
	 * Konstruktorem předám parametry z CLI.
	 */
	this (string[] args)
	{
		this.home = environment.get("HOME");
	}


	/**
	 * Cesta ke kořeni domovského adresáře.
	 */
	Config setHomePath(string m)
	{
		//ret = rtrim(ret, '/\\');
		this.home = m;
		return this;
	}



	/**
	 * Cesta ke kořeni domovského adresáře.
	 *
	 * @return string
	 */
	string getHomePath()
	{
		//ret = rtrim(ret, '/\\');
		return this.home;
	}
	unittest {
		Config c = (new Config(["main", "build", "install"])).setHomePath("/home/stasi");
		assert(c.getHomePath(), "/home/stasi");
	}


	/**
	 * Cesta k souboru s nastavení acl.
	 *
	 * @return string
	 */
	string getAclFile()
	{
		return this.getHomePath() ~ "/.config/stasi/access.xml";
	}
	unittest {
		Config c = (new Config(["main", "build", "install"])).setHomePath("/home/stasi");
		assert(c.getAclFile(), "/home/stasi/.config/stasi/access.xml");
	}



}




/**
 *	Konkrétní konfigurace balíčku.
 */
interface IConfigReader
{


	/**
	 *	Seznam uživatelů.
	 *	@return array
	 */
	Config fill(Config config);




}

/**
 * Čistě čtení xml souboru s uloženou konfigurací. Nijak nezohlednuje nastavení
 * předané skrze příkazovou řádku, nebo tak něco.
 */
class ConfigXmlReader : IConfigReader
{

	private string content;


	class _Group
	{
		string name;
		string[] users;
		this(string name)
		{
			this.name = name;
		}
	}

	/**
	 * Skupiny si zpracováváme interně.
	 */
	private _Group[string] groups;


	this(string s)
	{
		this.content = s;
	}

	/**
	 * Překlad názvu na enum.
	 */
	private RepositoryType parseRepositoryType(string s)
	{
		switch(s) {
			case "git":
				return RepositoryType.GIT;
			case "hg":
			case "mercurial":
				return RepositoryType.MERCURIAL;
			default:
				return RepositoryType.UNKNOW;
		}
	}


	/**
	 * Zpracuje retězec na xml a výsledkem je instance schematu Projektu.
	 */
	Config fill(Config config)
	{
		string nsstaci = "s:";
		string nscontact = "c:";

		check(this.content);

		auto xml = new DocumentParser(this.content);

		//	Zpracování NS.
		foreach (k, ns; xml.tag.attr) {
			switch (ns) {
				case "urn:nermal/stasi":
					nsstaci = k[6 .. $] ~ ":";
					break;
				case "urn:nermal/contact":
					nscontact = k[6 .. $] ~ ":";
					break;
				default:
					break;
			}
		}

		//	Nejdříve skupiny a uživatele a repozitáře
		xml.onStartTag[nsstaci ~ "group"] = (ElementParser xml)
		{
			string groupname = xml.tag.attr["name"];
			if (groupname in this.groups) {
				writefln("cau group už existuje ------");
			}
			else {
				this.groups[groupname] = new _Group(groupname);
			}

			xml.onStartTag[nsstaci ~ "user"] = (ElementParser xml)
			{
				this.groups[groupname].users ~= xml.tag.attr["ref"];
				xml.parse();
			};

			xml.parse();
		};

		xml.onStartTag[nsstaci ~ "user"] = (ElementParser xml)
		{
			if ("name" in xml.tag.attr) {
				config.users[xml.tag.attr["name"]] = new User(xml.tag.attr["name"]);
			}

			xml.parse();
		};

		xml.onStartTag[nsstaci ~ "repository"] = (ElementParser xml)
		{
			if (("name" in xml.tag.attr) && ("type" in xml.tag.attr)) {
				config.repositories[xml.tag.attr["name"]] = new Repository(xml.tag.attr["name"], this.parseRepositoryType(xml.tag.attr["type"]));
			}

			xml.parse();
		};

		xml.onStartTag[nsstaci ~ "acl"] = (ElementParser xml)
		{
			xml.parse();
		};

		xml.parse();


		//	Nakonec vztahy mezi repozitáři a uživateli.
		xml = new DocumentParser(this.content);

		xml.onStartTag[null] = (ElementParser xml)
		{
			xml.parse();
		};

		xml.onStartTag[nsstaci ~ "acl"] = (ElementParser xml)
		{
			// Seznam repozitářů v tomto acl-ku.
			string[] repos;

			xml.onStartTag[nsstaci ~ "repository"] = (ElementParser xml)
			{
				repos ~= xml.tag.attr["ref"];
				xml.parse();
			};

			xml.onStartTag[nsstaci ~ "access"] = (ElementParser xml)
			{
				Permission perm = Permission.DENY;
				foreach (s; split(xml.tag.attr["permission"], ",")) {
					switch(s) {
						case "init":
							perm |= Permission.INIT;
							break;
						case "read":
							perm |= Permission.READ;
							break;
						case "write":
							perm |= Permission.WRITE;
							break;
						case "remove":
							perm |= Permission.REMOVE;
							break;
						default:
							break;
					}
				}

				xml.onStartTag[nsstaci ~ "user"] = (ElementParser xml)
				{
					string name = xml.tag.attr["ref"];
					foreach (repo; repos) {
						if (! (name in config.users)) {
							throw new InvalidConfigException(format("User [%s] is not declared.", name));
						}
						if (! (repo in config.repositories)) {
							throw new InvalidConfigException(format("Repository [%s] is not declared.", repo));
						}
						config.users[name]
							.repositories[repo] = new AccessRepository(
								repo,
								config.repositories[repo]
									.type, perm);
					}
					xml.parse();
				};
				xml.parse();
			};

			xml.parse();
		};

		xml.parse();

		return config;
	}

}
unittest {
		string s = "<?xml version=\"1.0\"?>
<s:stasi xmlns:s=\"urn:nermal/stasi\"
			xmlns:c=\"urn:nermal/contact\">

	<!--
		Skupina uživatelů
		-->
	<s:group name=\"admins\">
		<s:user ref=\"taco\" />
		<s:user ref=\"mira\" />
	</s:group>

	<s:group name=\"vyvojari\">
		<s:user ref=\"taco\" />
		<s:user ref=\"mira\" />
		<s:user ref=\"fean\" />
	</s:group>



	<!--
		Definice konkrétních uživatelů. Definujeme email a ssh. Klíčů může být
		vícero, protože pod stejným jménem se může přihlašovat z více míst.
		-->
	<s:user name=\"taco\">
		<c:firstname>Martin</c:firstname>
		<c:lastname>Takáč</c:lastname>
		<c:email>mt@taco-beru.name</c:email>
		<s:ssh type=\"dsa\">ssh-dss AAAAB3NzaC1kc3MAAACBA...l6yXMPCoEtM6WGJWo5vxA== taco@taco.example.cz</s:ssh>
		<s:ssh type=\"dsa\">ssh-dss AAAAB3NzaA1kc3MAAACBAIX...66tl5l6yXMPCoEtM6WGJWo5vxA== taco@home.localhost</s:ssh>
	</s:user>

	<s:user name=\"mira\">
		<c:firstname>Miroslav</c:firstname>
		<c:lastname>Falco</c:lastname>
		<c:email>mf@taco-beru.name</c:email>
		<s:ssh type=\"dsa\">ssh-dss AAAAB3NzaC1kc3MAAACBAIXclzahWltq96N5cz3Rf...6yXMPCoEtM6WGJWo5vxA== taco@taco.example.cz</s:ssh>
	</s:user>

	<s:user name=\"fean\">
		<c:firstname>Andreaw</c:firstname>
		<c:lastname>Fean</c:lastname>
		<c:email>mt@taco-beru.name</c:email>
		<s:ssh type=\"dsa\">ssh-dss AAAAB3NzaC1kc3MAAACBAIXcl...oEtM6WGJWo5vxA== taco@taco.example.cz</s:ssh>
	</s:user>

	<s:user name=\"michal\">
		<c:email>michal@example.org</c:email>
	</s:user>



	<!--
		Definice repositářů, jejiích umístění, jejich speciální konfigurace.
		-->
	<s:repository name=\"stasi-admin\" type=\"git\">
		<s:repo-path>repository/stasi-admin</s:repo-path>
		<s:working-path>.config/stasi</s:working-path>
	</s:repository>
	<s:repository name=\"stasi.git\" type=\"git\">
		<s:working-path>Development/lab/working</s:working-path>
	</s:repository>
	<s:repository name=\"testing.git\" type=\"git\" />
	<s:repository name=\"projekt51\" type=\"git\" />
	<s:repository name=\"zizkov.hg\" type=\"mercurial\" />
	<s:repository name=\"koralky.hg\" type=\"mercurial\" />


	<!--
		Definice kdo může k jakému repozitáři s jakými právy.
		-->
	<s:acl>
		<!--
			Repozitář, který spravuje přístupy.
			-->
		<s:repository ref=\"stasi-admin\" />
		<s:access permission=\"read,write,remove\">
			<s:group ref=\"admins\" />
		</s:access>
	</s:acl>


	<!--
	repo testing
		RW+     =   @all
		-->
	<s:acl>
		<s:repository ref=\"testing.git\" />
		<s:access permission=\"init,read,write,remove\">
			<s:group ref=\"all\" />
		</s:access>
	</s:acl>


	<!--
	repo projekt51 zizkov
		RW+ = michal taco
		RW  = @vyvojari
		R   = @testeri
		-->
	<s:acl>
		<s:repository ref=\"projekt51\" />
		<s:repository ref=\"zizkov.hg\" />
		<s:access permission=\"init,read,write,remove\">
			<s:user ref=\"michal\" />
			<s:user ref=\"taco\" />
		</s:access>
		<s:access permission=\"read,write\">
			<s:group ref=\"vyvojari\" />
		</s:access>
		<s:access permission=\"read\">
			<s:group ref=\"testeri\" />
			<s:user ref=\"fean\" />
		</s:access>
	</s:acl>


	<!--
	repo koralky
		RW+     =   taco
		-->
	<s:acl>
		<s:repository ref=\"koralky.hg\" />
		<s:access permission=\"read\">
			<s:user ref=\"taco\" />
		</s:access>
		<s:access permission=\"read,write\">
			<s:user ref=\"vojta\" />
		</s:access>
	</s:acl>


	<s:acl>
		<s:repository ref=\"stasi.git\" />
		<s:access permission=\"read,write\">
			<s:user ref=\"taco\" />
			<s:user ref=\"vojta\" />
			<s:user ref=\"fean\" />
		</s:access>
	</s:acl>


	<s:user name=\"vojta\">
		<c:email>vojta@example.org</c:email>
	</s:user>


</s:stasi>";

	ConfigXmlReader parser = new ConfigXmlReader(s);
    Config config = parser.fill(new Config([]));

	assert(config.users.length == 5, "Celkem naimportovaných uživatelů.");
	assert(config.users["taco"].name == "taco");
	assert(config.users["taco"].repositories.length == 4);
	assert(config.users["taco"].repositories["projekt51"].permission == (Permission.INIT | Permission.READ | Permission.WRITE | Permission.REMOVE));
	assert(config.users["taco"].repositories["stasi.git"].permission == (Permission.READ | Permission.WRITE));
	assert(config.users["taco"].repositories["koralky.hg"].permission == (Permission.READ));
	assert(config.users["mira"].name == "mira");
	assert(config.users["mira"].repositories.length == 0);
	assert(config.users["fean"].name == "fean");
	assert(config.users["fean"].repositories.length == 3);
	assert(config.users["fean"].repositories["projekt51"].permission == Permission.READ);
	assert(config.users["fean"].repositories["zizkov.hg"].permission == Permission.READ);
	assert(config.users["fean"].repositories["stasi.git"].permission == (Permission.READ | Permission.WRITE));

	assert(config.repositories.length == 6);
	assert(config.repositories["stasi-admin"].name == "stasi-admin");
	assert(config.repositories["stasi.git"].name == "stasi.git");
	assert(config.repositories["testing.git"].name == "testing.git");

}


