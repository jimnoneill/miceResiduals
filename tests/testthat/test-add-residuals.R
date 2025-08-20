library(testthat)
library(mice)
library(miceResiduals)

# Create test data
test_that("add_residuals_to_mice works with basic example", {
  skip_if_not_installed("mice")
  
  # Create test data
  set.seed(123)
  data(nhanes2, package = "mice")
  imp_data <- mice(nhanes2, m = 3, printFlag = FALSE)
  
  # Fit test models
  model1 <- with(imp_data, glm(chl ~ age + bmi, family = gaussian()))
  model2 <- with(imp_data, glm(chl ~ age + bmi + hyp, family = gaussian()))
  
  models <- list("baseline" = model1, "adjusted" = model2)
  
  # Test the function
  result <- add_residuals_to_mice(imp_data, models)
  
  # Check that it's still a mids object
  expect_s3_class(result, "mids")
  
  # Check that residual variables were added
  expect_true("residuals_baseline" %in% names(result$data))
  expect_true("residuals_adjusted" %in% names(result$data))
  
  # Check that imputations are preserved
  expect_equal(result$m, imp_data$m)
  
  # Check that completed data has residuals
  completed <- complete(result, 1)
  expect_true("residuals_baseline" %in% names(completed))
  expect_true("residuals_adjusted" %in% names(completed))
})

test_that("add_residuals_to_mice validates input", {
  skip_if_not_installed("mice")
  
  data(nhanes2, package = "mice")
  imp_data <- mice(nhanes2, m = 2, printFlag = FALSE)
  model1 <- with(imp_data, glm(chl ~ age + bmi, family = gaussian()))
  
  # Test with non-mids object
  expect_error(
    add_residuals_to_mice("not_mids", list("model" = model1)),
    "must be a mids object"
  )
  
  # Test with non-list models
  expect_error(
    add_residuals_to_mice(imp_data, model1),
    "must be a named list"
  )
  
  # Test with unnamed list
  expect_error(
    add_residuals_to_mice(imp_data, list(model1)),
    "must be a named list"
  )
  
  # Test with non-mira object
  fake_model <- glm(chl ~ age + bmi, data = nhanes2, family = gaussian())
  expect_error(
    add_residuals_to_mice(imp_data, list("fake" = fake_model)),
    "must be fitted with mice::with"
  )
})

test_that("build_exposure_models creates correct models", {
  skip_if_not_installed("mice")
  
  # Create test data with environmental variables
  set.seed(456)
  test_data <- data.frame(
    outcome1 = rnorm(20, 100, 15),
    outcome2 = rnorm(20, 50, 10),
    predictor1 = rnorm(20, 10, 3),
    predictor2 = rbinom(20, 1, 0.3),
    marijuana = rbinom(20, 1, 0.2),
    age = sample(20:65, 20, replace = TRUE)
  )
  
  # Add missing values
  test_data$predictor1[sample(20, 3)] <- NA
  test_data$age[sample(20, 2)] <- NA
  
  imp_data <- mice(test_data, m = 2, printFlag = FALSE)
  
  models <- build_exposure_models(
    mice_object = imp_data,
    outcome_vars = c("outcome1", "outcome2"),
    base_predictors = c("predictor1", "predictor2", "age"),
    marijuana_var = "marijuana"
  )
  
  # Should have 4 models (2 outcomes x 2 model types)
  expect_length(models, 4)
  
  # Check naming convention
  model_names <- names(models)
  expect_true(any(grepl("outcome1.*base", model_names)))
  expect_true(any(grepl("outcome1.*mj", model_names)))
  expect_true(any(grepl("outcome2.*base", model_names)))
  expect_true(any(grepl("outcome2.*mj", model_names)))
  
  # Check that all are mira objects
  expect_true(all(sapply(models, function(x) inherits(x, "mira"))))
})

test_that("calculate_residual_differences works correctly", {
  skip_if_not_installed("mice")
  
  set.seed(789)
  data(nhanes2, package = "mice")
  imp_data <- mice(nhanes2, m = 2, printFlag = FALSE)
  
  model1 <- with(imp_data, glm(chl ~ age + bmi, family = gaussian()))
  model2 <- with(imp_data, glm(chl ~ age + bmi + hyp, family = gaussian()))
  
  models <- list("model1" = model1, "model2" = model2)
  
  # Add residuals first
  result <- add_residuals_to_mice(imp_data, models)
  
  # Calculate differences
  result_diff <- calculate_residual_differences(
    result,
    "residuals_model1",
    "residuals_model2",
    "residual_diff"
  )
  
  # Check that difference variable was created
  expect_true("residual_diff" %in% names(result_diff$data))
  
  # Check that it's still a mids object
  expect_s3_class(result_diff, "mids")
  
  # Verify the calculation is correct
  completed <- complete(result_diff, 1)
  expected_diff <- completed$residuals_model1 - completed$residuals_model2
  expect_equal(completed$residual_diff, expected_diff)
})

test_that("utility functions work correctly", {
  skip_if_not_installed("mice")
  
  data(nhanes2, package = "mice")
  imp_data <- mice(nhanes2, m = 2, printFlag = FALSE)
  
  # Test validate_mids
  expect_true(validate_mids(imp_data))
  expect_error(validate_mids("not_mids"), "must be a mids object")
  
  # Test make_safe_var_name
  expect_equal(make_safe_var_name("test name!"), "residuals_test_name_")
  expect_equal(make_safe_var_name("normal_name"), "residuals_normal_name")
  
  # Test model validation
  model1 <- with(imp_data, glm(chl ~ age + bmi, family = gaussian()))
  models <- list("test" = model1)
  expect_true(validate_model_list(models))
  
  expect_error(validate_model_list("not_list"), "must be a list")
  expect_error(validate_model_list(list(model1)), "must be a named list")
})



