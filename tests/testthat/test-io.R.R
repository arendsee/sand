context("io.R")

test_that(
  "test type parsers",
  {

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
    expect_equal({d <- read_sand('samples/diamonds'); names(d)[1]}, 'carat')
    expect_equal(d[[1]][1], 0.23)
  }
)

test_that(
  "reading diamonds without headers",
  {
    expect_equal(
      {
        d <- read_sand(
          'samples/diamonds_no_header',
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
