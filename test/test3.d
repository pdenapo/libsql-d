
module source.test3;

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

@("Persons with D")
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

	libsql_stmt_t insert_stmt;

	int libsql_prepare(libsql_connection_t conn, const char *sql, libsql_stmt_t *out_stmt, const char **out_err_msg);


	void insert_person(Person p, LibsqlClient client)
	{
		const sql = "INSERT INTO Persons3 VALUES ('" ~ p.name ~ "'," ~ to!string(
			p.age) ~ "," ~ to!string(p.height) ~",'" ~ to!string(p.hobby) ~ "');";
		client.execute(sql); 
	}

	const string url= environment.get("LIBSQL_URL",":memory:");
	writeln("url=",url);

	const auth_token=  environment.get("LIBSQL_AUTH_TOKEN","");
	
	auto client= new LibsqlClient();
	
	client.connect(url,auth_token,true);

  const string drop_table="DROP TABLE IF EXISTS Persons3;";
	client.execute(drop_table);
  
	const string create_table = "CREATE TABLE Persons3(
	name TEXT,
	age INTEGER,
	height REAL,
	hobby TEXT
	);";

	client.execute(create_table);

	people[0] = Person("Paul", 20, 174.5,"chess");
	people[1] = Person("Laura", 30, 161.0,"dancing");
	foreach (p; people)
	{
		insert_person(p,client);
	}

	rows=client.query("SELECT * FROM Persons3;");
	
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
