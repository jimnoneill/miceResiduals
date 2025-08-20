\name{build_exposure_models}
\alias{build_exposure_models}
\title{Build Exposure Models for Multiple Imputation}
\usage{
build_exposure_models(mice_object, outcome_vars, base_predictors, 
                     marijuana_var = NULL, family = gaussian())
}
\arguments{
\item{mice_object}{A mids object containing multiply imputed data}

\item{outcome_vars}{Character vector of outcome variable names}

\item{base_predictors}{Character vector of base predictor variable names}

\item{marijuana_var}{Name of marijuana exposure variable (optional)}

\item{family}{Model family (default: gaussian())}
}
\value{
A named list of mira objects (fitted models)
}
\description{
A helper function to build multiple exposure models commonly used in
environmental health research, particularly cannabis exposure studies.
}
\details{
This function creates standardized exposure models for analysis
of environmental exposures. It builds models with and without marijuana
exposure variables for comparison.
}
\examples{
\dontrun{
# Define your variables
outcomes <- c("meancountsM", "AGG5_PGE15000M")
predictors <- c("AirNicotineugm3", "cig7new", "cigar7new", "pipe7new")

# Build models
models <- build_exposure_models(
  mice_object = imp_data,
  outcome_vars = outcomes,
  base_predictors = predictors,
  marijuana_var = "mj7yes"
)
}
}



