#' sandr: A package for sharing and documenting whole data
#'
#' The SAND format is designed to allow clean packaging of data in a purely
#' textual environment.
#'
#' Data is frequently shared between researchers or stored within projects as
#' scattered csv text files or excel spreadsheets. Since these are independent
#' entities meant to be used in their entirety, there is little incentive to
#' build them into formal databases. In this context, ease of implementation
#' and depth of documentation of the data is more important than distribution
#' or accesibility.
#'
#' @section Main functions:
#'
#' \itemize{
#'   \item read_sand - read a sand project
#'   \item write_sand - write a sand project
#'   \item as.sand - turn a data frame into a sand object
#'   \item field_info - view metadata for a column in a sand table
#'   \item desc - view sand project README
#'   \item meta - view table of column annotations
#' }
#'
#' @docType package
#' @name sandr
NULL

#' @include sqldb.R
#' @include parsers.R
#' @include access.R
#' @include io.R

#' @importFrom magrittr "%>%"
utils::globalVariables(c("%>%", "."))
NULL
