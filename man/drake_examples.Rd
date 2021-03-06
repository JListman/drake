% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/examples.R
\name{drake_examples}
\alias{drake_examples}
\title{List the names of all the drake examples.}
\usage{
drake_examples()
}
\value{
Names of all the drake examples.
}
\description{
The \code{'basic'} example is the one from the
quickstart vignette: \code{vignette('quickstart')}.
All are in the \code{inst/examples/} folder
of the package source code.
}
\examples{
\dontrun{
test_with_dir("Quarantine side effects.", {
drake_examples() # List all the drake examples.
# Sets up the same example as the quickstart vignette.
drake_example("basic")
# Sets up the SLURM example.
drake_example("slurm")
})
}
}
\seealso{
\code{\link[=drake_example]{drake_example()}}, \code{\link[=make]{make()}}
}
