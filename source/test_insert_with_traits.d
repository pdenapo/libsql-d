
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
import std.datetime.date;

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
		Date bithday;
		DateTime test;
		//bool married; // TODO: support boolean
	}

	Person[2] people;

	libsql_rows_t rows;

	const string url= environment.get("LIBSQL_URL",":memory:");
	writeln("url=",url);

	const auth_token=  environment.get("LIBSQL_AUTH_TOKEN","");
	
	auto client= new LibsqlClient(url,auth_token,true);

  const string drop_table="DROP TABLE IF EXISTS Persons5;";
	client.execute(drop_table);

  client.create_table!Person("Persons5");
  
	//people[0] = Person("Paul", 52, 174.5,"chess",Date(1972,3,1), DateTime(2000, 6, 1, 10, 30, 0),true);
	//people[1] = Person("Laura",49, 161.0,"dancing",Date(1975,8,6),DateTime(2001, 7, 1, 11, 32, 5),false);

  people[0] = Person("Paul", 52, 174.5,"chess",Date(1972,3,1), DateTime(2000, 6, 1, 10, 30, 0));
	people[1] = Person("Laura",49, 161.0,"dancing",Date(1975,8,6),DateTime(2001, 7, 1, 11, 32, 5));
	
	foreach (p; people)
	{
		client.insert!Person(p,"Persons5");
	}

	rows=client.query("SELECT * FROM Persons5;");
	
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
