# Test suite for put_diagram() function
library(testthat)

# Helper function to create test workflow data
create_test_workflow <- function() {
  data.frame(
    file_name = c("01_load.R", "02_process.py", "03_analyze.R"),
    file_type = c("r", "py", "r"),
    id = c("load_data", "process_data", "analyze_results"),
    label = c("Load Raw Data", "Process Data", "Analyze Results"),
    node_type = c("input", "process", "output"),
    input = c(NA, "raw_data.csv", "processed_data.csv"),
    output = c("raw_data.csv", "processed_data.csv", "final_report.html"),
    stringsAsFactors = FALSE
  )
}

# Helper function to create test workflow with terminal outputs
create_test_workflow_with_terminal <- function() {
  data.frame(
    file_name = c("load.R", "process.R"),
    file_type = c("r", "r"),
    id = c("load", "process"),
    label = c("Load Data", "Process Data"),
    node_type = c("input", "process"),
    input = c(NA, "data.csv"),
    output = c("data.csv", "final_results.csv"),  # final_results.csv is terminal
    stringsAsFactors = FALSE
  )
}

test_that("put_diagram() creates basic mermaid diagram", {
  workflow <- create_test_workflow()

  # Capture output
  result <- capture.output({
    diagram_code <- put_diagram(workflow)
  })

  # Check that mermaid code block is created
  expect_true(any(grepl("```mermaid", result)))
  expect_true(any(grepl("flowchart TD", result)))
  expect_true(any(grepl("```", result)))

  # Check that diagram code is returned invisibly
  expect_true(is.character(diagram_code))
  expect_true(grepl("flowchart TD", diagram_code))
})

test_that("put_diagram() handles different directions", {
  workflow <- create_test_workflow()

  # Test different directions
  directions <- c("TD", "LR", "BT", "RL")

  for (dir in directions) {
    diagram_code <- put_diagram(workflow, direction = dir, output = "none")
    expect_true(grepl(paste0("flowchart ", dir), diagram_code))
  }
})

test_that("put_diagram() handles different node label options", {
  workflow <- create_test_workflow()

  # Test ID labels (node_labels = "name" shows IDs)
  diagram_id <- put_diagram(workflow, node_labels = "name", output = "none")
  expect_true(grepl("load_data", diagram_id))

  # Test description labels
  diagram_label <- put_diagram(workflow, node_labels = "label", output = "none")
  expect_true(grepl("Load Raw Data", diagram_label))

  # Test both labels
  diagram_both <- put_diagram(workflow, node_labels = "both", output = "none")
  expect_true(grepl("load_data: Load Raw Data", diagram_both))
})

test_that("put_diagram() generates correct node shapes", {
  workflow <- create_test_workflow()
  diagram_code <- put_diagram(workflow, output = "none")

  # Check shapes for different node types
  expect_true(grepl("\\(\\[.*\\]\\)", diagram_code)) # Stadium shape for input
  expect_true(grepl("\\[.*\\]", diagram_code)) # Rectangle for process
  expect_true(grepl("\\[\\[.*\\]\\]", diagram_code)) # Subroutine for output
})

test_that("put_diagram() creates connections based on file flow", {
  workflow <- create_test_workflow()
  diagram_code <- put_diagram(workflow, output = "none")

  # Should have connections between nodes that share files
  expect_true(grepl("load_data --> process_data", diagram_code))
  expect_true(grepl("process_data --> analyze_results", diagram_code))
})

test_that("put_diagram() shows file names on connections when requested", {
  workflow <- create_test_workflow()

  # Without file names
  diagram_no_files <- put_diagram(workflow, show_files = FALSE, output = "none")
  expect_true(grepl("load_data --> process_data", diagram_no_files))
  expect_false(grepl("raw_data.csv", diagram_no_files))

  # With file names
  diagram_with_files <- put_diagram(workflow, show_files = TRUE, output = "none")
  expect_true(grepl("\\|raw_data.csv\\|", diagram_with_files))
  expect_true(grepl("\\|processed_data.csv\\|", diagram_with_files))
})

test_that("put_diagram() adds styling when requested", {
  workflow <- create_test_workflow()

  # With styling
  diagram_styled <- put_diagram(workflow, style_nodes = TRUE, output = "none")
  expect_true(grepl("classDef inputStyle", diagram_styled))
  expect_true(grepl("classDef processStyle", diagram_styled))
  expect_true(grepl("classDef outputStyle", diagram_styled))

  # Without styling
  diagram_unstyled <- put_diagram(workflow, style_nodes = FALSE, output = "none")
  expect_false(grepl("classDef", diagram_unstyled))
})

test_that("put_diagram() includes title when provided", {
  workflow <- create_test_workflow()

  diagram_with_title <- put_diagram(workflow, title = "My Workflow", output = "none")
  expect_true(grepl("title: My Workflow", diagram_with_title))

  diagram_no_title <- put_diagram(workflow, title = NULL, output = "none")
  expect_false(grepl("title:", diagram_no_title))
})

