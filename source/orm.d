module libsql.orm;

import libsql.deimos;
import libsql.utils;
import std.stdio;
//import std.algorithm:startsWith;
import std.string:toStringz;
import std.conv;

class LibsqlClient {
	libsql_database_t db;
	libsql_connection_t conn;
	bool print_sql;
	 	
	this(string url,string auth_token,bool print_sql=false)
	{
		char* err;
		this.print_sql=print_sql;
		int retval = libsql_open_any(url,auth_token, &db, &err);	
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

	void create_table (T)(string table)
	{
	  string sql = "CREATE TABLE "~ table ~ "(";

	  foreach(i,member;__traits(allMembers, T))
    {
					if (i>0) sql ~=",";
					sql ~= member; 
					static if (is(typeof(__traits(getMember, T, member))==int))
					{
						sql ~=  " INTEGER NOT NULL ";   
					}
					else static if (is(typeof(__traits(getMember, T, member))==string))
					{
						sql ~=  " TEXT NOT NULL ";
					}
					else static if (is(typeof(__traits(getMember, T, member))==double))
					{
						sql ~=  " REAL NOT NULL ";
					}
    }
		sql ~= ");";
		execute(sql);
	}

	void insert (T)(T p, string table)
	{
		//const sql = "INSERT INTO Persons4 VALUES ('" ~ p.name ~ "'," ~ to!string(
		//	p.age) ~ "," ~ to!string(p.height) ~",'" ~ to!string(p.hobby) ~ "');";

		
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
					static if (is(typeof(__traits(getMember, p, member))==int))
					{
					  retval=libsql_bind_int(insert_stmt,i+1,__traits(getMember, p, member) , &err);
						if (retval != 0) throw new Exception("libsql_bind_int:"~ to!string(err));
					}
					else static if (is(typeof(__traits(getMember, p, member))==string))
					{
						retval=libsql_bind_string(insert_stmt,i+1, toStringz(__traits(getMember, p, member)), &err);
  					if (retval != 0) throw new Exception("libsql_bind_string:"~ to!string(err));
					}
					else static if (is(typeof(__traits(getMember, p, member))==double))
					{
						retval=libsql_bind_float(insert_stmt,i+1,  __traits(getMember, p, member), &err);
					}
    }
		
		retval= libsql_execute_stmt(insert_stmt, &err);
		if (retval != 0) throw new Exception("libsql_execute_stmt:"~ to!string(err));

		//retval= libsql_reset_stmt(insert_stmt, &err);
		//if (retval != 0) throw new Exception("libsql_reset_stmt:"~ to!string(err));
		libsql_free_stmt(insert_stmt);

	}

}


