#' Type parsers for sander
#'
#' @param x a string
#' @name parsers

#' @rdname parsers
#' @export
format_types <- function(x){
  if(is.null(x)) return(NULL)
  if(!is.character(x)) stop("Input to format_types must be a character vector")
  factors <- stringr::str_detect(x, '^factor\\(')
  if(sum(factors) > 0){
    x[factors] <-
      stringr::str_replace(x[factors], 'factor', '') %>%
      stringr::str_replace_all('[\'"()]', '')        %>%
      stringr::str_split('\\s*,\\s*')                %>%
      lapply(stringr::str_c, collapse="','")         %>%
      unlist                                         %>%
      sprintf(fmt="col_factor(c('%s'))")             %>%
      stringr::str_replace('\\(c\\(\'\'\\)\\)', '')
  }
  if(sum(!factors) > 0){
    x[!factors] <- sprintf('col_%s()', x[!factors]) 
  }
  if(any(stringr::str_detect(x, '^col_factor\\(\\)$'))){
    warning("All factors must specify levels, e.g. 'factor(A,B,C)', converting to character")
    x <- stringr::str_replace_all(x, '^col_factor\\(\\)$', 'col_character()')
  }
  x <- stringr::str_replace_all(x, '^col_', 'readr::col_')
  x
}

#' @rdname parsers
#' @export
unformat_types <- function(x){
  if(is.null(x)) return(NULL)
  if(!is.character(x)) stop("Input to unformat_types must be a character vector")
  x <- stringr::str_replace_all(x, 'readr::', '')
  factors <- stringr::str_detect(x, '^col_factor\\(c\\(.*\\)\\)')
  if(sum(factors) > 0){
    x[factors] <-
      stringr::str_replace(x[factors], 'col_factor\\(c\\((.*)\\)\\)', '\\1') %>%
      stringr::str_split('\\s*\',\\s*\'')                                    %>%
      lapply(stringr::str_c, collapse=",")                                   %>%
      unlist                                                                 %>%
      stringr::str_replace_all("'", '')                                      %>%
      sprintf(fmt="factor(%s)")
  }
  if(sum(!factors) > 0){
    x[!factors] <- stringr::str_replace(x[!factors], 'col_([^\\(]+)..', '\\1')
  }
  x
}