test_that("put_diagram() handles file output", {
  workflow <- create_test_workflow()
  temp_file <- tempfile(fileext = ".md")

  # Test file output
  expect_message(
    {
      put_diagram(workflow, output = "file", file = temp_file)
    },
    "Diagram saved to"
  )

  # Check file was created and has correct content
  expect_true(file.exists(temp_file))

  content <- readLines(temp_file)
  expect_true(any(grepl("```mermaid", content)))
  expect_true(any(grepl("flowchart TD", content)))

  # Clean up
  unlink(temp_file)
})

test_that("put_diagram() validates input", {
  # Empty workflow
  expect_error(put_diagram(data.frame()), "non-empty data frame")

  # Missing required columns
  bad_workflow <- data.frame(x = 1, y = 2)
  expect_error(put_diagram(bad_workflow), "must contain 'id' and 'file_name' columns")

  # All IDs missing
  workflow_no_ids <- data.frame(
    id = c(NA, "", NA),
    file_name = c("a.R", "b.py", "c.R"),
    stringsAsFactors = FALSE
  )
  expect_error(put_diagram(workflow_no_ids), "No valid workflow nodes found")
})

test_that("sanitize_node_id() works correctly", {
  # Test normal names
  expect_equal(sanitize_node_id("load_data"), "load_data")
  expect_equal(sanitize_node_id("process-data"), "process_data")
  expect_equal(sanitize_node_id("analyze.results"), "analyze_results")

  # Test names starting with numbers
  expect_equal(sanitize_node_id("1_load_data"), "node_1_load_data")

  # Test special characters
  expect_equal(sanitize_node_id("load@data#1"), "load_data_1")
})

test_that("split_file_list() handles various inputs", {
  # Single file
  expect_equal(split_file_list("file.csv"), "file.csv")

  # Multiple files
  expect_equal(split_file_list("file1.csv,file2.json"), c("file1.csv", "file2.json"))

  # With spaces
  expect_equal(
    split_file_list("file1.csv, file2.json, file3.txt"),
    c("file1.csv", "file2.json", "file3.txt")
  )

  # Empty string
  expect_equal(split_file_list(""), character(0))
  expect_equal(split_file_list(NA), character(0))
})

test_that("get_node_shape() returns correct shapes", {
  expect_equal(get_node_shape("input"), c("([", "])"))
  expect_equal(get_node_shape("process"), c("[", "]"))
  expect_equal(get_node_shape("output"), c("[[", "]]"))
  expect_equal(get_node_shape("decision"), c("{", "}"))
  expect_equal(get_node_shape(NA), c("[", "]"))
  expect_equal(get_node_shape("unknown"), c("[", "]"))
})

test_that("put_diagram() handles complex workflows", {
  # Create workflow with multiple inputs/outputs and various node types
  complex_workflow <- data.frame(
    file_name = c("collect.py", "clean.R", "analyze.R", "report.R", "decide.R"),
    id = c("collect", "clean", "analyze", "report", "decide"),
    label = c("Collect Data", "Clean Data", "Analyze", "Generate Report", "Make Decision"),
    node_type = c("input", "process", "process", "output", "decision"),
    input = c(NA, "raw.csv", "clean.csv", "analysis.rds", "analysis.rds"),
    output = c("raw.csv", "clean.csv", "analysis.rds", "report.html", "decision.json"),
    stringsAsFactors = FALSE
  )

  diagram_code <- put_diagram(complex_workflow, output = "none")

  # Should handle all node types
  expect_true(grepl("collect", diagram_code))
  expect_true(grepl("clean", diagram_code))
  expect_true(grepl("analyze", diagram_code))
  expect_true(grepl("report", diagram_code))
  expect_true(grepl("decide", diagram_code))

  # Should have appropriate connections
  expect_true(grepl("collect --> clean", diagram_code))
  expect_true(grepl("clean --> analyze", diagram_code))
})

test_that("put_diagram() handles workflows with no connections", {
  # Independent nodes with no shared files
  independent_workflow <- data.frame(
    file_name = c("task1.R", "task2.R", "task3.R"),
    id = c("task1", "task2", "task3"),
    label = c("Task 1", "Task 2", "Task 3"),
    node_type = c("process", "process", "process"),
    input = c("file1.csv", "file2.csv", "file3.csv"),
    output = c("out1.csv", "out2.csv", "out3.csv"),
    stringsAsFactors = FALSE
  )

  diagram_code <- put_diagram(independent_workflow, output = "none")

  # Should still create valid diagram with nodes
  expect_true(grepl("flowchart TD", diagram_code))
  expect_true(grepl("task1", diagram_code))
  expect_true(grepl("task2", diagram_code))
  expect_true(grepl("task3", diagram_code))

  # Should not have connections
  expect_false(grepl("-->", diagram_code))
})

