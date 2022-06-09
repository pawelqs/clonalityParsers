
rename_column_if_exist <- function(df, old, new) {
  if (old %in% names(df)) {
    df[new] <- df[old]
    df[old] <- NULL
  }
  df
}
