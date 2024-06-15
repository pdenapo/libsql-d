module source.test3;

import libsql_deimos;
import libsql_json;
import core.stdc.stdio;
import std.string;
import std.stdio;
import vibe.data.json;
import std.conv;

@("Persons with Json")
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

	libsql_database_t db;
	libsql_connection_t conn;
	char* err = null;
	int retval = 0;
	libsql_rows_t rows;
	libsql_row_t row;
	int num_cols;

	void insert_person(Person p)
	{
		const sql = "INSERT INTO Persons VALUES ('" ~ p.name ~ "'," ~ to!string(
			p.age) ~ "," ~ to!string(p.height) ~",'" ~ to!string(p.hobby) ~ "');";
		writeln(sql);
		retval = libsql_execute(conn, toStringz(sql), &err);
		if (retval != 0)
		{
			fprintf(core.stdc.stdio.stderr, "%s\n", err);
		}
		assert(retval == 0);
	}

	retval = libsql_open_ext(":memory:", &db, &err);
	if (retval != 0)
	{
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
	}
	assert(retval == 0);

	retval = libsql_connect(db, &conn, &err);
	if (retval != 0)
	{
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
	}
	assert(retval == 0);

	const string create_table = "CREATE TABLE Persons(
	name TEXT,
	age INTEGER,
	height REAL,
	hobby TEXT
	);";

	retval = libsql_execute(conn, toStringz(create_table), &err);
	assert(retval == 0);

	people[0] = Person("Paul", 20, 174.5,"chess");
	people[1] = Person("Laura", 30, 161.0,"dancing");
	foreach (p; people)
	{
		insert_person(p);
	}

	retval = libsql_query(conn, "SELECT * FROM Persons;", &rows, &err);
	if (retval != 0)
	{
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
	}
	assert(retval == 0);
	
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

quit:
	libsql_free_rows(rows);
	libsql_disconnect(conn);
	libsql_close(db);
}
