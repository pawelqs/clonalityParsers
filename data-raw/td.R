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

td <- read_files(Mutect_file, FACETS_files, sample_ids = S1_sample_ids, sex = S1_sex)

usethis::use_data(td, overwrite = TRUE)
