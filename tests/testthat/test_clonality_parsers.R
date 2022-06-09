exp_header <- c(
  "mutation_id", "sample_id", "ref_counts", "alt_counts",
  "major_cn", "minor_cn", "normal_cn" #,"tumour_content"
)
FACETS_files <- c(
  S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
  S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
)
Mutect_file <- system.file("testdata", "S1_Mutect.vcf", package = "clonalityParsers")
S1_sample_ids <- c("S1_P1", "S1_L1")
S1_genome_build <- "hg38"
S1_sex <- "male"


test_that("Pyclone-VI parser works", {
  df <- prepare_pycloneVI_input(
    Mutect_file, FACETS_files,
    sample_ids = S1_sample_ids, sex = S1_sex, genome_build = S1_genome_build)
  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_header)
})
