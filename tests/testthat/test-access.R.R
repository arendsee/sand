context("access.R")

test_that(
  "test access",
  {
    expect_true(is.sand(as.sand(iris)))
    expect_error(as.sand(1))

    iris_sand <- as.sand(iris)
    expect_identical(as.sand(iris_sand), iris_sand)

    expect_equal(desc(iris_sand), "No description\n")
    expect_equal({desc(iris_sand) <- 'flower power'; desc(iris_sand)}, 'flower power')
    expect_equal(meta(iris_sand)[[1]], names(iris))
    expect_output(field_info(iris_sand, 'Sepal.Length'))
    expect_error(field_info(iris_sand, 'floofy_shorts'))
  }
)
