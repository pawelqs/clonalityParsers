FACETS_files <- c(
  S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
  S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
)
S1_FACETS_purities <- tibble(
  sample_id = names(FACETS_files),
  purity = c(0.5056, 0.5)
)


test_that("FACETS purity parsing works", {
  cnvs <- read_cnvs(FACETS_files, names(FACETS_files), sex = "male", genome_build = "hg38")
  pur <- get_purities(purity = "FACETS", cnvs = cnvs)
  expect_identical(pur, S1_FACETS_purities)
})


test_that("Test that parsing sample_wise numeric purities works", {
  pur <- get_purities(purity = c(0.8, 0.9), sample_ids = names(FACETS_files))
  exp <- tibble(
    sample_id = names(FACETS_files),
    purity = c(0.8, 0.9)
  )
  expect_identical(pur, exp)
})


test_that("Test that parsing single numeric purity works", {
  pur <- get_purities(purity = 0.4, sample_ids = names(FACETS_files))
  exp <- tibble(
    sample_id = names(FACETS_files),
    purity = c(0.4, 0.4)
  )
  expect_identical(pur, exp)
})


test_that("Test that returnung empty purity tibble works", {
  pur <- get_purities(sample_ids = names(FACETS_files))
  exp <- tibble(sample_id = names(FACETS_files))
  expect_identical(pur, exp)
})
