find_desc_ <- function(x){
  x[ grepl('^readme', x, ignore.case=TRUE) ]
}

find_meta_ <- function(x){
  x[ grepl('^column', x, ignore.case=TRUE) ]
}

find_data_ <- function(x){
  tabular_files <- x[ grepl('\\.(tsv|tab|xls|xlsx)', x) ]
  meta_files <- find_meta_(x)
  setdiff(tabular_files, meta_files)
}

read_text_ <- function(x){
  readr::read_file(x) 
}

read_table_ <- function(x){
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
    d <- readr::read_tsv(x)
  }
  d
}

read_with_look_ <- function(find_, read_){
  function(x=NA, path=NA){
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
      read_(f)
    }
  }
}

read_meta <- read_with_look_(find_meta_, read_table_)
read_data <- read_with_look_(find_data_, read_table_)
read_desc <- read_with_look_(find_desc_, read_text_)

#' Read an unnested SAND directory
#' 
#' @param x directory name
#' @param rdata main data file reader
#' @param rdesc description file reader
#' @param rmeta metadata file reader
#' @return a sand object
#' @export
read_sand <- function(
  x,
  rdata=read_data,
  rdesc=read_desc,
  rmeta=read_meta
){
  if(!dir.exists(x)){
    stop("x must be a directory")
  }

  sdata <- rdata(path=x)
  smeta <- rmeta(path=x)
  sdesc <- rdesc(path=x)

  if(is.null(smeta)){
    smeta <- tibble::data_frame(variable = names(sdata))
  }

  if(is.null(sdesc)){
    sdesc <- "No description\n"
  }

  if(nrow(smeta) != ncol(sdata)){
    stop("assertion failed: nrow(meta) == ncol(sdata)")
  }

  if(!setequal(smeta[[1]], names(sdata))){
    stop("first column of COLUMN file != data header names")
  }

  attributes(sdata)$meta <- smeta
  attributes(sdata)$desc <- sdesc
  class(sdata) <- c('sand', class(sdata))

  sdata
}

#' Write SAND object to SAND formatted directory
#' 
#' @param x a sand object
#' @param path name of directory that will be created
#' @export
write_sand <- function(x, path) {
  if(dir.exists(path)){
    stop(sprintf("Refusing to overwrite '%s'", path))
  }
  dir.create(path)

  x <- as.sand(x)

  readr::write_file(attributes(x)$desc, file.path(path, 'README.md'))
  readr::write_tsv(attributes(x)$meta, file.path(path, 'COLUMN.tsv'))
  readr::write_tsv(x, file.path(path, paste0(basename(path), '.tsv', collapse="")))
}
