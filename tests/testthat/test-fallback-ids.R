# Tests for ids of annotations that omit `id` (#58).
# With the uuid package installed, put() gives them UUIDs; without it,
# fill_missing_ids() numbers them. These tests pass either way.

test_that("fill_missing_ids() numbers annotations that have no id", {
  results <- list(
    list(label = "Extract"),
    list(label = "Transform"),
    list(label = "Load")
  )

  filled <- fill_missing_ids(results)

  ids <- vapply(filled, function(annotation) annotation[["id"]], character(1))
  expect_equal(ids, c("node_1", "node_2", "node_3"))
  expect_equal(
    vapply(filled, function(annotation) annotation[["label"]], character(1)),
    c("Extract", "Transform", "Load")
  )
})

test_that("fill_missing_ids() skips ids that are already in use", {
  results <- list(
    list(id = "node_1", label = "Explicit"),
    list(label = "First without id"),
    list(id = "node_3", label = "Also explicit"),
    list(label = "Second without id")
  )

  filled <- fill_missing_ids(results)

  ids <- vapply(filled, function(annotation) annotation[["id"]], character(1))
  expect_equal(ids, c("node_1", "node_2", "node_3", "node_4"))
  expect_false(anyDuplicated(ids) > 0)
})

test_that("fill_missing_ids() keeps explicit ids, including empty ones", {
  results <- list(
    list(id = "extract", label = "Extract"),
    list(id = "", label = "Empty id")
  )

  expect_identical(fill_missing_ids(results), results)
})

test_that("fill_missing_ids() does not treat a property starting with 'id' as an id", {
  # `$` would partially match "identifier" to "id"; the helper must not.
  results <- list(list(identifier = "x", label = "Step"))

  filled <- fill_missing_ids(results)

  expect_equal(filled[[1]][["id"]], "node_1")
  expect_equal(filled[[1]][["identifier"]], "x")
})

test_that("put() gives every annotation an id and put_diagram() draws them all", {
  test_dir <- file.path(tempdir(), "putior_test_fallback_ids")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # The quick-start example: no annotation sets an id.
  create_test_file(c(
    '# put label:"Extract", output:"raw.csv"',
    '# put label:"Transform", input:"raw.csv", output:"clean.csv"',
    '# put label:"Load", input:"clean.csv", output:"database.db"'
  ), "etl.R", test_dir)
  # A second file where only some annotations set an id.
  create_test_file(c(
    '# put id:"report", label:"Report", input:"database.db", output:"report.html"',
    '# put label:"Publish", input:"report.html", output:"site.zip"'
  ), "report.R", test_dir)

  workflow <- put(test_dir)

  expect_equal(nrow(workflow), 5)
  expect_true("id" %in% names(workflow))
  expect_false(any(is.na(workflow$id) | workflow$id == ""))
  expect_false(anyDuplicated(workflow$id) > 0)
  expect_true("report" %in% workflow$id)

  diagram <- put_diagram(workflow, output = "raw")
  for (node_label in c("Extract", "Transform", "Load", "Report", "Publish")) {
    expect_match(diagram, paste0('"', node_label, '"'), fixed = TRUE)
  }
})
