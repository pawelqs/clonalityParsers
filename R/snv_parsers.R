
read_vcf <- function(vcf_file, sample_ids) {
  snv_algorithm <- recognize_vcf_algorithm(vcf_file)
  if (snv_algorithm == "Mutect") {
    snvs <- read_mutect(vcf_file, sample_ids)
  }
  snvs
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
    vcfR2tidy(format_fields = "AD")
  inner_join(
    filter(tidy_vcf$fix, FILTER == "PASS"),
    filter(tidy_vcf$gt, !is.na(gt_AD))
  ) %>%
    transmute(
      sample_id = Indiv,
      seqnames = CHROM,
      start = POS,
      end = POS,
      mutation_id = str_c(seqnames, POS, sep = "_"),
      gt_AD,
      n_variants = str_split(gt_AD, ",") %>%
        map_int(length)
    ) %>%
    filter(n_variants == 2, sample_id %in% sample_ids) %>%
    separate(gt_AD, into = c("ref_counts", "var_counts")) %>%
    select(-n_variants)
}
