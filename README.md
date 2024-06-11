# libsql-d

Dlang bindings for [Libsql](https://github.com/tursodatabase/libsql), an Sqlite fork created by Turso, that supports remote connections to a server. 
Based on the C bindings (experimental).

(C) 2024 by Pablo De Nápoli (pdenapo AT gmail.com)

To use it, you need first to build libsql from the sources with 

cargo xtask build

and set the LIBSQL_PATH environment variable, to the the location of libsql_experimental.a in your system (like in my set_env.sh script).

Then build it with 

  dub build 



