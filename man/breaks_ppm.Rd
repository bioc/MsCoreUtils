% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/binning.R
\name{breaks_ppm}
\alias{breaks_ppm}
\title{Sequence with increasing difference between elements}
\usage{
breaks_ppm(from = 1, to = 1, by = 1, ppm = 0)
}
\arguments{
\item{from}{\code{numeric(1)} with the value from which the sequence should start.}

\item{to}{\code{numeric(1)} defining the upper bound of the sequence. Note that
the last value of the result will not be equal to \code{to} but equal to the
first number in the sequence which is larger than this value.}

\item{by}{\code{numeric(1)} defining the constant part of the difference by which
numbers should increase.}

\item{ppm}{\code{numeric(1)} defining the variable part of the difference by
which numbers should increase (expressed in parts-per-million of the
values).}
}
\value{
\code{numeric} with the sequence of values with increasing differences.
The returned values include \code{from} and \code{to}.
}
\description{
\code{breaks_ppm} creates a sequence of numbers with increasing differences
between them. Parameter \code{ppm} defines the amount by which the difference
between values increases. The value for an element \code{i+1} is calculated by
adding \code{size} to the value of element \code{i} and in addition also the
\code{ppm(a, ppm)}, where \code{a} is the value of the element \code{i} plus \code{size}. This
iterative calculation is stopped once the value of an element is larger
than \code{to}. The last value in the result vector will thus not be equal to
\code{to} (which is in contrast to the base \code{\link[=seq]{seq()}} function) but slightly
higher.

A typical use case of this function would be to calculate breaks for the
binning of m/z values of mass spectra. This function allows to create
m/z-relative bin sizes which better represents measurement errors observed
on certain mass spectrometry instruments.
}
\examples{

res <- breaks_ppm(20, 50, by = 1, ppm = 50)
res

## difference between the values increases (by ppm)
diff(res)
}
\author{
Johannes Rainer
}
