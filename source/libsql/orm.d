module libsql.orm;

import libsql.deimos;
import libsql.utils;
import std.stdio;
//import std.algorithm:startsWith;
import std.string:toStringz;
import std.conv;
import std.datetime.date;
import std.traits;

enum SQL;

class SQLTable!T {
		  string[] records;
		}

class LibsqlClient {
	libsql_database_t db;
	libsql_connection_t conn;
	bool print_sql;

	void connect(string url,string auth_token,bool print_sql=false)
	{
		char* err;
		this.print_sql=print_sql;
		int retval = libsql_open_any(url,auth_token, &db, &err);	
		if (retval != 0) throw new Exception("libsql_open_any error:"~ to!string(err));
	
		retval = libsql_connect(db, &conn, &err);
		if (retval != 0) throw new Exception("libsql_connect error:"~ to!string(err));
	}

	this() {}

	~this()
	{
		//debug writeln("LibsqlClient destructor at the begining");
		libsql_disconnect(conn);
		libsql_close(db);
		debug writeln("LibsqlClient destructor at the end");
	}

	void execute(string statement)
	{
	  if (print_sql) writeln(statement);
	  char* err;
	  int retval = libsql_execute(conn,toStringz(statement), &err);
	  if (retval != 0) {
				throw new Exception(to!string(err));
				}
		}

	libsql_rows_t query(string statement){
		if (print_sql) writeln(statement);
		char* err;
		libsql_rows_t rows;
		int retval = libsql_query(conn, toStringz(statement), &rows, &err);
		if (retval != 0) {
				throw new Exception("libsql_query:" ~ to!string(err));
			}
		 //return QueryResult(rows);
		 return rows; 
	}

	

	private void create_table_internal (T)(string table, string sql_inicial)
	{
	  string sql = sql_inicial;

	  int col=0; // column number in the databse;
	  foreach(member;__traits(allMembers, T))
		{
					//pragma(msg, member);
					enum prot = __traits(getProtection,
                             __traits(getMember, T, member));
           // Only the public memeber of T are mapped to the database
          static if (hasUDA!( __traits(getMember, T, member),SQL ) && (prot == "public")) {
						//pragma(msg, typeof(__traits(getMember, T, member).stringof));
						if (col>0) sql ~=",";
						sql ~= member;
						static if (__traits(isIntegral,typeof(__traits(getMember, T, member)))) 
						{
							sql ~=  " INTEGER NOT NULL ";   
						}
						else static if (is(typeof(__traits(getMember, T, member))==double))
						{
							sql ~=  " REAL NOT NULL ";
						}
						else					
					//else static if (is(typeof(__traits(getMember, T, member))==string))
						{
							sql ~=  " TEXT NOT NULL ";
						}
						col++;
					}
    }
		sql ~= ");";
		execute(sql);
	}

	void create_table(T)(string table)
	{
	  string sql = "CREATE TABLE IF NOT EXISTS "~ table ~ "(";
	  create_table_internal !T(table,sql);
	}

	void create_table_if_not_exists(T)(string table)
	{
	  string sql = "CREATE TABLE IF NOT EXISTS "~ table ~ "(";
	  create_table_internal !T(table,sql);
	}

