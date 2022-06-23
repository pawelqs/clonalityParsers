
new_tumordata <- function(x) {
  stopifnot(is.list(x))
  structure(x, class = "tumordata")
}


tumordata <- function(snvs, cnvs, purities) {
  x <- lst(snvs, cnvs, purities)
  new_tumordata(x)
}


#' Reads SNV and CNV calls tumordata object
#'
#' @param vcf_file (required) Path to VCF file
#' @param cnv_files (required) Path to CNV files
#' @param sample_ids (required) Sample IDs
#' @param sex "male"/"female"/"unknown", if NULL/unknown - sex chromosomes will be dropped
#' @param genome_build eg. "hg38"
#' @param purity FACETS to use FACETS purity estimations, single value for all samples or
#'               single value per sample. Default: NULL (no purity column created)
#' @param purity_files currently not used
#' @param snv_algorithm algorithm used for SNVs detection, will be recognized if NULL, default: NULL
#' @param cnv_algorithm algorithm used for CNVs detection, will be recognized if NULL, default: NULL
#'
#' @return tumordata object
#' @export
#'
#' @examples
#'
#' FACETS_files <- c(
#'   S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
#'   S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
#' )
#' Mutect_file <- system.file("testdata", "S1_Mutect.vcf", package = "clonalityParsers")
#' sample_ids <- c("S1_P1", "S1_L1")
#' sex <- "female"
#'
#' td <- read_files(Mutect_file, FACETS_files, sample_ids = sample_ids, sex = sex)
read_files <- function(vcf_file, cnv_files, sample_ids,
                       sex = NULL, genome_build = NULL,
                       purity = NULL, purity_files = NULL,
                       snv_algorithm = NULL, cnv_algorithm = NULL) {

  sex <- if (!is.null(sex) && sex == "unknown") NULL else sex
  cnvs <- read_cnvs(cnv_files, sample_ids, sex, cnv_algorithm, genome_build)
  snvs <- read_vcf(vcf_file, sample_ids, sex, snv_algorithm)
  purities <- get_purities(purity, cnvs, snvs, sample_ids, purity_files)
  tumordata(snvs, cnvs, purities)
}
