module libsql.utils;

import libsql.deimos;
//import std.stdio;
import std.algorithm:startsWith;
import std.string:toStringz;
//import std.conv;


int libsql_open_any(string url, string auth_token, libsql_database_t *out_db, const char **out_err_msg)
{
  //debug writeln("url=",url);
  //debug writeln("auth_token=",auth_token);
  if (url.startsWith("http://") || url.startsWith("libsql://"))
			return libsql_open_remote(toStringz(url),toStringz(auth_token), out_db, out_err_msg);
  else 
			return libsql_open_ext(toStringz(url), out_db, out_err_msg);
}



