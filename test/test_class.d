
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

@("orm: create_table_if_not_exists using classes")
unittest
{

	class Person
	{
		@SQL string name; 
		@SQL int age;

		this(string name,int age)
		{
		 this.name=name;
		 this.age=age;
		}
	}

	Person[2] people;
	const table_name="Persons6";

	libsql_rows_t rows;

	const string url= environment.get("LIBSQL_URL",":memory:");
	writeln("url=",url);

	const auth_token=  environment.get("LIBSQL_AUTH_TOKEN","");
	
	auto client= new LibsqlClient();
	
	client.connect(url,auth_token,true);

  client.drop_table_if_exists(table_name);
  
  client.create_table_if_not_exists!Person(table_name);
  
	people[0] = new Person("Paul", 52);
	people[1] = new Person("Laura",49);

	
foreach (p; people)
	{
		client.insert!Person(p,table_name);
	}

	rows=client.query("SELECT * FROM "~ table_name~ ";");


  int retval;
	char* err;
	libsql_row_t row;
	int i=0;

	while ((retval = libsql_next_row(rows, &row, &err)) == 0)
	{
 	Person someone;
	 if (retval != 0)
		{
			throw new Exception(to!string(err));
		}
		if (!row)
			break;
		someone= client.get!Person(row);
		writeln(someone);
		assert(someone == people[i]);
		i++;
	}


	
	// Json json_rows = rows_to_Json(rows);
	// writeln(json_rows);
	// int i = 0;
	// foreach (json_row; json_rows)
	// {
	// 	Person someone = deserializeJson!Person(json_row);
	// 	assert(someone == people[i]);
	// 	writeln(someone);
	// 	i++;
	// }

	//libsql_free_rows(rows);
	
}
