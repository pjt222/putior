# Test suite for run_sandbox()
library(testthat)
library(putior)

test_that("run_sandbox() app directory exists in installed package", {
  app_dir <- system.file("shiny", "putior-sandbox", package = "putior")
  expect_true(nzchar(app_dir))
  expect_true(dir.exists(app_dir))
})

test_that("run_sandbox() app directory contains app.R", {
  app_dir <- system.file("shiny", "putior-sandbox", package = "putior")
  expect_true(file.exists(file.path(app_dir, "app.R")))
})

test_that("run_sandbox() is an exported function", {
  expect_true(is.function(putior::run_sandbox))
})

test_that("run_sandbox() takes no required arguments", {
  args <- formals(putior::run_sandbox)
  expect_equal(length(args), 0)
})
