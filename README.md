[![deprecated](http://badges.github.io/stability-badges/dist/deprecated.svg)](http://github.com/badges/stability-badges)
[![Travis-CI Build Status](https://travis-ci.org/arendsee/sandr.svg?branch=master)](https://travis-ci.org/arendsee/sandr)
[![Coverage Status](https://img.shields.io/codecov/c/github/arendsee/sandr/master.svg)](https://codecov.io/github/arendsee/sandr?branch=master)

:ghost: :ghost: :ghost:

`sandr` was designed to easily confer some modicum of order on the scattered
files commonly used in data analysis and storage (e.g. on FTP sites).
Currently, `sandr` supports tabular data. But I have been thinking about
extending support to alternative formats. Also, there are enough ambiguities,
even in tabular data, to require a little configuration file. So I had been
considering adding a JSON or YAML file to describe the data.

Well, this already exists. `sandr` is evolving towards a recreation of the
[Data Package](https://frictionlessdata.io/specs/data-package/) concept. So,
I shall kill it before it does any harm to the world.

There is some nice material in this repo. I will look for pieces I can scavenge
and apply towards better open source projects.

So, farewell `SAND` and `sandr`, you shall not be missed.

:ghost: :ghost: :ghost:

# sandr

Read and write annotated datasets stored in file directories.

`sandr` is a prototype manager for data stored according the
**S**elf-**A**nnotating **N**ested **D**ata (SAND) specification. This spec
mostly exists only in my head at the moment. See SAND specification below for
more information. 

## Installation

You can install from github with:

``` R
devtools::install_github("arendsee/sandr")
```

## SAND Specification

The SAND spec is intended to closely mirror the usual practice of storing data
in folders along with its annotations. Datasets for most projects are stored in
folders as a collection of tables (e.g. TAB-delimited or excel files) or
specialized textual formats (e.g. FASTA for sequence or DOT for graphs). Beyond
local projects, many online resources share collections of data in FTP file
systems. The SAND spec is designed to support clean documentation and
organization of the datasets in a manner sufficiently uniform to allow machine
parsing.

Hierarchical organization of data often falls into two strategies: group by
topic or group by type. When grouping by topic, nesting moves from high-level
group to individual, where the individual leaf folder contains several files of
diverse type. When grouping by type, the data related to an individual is
scattered, but the leaf directories have collections of files of uniform type. 

The SAND specification favors type grouping. This allows type coupling between
annotation of the data types with minimal duplication. For example, a key
annotation for a table is the description of its columns. SAND specifies that
this should be in a COLUMN.tsv file. Keeping all tables of the same type in one
folder allows the tables to share a common COLUMN.tsv file in the most obvious
way possible.

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
