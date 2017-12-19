context("io.R")

diamonds_dir <- system.file('extdata', 'diamonds', package='sandr')
diamonds_headless_dir <- system.file('extdata', 'diamonds_no_header', package='sandr')

test_that(
  "test basic inputs",
  {
    expect_error(read_sand('hi'))
  }
)

test_that(
  "File finders work",
  {
    files <- c("aREADME", "README",  "COLUMN.tsv", "foo.tsv")
    expect_equal(find_desc_(files), "README")
    expect_equal(find_desc_(c(files, "README.md")), c("README", "README.md"))
    expect_equal(find_meta_(files), "COLUMN.tsv")
    expect_equal(find_data_(files), "foo.tsv")
  }
)

test_that(
  "reading diamonds",
  {
    expect_equal({d <- read_sand(diamonds_dir); names(d)[1]}, 'carat')
    expect_equal(d[[1]][1], 0.23)
  }
)

test_that(
  "reading diamonds without headers",
  {
    expect_equal(
      {
        d <- read_sand(
          diamonds_headless_dir,
          meta_has_header=FALSE,
          data_has_header=FALSE
        )
        names(d)[1]
      },
      'carat'
    )
    expect_equal(d[[1]][1], 0.23)
  }
)

test_that(
  "can set data types",
  {
    expect_equal(
      {
        d <- read_sand(diamonds_dir, col_types='ccccnncnnn')
        lapply(d, class)[[1]]
      },
      'character'
    )
  }
)
