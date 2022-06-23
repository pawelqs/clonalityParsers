exp_colnames <- c("sample_id", "seqnames", "start", "end", "mutation_id", "ref_reads", "alt_reads")
FACETS_files <- c(
  S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
  S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
)
Mutect_file <- system.file("testdata", "S1_Mutect.vcf", package = "clonalityParsers")
S1_sample_ids <- c("S1_P1", "S1_L1")

test_that("SNV reading works", {
  df <- read_vcf(Mutect_file, S1_sample_ids)
  expect_true(is.data.frame(df))
})

test_that("VCF recognizing works", {
  expect_identical(recognize_vcf_algorithm(Mutect_file), "Mutect")
  expect_error(recognize_vcf_algorithm(FACETS_files[[1]]))
})

test_that("Mutect reading works", {
  df <- read_mutect(Mutect_file, S1_sample_ids)
  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_colnames)
})
