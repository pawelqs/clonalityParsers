
get_purities <- function(purity = NULL, cnvs = NULL, snvs = NULL, sample_ids = NULL,
                         purity_files = NULL) {
  if (length(purity) == 1 && purity == "FACETS") {
    cnvs %>%
      as_tibble() %>%
      select(sample_id, purity) %>%
      unique()
  } else if (length(purity) == 1 && is.numeric(purity)) {
    tibble(
      sample_id = sample_ids,
      purity = purity
    )
  } else if ((length(purity) == length(sample_ids)) && is.numeric(purity)) {
    tibble(
      sample_id = sample_ids,
      purity = purity
    )
  } else if (is.null(purity)) {
    tibble(
      sample_id = sample_ids,
      purity = NA_real_
    )  }
}
