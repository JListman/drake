% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read_drake_meta}
\alias{read_drake_meta}
\title{Read the metadata of a target or import.}
\usage{
read_drake_meta(targets = NULL, path = getwd(), search = TRUE,
  cache = NULL, verbose = 1, jobs = 1)
}
\arguments{
\item{targets}{character vector, names of the targets
to get metadata. If \code{NULL}, all metadata is collected.}

\item{path}{Root directory of the drake project,
or if \code{search} is \code{TRUE}, either the
project root or a subdirectory of the project.}

\item{search}{logical. If \code{TRUE}, search parent directories
to find the nearest drake cache. Otherwise, look in the
current working directory only.}

\item{cache}{optional drake cache. See code{\link{new_cache}()}.
If \code{cache} is supplied,
the \code{path} and \code{search} arguments are ignored.}

\item{verbose}{whether to print console messages}

\item{jobs}{number of jobs for light parallelism.
Supports 1 job only on Windows.}
}
\value{
The cached master internal configuration list
of the last \code{\link[=make]{make()}}.
}
\description{
The metadata helps determine if the
target is up to date or outdated. The metadata of imports
is used to compute the metadata of targets.
}
\details{
Target metadata is computed
with \code{\link[=drake_meta]{drake_meta()}} and then
\code{drake:::finish_meta()}.
This metadata corresponds
to the state of the target immediately after it was built
or imported in the last \code{\link[=make]{make()}} that
did not skip it.
The exception to this is the \code{$missing} element
of the metadata, which indicates if the target/import
was missing just \emph{before} it was built.
}
\examples{
\dontrun{
test_with_dir("Quarantine side effects.", {
load_basic_example() # Get the code with drake_example("basic").
make(my_plan) # Run the project, build the targets.
# Retrieve the build decision metadata for one target.
read_drake_meta(targets = "small")
# Retrieve the build decision metadata for all targets,
# parallelizing over 2 jobs.
read_drake_meta(jobs = 2)
})
}
}
\seealso{
\code{\link[=dependency_profile]{dependency_profile()}}, \code{\link[=make]{make()}}
}
