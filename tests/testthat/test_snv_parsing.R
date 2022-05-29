
test_that("Mutect reading works", {
  files <- c("../testdata/S1_Mutect.vcf")
  ids <- c("S1_P1", "S1_L1")
  df <- read_mutect(files, ids)
  expect_true(is.data.frame(df))
})
