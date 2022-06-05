# cnv_files <- c("tests/testdata/S1_P1.csv", "tests/testdata/S1_L1.csv")
# vcf_file <- c("tests/testdata/S1_Mutect.vcf")
# sample_ids <- c("S1_P1", "S1_L1")
# genome_build <- "hg38"
# sex <- "male"
exp_header <- c("mutation_id", "sample_id", "ref_counts", "alt_counts",
                "major_cn", "minor_cn", "normal_cn", "tumour_content")

test_that("Pyclone-VI parser works", {
  cnv_files <- c("../testdata/S1_P1.csv", "../testdata/S1_L1.csv")
  vcf_file <- c("../testdata/S1_Mutect.vcf")
  ids <- c("S1_P1", "S1_L1")
  genome_build <- "hg38"
  sex <- "male"
  df <- prepare_pycloneVI_input(vcf_file, cnv_files, ids, sex, genome_build)
  expect_true(is.data.frame(df))
  expect_identical(colnames(df), exp_header)
})
