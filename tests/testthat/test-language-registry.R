# Test suite for language registry functionality
# Tests for comment prefix detection and multi-language annotation support

library(testthat)

# ============================================================================
# Test get_comment_prefix()
# ============================================================================

test_that("get_comment_prefix() returns correct prefix for hash group", {
  expect_equal(get_comment_prefix("r"), "#")
  expect_equal(get_comment_prefix("R"), "#")
  expect_equal(get_comment_prefix("py"), "#")
  expect_equal(get_comment_prefix("sh"), "#")
  expect_equal(get_comment_prefix("bash"), "#")
  expect_equal(get_comment_prefix("jl"), "#")
  expect_equal(get_comment_prefix("rb"), "#")
  expect_equal(get_comment_prefix("pl"), "#")
  expect_equal(get_comment_prefix("yaml"), "#")
  expect_equal(get_comment_prefix("yml"), "#")
  expect_equal(get_comment_prefix("toml"), "#")
})

test_that("get_comment_prefix() returns correct prefix for dash group", {
  expect_equal(get_comment_prefix("sql"), "--")
  expect_equal(get_comment_prefix("SQL"), "--")
  expect_equal(get_comment_prefix("lua"), "--")
  expect_equal(get_comment_prefix("hs"), "--")
})

test_that("get_comment_prefix() returns correct prefix for slash group", {
  expect_equal(get_comment_prefix("js"), "//")
  expect_equal(get_comment_prefix("ts"), "//")
  expect_equal(get_comment_prefix("jsx"), "//")
  expect_equal(get_comment_prefix("tsx"), "//")
  expect_equal(get_comment_prefix("c"), "//")
  expect_equal(get_comment_prefix("cpp"), "//")
  expect_equal(get_comment_prefix("h"), "//")
  expect_equal(get_comment_prefix("hpp"), "//")
  expect_equal(get_comment_prefix("java"), "//")
  expect_equal(get_comment_prefix("go"), "//")
  expect_equal(get_comment_prefix("rs"), "//")
  expect_equal(get_comment_prefix("swift"), "//")
  expect_equal(get_comment_prefix("kt"), "//")
  expect_equal(get_comment_prefix("cs"), "//")
  expect_equal(get_comment_prefix("php"), "//")
  expect_equal(get_comment_prefix("scala"), "//")
})

test_that("get_comment_prefix() returns correct prefix for percent group", {
  expect_equal(get_comment_prefix("m"), "%")
  expect_equal(get_comment_prefix("tex"), "%")
})

test_that("get_comment_prefix() falls back to hash for unknown extensions", {
  expect_equal(get_comment_prefix("xyz"), "#")
  expect_equal(get_comment_prefix("unknown"), "#")
  expect_equal(get_comment_prefix("abc123"), "#")
})

# ============================================================================
# Test ext_to_language()
# ============================================================================

test_that("ext_to_language() returns correct language names", {
  # Hash group
  expect_equal(ext_to_language("r"), "r")
  expect_equal(ext_to_language("py"), "python")
  expect_equal(ext_to_language("sh"), "shell")
  expect_equal(ext_to_language("bash"), "shell")
  expect_equal(ext_to_language("jl"), "julia")

  # Dash group
  expect_equal(ext_to_language("sql"), "sql")
  expect_equal(ext_to_language("lua"), "lua")
  expect_equal(ext_to_language("hs"), "haskell")

  # Slash group
  expect_equal(ext_to_language("js"), "javascript")
  expect_equal(ext_to_language("ts"), "typescript")
  expect_equal(ext_to_language("jsx"), "javascript")
  expect_equal(ext_to_language("tsx"), "typescript")
  expect_equal(ext_to_language("c"), "c")
  expect_equal(ext_to_language("cpp"), "cpp")
  expect_equal(ext_to_language("java"), "java")
  expect_equal(ext_to_language("go"), "go")
  expect_equal(ext_to_language("rs"), "rust")
  expect_equal(ext_to_language("swift"), "swift")
  expect_equal(ext_to_language("kt"), "kotlin")
  expect_equal(ext_to_language("cs"), "csharp")

  # Percent group
  expect_equal(ext_to_language("m"), "matlab")
  expect_equal(ext_to_language("tex"), "latex")
})

test_that("ext_to_language() returns NULL for unknown extensions", {
  expect_null(ext_to_language("xyz"))
  expect_null(ext_to_language("unknown"))
})

# ============================================================================
# Test get_supported_extensions()
# ============================================================================

test_that("get_supported_extensions() returns all extensions", {
  exts <- get_supported_extensions()

  # Check that key extensions are present
  expect_true("r" %in% exts)
  expect_true("py" %in% exts)
  expect_true("sql" %in% exts)
  expect_true("js" %in% exts)
  expect_true("ts" %in% exts)
  expect_true("m" %in% exts)

  # Check reasonable count (should be 30+)
  expect_true(length(exts) >= 25)
})

# ============================================================================
# Test list_supported_languages()
# ============================================================================

