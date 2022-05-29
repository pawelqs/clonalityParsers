
rocognize_cnv_algorithm <- function(cnv_files) {
  cnv_file <- file(cnv_files[[1]], "r")
  first_line <- readLines(cnv_file, n = 1)
  close(cnv_file)
  if (str_detect(first_line, "chrom,seg,num.mark,nhet,cnlr.median,mafR,segclust,cnlr.median.clust")) {
    return("FACETS")
  } else {
    stop("Unknown CNV input!")
  }
}


read_cnvs <- function(cnv_files, sample_ids, cnv_algorithm, genome_build) {
  if (cnv_algorithm == "FACETS") {
    cnvs <- read_FACETS(cnv_files, sample_ids)
  }
  create_cnv_granges(cnvs, genome_build)
}


#' Title
#'
#' @param facets_files sdf
#' @param sample_ids sf
#'
#' @return val
#' @export
read_FACETS <- function(facets_files, sample_ids) {
  facets_files %>%
    set_names(sample_ids) %>%
    map(read_csv) %>%
    bind_rows(.id = "sample_id") %>%
    transmute(
      sample_id,
      seqnames = if_else(str_detect(chrom, "chr"), chrom, str_c("chr", chrom)),
      start,
      end,
      total_cn = tcn.em,
      minor_cn = lcn.em,
      major_cn = total_cn - minor_cn
    )
}


#' Title
#'
#' @param cnv
#' @param genome_build
#'
#' @return
#' @export
#' @importFrom plyranges genome_info set_genome_info as_granges
#' @importFrom GenomeInfoDb seqinfo
create_cnv_granges <- function(cnvs, genome_build) {
  chromosomes <-unique(cnvs$seqnames)
  seq_info <- plyranges::genome_info(genome_build) %>%
    seqinfo() %>%
    as.data.frame() %>%
    rownames_to_column("chr") %>%
    filter(chr %in% chromosomes)

  as_granges(cnvs) %>%
    set_genome_info(
      genome = genome_build,
      seqnames = seq_info$chr,
      seqlengths = seq_info$seqlengths,
      is_circular = seq_info$isCircular
    )
}

# add_normal_regions <- function(cnv) {
#   normal_regions <- cnv %>%
#     compute_coverage() %>%
#     filter(score == 0) %>%
#     select(-score)
#
#   c(cnv, normal_regions) %>%
#     sort() %>%
#     mutate(
#       sex,
#       chr = as.character(seqnames),
#       normal_cn = if_else(chr == "chrY" & sex == "male", 1, 2),
#       minor_cn = replace_na(minor_cn, 0),
#       major_cn = if_else(is.na(major_cn), normal_cn, major_cn)
#     )
# }


