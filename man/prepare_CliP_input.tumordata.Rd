% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clonality_parsers.R
\name{prepare_CliP_input.tumordata}
\alias{prepare_CliP_input.tumordata}
\title{Parses tumordata object into CliP input format}
\usage{
\method{prepare_CliP_input}{tumordata}(
  td,
  outdir,
  suffixes = c(".clip-snv.tsv", ".clip-cna.tsv", ".clip-purity.txt")
)
}
\arguments{
\item{td}{(required) tumordata object}

\item{outdir}{directory to save CliP input files}

\item{suffixes}{suffixes for CliP input files}
}
\description{
Parses tumordata object into CliP input format
}
