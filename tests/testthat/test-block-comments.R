# Tests for block comment annotations (Issue #37)

# =============================================================================
# get_block_comment_syntax()
# =============================================================================

test_that("get_block_comment_syntax returns NULL for hash-group languages", {
  for (ext in c("r", "py", "sh", "jl", "rb")) {
    expect_null(get_block_comment_syntax(ext))
  }
})

test_that("get_block_comment_syntax returns NULL for dash-group languages", {
  for (ext in c("sql", "lua", "hs")) {
    expect_null(get_block_comment_syntax(ext))
  }
})

test_that("get_block_comment_syntax returns NULL for percent-group languages", {
  for (ext in c("m", "tex")) {
    expect_null(get_block_comment_syntax(ext))
  }
})

test_that("get_block_comment_syntax returns block syntax for slash-group languages", {
  for (ext in c("js", "ts", "c", "cpp", "java", "go", "rs")) {
    result <- get_block_comment_syntax(ext)
    expect_false(is.null(result))
    expect_equal(result$block_open, "/*")
    expect_equal(result$block_close, "*/")
    expect_equal(result$block_line_prefix, "*")
  }
})

test_that("get_block_comment_syntax returns NULL for unknown extension", {
  expect_null(get_block_comment_syntax("xyz"))
})

# =============================================================================
# find_block_comment_annotations()
# =============================================================================

test_that("find_block_comment_annotations finds JSDoc-style annotation", {
  lines <- c(
    "/**",
    " * put id:\"a\", label:\"Step A\"",
    " */",
    "function doSomething() {}"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 2L)
})

test_that("find_block_comment_annotations finds C-style block annotation", {
  lines <- c(
    "/* Block comment start",
    " * put id:\"b\", label:\"Process Data\"",
    " * More comments",
    " */",
    "int main() {}"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 2L)
})

test_that("find_block_comment_annotations finds single-line block comment", {
  lines <- c(
    "/* put id:\"x\", label:\"Quick\" */",
    "const x = 1;"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 1L)
})

test_that("find_block_comment_annotations finds multiple annotations in one block", {
  lines <- c(
    "/**",
    " * put id:\"a\", label:\"First\"",
    " * put id:\"b\", label:\"Second\"",
    " */",
    "code();"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, c(2L, 3L))
})

