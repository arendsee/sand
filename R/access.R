#' SAND access and assignment functions
#'
#' @param x anything
#' @param value object on right side of assignment
#' @name access
NULL

#' @rdname access
#' @export
is.sand <- function(x){
  'sand' %in% class(x)
}

#' @rdname access
#' @export
as.sand <- function(x){

  if(is.sand(x)) return(x)

  if(is.data.frame(x)){
    x <- tibble::as_data_frame(x)
    class(x) <- c('sand', class(x))
    smeta(x) <- tibble::data_frame(variable = names(x))
    sdesc(x) <- "No description\n"
    return(x)
  }

  stop("Cannot convert object of class '%s' to sand", paste0(class(x), collapse=", "))
}

#' @rdname access
#' @export
smeta <- function(x){
  attributes(x)$meta
}

#' @rdname access
#' @export
`smeta<-` <- function(x, value){
  attributes(x)$meta <- value
  x
}

#' @rdname access
#' @export
sdesc <- function(x){
  attributes(x)$desc
}

#' @rdname access
#' @export
`sdesc<-` <- function(x, value){
  attributes(x)$desc <- value
  x
}
