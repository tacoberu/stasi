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
import std.conv;
import std.stdio;



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
	 * Seznam uživatelů.
	 */
	public User[] users;



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
	// function getUserList();




}

/**
 * Čistě čtení xml souboru s uloženou konfigurací. Nijak nezohlednuje nastavení
 * předané skrze příkazovou řádku, nebo tak něco.
 * /
class ConfigXmlReader : IConfigReader
{

	/**
	 *	Xml instance.
	 * /
	private source;


	/**
	 *	Kde soubor s definicí konfigurace.
	 * /
	private location;


	/**
	 *	Instance readeru obaluje soubor.
	 * /
	public function __construct(location)
	{
		if (!file_exists(location)) {
			throw new \InvalidArgumentException('File [' . location . '] not found.');
		}
		this.location = location;
	}



	/**
	 *	Verze schematu xmlka.
	 *	@return string
	 * /
	public function getUserList()
	{
		source = this.getSource();
		response = array();
		foreach (source.xpath('staci:user') as node) {
			node.registerXPathNamespace('staci', 'urn:nermal/staci');
			node.registerXPathNamespace('contact', 'urn:nermal/contact');

			entry = (object) array (
					'ident' => (string)node['name'],
					'firstname' => self::xmlContent(node, 'contact:firstname'),
					'lastname' => self::xmlContent(node, 'contact:lastname'),
					'email' => self::xmlContent(node, 'contact:email'),
					'permission' => array(),
					);

			foreach (node.xpath('staci:access/staci:permission') as perm) {
				entry.permission[] = (string)perm;
			}
			response[] = entry;
		}

		return response;
	}



	/**
	 * @return ...
	 * /
	public function getRepoPath()
	{
		source = this.getSource();
		path = source.xpath('staci:setting/staci:repo-path');
		if (isset(path[0])) {
			return (string)path[0];
		}
		throw new \RuntimeException('repo-path not setting');
	}


	/**
	 *	Lazy loading configurace.
	 * /
	private function getSource()
	{
		if (empty(this.source)) {
			source = \simplexml_load_file(this.location);
			source.registerXPathNamespace('staci', 'urn:nermal/staci');
			source.registerXPathNamespace('contact', 'urn:nermal/contact');
			this.source = source;
		}

		return this.source;
	}



	/**
	 * @param SimpleXmlElement xml uzel, ve kterém vyhledáváme.
	 * @param stirng xpath Cesta.
	 *
	 * @return string
	 * /
	private static function xmlContent(node, xpath)
	{
		el = node.xpath(xpath);
		if (isset(el[0])) {
			return (string)el[0];
		}
	}


}
*/



/**
 * Vytvoření projektu ze xml souboru.
 */
class XmlParser
{
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
	
	
	
