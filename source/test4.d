
module source.test4;

import libsql.deimos;
import libsql.json;
import libsql.utils;
import core.stdc.stdio;
import std.string:toStringz;
import std.stdio;
import vibe.data.json;
import std.conv;
import std.process:environment;

// Test using some D constructions

@("Persons with D and prepared statements")
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
  
	const string create_table = "CREATE TABLE Persons4(
	name TEXT,
	age INTEGER,
	height REAL,
	hobby TEXT
	);";

	client.execute(create_table);

	libsql_stmt_t insert_stmt;
	char *err;

	const insert_sql = "INSERT INTO Persons4 VALUES (?,?,?,?)";

	int retval=libsql_prepare(client.conn, toStringz(insert_sql), &insert_stmt, &err);
	if (retval != 0) throw new Exception("libsql_prepare error:"~ to!string(err));

	
	void insert_person(Person p)
	{
		//const sql = "INSERT INTO Persons4 VALUES ('" ~ p.name ~ "'," ~ to!string(
		//	p.age) ~ "," ~ to!string(p.height) ~",'" ~ to!string(p.hobby) ~ "');";

		debug writeln("insert_person",p);
		char* err;
		int retval=libsql_bind_string(insert_stmt,1, toStringz(p.name), &err);
		if (retval != 0) throw new Exception("libsql_bind_string:"~ to!string(err));
		
		retval=libsql_bind_int(insert_stmt,2, p.age, &err);
		if (retval != 0) throw new Exception("libsql_bind_int:"~ to!string(err));

		retval=libsql_bind_float(insert_stmt,3, p.height, &err);
		if (retval != 0) throw new Exception("libsql_bind_float:"~ to!string(err));

		retval=libsql_bind_string(insert_stmt,4, toStringz(p.hobby), &err);
		if (retval != 0) throw new Exception("libsql_bind_string:"~ to!string(err));

		retval= libsql_execute_stmt(insert_stmt, &err);
		if (retval != 0) throw new Exception("libsql_execute_stmt:"~ to!string(err));

		retval= libsql_reset_stmt(insert_stmt, &err);
		if (retval != 0) throw new Exception("libsql_reset_stmt:"~ to!string(err));

	}


	people[0] = Person("Paul", 20, 174.5,"chess");
	people[1] = Person("Laura", 30, 161.0,"dancing");
	foreach (p; people)
	{
		insert_person(p);
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
	libsql_free_stmt(insert_stmt);
}
