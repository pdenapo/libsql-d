import libsql_deimos;
import core.stdc.stdio;
import std.string;

@("Persons")
unittest {
	libsql_database_t db;
	libsql_connection_t conn;
	char *err = null;
	int retval = 0;
	libsql_rows_t rows;
	libsql_row_t row;
	int num_cols;

	
  retval = libsql_open_ext(":memory:", &db, &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);

  retval = libsql_connect(db, &conn, &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);

 const string create_table="CREATE TABLE Persons(
	Name TEXT,
	Age INTEGER
	);";

  retval = libsql_execute(conn,toStringz(create_table), &err);
  assert(retval == 0);

	const insert_person="INSERT INTO Persons VALUES ('Paul',20);";

	retval = libsql_execute(conn,toStringz(insert_person), &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);
  
 const insert_person2="INSERT INTO Persons VALUES ('Laura',30)";

	retval = libsql_execute(conn,toStringz(insert_person2), &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
	}
  assert(retval == 0);


	retval = libsql_query(conn, "SELECT * FROM Persons;", &rows, &err);
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
