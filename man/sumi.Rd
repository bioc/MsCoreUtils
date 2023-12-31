% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sumi.R
\name{sumi}
\alias{sumi}
\title{Summing MS Intensity Values}
\usage{
sumi(x)
}
\arguments{
\item{x}{\code{numeric} with intensity values to be summed up. Will be coerced
to \code{numeric} using \code{as.double}.}
}
\value{
\code{numeric(1)} representing the sum of values in \code{x}. Always returns
a numeric (double) even if \code{x} is an integer.
}
\description{
\code{sumi} sums mass spectrometry intensity values, e.g. from a spectrum or
chromatogram. In contrast to the base R \code{\link[=sum]{sum()}} function this function
returns \code{NA_real_} if all intensity values are \code{NA} or if \code{length(x)} is 0.
}
\examples{

x <- c(3.2, 34.4, 1.3, NA)
sumi(x)

## Compared to base R sum:
sum(x)
sum(x, na.rm = TRUE)

sum(numeric(), na.rm = TRUE)
sumi(numeric())

sum(c(NA, NA), na.rm = TRUE)
sumi(c(NA, NA))
}
\seealso{
\code{\link[=maxi]{maxi()}}
}
\author{
Johannes Rainer
}
