module libsql.utils;

import libsql.deimos;
import std.stdio;
import std.algorithm:startsWith;
import std.string:toStringz;
import std.conv;


int libsql_open_any(string url, string auth_token, libsql_database_t *out_db, const char **out_err_msg)
{
  if (url.startsWith("http://") || url.startsWith("libsql://"))
			return libsql_open_remote(toStringz(url),toStringz(auth_token), out_db, out_err_msg);
  else 
			return libsql_open_ext(toStringz(url), out_db, out_err_msg);
}

// To implement iterator

struct QueryResult
{
 libsql_rows_t rows;
}


class LibsqlClient {
	libsql_database_t db;
	libsql_connection_t conn;

	
	this(string url,string auth_token)
	{
		char* err;
		int retval = libsql_open_any(url,"", &db, &err);	
		if (retval != 0) throw new Exception("libsql_open_any error:"~ to!string(err));
	
		retval = libsql_connect(db, &conn, &err);
		if (retval != 0) throw new Exception("libsql_connect error:"~ to!string(err));
	}

	~this()
	{
		//debug writeln("LibsqlClient destructor at the begining");
		libsql_disconnect(conn);
		libsql_close(db);
		debug writeln("LibsqlClient destructor at the end");
	}

	void execute(string statement)
	{
	  writeln(statement);
	  char* err;
	  int retval = libsql_execute(conn,toStringz(statement), &err);
	  if (retval != 0) {
				throw new Exception(to!string(err));
				}
	}

	 libsql_rows_t query(string statement){
	 	writeln(statement);
		 char* err;
		 libsql_rows_t rows;
		 int retval = libsql_query(conn, toStringz(statement), &rows, &err);
		 if (retval != 0) {
				throw new Exception(to!string(err));
			}
		 //return QueryResult(rows);
		 return rows; 
	}
	
}


