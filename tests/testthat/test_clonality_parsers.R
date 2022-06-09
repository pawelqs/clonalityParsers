PyClone_VI_required_columns <- c(
  "mutation_id", "sample_id", "ref_counts", "alt_counts",
  "major_cn", "minor_cn", "normal_cn"
)
PyClone_VI_purity_col <- "tumour_content"
FACETS_files <- c(
  S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
  S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
)
Mutect_file <- system.file("testdata", "S1_Mutect.vcf", package = "clonalityParsers")
S1_pyclonevi_exp_file <- system.file("testdata", "S1.expeted-pylonevi-input.tsv", package = "clonalityParsers")
S1_sample_ids <- c("S1_P1", "S1_L1")
S1_genome_build <- "hg38"
S1_sex <- "female"


test_that("Pyclone-VI parser without purity works", {
  df <- prepare_pycloneVI_input(Mutect_file, FACETS_files, sample_ids = S1_sample_ids, sex = S1_sex)
  exp <- read_tsv(S1_pyclonevi_exp_file, col_types = "ccddddd")

  expect_true(is.data.frame(df))
  expect_identical(colnames(df), PyClone_VI_required_columns)
  expect_identical(df, exp)
})


test_that("Pyclone-VI parser with FACETS purity works", {
  df <- prepare_pycloneVI_input(
    Mutect_file, FACETS_files, sample_ids = S1_sample_ids,
    purity = "FACETS", sex = S1_sex)
  exp <- read_tsv(S1_pyclonevi_exp_file, col_types = "ccddddd") %>%
    mutate(tumour_content = c(0.5, rep(c(0.5, 0.5056), times = 6)))
  exp_columns <- c(PyClone_VI_required_columns, PyClone_VI_purity_col)

  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_columns)
  expect_identical(df, exp)
})


test_that("Pyclone-VI parser with single purity value works", {
  df <- prepare_pycloneVI_input(
    Mutect_file, FACETS_files, sample_ids = S1_sample_ids,
    purity = 1, sex = S1_sex)
  exp <- read_tsv(S1_pyclonevi_exp_file, col_types = "ccddddd") %>%
    mutate(., tumour_content = rep(1, times = nrow(.)))
  exp_columns <- c(PyClone_VI_required_columns, PyClone_VI_purity_col)

  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_columns)
  expect_identical(df, exp)
})


test_that("Test that parser drops sex chromosomes only if sex not provided", {
  df <- prepare_pycloneVI_input(Mutect_file, FACETS_files, sample_ids = S1_sample_ids)
  sex_chrs_present <- any(str_detect(df$mutation_id, "chrX"))
  expect_false(sex_chrs_present)

  df <- prepare_pycloneVI_input(Mutect_file, FACETS_files, sample_ids = S1_sample_ids, sex = "female")
  sex_chrs_present <- any(str_detect(df$mutation_id, "chrX"))
  expect_true(sex_chrs_present)
})
