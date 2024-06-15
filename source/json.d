module libsql_json;
import libsql_deimos;
import vibe.data.json;
import core.stdc.stdio;
import std.conv;
import std.stdio;

Json rows_to_Json(libsql_rows_t rows)
{
	char* err = null;
	int retval = 0;
	libsql_row_t row;
	Json[] json_rows;
	int num_cols = libsql_column_count(rows);
	while ((retval = libsql_next_row(rows, &row, &err)) == 0)
	{
		if (retval != 0)
		{
			throw new Exception(to!string(err));
		}
		if (!row)
			break;
		Json[string] json_row;
		for (int col = 0; col < num_cols; col++)
		{
			char* col_name;
			retval = libsql_column_name(rows, col, &col_name, &err);
			if (retval != 0)
			{
				throw new Exception(to!string(err));
			}
			string col_name_string = to!string(col_name);

			int col_type;
			retval = libsql_column_type(rows, row, col, &col_type, &err);
			if (retval != 0)
			{
				throw new Exception(to!string(err));
			}
			switch (col_type)
			{
			case LIBSQL_INT:
				long value;
				retval = libsql_get_int(row, col, &value, &err);
				if (retval != 0) {
					fprintf(core.stdc.stdio.stderr, "%s\n", err);
				}
				json_row[col_name_string] = Json(value);
				break;	
			case LIBSQL_TEXT:
				char* value;
				retval = libsql_get_string(row, col, &value, &err);
				if (retval != 0)
				{
					fprintf(core.stdc.stdio.stderr, "%s\n", err);
				}
				json_row[col_name_string] = Json(to!string(value));
				break;
			default:
				assert(false);
			}

		}
		err = null;
		json_rows ~= Json(json_row);
	}
	return Json(json_rows);
}
