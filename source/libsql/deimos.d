module libsql.deimos;

import  core.stdc.stdint;

extern (C) {

const  LIBSQL_INT =1;

const  LIBSQL_FLOAT=2;

const LIBSQL_TEXT=3;

const LIBSQL_BLOB=4;

const LIBSQL_NULL=5;

struct libsql_connection;

struct libsql_database;

struct libsql_row;

struct libsql_rows;

struct libsql_rows_future;

struct libsql_stmt;

alias  libsql_database_t =libsql_database*;

alias libsql_connection_t=libsql_connection*;

alias libsql_stmt_t=libsql_stmt*;

alias libsql_rows_t=libsql_rows*;

alias libsql_rows_future_t=libsql_rows_future*;

alias libsql_row_t=  libsql_row*;

struct blob {
  const char *ptr;
  int len;
};

int libsql_sync(libsql_database_t db, const char **out_err_msg);

int libsql_open_sync(const char *db_path,
                     const char *primary_url,
                     const char *auth_token,
                     char read_your_writes,
                     const char *encryption_key,
                     libsql_database_t *out_db,
                     const char **out_err_msg);

int libsql_open_sync_with_webpki(const char *db_path,
                                 const char *primary_url,
                                 const char *auth_token,
                                 char read_your_writes,
                                 const char *encryption_key,
                                 libsql_database_t *out_db,
                                 const char **out_err_msg);

int libsql_open_ext(const char *url, libsql_database_t *out_db, const char **out_err_msg);

int libsql_open_file(const char *url, libsql_database_t *out_db, const char **out_err_msg);

int libsql_open_remote(const char *url, const char *auth_token, libsql_database_t *out_db, const char **out_err_msg);

int libsql_open_remote_with_webpki(const char *url,
                                   const char *auth_token,
                                   libsql_database_t *out_db,
                                   const char **out_err_msg);

void libsql_close(libsql_database_t db);

int libsql_connect(libsql_database_t db, libsql_connection_t *out_conn, const char **out_err_msg);

int libsql_reset(libsql_connection_t conn, const char **out_err_msg);

void libsql_disconnect(libsql_connection_t conn);

int libsql_prepare(libsql_connection_t conn, const char *sql, libsql_stmt_t *out_stmt, const char **out_err_msg);

int libsql_bind_int(libsql_stmt_t stmt, int idx, long value, const char **out_err_msg);

int libsql_bind_float(libsql_stmt_t stmt, int idx, double value, const char **out_err_msg);

int libsql_bind_null(libsql_stmt_t stmt, int idx, const char **out_err_msg);

int libsql_bind_string(libsql_stmt_t stmt, int idx, const char *value, const char **out_err_msg);

int libsql_bind_blob(libsql_stmt_t stmt, int idx, const ubyte *value, int value_len, const char **out_err_msg);

int libsql_query_stmt(libsql_stmt_t stmt, libsql_rows_t *out_rows, const char **out_err_msg);

int libsql_execute_stmt(libsql_stmt_t stmt, const char **out_err_msg);

int libsql_reset_stmt(libsql_stmt_t stmt, const char **out_err_msg);

void libsql_free_stmt(libsql_stmt_t stmt);

int libsql_query(libsql_connection_t conn, const char *sql, libsql_rows_t *out_rows, const char **out_err_msg);

int libsql_execute(libsql_connection_t conn, const char *sql, const char **out_err_msg);

void libsql_free_rows(libsql_rows_t res);

void libsql_free_rows_future(libsql_rows_future_t res);

void libsql_wait_result(libsql_rows_future_t res);

int libsql_column_count(libsql_rows_t res);

int libsql_column_name(libsql_rows_t res, int col, const char **out_name, const char **out_err_msg);

int libsql_column_type(libsql_rows_t res, libsql_row_t row, int col, int *out_type, const char **out_err_msg);

uint64_t libsql_changes(libsql_connection_t conn);

int64_t libsql_last_insert_rowid(libsql_connection_t conn);

int libsql_next_row(libsql_rows_t res, libsql_row_t *out_row, const char **out_err_msg);

void libsql_free_row(libsql_row_t res);

int libsql_get_string(libsql_row_t res, int col, const char **out_value, const char **out_err_msg);

void libsql_free_string(const char *ptr);

int libsql_get_int(libsql_row_t res, int col, long *out_value, const char **out_err_msg);

int libsql_get_float(libsql_row_t res, int col, double *out_value, const char **out_err_msg);

int libsql_get_blob(libsql_row_t res, int col, blob *out_blob, const char **out_err_msg);

void libsql_free_blob(blob b);

}
