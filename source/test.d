import libsql_deimos;
import core.stdc.stdio;

@("Example for libsql")
unittest {
	libsql_database_t db;
	libsql_connection_t conn;
	char *err = null;
	int retval = 0;
	libsql_rows_t rows;
	libsql_row_t row;
	int num_cols;

	
  retval = libsql_open_ext(":memory:", &db, &err);
  assert(retval == 0);

  retval = libsql_connect(db, &conn, &err);
  assert(retval == 0);

	retval = libsql_query(conn, "SELECT 1", &rows, &err);
	assert(retval == 0);


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
