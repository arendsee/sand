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

read_table_ <- function(x, has_header=TRUE){
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
    d <- readr::read_tsv(x, col_names=has_header)
  }
  d
}

read_meta_ <- function(x, has_header=TRUE){
  d <- read_table_(x, has_header)
  if(has_header){
    default_header <- c('variable', 'description')
    if(ncol(d) == 1){
      names(d)[1] <- default_header[1]
    }
    if(ncol(d) == 2){
      names(d) <- default_header
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

read_meta <- read_with_look_(find_meta_, read_meta_)
read_data <- read_with_look_(find_data_, read_table_)
read_desc <- read_with_look_(find_desc_, read_text_)

#' Read an unnested SAND directory
#' 
#' @param x directory name
#' @param data_has_header does the data file have headers?
#' @param meta_has_header does the COLUMN file have headers?
#' @param rdata main data file reader
#' @param rdesc description file reader
#' @param rmeta metadata file reader
#' @return a sand object
#' @export
read_sand <- function(
  x,
  data_has_header=TRUE,
  meta_has_header=TRUE,
  rdata=read_data,
  rdesc=read_desc,
  rmeta=read_meta
){
  if(!dir.exists(x)){
    stop("x must be a directory")
  }

  sdata <- rdata(path=x, has_header=data_has_header)
  smeta <- rmeta(path=x, has_header=meta_has_header)
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

  if(!data_has_header){
    names(sdata) <- smeta[[1]]
  }

  if(!setequal(smeta[[1]], names(sdata))){
    stop("first column of COLUMN file != data header names")
  }

  meta(sdata) <- smeta
  desc(sdata) <- sdesc

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