test_that("find_block_comment_annotations ignores lines outside blocks", {
  lines <- c(
    "// put id:\"single\", label:\"Single Line\"",
    "/**",
    " * put id:\"block\", label:\"Block\"",
    " */",
    "code();"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  # Should only find line 3 (inside block), not line 1 (single-line comment)
  expect_equal(result, 3L)
})

test_that("find_block_comment_annotations handles empty blocks", {
  lines <- c(
    "/**",
    " */",
    "code();"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_length(result, 0)
})

test_that("find_block_comment_annotations handles multiple separate blocks", {
  lines <- c(
    "/**",
    " * put id:\"a\", label:\"A\"",
    " */",
    "code();",
    "/**",
    " * put id:\"b\", label:\"B\"",
    " */"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, c(2L, 6L))
})

test_that("find_block_comment_annotations handles annotation on opening line", {
  lines <- c(
    "/** put id:\"x\", label:\"On Open\"",
    " */",
    "code();"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 1L)
})

test_that("find_block_comment_annotations returns empty for no annotations", {
  lines <- c(
    "/**",
    " * Just a regular comment",
    " */",
    "code();"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_length(result, 0)
})

test_that("find_block_comment_annotations handles unclosed block at EOF", {
  lines <- c(
    "/**",
    " * put id:\"x\", label:\"Unclosed\"",
    " * More comment"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 2L)
})

test_that("find_block_comment_annotations handles put with pipe separator", {
  lines <- c(
    "/**",
    " * put| id:\"a\", label:\"Pipe\"",
    " */"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 2L)
})

test_that("find_block_comment_annotations handles put with colon separator", {
  lines <- c(
    "/**",
    " * put: id:\"a\", label:\"Colon\"",
    " */"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 2L)
})

# =============================================================================
# parse_put_annotation() with block comment prefixes
# =============================================================================

test_that("parse_put_annotation handles * prefix from block body", {
  result <- parse_put_annotation(" * put id:\"a\", label:\"Block\"")
  expect_false(is.null(result))
  expect_equal(result$id, "a")
  expect_equal(result$label, "Block")
})

test_that("parse_put_annotation handles /** prefix from opening line", {
  result <- parse_put_annotation("/** put id:\"b\", label:\"Open\"")
  expect_false(is.null(result))
  expect_equal(result$id, "b")
  expect_equal(result$label, "Open")
})

test_that("parse_put_annotation handles /* prefix from opening line", {
  result <- parse_put_annotation("/* put id:\"c\", label:\"Plain\"")
  expect_false(is.null(result))
  expect_equal(result$id, "c")
  expect_equal(result$label, "Plain")
})

test_that("parse_put_annotation handles * put with pipe separator", {
  result <- parse_put_annotation(" * put| id:\"d\", label:\"Pipe\"")
  expect_false(is.null(result))
  expect_equal(result$id, "d")
})

test_that("parse_put_annotation still handles single-line prefixes", {
  # Ensure backward compatibility
  for (test in list(
    list(line = '# put id:"r", label:"R"', id = "r"),
    list(line = '// put id:"js", label:"JS"', id = "js"),
    list(line = '-- put id:"sql", label:"SQL"', id = "sql"),
    list(line = '% put id:"m", label:"MATLAB"', id = "m")
  )) {
    result <- parse_put_annotation(test$line)
    expect_false(is.null(result))
    expect_equal(result$id, test$id)
  }
})

# =============================================================================
# Integration: put() with block comment files
# =============================================================================

test_that("put() finds annotations in JSDoc block comments (.js)", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_js_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/**",
    " * put id:\"load\", label:\"Load Data\", node_type:\"input\"",
    " */",
    "function loadData() { return fetch('/api/data'); }"
  ), file.path(sub_dir, "main.js"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "load")
  expect_equal(wf$label, "Load Data")
})

test_that("put() finds annotations in JSDoc block comments (.ts)", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_ts_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/**",
    " * put id:\"process\", label:\"Process Records\"",
    " */",
    "export function process(records: Record[]): void {}"
  ), file.path(sub_dir, "processor.ts"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "process")
})

test_that("put() finds annotations in C-style block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_c_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/*",
    " * put id:\"init\", label:\"Initialize System\"",
    " */",
    "void init() {}"
  ), file.path(sub_dir, "main.c"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "init")
})

test_that("put() finds annotations in Java block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_java_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/**",
    " * put id:\"serve\", label:\"Serve Request\", node_type:\"process\"",
    " */",
    "public void serve(Request req) {}"
  ), file.path(sub_dir, "Server.java"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "serve")
})

test_that("put() finds annotations in Go block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_go_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/*",
    " * put id:\"handle\", label:\"Handle HTTP\"",
    " */",
    "func handleHTTP(w http.ResponseWriter, r *http.Request) {}"
  ), file.path(sub_dir, "handler.go"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "handle")
})

test_that("put() finds annotations in Rust block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_rs_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/*",
    " * put id:\"parse\", label:\"Parse Config\"",
    " */",
    "fn parse_config() -> Config {}"
  ), file.path(sub_dir, "config.rs"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "parse")
})

test_that("put() finds single-line block comment annotation", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_single_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/* put id:\"quick\", label:\"Quick Op\" */",
    "const x = 1;"
  ), file.path(sub_dir, "quick.js"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "quick")
})

# =============================================================================
# Mixed: single-line and block comment annotations in same file
# =============================================================================

test_that("put() finds both single-line and block annotations", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_mixed_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "// put id:\"single\", label:\"Single Line\"",
    "const a = 1;",
    "/**",
    " * put id:\"block\", label:\"Block Comment\"",
    " */",
    "function doSomething() {}"
  ), file.path(sub_dir, "mixed.js"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 2)
  ids <- sort(wf$id)
  expect_equal(ids, c("block", "single"))
})

test_that("put() deduplicates overlapping annotations", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_dedup_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  # This should only produce 1 annotation, not 2
  writeLines(c(
    "// put id:\"only_one\", label:\"Only Once\"",
    "const x = 1;"
  ), file.path(sub_dir, "dedup.js"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "only_one")
})

