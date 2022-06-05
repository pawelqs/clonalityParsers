# files <- c("tests/testdata/S1_Mutect.vcf")
exp_colnames <- c("sample_id", "seqnames", "start", "end", "mutation_id", "ref_counts", "var_counts")

test_that("SNV reading works", {
  files <- c("../testdata/S1_Mutect.vcf")
  ids <- c("S1_P1", "S1_L1")
  df <- read_vcf(files, ids)
  expect_true(is.data.frame(df))
})

test_that("VCF recognizing works", {
  files <- c("../testdata/S1_Mutect.vcf")
  expect_identical(recognize_vcf_algorithm(files), "Mutect")
  expect_error(recognize_vcf_algorithm("../testdata/S1_P1.csv"))
})

test_that("Mutect reading works", {
  files <- c("../testdata/S1_Mutect.vcf")
  ids <- c("S1_P1", "S1_L1")
  df <- read_mutect(files, ids)
  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_colnames)
})
