import libsql.deimos;
import libsql.utils;

import core.stdc.stdio;
import std.string:toStringz;
import std.stdio;
import std.process:environment;
import std.conv;

// A more realistic test, still using the C API.

@("Persons")
unittest {
	libsql_database_t db;
	libsql_connection_t conn;
	char *err = null;
	int retval = 0;
	libsql_rows_t rows;
	libsql_row_t row;
	int num_cols;

	const string url= environment.get("LIBSQL_URL",":memory:");
	writeln("url=",url);

	const auth_token=  environment.get("LIBSQL_AUTH_TOKEN","");

	retval = libsql_open_any(url,auth_token, &db, &err);	
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);

  retval = libsql_connect(db, &conn, &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);

 
 const string drop_table="DROP TABLE IF EXISTS Persons2;";
 std.stdio.stderr.writeln(drop_table);
 retval = libsql_execute(conn,toStringz(drop_table), &err);
 if (retval != 0) {
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
		throw new Exception("DROP TABLE :" ~ to!string(err));
	}

 const string create_table="CREATE TABLE Persons2(
	Name TEXT,
	Age INTEGER
	);";

  retval = libsql_execute(conn,toStringz(create_table), &err);
  if (retval != 0) {
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
		throw new Exception("CREATE TABLE :" ~ to!string(err));
	}
  
	const insert_person="INSERT INTO Persons2 VALUES ('Paul',20);";

	retval = libsql_execute(conn,toStringz(insert_person), &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);
  
 const insert_person2="INSERT INTO Persons2 VALUES ('Laura',30)";

	retval = libsql_execute(conn,toStringz(insert_person2), &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);


	retval = libsql_query(conn, "SELECT * FROM Persons2;", &rows, &err);
	if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
	assert(retval == 0);

	num_cols = libsql_column_count(rows);
	//fprintf( core.stdc.stdio.stderr, "num_colds =%d\n", num_cols);
	assert(num_cols==2);

	while ((retval = libsql_next_row(rows, &row, &err)) == 0) {
		if (!err && !row) {
			break;
		}
		for (int col = 0; col < num_cols; col++) {
			if (col==0) {
			  char* value;
				retval = libsql_get_string(row, col, &value, &err);
				if (retval != 0) {
					fprintf(core.stdc.stdio.stderr, "%s\n", err);
				} else {
					printf("%s\t", value);
				}
			} else if (col==1) {
				long value;
				retval = libsql_get_int(row, col, &value, &err);
				if (retval != 0) {
					fprintf(core.stdc.stdio.stderr, "%s\n", err);
				} else {
					printf("%lld\n", value);
				}
			}
 		 assert(retval == 0);
		}
		err = null;
	}
 assert(retval == 0);

 quit:
	libsql_free_rows(rows);
	libsql_disconnect(conn);
	libsql_close(db);
}
