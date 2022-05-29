

prepare_pycloneVI_input <- function(snv_files, cnv_files, sample_ids, genome_build) {
  cnv_algorithm <- rocognize_cnv_algorithm(cnv_files)
  # snv_algorithm <- rocognize_snv_algorithm()
  cnvs <- read_cnvs(cnv_files, sample_ids, cnv_algorithm, genome_build)
  # snvs <- read_snvs(snv_files, snv_algorithm)

  # join snv with cnv
  # muts %>%
  #   as_granges() %>%
  #   join_overlap_left(cnvs) %>%
  #   as.data.frame() %>%
  #   select(mutation_id, ref_counts, var_counts, normal_cn, minor_cn, major_cn) %>%
  #   drop_na() %>%
  #   filter(major_cn > 0)

  # tibble(
  #   mutation_id = NULL,
  #   sample_id = NULL,
  #   ref_counts = NULL,
  #   alt_counts = NULL,
  #   major_cn = NULL,
  #   minor_cn = NULL,
  #   normal_cn = NULL,
  #   tumour_content = NULL
  # )
}

