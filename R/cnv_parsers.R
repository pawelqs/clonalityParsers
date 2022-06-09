
read_cnvs <- function(cnv_files, sample_ids, sex = NULL, cnv_algorithm = NULL, genome_build = NULL) {
  if (is.null(cnv_algorithm))
    cnv_algorithm <- recognize_cnv_algorithm(cnv_files)

  if (cnv_algorithm == "FACETS")
    cnvs <- read_FACETS(cnv_files, sample_ids)

  cnvs %>%
    drop_sex_chromosomes_if_sex_unknown(sex) %>%
    create_cnv_granges(genome_build) %>%
    add_normal_cn(sex)
}


recognize_cnv_algorithm <- function(cnv_files) {
  cnv_file <- file(cnv_files[[1]], "r")
  first_line <- readLines(cnv_file, n = 1)
  close(cnv_file)
  if (str_detect(first_line, "chrom,seg,num.mark,nhet,cnlr.median,mafR,segclust,cnlr.median.clust")) {
    return("FACETS")
  } else {
    stop("Unknown CNV input!")
  }
}


read_FACETS <- function(facets_files, sample_ids) {
  facets_files %>%
    set_names(sample_ids) %>%
    map(read_csv, col_types = "cddddddddddddddd") %>%
    bind_rows(.id = "sample_id") %>%
    transmute(
      sample_id,
      seqnames = if_else(str_detect(chrom, "chr"), chrom, str_c("chr", chrom)),
      start,
      end,
      total_cn = tcn.em,
      minor_cn = lcn.em,
      major_cn = total_cn - minor_cn,
      purity = Purity
    )
}


create_cnv_granges <- function(cnvs, genome_build = NULL) {
  if (is.null(genome_build)) {
    as_granges(cnvs)
  } else {
    chromosomes <-unique(cnvs$seqnames)
    seq_info <- genome_info(genome_build) %>%
      seqinfo() %>%
      as.data.frame() %>%
      rownames_to_column("chr") %>%
      filter(chr %in% chromosomes)

    cnvs %>%
      as_granges() %>%
      set_genome_info(
        genome = genome_build,
        seqnames = seq_info$chr,
        seqlengths = seq_info$seqlengths,
        is_circular = seq_info$isCircular
      )
  }
}


add_normal_cn <- function(cnvs, sex = NULL) {
  if (is.null(sex))
    sex <- "null"
  cnvs %>%
    sort() %>%
    mutate(
      chr = as.character(seqnames),
      normal_cn = case_when(
        chr %in% c("chrX", "chrY") & sex == "male" ~ 1,
        chr %in% c("chrX", "chrY") & sex == "null" ~ NA_real_,
        TRUE ~ 2
      )
    ) %>%
    select(-chr)
}