	/**
	 * Zpracuje retězec na xml a výsledkem je instance schematu Projektu.
	 */
	Config fill(Config config, string s)
	{
		writefln("parsing...");
		check(s);

//		ProjectDefine response = new ProjectDefine();

		auto xml = new DocumentParser(s);
writeln(xml.tag.type);
writeln(xml.tag.name);
writeln(xml.tag.attr);
writeln("------------------------");

		xml.onStartTag["s:group"] = (ElementParser xml)
		{
			string groupname = xml.tag.attr["name"];
			
			writeln("s:group: ", groupname);
			if (groupname in this.groups) {
				writefln("cau group už existuje ------");
//				this.groups[groupname].users ~= 
			}
			else {
				this.groups[groupname] = new _Group(groupname);
			}
/*
//			xml.onStartTag["s:user"] = (ElementParser xml)
			xml.onEndTag["task"] = (in Element e) {
			{
				writefln("s:user: [%s]", e.tag.attr["ref"]);
				this.groups[groupname].users ~= e.tag.attr["ref"];
			};
//			xml.parse();

//*/
			//response.identity = new IdentityDefine();
			xml.onEndTag["s:user"] = (in Element e) {
				writefln("s:user: [%s]", xml.tag.attr["ref"]);
				this.groups[groupname].users ~= xml.tag.attr["ref"];
			};
/*
			xml.onEndTag["vendor"] = (in Element e) {
				response.identity.vendor = e.text();
			};
			xml.onEndTag["author"] = (in Element e) {
				response.identity.author = e.text();
			};
			xml.onEndTag["description"] = (in Element e) {
				response.identity.description = e.text();
			};
			xml.onEndTag["version"] = (in Element e) {
				string[] v = split(e.text(), ".");
				if (v.length == 3) {
					response.identity._version = new VersionDefine(to!int(v[0]), to!int(v[1]), to!int(v[2]));
				}
			};*/

			xml.parse();
		};

/*
		xml.onStartTag["s:user"] = (ElementParser xml)
		{
			User u = new User(xml.tag.attr["name"]);
			

			config.users ~= u;
			xml.parse();
		};

/*
		xml.onStartTag["goals"] = (ElementParser xml)
		{
			xml.onStartTag["goal"] = (ElementParser xml)
			{
				GoalDefine g = new GoalDefine("");
				g.name = xml.tag.attr["name"];
				g.description = xml.tag.attr["description"];
				if ("depends" in xml.tag.attr) {
					string[] depends = split(xml.tag.attr["depends"], ",");
					foreach (string depend; depends) {
						g.addDependency(strip(depend));
					}
				}

				xml.onStartTag["task"] = (ElementParser xml)
				{
					TaskDefine t = new TaskDefine(xml.tag.attr["type"], "");
					xml.onEndTag["task"] = (in Element e) {
						if (e.elements.length > 0) {
							throw new Exception("Zatim neimplementováno parsování složitějšího obsahu.");
						}
						else {
							GenericTaskLocalParams local = new GenericTaskLocalParams();
							local.content = e.text();
							t.content = local;
						}
					};
					xml.parse();

					g.tasks ~= t;
				};
				xml.parse();

				response.goals[g.name] = g;
			};
			xml.parse();

		};
		* 
		* */
		xml.parse();

		return config;
	}

}
unittest {
		string s = "<?xml version=\"1.0\"?>
<s:staci xmlns:s=\"urn:nermal/staci\"
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
		- ->
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

	-->
	<!--
		Definice repositářů, jejiích umístění, jejich speciální konfigurace.
		-->
	<s:repo name=\"staci-admin\" type=\"git\">
		<s:repo-path>repository/stasi-admin</s:repo-path>
		<s:working-path>.config/stasi</s:working-path>
	</s:repo>
	<s:repo name=\"staci.git\" type=\"git\">
		<s:working-path>Development/lab/working</s:working-path>
	</s:repo>
	<s:repo name=\"testing.git\" type=\"git\" />
	<s:repo name=\"projekt51\" type=\"git\" />
	<s:repo name=\"zizkov.hg\" type=\"mercurial\" />
	<s:repo name=\"koralky.hg\" type=\"mercurial\" />


	<!--
		Definice kdo může k jakému repozitáři s jakými právy.
		-->
	<s:acl>
		<!--
			Repozitář, který spravuje přístupy.
			-->
		<s:repository ref=\"staci-admin\" />
		<s:access permission=\"read,write,remove\">
			<s:xgroup ref=\"admins\" />
		</s:access>	
	</s:acl>


	<!--
	repo testing
		RW+     =   @all
		-->
	<s:acl>
		<s:repository ref=\"testing.git\" />
		<s:access permission=\"init,read,write,remove\">
			<s:xgroup ref=\"all\" />
		</s:access>	
	</s:acl>


	<!--
	repo projekt51 zizkov
		RW+ = michal taco
		RW  = @vyvojari
		R   = @testeri
		-->
	<s:acl>
		<s:repository ref=\"projekt51.git\" />
		<s:repository ref=\"zizkov.hg\" />
		<s:access permission=\"init,read,write,remove\">
			<s:xuser ref=\"michal\" />
			<s:xuser ref=\"taco\" />
		</s:access>	
		<s:access permission=\"read,write\">
			<s:xgroup ref=\"vyvojari\" />
		</s:access>	
		<s:access permission=\"read\">
			<s:xgroup ref=\"testeri\" />
		</s:access>	
	</s:acl>


	<!--
	repo koralky
		RW+     =   taco
		-->
	<s:acl>
		<s:repository ref=\"koralky.hg\" />
		<s:access permission=\"init,read,write,remove\">
			<s:user ref=\"taco\" />
		</s:access>	
	</s:acl>
    

	<s:acl>
		<s:repository ref=\"staci.git\" />
		<s:access permission=\"init,read,write,remove\">
			<s:user ref=\"taco\" />
			<s:user ref=\"vojta\" />
		</s:access>	
	</s:acl>


</s:staci>";

	XmlParser parser = new XmlParser();
    Config config = parser.fill(new Config(["main", "build", "install"]), s);
	
	//assert(config.users.length == 3, "Celkem naimportovaných uživatelů.");
	//assert(config.users[0].name == "taco", "Jméno uživatele");
	//assert(config.users[1].name == "mira", "Jméno uživatele");
	//assert(config.users[2].name == "fean", "Jméno uživatele");
	//assert(project.identity.vendor == "taco", "Jméno vendoru.");
	//assert(project.identity.author == "Martin Takáč", "Autor.");
	//assert(project.identity._version.major == 0, "Major version");
	//assert(project.identity._version.minor == 0, "Minor version");
	//assert(project.identity._version.release == 1, "Release version");
	//assert(project.identity.description == "Builder sám na sebe.", "Popisek");

	//assert(project.goals.length == 3, "Počet targetů.");
	//assert(project.goals["update"].name == "update", "První target.");
	//assert(project.goals["push"].name == "push", "Druhý target.");
	//assert(project.goals["compile"].name == "compile", "Třetí target.");

	//assert(project.goals["update"].tasks.length == 2, "Počet tasků.");
	//assert(project.goals["push"].tasks.length == 1, "Počet tasků.");
	//assert(project.goals["compile"].tasks.length == 1, "Počet tasků.");

//	writeln(project.goals[0].tasks[0].type);
	//assert(project.goals["update"].tasks[0].type == "vcs.pull", "Task vcs.pull.");
	//assert(project.goals["update"].tasks[1].type == "vcs.update", "Task vcs.update.");
	//assert(project.goals["push"].tasks[0].type == "vcs.push", "Task vcs.push.");
	//assert(project.goals["compile"].tasks[0].type == "compile.compile", "Task compile.compile.");

}


