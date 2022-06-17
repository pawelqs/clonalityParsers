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

test_that("SNVs filtering works", {
  df <- read_mutect(Mutect_file, S1_sample_ids)

  df2 <- filter_SNVs(df)
  expect_identical(df, df2)

  df3 <- filter_SNVs(df, filters = list(filter_min_DP = 100))
  exp_mutations <- c("chr1_100", "chr1_100", "chr2_100", "chr2_100")
  expect_identical(df3$mutation_id, exp_mutations)

  df4 <- filter_SNVs(df, filters = list(filter_min_alt_reads = 5))
  exp_mutations <- c("chr2_100", "chr2_100")
  expect_identical(df4$mutation_id, exp_mutations)
  })
