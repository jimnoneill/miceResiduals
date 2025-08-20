# miceResiduals

**Multiple Imputation and Residual Integration for Restricted Cubic Splines**

## Overview

The `miceResiduals` package provides functionality for working with multiply imputed datasets in the context of Restricted Cubic Spline (RCS) modeling. This package addresses a specific limitation: RCS models don't work directly on multiple datasets, requiring data to be pooled first.

Originally developed for cannabis exposure research, this package is applicable to any multiple imputation workflow requiring residual integration.

## The Problem

When working with multiple imputation and RCS models:

1. **RCS models don't work on multiple datasets**: Unlike SAS which provides pre-pooled data, R's `mice` package creates separate datasets that can't directly be used with RCS models.

2. **Need to pool datasets for RCS**: You must pool the 30+ imputed datasets to run RCS models.

3. **Need to add residuals back**: After fitting models, you need to add the residuals back to each individual imputed dataset.

4. **Repack into MICE format**: The modified datasets need to be repacked into the proper `mids` format for further analysis.

## The Solution

This package automates the workflow:

```
Multiple Imputed Data (mids) 
    → Extract completed datasets 
    → Fit models and extract residuals 
    → Add residuals to each dataset 
    → Repack into mids format
    → Ready for further analysis
```

## Installation

Install from GitHub:

```r
# Install devtools if you haven't already
# install.packages("devtools")
devtools::install_github("jimnoneill/miceResiduals")
```

## Quick Start

```r
library(miceResiduals)
library(mice)

# Assume you have multiply imputed data
data(nhanes2, package = "mice")
imp_data <- mice(nhanes2, m = 5, printFlag = FALSE)

# Build your exposure models
models <- list(
  baseline = with(imp_data, glm(chl ~ age + bmi, family = gaussian())),
  adjusted = with(imp_data, glm(chl ~ age + bmi + hyp, family = gaussian()))
)

# Add residuals to your mids object
result <- add_residuals_to_mice(imp_data, models)

# Now you can use the residuals in further analysis
analysis <- with(result, glm(chl ~ residuals_baseline, family = gaussian()))
pooled_results <- pool(analysis)
summary(pooled_results)
```

## Key Functions

### `add_residuals_to_mice()`

The main function that handles the entire workflow:

- Takes a `mids` object and fitted models
- Extracts residuals from each imputation
- Adds residuals as new variables to all datasets  
- Repacks everything into proper `mids` format

### `build_exposure_models()`

Helper function for building standardized exposure models:

- Creates models with and without specific exposures (e.g., marijuana)
- Commonly used in environmental health research
- Returns a named list of fitted models

### `calculate_residual_differences()`

Calculate differences between model residuals:

- Useful for isolating effects of specific variables
- Creates new residual difference variables
- Maintains `mids` format

## Use Case: Cannabis Research

This package was originally developed for cannabis exposure research where:

- **30 imputed datasets** need to be pooled for RCS modeling
- **Multiple exposure models** are fitted (with/without cannabis)
- **Residuals must be added back** to individual datasets for downstream analysis
- **Proper MICE format** must be maintained for valid inference

```r
# Cannabis research workflow
exposure_models <- build_exposure_models(
  mice_object = baseline_imp30,
  outcome_vars = c("meancountsM", "AGG5_PGE15000M"),
  base_predictors = c("AirNicotineugm3", "cig7new", "cigar7new", "pipe7new"),
  marijuana_var = "mj7yes"
)

# Add all residuals at once
final_data <- add_residuals_to_mice(baseline_imp30, exposure_models)

# Calculate cannabis-specific residuals
final_data <- calculate_residual_differences(
  final_data,
  "residuals_baseline", 
  "residuals_cannabis",
  "residuals_cannabis_effect"
)
```

## Why This Matters

### Statistical Validity
- Maintains proper multiple imputation inference
- Preserves uncertainty across imputations
- Allows for valid pooling of results

### Workflow Efficiency  
- Automates tedious manual processes
- Reduces errors in data manipulation
- Standardizes analysis approaches

### Research Applications
- Environmental health studies
- Cannabis exposure research  
- Any RCS modeling with missing data
- Complex multiple imputation workflows

## Technical Details

The package handles several technical challenges:

1. **MICE Format Preservation**: Maintains all metadata and structure required by the `mice` package

2. **Memory Efficiency**: Processes large datasets without excessive memory usage

3. **Error Handling**: Comprehensive validation and informative error messages

4. **Reproducibility**: Proper seed handling for reproducible results

## Requirements

- R >= 4.0.0
- mice
- dplyr  
- purrr

## Contributing

Contributions are welcome! Please see our contributing guidelines and submit pull requests to the GitHub repository.

## Citation

If you use this package in your research, please cite:

```
O'Neill, J. (2024). miceResiduals: Multiple Imputation and Residual Integration for Restricted Cubic Splines. 
R package version 0.1.0. https://github.com/jimnoneill/miceResiduals
```

## License

MIT License - see LICENSE file for details.

## Support

- GitHub Issues: https://github.com/jimnoneill/miceResiduals/issues
- Documentation: See package vignettes and function help pages
