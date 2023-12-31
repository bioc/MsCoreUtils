% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ppm.R
\name{ppm}
\alias{ppm}
\title{PPM - Parts per Million}
\usage{
ppm(x, ppm)
}
\arguments{
\item{x}{\code{numeric}, value(s) used for ppm calculation, e.g. mz value(s).}

\item{ppm}{\code{numeric}, parts-per-million (ppm) value(s).}
}
\value{
\code{numeric}: parts-per-million of \code{x} (always a positive value).
}
\description{
\code{ppm} is a small helper function to determine the parts-per-million for a
user-provided value and ppm.
}
\examples{
ppm(c(1000, 2000), 5)

ppm(c(-300, 200), 5)
}
\author{
Sebastian Gibb
}
\concept{helper functions for users}
