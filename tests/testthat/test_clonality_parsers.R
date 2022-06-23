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

data(td)


test_that("tumordata creation works", {
  expect_s3_class(td, "tumordata")
  expect_identical(names(td), c("snvs", "cnvs", "purities"))
})


test_that("tumordata filtering works", {
  td1 <- filter_SNVs(td)
  expect_identical(td, td1)

  td2 <- filter_SNVs(td, filter_min_DP = 100)
  exp_mutations <- c("chr1_100", "chr1_100", "chr2_100", "chr2_100")
  expect_identical(td2$snvs$mutation_id, exp_mutations)

  td3 <- filter_SNVs(td, filter_min_alt_reads = 5)
  exp_mutations <- c("chr2_100", "chr2_100")
  expect_identical(td3$snvs$mutation_id, exp_mutations)
})


test_that("Pyclone-VI parser without purity works", {
  df <- prepare_pycloneVI_input(td)
  exp <- read_tsv(S1_pyclonevi_exp_file, col_types = "ccddddd")

  expect_true(is.data.frame(df))
  expect_identical(colnames(df), PyClone_VI_required_columns)
  expect_identical(df, exp)
})


test_that("Pyclone-VI parser with FACETS purity works", {
  td <- read_files(
    Mutect_file, FACETS_files, sample_ids = S1_sample_ids,
    purity = "FACETS", sex = S1_sex)
  df <- prepare_pycloneVI_input(td)
  exp <- read_tsv(S1_pyclonevi_exp_file, col_types = "ccddddd") %>%
    mutate(tumour_content = c(0.5, rep(c(0.5, 0.5056), times = 6)))
  exp_columns <- c(PyClone_VI_required_columns, PyClone_VI_purity_col)

  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_columns)
  expect_identical(df, exp)
})


test_that("Pyclone-VI parser with single purity value works", {
  td <- read_files(
    Mutect_file, FACETS_files, sample_ids = S1_sample_ids,
    purity = 1, sex = S1_sex)
  df <- prepare_pycloneVI_input(td)
  exp <- read_tsv(S1_pyclonevi_exp_file, col_types = "ccddddd") %>%
    mutate(., tumour_content = rep(1, times = nrow(.)))
  exp_columns <- c(PyClone_VI_required_columns, PyClone_VI_purity_col)

  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_columns)
  expect_identical(df, exp)
})


test_that("Test that parser drops sex chromosomes only if sex not provided", {
  td <- read_files(Mutect_file, FACETS_files, sample_ids = S1_sample_ids)
  sex_chrs_present <- any(str_detect(td$snvs$mutation_id, "chrX"))
  expect_false(sex_chrs_present)

  td <- read_files(Mutect_file, FACETS_files, sample_ids = S1_sample_ids, sex = "female")
  sex_chrs_present <- any(str_detect(td$snvs$mutation_id, "chrX"))
  expect_true(sex_chrs_present)
})


test_that("CliP input data preparation works", {
  temp_dir <- tempdir()
  prepare_CliP_input(td, temp_dir)
  expect_identical(
    read_tsv(create_path(temp_dir, "S1_L1", ".clip-snv.tsv")),
    read_tsv(system.file("testdata", "S1_L1.clip-snv.tsv", package = "clonalityParsers"))
  )
  expect_identical(
    read_tsv(create_path(temp_dir, "S1_L1", ".clip-cna.tsv")),
    read_tsv(system.file("testdata", "S1_L1.clip-cna.tsv", package = "clonalityParsers"))
  )
  expect_identical(
    read_tsv(create_path(temp_dir, "S1_L1", ".clip-purity.txt")),
    read_tsv(system.file("testdata", "S1_L1.clip-purity.txt", package = "clonalityParsers"))
  )
})


test_that("chr to int works", {
  chrs <- c("chr1", "chr1", "chr2", "chrX", "chrY")
  expect_identical(chromosomes_to_int(chrs), c(1, 1, 2, 98, 99))
})
