# Shared test helper functions
# This file is automatically loaded by testthat before tests run

#' Create a temporary file for testing
#' @param content Character vector of lines to write
#' @param filename Name of the file to create
#' @param dir Directory to create the file in
#' @return Path to the created file
create_test_file <- function(content, filename, dir) {
  filepath <- file.path(dir, filename)
  writeLines(content, filepath)
  return(filepath)
}
