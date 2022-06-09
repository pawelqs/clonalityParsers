FACETS_cols <- c("sample_id", "total_cn", "minor_cn", "major_cn", "purity", "normal_cn")
FACETS_files <- c(
  S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
  S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
)
Mutect_file <- system.file("testdata", "S1_Mutect.vcf", package = "clonalityParsers")

test_that("CNV reading works", {
  files <- FACETS_files
  ids <- names(FACETS_files)
  res <- read_cnvs(files, ids, sex = "male", genome_build = "hg38")
  expect_true("GRanges" %in% class(res))
  expect_identical(colnames(res@elementMetadata), FACETS_cols)
  expect_error(read_cnvs(Mutect_file, ids, sex = "male", genome_build = "hg38"))
})

test_that("CNV recognizing works", {
  files <- FACETS_files
  expect_identical(recognize_cnv_algorithm(files), "FACETS")
  expect_error(recognize_cnv_algorithm(Mutect_file))
})

test_that("FACETS reading works", {
  files <- FACETS_files
  ids <- names(FACETS_files)
  df <- read_FACETS(files, ids)
  expect_true(is.data.frame(df))
})
