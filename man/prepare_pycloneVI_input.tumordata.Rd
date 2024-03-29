% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clonality_parsers.R
\name{prepare_pycloneVI_input.tumordata}
\alias{prepare_pycloneVI_input.tumordata}
\title{Parses tumordata object into PyClone-VI input format}
\usage{
\method{prepare_pycloneVI_input}{tumordata}(td, filename = NULL)
}
\arguments{
\item{td}{(required) tumordata object}

\item{filename}{File name to create on disk, default: NULL}
}
\value{
parsed tibble
}
\description{
Parses tumordata object into PyClone-VI input format
}
\examples{
data(td)
pyclonevi_input <- prepare_pycloneVI_input(td)
}
