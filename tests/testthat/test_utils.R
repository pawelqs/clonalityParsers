
test_that("Safe column renaming works", {
  df <- tibble(a = 1:3)
  expect_error(rename(df, b = c))
  expect_identical(rename_column_if_exist(df, "b", "c"), df)
  expect_identical(rename_column_if_exist(df, "a", "c"), tibble(c = 1:3))
})
