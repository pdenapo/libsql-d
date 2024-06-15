import libsql_deimos;
import core.stdc.stdio;
import std.process:environment;
import std.string:toStringz;
import std.stdio;

@("Example for libsql")
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
  retval = libsql_open_ext(toStringz(url), &db, &err);
  //retval = libsql_open_remote(toStringz(url),toStringz(""), &db, &err);	

  if (retval != 0)
	{
   fprintf(core.stdc.stdio.stderr, "retval=%d\n%s\n", retval,err);
	throw new Exception("libsql_open_ext failed");
	}

  retval = libsql_connect(db, &conn, &err);
  if (retval != 0)
  {
   fprintf(core.stdc.stdio.stderr, "retval=%d\n%s\n", retval,err);
	throw new Exception("libsql_connect failed");
  }

  retval = libsql_query(conn, "SELECT 1;", &rows, &err);
  if (retval != 0)
  {
   fprintf(core.stdc.stdio.stderr, "retval=%d\n%s\n", retval,err);
   throw new Exception("libsql_query failed");
  }

	num_cols = libsql_column_count(rows);
	assert(num_cols==1);

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