# =============================================================================
# Line numbers with block annotations
# =============================================================================

test_that("put() reports correct line numbers for block annotations", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_linenum_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "// Some regular code",
    "const x = 1;",
    "/**",
    " * put id:\"step\", label:\"Step\"",
    " */",
    "function step() {}"
  ), file.path(sub_dir, "lines.js"))

  wf <- put(sub_dir, include_line_numbers = TRUE, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$line_number, 4)
})

# =============================================================================
# Multiple annotations in one block
# =============================================================================

test_that("put() finds multiple annotations in a single block", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_multi_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/**",
    " * put id:\"a\", label:\"Step A\"",
    " * put id:\"b\", label:\"Step B\"",
    " */",
    "function multi() {}"
  ), file.path(sub_dir, "multi.js"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 2)
  expect_true("a" %in% wf$id)
  expect_true("b" %in% wf$id)
})

# =============================================================================
# Backward compatibility
# =============================================================================

test_that("put() still works with single-line // comments (no regression)", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_compat_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "// put id:\"classic\", label:\"Classic Style\"",
    "const data = [];"
  ), file.path(sub_dir, "classic.js"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "classic")
  expect_equal(wf$label, "Classic Style")
})

test_that("put() still works with # comments (no regression for R files)", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_r_compat_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"r_step", label:"R Step"', file.path(sub_dir, "script.R"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "r_step")
})

test_that("put() still works with -- comments (no regression for SQL files)", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_sql_compat_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('-- put id:"query", label:"Run Query"', file.path(sub_dir, "query.sql"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "query")
})

# =============================================================================
# put_auto() with block comment files
# =============================================================================

test_that("put_auto() works with files containing block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_auto_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "const fs = require('fs');",
    "const data = fs.readFileSync('input.txt', 'utf-8');"
  ), file.path(sub_dir, "reader.js"))

  wf <- put_auto(sub_dir)
  expect_gte(nrow(wf), 1)
})

# =============================================================================
# put_merge() with block comment files
# =============================================================================

test_that("put_merge() works with block-annotated files", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_merge_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/**",
    " * put id:\"load\", label:\"Load Data\", output:\"data.json\"",
    " */",
    "const data = require('./data.json');"
  ), file.path(sub_dir, "loader.js"))

  wf <- put_merge(sub_dir)
  expect_gte(nrow(wf), 1)
  expect_true("load" %in% wf$id)
})

# =============================================================================
# Edge cases
# =============================================================================

test_that("block annotation with leading whitespace", {
  lines <- c(
    "    /**",
    "     * put id:\"indented\", label:\"Indented\"",
    "     */",
    "    function indented() {}"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_equal(result, 2L)
})

test_that("block comment with no star prefix on annotation line", {
  lines <- c(
    "/*",
    "  This is a comment without star prefix",
    " */",
    "code();"
  )
  block_syntax <- list(block_open = "/*", block_close = "*/", block_line_prefix = "*")
  result <- find_block_comment_annotations(lines, block_syntax)
  expect_length(result, 0)
})

test_that("nested comment-like patterns don't cause false positives", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_nested_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  # String containing /* should not be treated as block comment
  writeLines(c(
    "const pattern = '/* this is not a comment */';",
    "// put id:\"real\", label:\"Real Annotation\"",
    "doStuff();"
  ), file.path(sub_dir, "nested.js"))

  wf <- put(sub_dir, validate = FALSE)
  # Should find at least the single-line annotation
  expect_gte(nrow(wf), 1)
  expect_true("real" %in% wf$id)
})

test_that("WGSL files support block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_wgsl_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/*",
    " * put id:\"shader\", label:\"Compute Shader\"",
    " */",
    "@compute fn main() {}"
  ), file.path(sub_dir, "shader.wgsl"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "shader")
})

test_that("C++ files support block comments", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "block_cpp_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    "/**",
    " * put id:\"render\", label:\"Render Frame\"",
    " */",
    "void render() {}"
  ), file.path(sub_dir, "engine.cpp"))

  wf <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$id, "render")
})
