
drop_sex_chromosomes_if_sex_unknown <- function(df, sex) {
  if (is.null(sex))
    filter(df, !seqnames %in% c("chrX", "chrY"))
  else
    df
}