test_that("list_supported_languages() returns expected languages", {
  languages <- list_supported_languages()

  # Check key languages
  expect_true("r" %in% languages)
  expect_true("python" %in% languages)
  expect_true("sql" %in% languages)
  expect_true("javascript" %in% languages)
  expect_true("typescript" %in% languages)
  expect_true("java" %in% languages)
  expect_true("go" %in% languages)
  expect_true("rust" %in% languages)
  expect_true("matlab" %in% languages)
  expect_true("latex" %in% languages)
})

test_that("list_supported_languages(detection_only = TRUE) returns subset", {
  detection_langs <- list_supported_languages(detection_only = TRUE)
  all_langs <- list_supported_languages(detection_only = FALSE)

  # Detection-only should be a subset
  expect_true(length(detection_langs) < length(all_langs))

  # Should include languages with detection patterns (15 total)
  expect_true("r" %in% detection_langs)
  expect_true("python" %in% detection_langs)
  expect_true("sql" %in% detection_langs)
  expect_true("shell" %in% detection_langs)
  expect_true("julia" %in% detection_langs)
  expect_true("javascript" %in% detection_langs)
  expect_true("typescript" %in% detection_langs)
  expect_true("go" %in% detection_langs)
  expect_true("rust" %in% detection_langs)
  expect_true("java" %in% detection_langs)
  expect_true("c" %in% detection_langs)
  expect_true("cpp" %in% detection_langs)
  expect_true("matlab" %in% detection_langs)
  expect_true("ruby" %in% detection_langs)
  expect_true("lua" %in% detection_langs)

  # Should have 15 languages with detection patterns
  expect_equal(length(detection_langs), 15)
})

# ============================================================================
# Test parse_put_annotation() with different comment prefixes
# ============================================================================

test_that("parse_put_annotation() handles SQL dash comments (--put)", {
  result <- parse_put_annotation('--put id:"sql_step", label:"SQL Query"')
  expect_equal(result$id, "sql_step")
  expect_equal(result$label, "SQL Query")

  # With space
  result2 <- parse_put_annotation('-- put id:"step2", node_type:"process"')
  expect_equal(result2$id, "step2")
  expect_equal(result2$node_type, "process")

  # With pipe
  result3 <- parse_put_annotation('--put| id:"step3", input:"table1"')
  expect_equal(result3$id, "step3")
  expect_equal(result3$input, "table1")

  # With colon
  result4 <- parse_put_annotation('--put: id:"step4", output:"results"')
  expect_equal(result4$id, "step4")
  expect_equal(result4$output, "results")
})

test_that("parse_put_annotation() handles JavaScript/C-style slash comments (//put)", {
  result <- parse_put_annotation('//put id:"js_step", label:"JavaScript Function"')
  expect_equal(result$id, "js_step")
  expect_equal(result$label, "JavaScript Function")

  # With space
  result2 <- parse_put_annotation('// put id:"step2", node_type:"process"')
  expect_equal(result2$id, "step2")
  expect_equal(result2$node_type, "process")

  # With pipe
  result3 <- parse_put_annotation('//put| id:"step3", input:"data.json"')
  expect_equal(result3$id, "step3")
  expect_equal(result3$input, "data.json")

  # With colon
  result4 <- parse_put_annotation('//put: id:"step4", output:"output.json"')
  expect_equal(result4$id, "step4")
  expect_equal(result4$output, "output.json")
})

test_that("parse_put_annotation() handles MATLAB/LaTeX percent comments (%put)", {
  result <- parse_put_annotation('%put id:"matlab_step", label:"MATLAB Function"')
  expect_equal(result$id, "matlab_step")
  expect_equal(result$label, "MATLAB Function")

  # With space
  result2 <- parse_put_annotation('% put id:"step2", node_type:"process"')
  expect_equal(result2$id, "step2")
  expect_equal(result2$node_type, "process")

  # With pipe
  result3 <- parse_put_annotation('%put| id:"step3", input:"data.mat"')
  expect_equal(result3$id, "step3")
  expect_equal(result3$input, "data.mat")

  # With colon
  result4 <- parse_put_annotation('%put: id:"step4", output:"results.mat"')
  expect_equal(result4$id, "step4")
  expect_equal(result4$output, "results.mat")
})

# ============================================================================
# Test file processing with different comment styles
# ============================================================================

test_that("put() processes SQL files with --put annotations", {
  # Create a temporary SQL file with --put annotation
  tmp_dir <- tempdir()
  sql_file <- file.path(tmp_dir, "test_query.sql")

  writeLines(c(
    "--put id:\"load_data\", label:\"Load Customer Data\", node_type:\"input\", output:\"customers\"",
    "SELECT * FROM customers WHERE active = 1;"
  ), sql_file)

  # Process the file
  result <- put(sql_file)

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "load_data")
  expect_equal(result$label[1], "Load Customer Data")
  expect_equal(result$node_type[1], "input")
  expect_equal(result$output[1], "customers")

  # Cleanup
  unlink(sql_file)
})

