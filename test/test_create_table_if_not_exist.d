
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

@("orm: create_table_if_not_exists")
unittest
{

	struct Person
	{
		@SQL string name;
		@SQL int age;
		@SQL double height;
		@SQL string hobby;
		@SQL Date bithday;
		@SQL DateTime test;
		@SQL bool married;
		@SQL uint test_uint; 
	}

	Person[2] people;

	libsql_rows_t rows;

	const string url= environment.get("LIBSQL_URL",":memory:");
	writeln("url=",url);

	const auth_token=  environment.get("LIBSQL_AUTH_TOKEN","");
	
	auto client= new LibsqlClient();
	
	client.connect(url,auth_token,true);

	const string table_name="Persons5";

  auto table = new SQLTable!Person(client,table_name);

  table.drop_if_exists();
  
  table.create_if_not_exists();
 
  
	people[0] = Person("Paul", 52, 174.5,"chess",Date(1972,3,1), DateTime(2000, 6, 1, 10, 30, 0),true,3);
	people[1] = Person("Laura",49, 161.0,"dancing",Date(1975,8,6),DateTime(2001, 7, 1, 11, 32, 5),false,5);

	
foreach (p; people)
	{
		table.insert(p);
	}

	rows=client.query("SELECT * FROM Persons5;");


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

	libsql_free_rows(rows);
	
}
