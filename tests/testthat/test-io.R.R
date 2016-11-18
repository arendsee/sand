context("io.R")

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
