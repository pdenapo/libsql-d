import std.stdio;
import std.string;
import core.stdc.stdio;
import libsql_deimos;

int main()
{
libsql_connection_t conn;
	libsql_rows_t rows;
	libsql_row_t row;
	libsql_database_t db;
	char *err = null;
	int retval = 0;
	int num_cols;


  retval = libsql_open_ext(":memory:", &db, &err);
  //retval = libsql_open_ext("hello.db", &db, &err);
  if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
		goto quit;
	}
	writeln("db=",db);

  retval = libsql_connect(db, &conn, &err);
	if (retval != 0) {
		fprintf( core.stdc.stdio.stderr, "%s\n", err);
		//stderr.writeln(err);
		goto quit;
	}
	writeln("conn=",conn);

	retval = libsql_query(conn, "SELECT 1", &rows, &err);
	if (retval != 0) {
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
		goto quit;
	}

	num_cols = libsql_column_count(rows);

	while ((retval = libsql_next_row(rows, &row, &err)) == 0) {
		if (!err && !row) {
			break;
		}
		for (int col = 0; col < num_cols; col++) {
			if (col > 0) {
				printf(", ");
			}
			long value;
			retval = libsql_get_int(row, col, &value, &err);
			if (retval != 0) {
				fprintf(core.stdc.stdio.stderr, "%s\n", err);
			} else {
				printf("%lld\n", value);
			}
		}
		err = null;
	}

	if (retval != 0) {
		fprintf(core.stdc.stdio.stderr, "%s\n", err);
		goto quit;
	}


  quit:
		libsql_free_rows(rows);
		libsql_disconnect(conn);
		libsql_close(db);

		//writeln("retval=",retval);
		fprintf(core.stdc.stdio.stderr, "retval=%d \n", retval);
		return retval;
}
