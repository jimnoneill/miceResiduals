\name{repack_mice_with_residuals}
\alias{repack_mice_with_residuals}
\title{Repack Completed Data into MIDS Format}
\usage{
repack_mice_with_residuals(completed_data, seed = 10000, max_iter = 50)
}
\arguments{
\item{completed_data}{List of completed data frames}

\item{seed}{Random seed used in original imputation}

\item{max_iter}{Maximum iterations from original imputation}
}
\value{
A mids object
}
\description{
Takes a list of completed datasets and repacks them into a proper mids object.
This is a utility function used internally by other functions.
}
\details{
This function handles the technical details of converting a list of
data frames back into the mids format expected by the mice package.
}

