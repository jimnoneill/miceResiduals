\name{calculate_residual_differences}
\alias{calculate_residual_differences}
\title{Calculate Residual Differences Between Models}
\usage{
calculate_residual_differences(mice_object, model1_residuals, 
                              model2_residuals, new_var_name)
}
\arguments{
\item{mice_object}{A mids object with residual variables already added}

\item{model1_residuals}{Name of the first residual variable}

\item{model2_residuals}{Name of the second residual variable}

\item{new_var_name}{Name for the new difference variable}
}
\value{
Updated mids object with residual difference variable added
}
\description{
Calculate the difference between residuals from two models. This is useful
for isolating the effect of specific variables (like marijuana exposure).
}
\examples{
\dontrun{
# After adding residuals, calculate differences
result <- calculate_residual_differences(
  result,
  "residuals_exp_base",
  "residuals_exp_mj", 
  "residuals_mj_diff"
)
}
}

