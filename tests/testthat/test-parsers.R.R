context("parsers.R")

test_that(
  "test type parsers",
  {
    expect_equal(format_types('number'), 'readr::col_number()')

    expect_warning(x <- format_types('factor'))
    expect_equal(x, 'readr::col_character()')

    expect_equal(format_types('factor(cats,dogs)'), "readr::col_factor(c('cats','dogs'))")

    expect_equal(unformat_types(format_types('number')), 'number')
    expect_equal(unformat_types(format_types('factor(cats,dogs)')), 'factor(cats,dogs)')

    expect_null(format_types(NULL))
    expect_null(unformat_types(NULL))

    expect_error(format_types(1))
    expect_error(unformat_types(1))
  }
)