# Mock clipr for clipboard tests
test_that("put_diagram() handles clipboard output", {
  workflow <- create_test_workflow()

  # Mock clipr not being available
  if (!requireNamespace("clipr", quietly = TRUE)) {
    expect_warning(
      {
        result <- capture.output({
          put_diagram(workflow, output = "clipboard")
        })
      },
      "clipr package not available"
    )

    # Should fall back to console output
    expect_true(any(grepl("```mermaid", result)))
  }
})

# ============================================================================
# Artifact functionality tests
# ============================================================================

test_that("put_diagram() supports show_artifacts parameter", {
  workflow <- create_test_workflow_with_terminal()
  
  # Test that show_artifacts parameter is accepted
  expect_no_error({
    diagram_simple <- put_diagram(workflow, output = "none")
    diagram_artifacts <- put_diagram(workflow, show_artifacts = TRUE, output = "none")
  })
  
  # Diagrams should be different
  diagram_simple <- put_diagram(workflow, output = "none")
  diagram_artifacts <- put_diagram(workflow, show_artifacts = TRUE, output = "none")
  expect_false(identical(diagram_simple, diagram_artifacts))
})

test_that("create_artifact_nodes() identifies data files correctly", {
  workflow <- create_test_workflow_with_terminal()
  artifacts <- create_artifact_nodes(workflow)
  
  # Should identify final_results.csv as an artifact (terminal output)
  expect_true(nrow(artifacts) > 0)
  expect_true("final_results.csv" %in% artifacts$file_name)
  expect_true(all(artifacts$node_type == "artifact"))
  expect_true(all(artifacts$is_artifact == TRUE))
})

test_that("artifact nodes have correct shape", {
  # Test artifact node shape
  expect_equal(get_node_shape("artifact"), c("[(", ")]"))
})

test_that("show_artifacts creates artifact nodes in diagram", {
  workflow <- create_test_workflow_with_terminal()
  diagram_code <- put_diagram(workflow, show_artifacts = TRUE, output = "none")
  
  # Should contain artifact node for terminal output
  expect_true(grepl("artifact_final_results_csv", diagram_code))
  expect_true(grepl("\\[\\(final_results\\.csv\\)\\]", diagram_code))
})

test_that("show_artifacts creates correct connections", {
  workflow <- create_test_workflow_with_terminal()
  diagram_code <- put_diagram(workflow, show_artifacts = TRUE, output = "none")
  
  # Should have BOTH script-to-script AND script-to-artifact connections
  # Script-to-script connection (preserved from simple mode)
  expect_true(grepl("load --> process", diagram_code))
  
  # Script-to-artifact and artifact-to-script connections
  expect_true(grepl("load --> artifact_data_csv", diagram_code))
  expect_true(grepl("artifact_data_csv --> process", diagram_code))
  expect_true(grepl("process --> artifact_final_results_csv", diagram_code))
})

test_that("artifact styling is applied correctly", {
  workflow <- create_test_workflow_with_terminal()
  diagram_code <- put_diagram(workflow, show_artifacts = TRUE, output = "none")
  
  # Should contain artifact styling
  expect_true(grepl("classDef artifactStyle", diagram_code))
  expect_true(grepl("class artifact_", diagram_code))
})

test_that("show_artifacts with show_files shows file labels", {
  workflow <- create_test_workflow_with_terminal()
  diagram_code <- put_diagram(workflow, show_artifacts = TRUE, show_files = TRUE, output = "none")
  
  # Should have file labels on connections
  expect_true(grepl("-->\\|.*\\|", diagram_code))  # Should have |file| labels
})

test_that("show_artifacts works with different themes", {
  workflow <- create_test_workflow_with_terminal()
  
  # Test multiple themes
  themes <- c("light", "dark", "github", "minimal", "auto")
  
  for (theme in themes) {
    expect_no_error({
      diagram_code <- put_diagram(workflow, show_artifacts = TRUE, theme = theme, output = "none")
      expect_true(grepl("artifact", diagram_code))
    })
  }
})

test_that("show_artifacts handles workflow with no artifacts", {
  # Create workflow where all outputs are script files
  workflow <- data.frame(
    file_name = c("main.R", "utils.R"),
    id = c("main", "utils"),
    label = c("Main", "Utils"),
    node_type = c("process", "input"),
    input = c("utils.R", NA),
    output = c("results.txt", "utils.R"),  # utils.R is script, not artifact
    stringsAsFactors = FALSE
  )
  
  diagram_code <- put_diagram(workflow, show_artifacts = TRUE, output = "none")
  
  # Should handle gracefully and show results.txt artifact
  expect_true(grepl("artifact_results_txt", diagram_code))
})

test_that("show_artifacts combines with existing node_type styling", {
  workflow <- create_test_workflow_with_terminal()
  diagram_code <- put_diagram(workflow, show_artifacts = TRUE, style_nodes = TRUE, output = "none")
  
  # Should have both script node styling and artifact styling
  expect_true(grepl("classDef inputStyle", diagram_code))
  expect_true(grepl("classDef processStyle", diagram_code))
  expect_true(grepl("classDef artifactStyle", diagram_code))
})
