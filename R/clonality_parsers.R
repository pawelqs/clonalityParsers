
#' Parses SNV and CNV calls into PyClone-VI input format
#'
#' @param vcf_file (required) Path to VCF file
#' @param cnv_files (required) Path to CNV files
#' @param sample_ids (required) Sample IDs
#' @param sex "male"/"female", if NULL - sex chromosomes will be dropped
#' @param genome_build eg. "hg38"
#' @param purity FACETS to use FACETS purity estimations, single value for all samples or
#'               single value per sample. Default: NULL (no purity column created)
#' @param purity_files currently not used
#' @param snv_algorithm algorithm used for SNVs detection, will be recognized if NULL, default: NULL
#' @param cnv_algorithm algorithm used for CNVs detection, will be recognized if NULL, default: NULL
#' @param filename File name to create on disk, default: NULL
#'
#' @return parsed tibble
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
#' df <- prepare_pycloneVI_input(Mutect_file, FACETS_files, sample_ids = sample_ids, sex = sex)
prepare_pycloneVI_input <- function(vcf_file, cnv_files, sample_ids,
                                    sex = NULL, genome_build = NULL,
                                    purity = NULL, purity_files = NULL,
                                    snv_algorithm = NULL, cnv_algorithm = NULL,
                                    filename = NULL) {

  cnvs <- read_cnvs(cnv_files, sample_ids, sex, cnv_algorithm, genome_build)
  snvs <- read_vcf(vcf_file, sample_ids, sex, snv_algorithm)
  purities <- get_purities(purity, cnvs, snvs, sample_ids, purity_files)

  parsed <- merge_muts_with_cnvs(snvs, cnvs) %>%
    select(mutation_id, sample_id, ref_counts, alt_counts = var_counts,
           major_cn, minor_cn, normal_cn) %>%
    drop_na() %>%
    filter(major_cn > 0) %>%
    left_join(purities, by = "sample_id")

  parsed <-
    if (is.null(purity))
      select(parsed, -purity)
    else
      rename(parsed, tumour_content = purity)

  if (!is.null(filename))
    write_tsv(parsed, filename)

  parsed
}


merge_muts_with_cnvs <- function(muts, cnvs) {
  muts %>%
    as_granges() %>%
    join_overlap_left(cnvs) %>%
    as_tibble() %>%
    filter(sample_id.x == sample_id.y) %>%
    mutate(sample_id = sample_id.x)
}
