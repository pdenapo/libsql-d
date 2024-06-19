
module libsql.traits;

import libsql.deimos;
import libsql.json;
import libsql.utils;
import libsql.orm;
import core.stdc.stdio;
import std.string:toStringz;
import std.stdio;
import vibe.data.json;
import std.conv;
import std.process:environment;

// Test using some D constructions

@("Persons with D and prepared statements and traits")
unittest
{

	struct Person
	{
		string name;
		int age;
		double height;
		string hobby;
	}

	Person[2] people;

	libsql_rows_t rows;

	const string url= environment.get("LIBSQL_URL",":memory:");
	writeln("url=",url);

	const auth_token=  environment.get("LIBSQL_AUTH_TOKEN","");
	
	auto client= new LibsqlClient(url,auth_token,true);

  const string drop_table="DROP TABLE IF EXISTS Persons4;";
	client.execute(drop_table);

  client.create_table!Person("Persons4");
  
	char *err;

	people[0] = Person("Paul", 20, 174.5,"chess");
	people[1] = Person("Laura", 30, 161.0,"dancing");
	foreach (p; people)
	{
		client.insert!Person(p,"Persons4");
	}

	rows=client.query("SELECT * FROM Persons4;");
	
	Json json_rows = rows_to_Json(rows);
	writeln(json_rows);
	int i = 0;
	foreach (json_row; json_rows)
	{
		Person someone = deserializeJson!Person(json_row);
		assert(someone == people[i]);
		writeln(someone);
		i++;
	}

	libsql_free_rows(rows);
	
}
