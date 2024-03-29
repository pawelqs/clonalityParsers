% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tumordata_loading.R
\name{read_files}
\alias{read_files}
\title{Reads SNV and CNV calls tumordata object}
\usage{
read_files(
  vcf_file,
  cnv_files,
  sample_ids,
  sex = NULL,
  genome_build = NULL,
  purity = NULL,
  purity_files = NULL,
  snv_algorithm = NULL,
  cnv_algorithm = NULL
)
}
\arguments{
\item{vcf_file}{(required) Path to VCF file}

\item{cnv_files}{(required) Path to CNV files}

\item{sample_ids}{(required) Sample IDs}

\item{sex}{"male"/"female"/"unknown", if NULL/unknown - sex chromosomes will be dropped}

\item{genome_build}{eg. "hg38"}

\item{purity}{FACETS to use FACETS purity estimations, single value for all samples or
single value per sample. Default: NULL (no purity column created)}

\item{purity_files}{currently not used}

\item{snv_algorithm}{algorithm used for SNVs detection, will be recognized if NULL, default: NULL}

\item{cnv_algorithm}{algorithm used for CNVs detection, will be recognized if NULL, default: NULL}
}
\value{
tumordata object
}
\description{
Reads SNV and CNV calls tumordata object
}
\examples{

FACETS_files <- c(
  S1_P1 = system.file("testdata", "S1_P1.csv", package = "clonalityParsers"),
  S1_L1 = system.file("testdata", "S1_L1.csv", package = "clonalityParsers")
)
Mutect_file <- system.file("testdata", "S1_Mutect.vcf", package = "clonalityParsers")
sample_ids <- c("S1_P1", "S1_L1")
sex <- "female"

td <- read_files(Mutect_file, FACETS_files, sample_ids = sample_ids, sex = sex)
}
