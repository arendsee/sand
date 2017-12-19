[![Travis-CI Build Status](https://travis-ci.org/arendsee/sandr.svg?branch=master)](https://travis-ci.org/arendsee/sandr)
[![Coverage Status](https://img.shields.io/codecov/c/github/arendsee/sandr/master.svg)](https://codecov.io/github/arendsee/sandr?branch=master)

# sandr

Read and write annotated tabular data.

## Installation

You can install from github with:

``` R
devtools::install_github("arendsee/sandr")
```

## Example

### Reading

`sandr` loads data from a folder. The simplest usage of `sandr` is to just read
a table of data. This table may be either a standard TAB-delimited file or an
Excel spreadsheet (currently there is no support for multiple sheets, but this
may be added in the future).

This is not particularly useful, since the same could be done with any standard
tsv reader. However, `sandr` recognizes three additional files:

 1. `COLUMN.*` - a tabular file (`tsv/tab/xls/xlsx`) with a string description
    for each column in the main table

 2. `TYPES.*` - a table specifying the type of each column

 3. `README.*` - a text file describing the table as a whole


```R
diamonds_dir <- system.file('extdata', 'diamonds', package='sandr')
d <- read_sand(diamonds_dir)
class(d)
```

``` R
# print the metadata associated with the column 'carat'
field_info(d, "carat")

# print the dataset description
desc(d)

# use the data as a normal data.frame
summary(d)

# write to a folder, this will recreate the COLUMN, TYPE, README in addition to
# the original table.
write_sand(d)

# alternatively, you can write the table to an SQLite database
write_to_db(d)
```

### Writing

Another usage case is to annotate a dataset built in R and then export it in
a language agnostic manner. For example:

```R
d <- as.sand(iris)
desc(d) <- "Dimensions of sepals and petals across three iris species"
meta(d)$description <- c(
    "The length of the sepal",
    "The width of the sepal",
    "The length of the petal",
    "The width of the petal",
    "The species name"
)
write_sand(d, 'iris')
```

Which creates the directory structure:

```
iris
 ├── COLUMN.tsv
 ├── README.md
 ├── TYPE.tsv
 └── iris.tsv
```

# TODO

 - [ ] Write a specification for SAND format 

 - [ ] Add a config file that specifies the SAND version, SAND flavor, whether
       the table has headers, etc. This should be optional but automatically
       produced when writing.

 - [ ] Allow the type, column, and desc file to be read from the worksheets of
       an Excel file

 - [ ] Write the metadata to the SQLite database (easy to do, just haven't
       gotten around to it)

 - [ ] Handle non-tabular data (e.g. hierarchical data from XML or JSON;
       network data from DOT; bioinformatics data such as FASTA, GFF, SAM, etc)

 - [ ] Support for loading many datasets together (e.g. deeply nested folders
       of data and multiple datasets in one folder).

 - [ ] Link to [metaoku](https://github.com/arendsee/metaoku)
