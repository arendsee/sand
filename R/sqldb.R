
#' Write SAND object to SQLite database
#' 
#' @param x SAND object
#' @param tblname name of new data table that will be created
#' @param dbname name of SQLite database
#' @return SQLiteConnection
#' @export
write_to_db <- function(x, tblname=deparse(substitute(x)), dbname=":memory:"){
  db <- RSQLite::dbConnect(RSQLite::SQLite(), dbname=dbname)
  RSQLite::dbWriteTable(conn=db, name=tblname, value=as.data.frame(x))
  db
}

#' Open a SAND SQLite database
#' 
#' @param dbname name of the sqlite database
#' @return SQLiteConnection
#' @export
open_sand_db <- function(dbname){
  RSQLite::dbConnect(RSQLite::SQLite(), dbname=dbname)
}