test_that("put() processes JavaScript files with //put annotations", {
  # Create a temporary JS file with //put annotation
  tmp_dir <- tempdir()
  js_file <- file.path(tmp_dir, "test_script.js")

  writeLines(c(
    "//put id:\"process_data\", label:\"Process JSON Data\", input:\"data.json\", output:\"results.json\"",
    "const data = require('./data.json');",
    "// Process the data",
    "module.exports = processData(data);"
  ), js_file)

  # Process the file
  result <- put(js_file, pattern = "\\.js$")

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "process_data")
  expect_equal(result$label[1], "Process JSON Data")
  expect_equal(result$input[1], "data.json")
  expect_equal(result$output[1], "results.json")

  # Cleanup
  unlink(js_file)
})

test_that("put() processes TypeScript files with //put annotations", {
  # Create a temporary TS file with //put annotation
  tmp_dir <- tempdir()
  ts_file <- file.path(tmp_dir, "test_module.ts")

  writeLines(c(
    "// put id:\"transform\", label:\"Transform Data\", node_type:\"process\"",
    "export function transform(data: DataType): ResultType {",
    "  return processData(data);",
    "}"
  ), ts_file)

  # Process the file
  result <- put(ts_file, pattern = "\\.ts$")

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "transform")
  expect_equal(result$label[1], "Transform Data")
  expect_equal(result$node_type[1], "process")

  # Cleanup
  unlink(ts_file)
})

# ============================================================================
# Test multiline annotations with different comment prefixes
# ============================================================================

test_that("put() handles multiline SQL annotations with --", {
  tmp_dir <- tempdir()
  sql_file <- file.path(tmp_dir, "test_multiline.sql")

  writeLines(c(
    "--put id:\"etl_step\", \\",
    "--     label:\"ETL Process\", \\",
    "--     input:\"source_table\", \\",
    "--     output:\"target_table\"",
    "INSERT INTO target_table SELECT * FROM source_table;"
  ), sql_file)

  result <- put(sql_file)

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "etl_step")
  expect_equal(result$label[1], "ETL Process")
  expect_equal(result$input[1], "source_table")
  expect_equal(result$output[1], "target_table")

  unlink(sql_file)
})

test_that("put() handles multiline JavaScript annotations with //", {
  tmp_dir <- tempdir()
  js_file <- file.path(tmp_dir, "test_multiline.js")

  writeLines(c(
    "//put id:\"api_handler\", \\",
    "//    label:\"API Request Handler\", \\",
    "//    input:\"request.json\", \\",
    "//    output:\"response.json\"",
    "async function handleRequest(req) {",
    "  return await processRequest(req);",
    "}"
  ), js_file)

  result <- put(js_file, pattern = "\\.js$")

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "api_handler")
  expect_equal(result$label[1], "API Request Handler")
  expect_equal(result$input[1], "request.json")
  expect_equal(result$output[1], "response.json")

  unlink(js_file)
})

# ============================================================================
# Test is_valid_put_annotation() with different prefixes
# ============================================================================

test_that("is_valid_put_annotation() works with all comment styles", {
  # Hash (R, Python)
  expect_true(is_valid_put_annotation('#put id:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('# put id:"test", label:"Test"'))

  # Dash (SQL)
  expect_true(is_valid_put_annotation('--put id:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('-- put id:"test", label:"Test"'))

slashes <- '//put id:"test", label:"Test"'
  expect_true(is_valid_put_annotation(slashes))
slashes_space <- '// put id:"test", label:"Test"'
  expect_true(is_valid_put_annotation(slashes_space))

  # Percent (MATLAB, LaTeX)
  expect_true(is_valid_put_annotation('%put id:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('% put id:"test", label:"Test"'))
})

# ============================================================================
# Test backward compatibility
# ============================================================================

test_that("R files still work with #put annotations", {
  tmp_dir <- tempdir()
  r_file <- file.path(tmp_dir, "test_r.R")

  writeLines(c(
    "#put id:\"r_step\", label:\"R Processing\", input:\"data.csv\", output:\"results.rds\"",
    "data <- read.csv('data.csv')",
    "saveRDS(data, 'results.rds')"
  ), r_file)

  result <- put(r_file)

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "r_step")
  expect_equal(result$label[1], "R Processing")

  unlink(r_file)
})

test_that("Python files still work with #put annotations", {
  tmp_dir <- tempdir()
  py_file <- file.path(tmp_dir, "test_py.py")

  writeLines(c(
    "#put id:\"py_step\", label:\"Python Processing\", input:\"data.csv\", output:\"results.csv\"",
    "import pandas as pd",
    "df = pd.read_csv('data.csv')",
    "df.to_csv('results.csv')"
  ), py_file)

  result <- put(py_file, pattern = "\\.py$")

  expect_equal(nrow(result), 1)
  expect_equal(result$id[1], "py_step")
  expect_equal(result$label[1], "Python Processing")

  unlink(py_file)
})
