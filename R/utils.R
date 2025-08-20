#' Utility Functions for miceResiduals Package
#'
#' @name miceResiduals-utils
#' @keywords internal
NULL

#' Validate MIDS Object
#' 
#' Internal function to validate that an object is a proper mids object
#' 
#' @param x Object to validate
#' @param arg_name Name of the argument being validated (for error messages)
#' @return TRUE if valid, stops with error if not
#' @keywords internal
validate_mids <- function(x, arg_name = "mice_object") {
  if (!inherits(x, "mids")) {
    stop(paste(arg_name, "must be a mids object from the mice package"), 
         call. = FALSE)
  }
  
  if (is.null(x$m) || x$m < 1) {
    stop(paste(arg_name, "must contain at least 1 imputation"), 
         call. = FALSE)
  }
  
  return(TRUE)
}

#' Validate Model List
#' 
#' Internal function to validate a list of models fitted with mice::with()
#' 
#' @param models List of models to validate
#' @param arg_name Name of the argument being validated
#' @return TRUE if valid, stops with error if not
#' @keywords internal
validate_model_list <- function(models, arg_name = "models") {
  if (!is.list(models)) {
    stop(paste(arg_name, "must be a list"), call. = FALSE)
  }
  
  if (is.null(names(models)) || any(names(models) == "")) {
    stop(paste(arg_name, "must be a named list with non-empty names"), 
         call. = FALSE)
  }
  
  for (i in seq_along(models)) {
    if (!inherits(models[[i]], "mira")) {
      stop(paste("Model", names(models)[i], "in", arg_name, 
                "must be fitted with mice::with()"), call. = FALSE)
    }
  }
  
  return(TRUE)
}

#' Check Variable Exists in Datasets
#' 
#' Internal function to check if variables exist in all imputations
#' 
#' @param completed_data List of completed datasets
#' @param var_names Character vector of variable names to check
#' @return TRUE if all exist, stops with error if not
#' @keywords internal
check_variables_exist <- function(completed_data, var_names) {
  for (i in seq_along(completed_data)) {
    missing_vars <- setdiff(var_names, names(completed_data[[i]]))
    if (length(missing_vars) > 0) {
      stop(paste("Variables", paste(missing_vars, collapse = ", "), 
                "not found in imputation", i), call. = FALSE)
    }
  }
  return(TRUE)
}

#' Create Safe Variable Name
#' 
#' Internal function to create safe variable names for residuals
#' 
#' @param base_name Base name to make safe
#' @param prefix Prefix to add (default: "residuals_")
#' @return Safe variable name
#' @keywords internal
make_safe_var_name <- function(base_name, prefix = "residuals_") {
  # Remove special characters and spaces
  safe_name <- gsub("[^A-Za-z0-9_]", "_", base_name)
  # Remove multiple consecutive underscores
  safe_name <- gsub("_+", "_", safe_name)
  # Remove leading/trailing underscores
  safe_name <- gsub("^_|_$", "", safe_name)
  # Add prefix
  paste0(prefix, safe_name)
}

#' Print Method for Enhanced MIDS Objects
#' 
#' Custom print method to show information about added residual variables
#' 
#' @param x A mids object with residual variables
#' @param ... Additional arguments (ignored)
#' @return Invisible x
#' @export
print.mids_with_residuals <- function(x, ...) {
  # Call standard mids print method first
  NextMethod()
  
  # Find residual variables
  all_vars <- names(x$data)
  residual_vars <- grep("^residuals_", all_vars, value = TRUE)
  
  if (length(residual_vars) > 0) {
    cat("\nResidual variables added by miceResiduals:\n")
    for (var in residual_vars) {
      cat("  -", var, "\n")
    }
  }
  
  invisible(x)
}

