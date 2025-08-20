\name{add_residuals_to_mice}
\alias{add_residuals_to_mice}
\title{Add Model Residuals to Multiply Imputed Datasets}
\usage{
add_residuals_to_mice(mice_object, models, seed = 10000, max_iter = 50)
}
\arguments{
\item{mice_object}{A mids object from the mice package containing multiply imputed data}

\item{models}{A named list of model objects fitted with mice::with(). Each model should
be fitted to the same mice object. Names will be used as suffixes for residual variables.}

\item{seed}{Random seed for reproducibility (default: 10000)}

\item{max_iter}{Maximum iterations for dummy mice call (default: 50)}
}
\value{
A mids object with residuals added as new variables
}
\description{
This function takes multiply imputed datasets (mids object) and fitted models,
extracts residuals from each imputation, adds them as new variables to the
datasets, and repacks everything into a proper mids format.
}
\details{
This function addresses the limitation that RCS (Restricted Cubic Spline) models
don't work directly on multiple datasets. It:
\enumerate{
  \item Extracts completed datasets from the mids object
  \item Adds residuals from fitted models as new variables
  \item Creates a dummy mids object with the expanded variable set  
  \item Repacks all data maintaining the original mids structure
}

The process preserves all original imputation metadata while adding the residual variables.
This is particularly useful for cannabis research and other applications where you need
to work with model residuals in multiple imputation contexts.
}
\examples{
\dontrun{
# Assume you have a mids object called 'imp_data'
# First fit your models
exposure_model <- with(imp_data, glm(outcome ~ predictor1 + predictor2, family = gaussian()))
exposure_model_mj <- with(imp_data, glm(outcome ~ marijuana + predictor1 + predictor2, 
                                       family = gaussian()))

# Create named list of models
models <- list(
  "exp" = exposure_model,
  "exp_mj" = exposure_model_mj
)

# Add residuals to the mids object
result <- add_residuals_to_mice(imp_data, models, seed = 12345)

# Now you can access residuals in your analysis
pooled_result <- with(result, glm(new_outcome ~ residuals_exp, family = gaussian()))
summary(pool(pooled_result))
}
}
