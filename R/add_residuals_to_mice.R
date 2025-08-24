# miceResiduals: Multiple Imputation and Residual Integration for RCS
# Copyright (c) 2024 Jim O'Neill
# Licensed under the MIT License - see LICENSE file for details
# 
# Originally developed for cannabis exposure research in environmental health
# Released as open source software to benefit the research community

#' Add Model Residuals to Multiply Imputed Datasets
#'
#' This function takes multiply imputed datasets (mids object) and fitted models,
#' extracts residuals from each imputation, adds them as new variables to the
#' datasets, and repacks everything into a proper mids format.
#'
#' @param mice_object A mids object from the mice package containing multiply imputed data
#' @param models A named list of model objects fitted with mice::with(). Each model should
#'   be fitted to the same mice object. Names will be used as suffixes for residual variables.
#' @param seed Random seed for reproducibility (default: 10000)
#' @param max_iter Maximum iterations for dummy mice call (default: 50)
#'
#' @return A mids object with residuals added as new variables
#'
#' @details This function addresses the limitation that RCS (Restricted Cubic Spline) models
#' don't work directly on multiple datasets. It:
#' \enumerate{
#'   \item Extracts completed datasets from the mids object
#'   \item Adds residuals from fitted models as new variables
#'   \item Creates a dummy mids object with the expanded variable set  
#'   \item Repacks all data maintaining the original mids structure
#' }
#'
#' The process preserves all original imputation metadata while adding the residual variables.
#' This is particularly useful for cannabis research and other applications where you need
#' to work with model residuals in multiple imputation contexts.
#'
#' @examples
#' \dontrun{
#' # Assume you have a mids object called 'imp_data'
#' # First fit your models
#' exposure_model <- with(imp_data, glm(outcome ~ predictor1 + predictor2, family = gaussian()))
#' exposure_model_mj <- with(imp_data, glm(outcome ~ marijuana + predictor1 + predictor2, 
#'                                         family = gaussian()))
#' 
#' # Create named list of models
#' models <- list(
#'   "exp" = exposure_model,
#'   "exp_mj" = exposure_model_mj
#' )
#' 
#' # Add residuals to the mids object
#' result <- add_residuals_to_mice(imp_data, models, seed = 12345)
#' 
#' # Now you can access residuals in your analysis
#' pooled_result <- with(result, glm(new_outcome ~ residuals_exp, family = gaussian()))
#' summary(pool(pooled_result))
#' }
#'
#' @export
#' @importFrom mice complete mice
#' @importFrom purrr map
#' @importFrom dplyr %>%
#' @importFrom stats as.formula
add_residuals_to_mice <- function(mice_object, models, seed = 10000, max_iter = 50) {
  
  # Input validation
  if (!inherits(mice_object, "mids")) {
    stop("mice_object must be a mids object from the mice package")
  }
  
  # Check if models is a named list first
  if (!is.list(models) || length(models) == 0) {
    stop("models must be a named list of model objects")
  }
  
  # Check if models has names
  if (is.null(names(models)) || any(names(models) == "")) {
    stop("models must be a named list of model objects")
  }
  
  # Special check: if models is a mira object (single model), it's not what we want
  if (inherits(models, "mira")) {
    stop("models must be a named list of model objects")
  }
  
  # Check that all models are mira objects (fitted with mice::with)
  for (i in seq_along(models)) {
    if (!inherits(models[[i]], "mira")) {
      stop(paste("Model", names(models)[i], "must be fitted with mice::with()"))
    }
  }
  
  # Get number of imputations
  m <- mice_object$m
  
  # Extract all completed datasets
  message("Extracting completed datasets...")
  completed_data <- complete(mice_object, "all")
  
  # Add residuals for each model to all datasets
  message("Adding residuals from models...")
  for (model_name in names(models)) {
    model <- models[[model_name]]
    resid_var_name <- paste0("residuals_", model_name)
    
    message(paste("Processing model:", model_name))
    
    # Add residuals to each imputation
    for (i in 1:m) {
      if (i <= length(model$analyses)) {
        completed_data[[i]][[resid_var_name]] <- model$analyses[[i]]$residuals
      } else {
        stop(paste("Model", model_name, "has fewer analyses than imputations in mice_object"))
      }
    }
  }
  
  # Set class for completed data
  class(completed_data) <- c("mild", "list")
  
  # Create dummy mids object to get the structure right
  message("Creating new mids structure...")
  set.seed(seed)
  dummy_mice <- mice(completed_data[[1]], printFlag = FALSE, m = 1, maxit = 1)
  
  # Fill dummy object with all imputed data
  variable_names <- names(dummy_mice$data)
  for (var_name in variable_names) {
    var_data <- map(completed_data, var_name)
    dummy_mice$imp[[var_name]] <- do.call(cbind, var_data)
  }
  
  # Set proper mids class and metadata
  class(dummy_mice) <- "mids"
  dummy_mice$m <- m
  dummy_mice$iteration <- max_iter
  dummy_mice$seed <- seed
  
  message("Successfully added residuals to mids object")
  return(dummy_mice)
}

