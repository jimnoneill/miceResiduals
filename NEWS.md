# miceResiduals 0.1.0

## New Features

* **Main Functions**:
  * `add_residuals_to_mice()` - Add model residuals to multiply imputed datasets
  * `build_exposure_models()` - Build standardized exposure models for environmental health research
  * `calculate_residual_differences()` - Calculate differences between model residuals
  * `repack_mice_with_residuals()` - Utility function to repack data into mids format

* **Workflow Support**:
  * Complete workflow from multiple imputation to residual integration
  * Maintains proper mids format for valid statistical inference
  * Supports cannabis research and environmental health applications
  * Handles 30+ imputations efficiently

* **Quality Assurance**:
  * Comprehensive input validation and error handling
  * Unit tests covering main functionality
  * Detailed vignette explaining the complete workflow
  * Examples for common use cases

## Documentation

* Complete package documentation with roxygen2
* Comprehensive README with installation and usage instructions
* Detailed vignette: "Working with MICE Residuals: A Complete Workflow"
* Function help pages with examples

## Technical Details

* **Dependencies**: mice, dplyr, purrr
* **License**: MIT
* **R Version**: >= 4.0.0
* **GitHub**: https://github.com/jimnoneill/miceResiduals

## Background

This **open source** package was developed to address a specific limitation in multiple imputation workflows where Restricted Cubic Spline (RCS) models don't work directly on multiple datasets. Originally created for **cannabis exposure research published in environmental health literature**, it's now freely available to the research community for any multiple imputation analysis requiring residual integration.

## Open Source Commitment

Released under the MIT License to benefit researchers worldwide. This package represents a contribution to open science, sharing methodological solutions developed for peer-reviewed environmental health research.

The package automates the complex process of:
1. Extracting completed datasets from mids objects
2. Adding model residuals to each dataset
3. Repacking data while maintaining mids format integrity
4. Enabling downstream analyses with proper multiple imputation inference

