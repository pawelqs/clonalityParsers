
read_vcf <- function(vcf_file, sample_ids, sex = NULL, snv_algorithm = NULL, filters = NULL) {
  if (is.null(snv_algorithm)){
    snv_algorithm <- recognize_vcf_algorithm(vcf_file)
  }
  if (snv_algorithm == "Mutect") {
    snvs <- read_mutect(vcf_file, sample_ids)
  }

  snvs %>%
    drop_sex_chromosomes_if_sex_unknown(sex)
}


recognize_vcf_algorithm <- function(vcf_file) {
  vcf <- read.vcfR(vcf_file, verbose = FALSE)
  meta <- vcf@meta
  if (any(str_detect(meta, "##MutectVersion"))) {
    return("Mutect")
  } else {
    stop("Unknown VCF type!")
  }
}


read_mutect <- function(vcf_file, sample_ids) {
  tidy_vcf <- vcf_file %>%
    read.vcfR(verbose = FALSE) %>%
    vcfR2tidy(format_fields = "AD", verbose = FALSE)
  inner_join(
    filter(tidy_vcf$fix, FILTER == "PASS"),
    filter(tidy_vcf$gt, !is.na(gt_AD)),
    by = c("ChromKey", "POS")
  ) %>%
    transmute(
      sample_id = Indiv,
      seqnames = if_else(str_detect(CHROM, "chr"), CHROM, str_c("chr", CHROM)),
      start = POS,
      end = POS,
      mutation_id = str_c(seqnames, POS, sep = "_"),
      gt_AD,
      n_variants = str_split(gt_AD, ",") %>%
        map_int(length)
    ) %>%
    filter(n_variants == 2, sample_id %in% sample_ids) %>%
    separate(gt_AD, into = c("ref_reads", "alt_reads")) %>%
    mutate(
      ref_reads = parse_double(ref_reads),
      alt_reads = parse_double(alt_reads)
    ) %>%
    select(-n_variants)
}


drop_sex_chromosomes_if_sex_unknown <- function(df, sex) {
  if (is.null(sex))
    filter(df, !seqnames %in% c("chrX", "chrY"))
  else
    df
}
