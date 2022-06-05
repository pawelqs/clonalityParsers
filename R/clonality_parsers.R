

#' Pyclone_VI input parser
#'
#' @param vcf_file Path to VCF file
#' @param cnv_files Path to CNV files
#' @param sample_ids Sample IDs
#' @param sex "male"/"female"
#' @param genome_build eg. "hg38"
#'
#' @return parsed tibble
#' @export
prepare_pycloneVI_input <- function(vcf_file, cnv_files, sample_ids, sex, genome_build) {
  cnvs <- read_cnvs(cnv_files, sample_ids, sex, genome_build)
  snvs <- read_vcf(vcf_file, sample_ids)

  res <- merge_muts_with_cnvs(snvs, cnvs) %>%
    select(
      mutation_id,
      sample_id,
      ref_counts,
      alt_counts = var_counts,
      major_cn,
      minor_cn,
      normal_cn,
      tumour_content = 1
    ) %>%
    drop_na() %>%
    filter(major_cn > 0)

  res
}


merge_muts_with_cnvs <- function(muts, cnvs) {
  muts %>%
    as_granges() %>%
    join_overlap_left(cnvs) %>%
    as.data.frame() %>%
    filter(sample_id.x == sample_id.y) %>%
    mutate(sample_id = sample_id.x)
}
