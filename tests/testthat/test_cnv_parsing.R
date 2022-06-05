# files <- c("tests/testdata/S1_P1.csv", "tests/testdata/S1_L1.csv")
cnv_meta_cols <- c("sample_id", "total_cn", "minor_cn", "major_cn", "normal_cn")

test_that("CNV reading works", {
  files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  ids <- c("S1_P1", "S1_L1")
  res <- read_cnvs(files, ids, sex = "male", genome_build = "hg38")
  expect_true("GRanges" %in% class(res))
  expect_identical(colnames(res@elementMetadata), cnv_meta_cols)
  expect_error(read_cnvs("../testdata/S1_Mutect.vcf"))
})

test_that("CNV recognizing works", {
  files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  expect_identical(recognize_cnv_algorithm(files), "FACETS")
  expect_error(recognize_cnv_algorithm("../testdata/S1_Mutect.vcf"))
})

test_that("FACETS reading works", {
  files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  ids <- c("S1_P1", "S1_L1")
  df <- read_FACETS(files, ids)
  expect_true(is.data.frame(df))
})
