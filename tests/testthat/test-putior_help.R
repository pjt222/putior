# Test suite for putior_help() and putior_skills()
library(testthat)
library(putior)

# =============================================================================
# putior_help() tests
# =============================================================================

test_that("putior_help() with no topic prints available topics", {
  output <- capture.output(putior_help())
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Quick Reference", combined))
  expect_true(grepl("annotation", combined))
  expect_true(grepl("themes", combined))
  expect_true(grepl("languages", combined))
  expect_true(grepl("node_types", combined))
  expect_true(grepl("patterns", combined))
  expect_true(grepl("examples", combined))
  expect_true(grepl("skills", combined))
})

test_that("putior_help() returns NULL invisibly", {
  result <- putior_help()
  expect_null(result)
})

test_that("putior_help('annotation') shows annotation syntax", {
  output <- capture.output(putior_help("annotation"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Annotation Syntax", combined))
  expect_true(grepl("SINGLE-LINE", combined))
  expect_true(grepl("MULTILINE", combined))
  expect_true(grepl("AVAILABLE PROPERTIES", combined))
  expect_true(grepl("id", combined))
  expect_true(grepl("label", combined))
  expect_true(grepl("node_type", combined))
})

test_that("putior_help('annotations') works as alias", {
  output_singular <- capture.output(putior_help("annotation"))
  output_plural <- capture.output(putior_help("annotations"))
  expect_equal(output_singular, output_plural)
})

test_that("putior_help('themes') shows all themes", {
  output <- capture.output(putior_help("themes"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Available Diagram Themes", combined))
  # Check all themes appear
  for (theme in c("light", "dark", "auto", "minimal", "github",
                   "viridis", "magma", "plasma", "cividis")) {
    expect_true(grepl(theme, combined), info = paste("Missing theme:", theme))
  }
})

test_that("putior_help('languages') shows language info", {
  output <- capture.output(putior_help("languages"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Supported Languages", combined))
  expect_true(grepl("hash", combined))
  expect_true(grepl("SQL", combined))
  expect_true(grepl("JavaScript", combined))
  expect_true(grepl("MATLAB", combined))
})

test_that("putior_help('language') works as alias", {
  output_singular <- capture.output(putior_help("language"))
  output_plural <- capture.output(putior_help("languages"))
  expect_equal(output_singular, output_plural)
})

test_that("putior_help('node_types') shows node types", {
  output <- capture.output(putior_help("node_types"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Available Node Types", combined))
  for (node_type in c("input", "process", "output", "decision", "start", "end")) {
    expect_true(grepl(node_type, combined), info = paste("Missing:", node_type))
  }
})

test_that("putior_help('nodes') works as alias for node_types", {
  output_nodes <- capture.output(putior_help("nodes"))
  output_types <- capture.output(putior_help("node_types"))
  expect_equal(output_nodes, output_types)
})

test_that("putior_help('patterns') shows detection patterns info", {
  output <- capture.output(putior_help("patterns"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Detection Patterns", combined))
  expect_true(grepl("put_auto", combined))
  expect_true(grepl("put_generate", combined))
  expect_true(grepl("LLM", combined))
})

test_that("putior_help('detection') works as alias for patterns", {
  output_detect <- capture.output(putior_help("detection"))
  output_pattern <- capture.output(putior_help("patterns"))
  expect_equal(output_detect, output_pattern)
})

test_that("putior_help('examples') shows usage examples", {
  output <- capture.output(putior_help("examples"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Quick Examples", combined))
  expect_true(grepl("put\\(", combined))
  expect_true(grepl("put_diagram", combined))
  expect_true(grepl("put_auto", combined))
  expect_true(grepl("run_sandbox", combined))
})

test_that("putior_help('skills') shows skills summary", {
  output <- capture.output(putior_help("skills"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("AI Assistant Skills", combined))
  expect_true(grepl("putior_skills", combined))
  expect_true(grepl("AVAILABLE TOPICS", combined))
})

test_that("putior_help('skill') works as alias", {
  output_singular <- capture.output(putior_help("skill"))
  output_plural <- capture.output(putior_help("skills"))
  expect_equal(output_singular, output_plural)
})

test_that("putior_help() handles unknown topic gracefully", {
  output <- capture.output(putior_help("nonexistent_topic"))
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("Unknown topic", combined))
  # Should fall back to showing available topics
  expect_true(grepl("Available topics", combined))
})

test_that("putior_help() handles case insensitivity", {
  output_lower <- capture.output(putior_help("themes"))
  output_upper <- capture.output(putior_help("THEMES"))
  output_mixed <- capture.output(putior_help("Themes"))
  expect_equal(output_lower, output_upper)
  expect_equal(output_lower, output_mixed)
})

test_that("putior_help() handles whitespace in topic", {
  output_clean <- capture.output(putior_help("themes"))
  output_padded <- capture.output(putior_help("  themes  "))
  expect_equal(output_clean, output_padded)
})

# =============================================================================
# putior_skills() tests
# =============================================================================

test_that("putior_skills() prints content to console", {
  output <- capture.output(putior_skills())
  expect_true(length(output) > 0)
  combined <- paste(output, collapse = "\n")
  expect_true(grepl("putior", combined))
})

test_that("putior_skills() returns content invisibly", {
  result <- capture.output(val <- putior_skills())
  expect_type(val, "character")
  expect_true(length(val) > 0)
})

test_that("putior_skills(output = 'raw') returns string", {
  result <- putior_skills(output = "raw")
  expect_type(result, "character")
  expect_equal(length(result), 1)
  expect_true(nchar(result) > 100)
  expect_true(grepl("putior", result))
})

test_that("putior_skills() filters by topic", {
  full <- putior_skills(output = "raw")
  quick <- putior_skills("quick-start", output = "raw")

  expect_true(nchar(quick) < nchar(full))
  expect_true(grepl("Quick Start", quick))
})

test_that("putior_skills() topic aliases work", {
  quick1 <- putior_skills("quick-start", output = "raw")
  quick2 <- putior_skills("quick", output = "raw")
  expect_equal(quick1, quick2)

  syntax1 <- putior_skills("syntax", output = "raw")
  syntax2 <- putior_skills("annotation", output = "raw")
  expect_equal(syntax1, syntax2)

  lang1 <- putior_skills("languages", output = "raw")
  lang2 <- putior_skills("language", output = "raw")
  expect_equal(lang1, lang2)

  func1 <- putior_skills("functions", output = "raw")
  func2 <- putior_skills("function", output = "raw")
  expect_equal(func1, func2)

  pat1 <- putior_skills("patterns", output = "raw")
  pat2 <- putior_skills("pattern", output = "raw")
  expect_equal(pat1, pat2)

  ex1 <- putior_skills("examples", output = "raw")
  ex2 <- putior_skills("example", output = "raw")
  expect_equal(ex1, ex2)
})

test_that("putior_skills() warns on unknown topic", {
  expect_warning(
    result <- putior_skills("nonexistent", output = "raw"),
    "Unknown topic"
  )
  # Should return full content as fallback
  full <- putior_skills(output = "raw")
  expect_equal(result, full)
})

test_that("putior_skills() validates output parameter", {
  expect_error(putior_skills(output = "invalid"))
})

test_that("extract_skills_topic() handles missing section", {
  fake_content <- c("# Title", "## Other Section", "some content")
  expect_warning(
    result <- putior:::extract_skills_topic(fake_content, "quick-start"),
    "not found"
  )
  expect_equal(result, fake_content)
})
