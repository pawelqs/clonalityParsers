
#' Filters SNVdata in tumordata object
#'
#' @param td (required) tumordata object
#' @param filter_min_DP minimal sequencing depth of mutation required in at least one sample
#' @param filter_min_alt_reads minimal alt_reads of mutation required in at least one sample
#'
#' @return tumordata object
#' @export
#'
#' @examples
#' data(td)
#' filter(td, filter_min_DP = 10, filter_min_alt_reads = 0)
filter_SNVs <- function(td, filter_min_DP = 0, filter_min_alt_reads = 0) {
  UseMethod("filter_SNVs")
}


#' @export
filter_SNVs.tumordata <- function(td, filter_min_DP = 0, filter_min_alt_reads = 0) {

  if (!is.null(filter_min_DP)) {
    muts_passed_in_any_sample <- td$snvs %>%
      filter(ref_reads + alt_reads >= filter_min_DP) %>%
      pull(mutation_id) %>%
      unique()
    td$snvs <- filter(td$snvs, mutation_id %in% muts_passed_in_any_sample)
  }

  if (!is.null(filter_min_alt_reads)) {
    muts_passed_in_any_sample <- td$snvs %>%
      filter(alt_reads >= filter_min_alt_reads) %>%
      pull(mutation_id) %>%
      unique()
    td$snvs <- filter(td$snvs, mutation_id %in% muts_passed_in_any_sample)
  }

  td
}


#' Parses tumordata object into PyClone-VI input format
#'
#' @param td (required) tumordata object
#' @param filename File name to create on disk, default: NULL
#'
#' @return parsed tibble
#' @export
#'
#' @examples
#' data(td)
#' pyclonevi_input <- prepare_pycloneVI_input(td)
prepare_pycloneVI_input <- function(td, filename) {
  UseMethod("prepare_pycloneVI_input")
}


#' @export
prepare_pycloneVI_input.tumordata <- function(td, filename = NULL) {
  parsed <- merge_muts_with_cnvs(td$snvs, td$cnvs) %>%
    select(mutation_id, sample_id, ref_counts = ref_reads, alt_counts = alt_reads,
           major_cn, minor_cn, normal_cn) %>%
    drop_na() %>%
    filter(major_cn > 0) %>%
    left_join(td$purities, by = "sample_id")

  parsed <-
    if (all(is.na(td$purities$purity)))
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


#' @rdname prepare_pycloneVI_input
#' @export
prepare_CliP_input <- function(td, outdir, suffixes = c(".clip-snv.tsv", ".clip-cna.tsv", ".clip-purity.txt")) {
  UseMethod("prepare_CliP_input")
}


#' @export
prepare_CliP_input.tumordata <- function(td, outdir, suffixes = c(".clip-snv.tsv", ".clip-cna.tsv", ".clip-purity.txt")) {

  snvs <- td$snvs %>%
    select(sample_id, chromosome_index = seqnames, position = start,
           alt_count = alt_reads, ref_count = ref_reads) %>%
    group_by(sample_id) %>%
    nest() %>%
    deframe()

  cnas <- td$cnvs %>%
    as_tibble() %>%
    select(sample_id, chromosome_index = seqnames, start_position = start, end_position = end,
           major_cn, minor_cn, total_cn) %>%
    group_by(sample_id) %>%
    nest() %>%
    deframe()

  purities <- td$purities %>%
    replace_na(list(purity = 1)) %>%
    deframe()

  if (!is.null(outdir)) {
    iwalk(snvs, ~write_tsv(.x, file = create_path(outdir, .y, suffixes[[1]])))
    iwalk(cnas, ~write_tsv(.x, file = create_path(outdir, .y, suffixes[[2]])))
    iwalk(purities, function(purity, sample_id) {
      f <- file(create_path(outdir, sample_id, suffixes[[3]]))
      print(purity)
      writeLines(as.character(purity), f)
      close(f)
    })
  }

  lst(snvs, cnas, purities)
}


create_path <- function(outdir, sample_id, suffix) {
  str_c(outdir, "/", sample_id, suffix) %>%
    str_replace("//", "/")
}

