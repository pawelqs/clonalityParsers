
test_that("CNV recognizing works", {
  files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  expect_identical(rocognize_cnv_algorithm(files), "FACETS")
  expect_error(rocognize_cnv_algorithm("../testdata/S1_Mutect.vcf"))
})

test_that("CNV reading works", {
  files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  ids <- c("S1_P1", "S1_L1")
  res <- read_cnvs(files, ids, cnv_algorithm = "FACETS", genome_build = "hg38")
  expect_true("GRanges" %in% class(res))
  expect_error(read_cnvs("../testdata/S1_Mutect.vcf"))
})

test_that("FACETS reading works", {
  files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  ids <- c("S1_P1", "S1_L1")
  df <- read_FACETS(files, ids)
  expect_true(is.data.frame(df))
})