#' Build Exposure Models for Multiple Imputation
#'
#' A helper function to build multiple exposure models commonly used in
#' environmental health research, particularly cannabis exposure studies.
#'
#' @param mice_object A mids object containing multiply imputed data
#' @param outcome_vars Character vector of outcome variable names
#' @param base_predictors Character vector of base predictor variable names
#' @param marijuana_var Name of marijuana exposure variable (optional)
#' @param family Model family (default: gaussian())
#'
#' @return A named list of mira objects (fitted models)
#'
#' @details This function creates standardized exposure models for analysis
#' of environmental exposures. It builds models with and without marijuana
#' exposure variables for comparison.
#'
#' @examples
#' \dontrun{
#' # Define your variables
#' outcomes <- c("meancountsM", "AGG5_PGE15000M")
#' predictors <- c("AirNicotineugm3", "cig7new", "cigar7new", "pipe7new")
#' 
#' # Build models
#' models <- build_exposure_models(
#'   mice_object = imp_data,
#'   outcome_vars = outcomes,
#'   base_predictors = predictors,
#'   marijuana_var = "mj7yes"
#' )
#' }
#'
#' @export
#' @importFrom stats glm gaussian as.formula
build_exposure_models <- function(mice_object, outcome_vars, base_predictors, 
                                 marijuana_var = NULL, family = gaussian()) {
  
  if (!inherits(mice_object, "mids")) {
    stop("mice_object must be a mids object")
  }
  
  models <- list()
  
  # Build base formula
  base_formula_str <- paste(base_predictors, collapse = " + ")
  
  for (outcome in outcome_vars) {
    # Base model without marijuana
    formula_base <- as.formula(paste(outcome, "~", base_formula_str))
    model_name <- paste0(gsub("[^A-Za-z0-9]", "_", outcome), "_base")
    models[[model_name]] <- with(mice_object, glm(formula_base, family = family))
    
    # Model with marijuana if specified
    if (!is.null(marijuana_var)) {
      formula_mj <- as.formula(paste(outcome, "~", marijuana_var, "+", base_formula_str))
      model_name_mj <- paste0(gsub("[^A-Za-z0-9]", "_", outcome), "_mj")
      models[[model_name_mj]] <- with(mice_object, glm(formula_mj, family = family))
    }
  }
  
  return(models)
}

#' Calculate Residual Differences Between Models
#'
#' Calculate the difference between residuals from two models. This is useful
#' for isolating the effect of specific variables (like marijuana exposure).
#'
#' @param mice_object A mids object with residual variables already added
#' @param model1_residuals Name of the first residual variable
#' @param model2_residuals Name of the second residual variable  
#' @param new_var_name Name for the new difference variable
#'
#' @return Updated mids object with residual difference variable added
#'
#' @examples
#' \dontrun{
#' # After adding residuals, calculate differences
#' result <- calculate_residual_differences(
#'   result,
#'   "residuals_exp_base",
#'   "residuals_exp_mj", 
#'   "residuals_mj_diff"
#' )
#' }
#'
#' @export
#' @importFrom mice complete
calculate_residual_differences <- function(mice_object, model1_residuals, 
                                         model2_residuals, new_var_name) {
  
  if (!inherits(mice_object, "mids")) {
    stop("mice_object must be a mids object")
  }
  
  # Get completed datasets
  completed_data <- complete(mice_object, "all")
  m <- mice_object$m
  
  # Calculate differences for each imputation
  for (i in 1:m) {
    if (!model1_residuals %in% names(completed_data[[i]])) {
      stop(paste("Variable", model1_residuals, "not found in imputation", i))
    }
    if (!model2_residuals %in% names(completed_data[[i]])) {
      stop(paste("Variable", model2_residuals, "not found in imputation", i))
    }
    
    completed_data[[i]][[new_var_name]] <- 
      completed_data[[i]][[model1_residuals]] - completed_data[[i]][[model2_residuals]]
  }
  
  # Repack into mids format
  repack_mice_with_residuals(completed_data, mice_object$seed, mice_object$iteration)
}

#' Repack Completed Data into MIDS Format  
#'
#' Takes a list of completed datasets and repacks them into a proper mids object.
#' This is a utility function used internally by other functions.
#'
#' @param completed_data List of completed data frames
#' @param seed Random seed used in original imputation
#' @param max_iter Maximum iterations from original imputation
#'
#' @return A mids object
#'
#' @details This function handles the technical details of converting a list of
#' data frames back into the mids format expected by the mice package.
#'
#' @export
#' @importFrom mice mice complete
#' @importFrom purrr map
#' @importFrom dplyr %>%
#' @importFrom stats as.formula
repack_mice_with_residuals <- function(completed_data, seed = 10000, max_iter = 50) {
  
  if (!is.list(completed_data)) {
    stop("completed_data must be a list of data frames")
  }
  
  m <- length(completed_data)
  
  # Set class for completed data
  class(completed_data) <- c("mild", "list")
  
  # Create dummy mids object
  set.seed(seed)
  dummy_mice <- mice(completed_data[[1]], printFlag = FALSE, m = 1, maxit = 1)
  
  # Fill with all data
  variable_names <- names(dummy_mice$data)
  for (var_name in variable_names) {
    var_data <- map(completed_data, var_name)
    dummy_mice$imp[[var_name]] <- do.call(cbind, var_data)
  }
  
  # Set proper metadata
  class(dummy_mice) <- "mids"
  dummy_mice$m <- m
  dummy_mice$iteration <- max_iter
  dummy_mice$seed <- seed
  
  return(dummy_mice)
}