	void insert (T)(T p, string table)
	{
		libsql_stmt_t insert_stmt;
		char* err;
		
		debug writeln("insert",p, " into ", table);

    string insert_sql = "INSERT INTO "~ table ~ " VALUES ("; 
    for (int i=0;i<__traits(allMembers, T).length;i++)
    {
      if (i>0) insert_sql ~=",";
      insert_sql ~="?";
    }
		insert_sql ~=");";	
    
		writeln(insert_sql);
		int retval=libsql_prepare(conn, toStringz(insert_sql), &insert_stmt, &err);
		if (retval != 0) throw new Exception("libsql_prepare error:"~ to!string(err));


    foreach(i,member;__traits(allMembers, T))
    {
    			//debug writeln(member,"=",__traits(getMember, p, member)," ",typeof(__traits(getMember, p, member)).stringof);
    			enum prot = __traits(getProtection,
                             __traits(getMember, T, member));
    			static if (hasUDA!( __traits(getMember, T, member),SQL ) && (prot == "public")) {
					
					// Integral types are represented using INTEGER 
					
					static if (__traits(isIntegral,typeof(__traits(getMember, p, member))))
					{
					  debug writeln("orm: ",member, "->INTEGER");
					  retval=libsql_bind_int(insert_stmt,i+1,to!long(__traits(getMember, p, member)), &err);
					}
					else static if (is(typeof(__traits(getMember, p, member))==double))
					{
						retval=libsql_bind_float(insert_stmt,i+1,  __traits(getMember, p, member), &err);
						debug writeln("orm: ",member, "->FLOAT" );
					}
					else static if (is(typeof(__traits(getMember, p, member))==Date)||
													is(typeof(__traits(getMember, p, member))==DateTime))
					{
						retval=libsql_bind_string(insert_stmt,i+1, toStringz( __traits(getMember, p, member).toISOExtString()), &err);
						debug writeln("orm: ",member, "-> ExtString" );
					}
					else //static if (is(typeof(__traits(getMember, p, member))==string))
					{
						retval=libsql_bind_string(insert_stmt,i+1, toStringz(to!string(__traits(getMember, p, member))), &err);
						debug writeln("orm: ",member, "->STRING");
					}
					if (retval != 0) throw new Exception("insert:"~ to!string(err));
					}
    }
		
		retval= libsql_execute_stmt(insert_stmt, &err);
		if (retval != 0) throw new Exception("libsql_execute_stmt:"~ to!string(err));

		//retval= libsql_reset_stmt(insert_stmt, &err);
		//if (retval != 0) throw new Exception("libsql_reset_stmt:"~ to!string(err));
		libsql_free_stmt(insert_stmt);

	}

	void drop_table(string table_name)
	{
		const string drop_table="DROP TABLE "~table_name~";";
		execute(drop_table);
	}


	void drop_table_if_exists(string table_name)
	{
		const string drop_table="DROP TABLE IF EXISTS "~table_name~";";
		execute(drop_table);
	}


	T get(T)(libsql_row_t row)
	{
		T result;
		int retval;
		int col=0;
		char* err;

    foreach(i,member;__traits(allMembers, T))
    {
    			enum prot = __traits(getProtection,
                             __traits(getMember, T, member));
    			static if (hasUDA!( __traits(getMember, T, member),SQL ) && (prot == "public")) {
					// Integral types are represented using INTEGER 
					
					static if (__traits(isIntegral,typeof(__traits(getMember, T, member))))
					{
	  				long value;
						retval = libsql_get_int(row, col, &value, &err);
						if (retval != 0) throw new Exception("libsql_get_int:"~ to!string(err));
						__traits(getMember, result, member) = cast(typeof(__traits(getMember, T, member))) value;
					}
					else static if (is(typeof(__traits(getMember, T, member))==double))
					{
							double value;
							retval = libsql_get_float(row, col, &value, &err);
						  if (retval != 0) throw new Exception("libsql_get_float:"~ to!string(err));
							__traits(getMember, result, member) = cast(typeof(__traits(getMember, T, member))) value;
					}
					// else static if (is(typeof(__traits(getMember, p, member))==Date)||
					// 								is(typeof(__traits(getMember, p, member))==DateTime))
					// {
					// 	retval=libsql_bind_string(insert_stmt,i+1, toStringz( __traits(getMember, p, member).toISOExtString()), &err);
					// 	debug writeln("orm: ",member, "-> ExtString" );
					// }
					 else static if (is(typeof(__traits(getMember, T, member))==string))
					 {
					 	char* value;
						retval = libsql_get_string(row, col, &value, &err);
						if (retval != 0) throw new Exception("libsql_get_string:"~ to!string(err));
						__traits(getMember, result, member) = to!string(value);
					 }
					 else static if (is(typeof(__traits(getMember, T, member))==Date))
					 {
					 	char* value;
						retval = libsql_get_string(row, col, &value, &err);
						if (retval != 0) throw new Exception("libsql_get_string:"~ to!string(err));
						__traits(getMember, result, member) = Date.fromISOExtString(to!string(value));
					 }
					 else static if (is(typeof(__traits(getMember, T, member))==DateTime))
					 {
					 	char* value;
						retval = libsql_get_string(row, col, &value, &err);
						if (retval != 0) throw new Exception("libsql_get_string:"~ to!string(err));
						__traits(getMember, result, member) = DateTime.fromISOExtString(to!string(value));
					 }
					col++;
					}
    }
		
		return result;
	}

}


