

#' Parses SNV and CNV calls into PyClone-VI input format
#'
#' @param vcf_file Path to VCF file
#' @param cnv_files Path to CNV files
#' @param sample_ids Sample IDs
#' @param sex "male"/"female"
#' @param genome_build eg. "hg38"
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
#' S1_sample_ids <- c("S1_P1", "S1_L1")
#' S1_genome_build <- "hg38"
#' S1_sex <- "male"
#'
#' df <- prepare_pycloneVI_input(
#'   Mutect_file, FACETS_files,
#'   sample_ids = S1_sample_ids, sex = S1_sex, genome_build = S1_genome_build)
prepare_pycloneVI_input <- function(vcf_file, cnv_files,
                                    sample_ids, sex, genome_build,
                                    snv_algorithm = NULL, cnv_algorithm = NULL,
                                    filename = NULL) {

  cnvs <- read_cnvs(cnv_files, sample_ids, sex, genome_build, cnv_algorithm)
  snvs <- read_vcf(vcf_file, sample_ids, snv_algorithm)

  parsed <- merge_muts_with_cnvs(snvs, cnvs) %>%
    select(mutation_id, sample_id, ref_counts, alt_counts = var_counts,
           major_cn, minor_cn, normal_cn) %>%
    drop_na() %>%
    filter(major_cn > 0)

  if (!is.null(filename))
    write_tsv(parsed, filename)

  parsed
}


merge_muts_with_cnvs <- function(muts, cnvs) {
  muts %>%
    as_granges() %>%
    join_overlap_left(cnvs) %>%
    as.data.frame() %>%
    filter(sample_id.x == sample_id.y) %>%
    mutate(sample_id = sample_id.x)
}
