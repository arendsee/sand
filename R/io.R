find_desc_ <- function(x){
  x[ grepl('^readme', x, ignore.case=TRUE, perl=TRUE) ]
}

find_meta_ <- function(x){
  x[ grepl('^columns?\\.', x, ignore.case=TRUE, perl=TRUE) ]
}

find_type_ <- function(x){
  x[ grepl('^types?\\.', x, ignore.case=TRUE, perl=TRUE) ]
}

find_data_ <- function(x){
  tabular_files <- x[ grepl('\\.(tsv|tab|xls|xlsx)', x) ]
  
  setdiff(tabular_files, c(find_meta_(x), find_type_(x)))
}

read_text_ <- function(x){
  readr::read_file(x) 
}

read_table_ <- function(x, has_header=TRUE, col_names=has_header, ...){

  if(has_header){
    col_names <- TRUE 
  }

  if(grepl('.*(.xls|.xlsx)$', x)){
    d <- readxl::read_excel(x)
    if(nrow(d) == 65535 || nrow(d) == 1048576){
      warning(paste(
        "There are exactly", nrow(d), "rows in this file, since this is a",
        "possible maximum for allowed number of rows in an excel file,",
        "it is likely that the file is truncated."
      ))
    }
  } else {
    d <- readr::read_tsv(x, col_names=col_names, ...)
  }
  d
}

read_deviant_table_ <- function(x, has_header=TRUE, col_names=NULL, ...){
  d <- read_table_(x, has_header, ...)
  if(has_header){
    if(ncol(d) == 1){
      names(d)[1] <- col_names[1]
    }
    if(ncol(d) == 2){
      names(d) <- col_names
    }
  }
  d
}

read_with_look_ <- function(find_, read_){
  function(x=NA, path=NA, ...){
    if(is.na(x)){
      if(!is.na(path)){
        x <- list.files(path)
      } else {
        stop("You must include either x or path")
      }
    }
    f <- file.path(path, find_(x))

    if(length(f) > 1){
      stop(sprintf("Exected 1 file, found '%s'", paste0(f, collapse="', '")))
    }

    if(length(f) == 0){
      NULL
    } else {
      read_(f, ...)
    }
  }
}

read_meta <- read_with_look_(find_meta_, read_deviant_table_)
read_data <- read_with_look_(find_data_, read_table_)
read_desc <- read_with_look_(find_desc_, read_text_)
read_type <- read_with_look_(find_type_, read_deviant_table_)

#' Read an unnested SAND directory
#' 
#' @param x directory name
#' @param data_has_header whether data file has headers
#' @param meta_has_header whether COLUMN file has headers
#' @param type_has_header whether TYPE file has headers
#' @param col_types data types for each column (see details)
#' @param rdata main data file reader
#' @param rdesc description file reader
#' @param rmeta metadata file reader
#' @param rtype type file reader
#' @return a sand object
#' @family io
#' @export
read_sand <- function(
  x,
  data_has_header = TRUE,
  meta_has_header = TRUE,
  type_has_header = TRUE,
  col_types = NULL,
  rdata = read_data,
  rdesc = read_desc,
  rmeta = read_meta,
  rtype = read_type
){
  if(!dir.exists(x)){
    stop("x must be a directory")
  }

  if(is.null(col_types)){
    stype <- rtype(path=x, has_header=type_has_header, col_names=c('variable', 'primary_type'))
    if(!is.null(stype)){
      stype[[2]] <- format_types(stype[[2]])
      cmd <- sprintf("readr::cols(%s)", paste0(paste0(stype[[1]], '=', stype[[2]]), collapse=", "))
      col_types <- eval(parse(text=cmd))
    }
  } else {
    stype <- NULL
  }

  smeta <- rmeta(path=x, has_header=meta_has_header, col_names=c('variable', 'description'))
  sdata <- rdata(path=x, has_header=data_has_header, col_names=smeta[[1]], col_types=col_types)
  sdesc <- rdesc(path=x)

  if(is.null(stype)){
    stype <- tibble::data_frame(variable=names(sdata), r_type=sapply(sdata, class))
  }

  if(is.null(smeta)){
    smeta <- tibble::data_frame(variable=names(sdata))
  }

  if(is.null(sdesc)){
    sdesc <- "No description\n"
  }

  if(nrow(smeta) != ncol(sdata)){
    stop("assertion failed: nrow(meta) == ncol(sdata)")
  }

  meta(sdata) <- smeta
  desc(sdata) <- sdesc
  type(sdata) <- stype

  class(sdata) <- c('sand', class(sdata))

  sdata
}

#' Write SAND object to SAND formatted directory
#' 
#' @param x a sand object
#' @param path name of directory that will be created
#' @family io
#' @export
write_sand <- function(x, path) {
  if(dir.exists(path)){
    stop(sprintf("Refusing to overwrite '%s'", path))
  }
  dir.create(path)

  x <- as.sand(x)

  readr::write_file(desc(x), file.path(path, 'README.md'))
  readr::write_tsv(meta(x), file.path(path, 'COLUMN.tsv'))
  readr::write_tsv(type(x), file.path(path, 'TYPE.tsv'))
  readr::write_tsv(x, file.path(path, paste0(basename(path), '.tsv', collapse="")))
}
