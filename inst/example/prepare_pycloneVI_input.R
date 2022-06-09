# install.packages("tidyverse")
# install.packages("remotes")
# install.packages("optparse")

remotes::install_github("https://github.com/pawel125/clonalityParsers.git")

suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(clonalityParsers))

option_list <- list(
  make_option(c("-s", "--vcf_file"), dest = "vcf_file",
              help="Path to VCF file"),
  make_option(c("-c", "--cnv_files"), dest="cnv_files",
              help="Path to CNV files"),
  make_option(c("-c", "--sample_ids"), dest = "sample_ids",
              help="Sample IDs"),
  make_option("--sex", dest = "sex",
              help = "male/female"),
  make_option("--genome_build", dest = "genome_build",
              help="eg. hg38, passed to GenomeInfoDb::seqinfo()"),
  make_option("--snv_algorithm", dest = "snv_algorithm",
              help="algorithm used for SNVs detection, will be recognized if NULL, default: NULL"),
  make_option("--cnv_algorithm", dest = "cnv_algorithm",
              help="algorithm used for CNVs detection, will be recognized if NULL, default: NULL"),
  make_option("--filename", dest = "filename",
              help="File name to create on disk, default: NULL, no save")
)

opt <- parse_args(OptionParser(option_list=option_list))

prepare_pycloneVI_input(
  vcf_file, cnv_files,
  sample_ids, sex, genome_build,
  snv_algorithm, cnv_algorithm,
  filename
)


