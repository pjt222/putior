# Test suite for parsing functionality
# Tests for parse_put_annotation(), parse_comma_separated_pairs(), and related functions

library(testthat)

# Test basic PUT annotation parsing
test_that("parse_put_annotation() handles basic formats correctly", {
  # Standard format
  result1 <- parse_put_annotation('#put id:"test", label:"Test Label"')
  expect_equal(result1$id, "test")
  expect_equal(result1$label, "Test Label")
  expect_equal(length(result1), 2)

  # With spaces after #
  result2 <- parse_put_annotation('# put id:"test2", node_type:"process"')
  expect_equal(result2$id, "test2")
  expect_equal(result2$node_type, "process")

  # With pipe separator
  result3 <- parse_put_annotation('#put| id:"test3", input:"data.csv"')
  expect_equal(result3$id, "test3")
  expect_equal(result3$input, "data.csv")

  # With colon separator
  result4 <- parse_put_annotation('#put: id:"test4", output:"result.txt"')
  expect_equal(result4$id, "test4")
  expect_equal(result4$output, "result.txt")
})

test_that("parse_put_annotation() handles different quote styles", {
  # Single quotes
  result1 <- parse_put_annotation("#put id:'test1', label:'Single Quotes'")
  expect_equal(result1$id, "test1")
  expect_equal(result1$label, "Single Quotes")

  # Mixed quotes
  result2 <- parse_put_annotation('#put id:"test2", label:\'Mixed Quotes\'')
  expect_equal(result2$id, "test2")
  expect_equal(result2$label, "Mixed Quotes")

  # Double quotes (standard)
  result3 <- parse_put_annotation('#put id:"test3", label:"Double Quotes"')
  expect_equal(result3$id, "test3")
  expect_equal(result3$label, "Double Quotes")
})

test_that("parse_put_annotation() handles whitespace correctly", {
  # Extra spaces around properties
  result1 <- parse_put_annotation('#put  id : "test" , label : "Test Label"  ')
  expect_equal(result1$id, "test")
  expect_equal(result1$label, "Test Label")

  # Tabs and mixed whitespace
  result2 <- parse_put_annotation("#put\tid:\t\"test\",\t\tlabel:\t\"Test\"")
  expect_equal(result2$id, "test")
  expect_equal(result2$label, "Test")

  # Leading and trailing whitespace in values should be preserved
  result3 <- parse_put_annotation('#put id:" test ", label:" Test Label "')
  expect_equal(result3$id, " test ") # Preserve internal whitespace
  expect_equal(result3$label, " Test Label ")
})

test_that("parse_put_annotation() handles empty and invalid inputs", {
  # Empty PUT annotation
  expect_null(parse_put_annotation("#put"))
  expect_null(parse_put_annotation("# put "))
  expect_null(parse_put_annotation("#put|"))
  expect_null(parse_put_annotation("#put:"))

  # Only whitespace after PUT
  expect_null(parse_put_annotation("#put   "))
  expect_null(parse_put_annotation("# put \t\n"))

  # Invalid syntax - no quotes
  expect_null(parse_put_annotation("#put id:test"))
  expect_null(parse_put_annotation("#put id:test, label:label"))

  # Invalid syntax - malformed
  expect_null(parse_put_annotation("#put invalid"))
  expect_null(parse_put_annotation("#put id"))
  expect_null(parse_put_annotation("#put :"))

  # Not a PUT annotation
  expect_null(parse_put_annotation("# Regular comment"))
  expect_null(parse_put_annotation("puts name:test"))
  expect_null(parse_put_annotation("put name:test"))
})

test_that("parse_put_annotation() handles complex property values", {
  # Commas inside quotes should be preserved
  result1 <- parse_put_annotation('#put id:"test", label:"Label with, commas, inside"')
  expect_equal(result1$id, "test")
  expect_equal(result1$label, "Label with, commas, inside")

  # Multiple commas and complex descriptions
  result2 <- parse_put_annotation('#put id:"complex", description:"Process A, B, and C data", files:"file1.csv,file2.csv"')
  expect_equal(result2$description, "Process A, B, and C data")
  expect_equal(result2$files, "file1.csv,file2.csv")

  # Special characters in values
  result3 <- parse_put_annotation('#put name:"special", path:"/path/to/file.csv", regex:"\\\\d+\\.csv$"')
  expect_equal(result3$path, "/path/to/file.csv")
  expect_equal(result3$regex, "\\\\d+\\.csv$")

  # URLs and complex strings
  result4 <- parse_put_annotation('#put name:"url_test", endpoint:"https://api.example.com/data?param=value&other=123"')
  expect_equal(result4$endpoint, "https://api.example.com/data?param=value&other=123")
})

test_that("parse_put_annotation() handles empty values", {
  # Empty string values
  result1 <- parse_put_annotation('#put name:"", label:"Not Empty"')
  expect_equal(result1$name, "")
  expect_equal(result1$label, "Not Empty")

  # Multiple empty values
  result2 <- parse_put_annotation('#put name:"test", input:"", output:"", label:"Test"')
  expect_equal(result2$name, "test")
  expect_equal(result2$input, "")
  expect_equal(result2$output, "")
  expect_equal(result2$label, "Test")
})

test_that("parse_put_annotation() preserves property order", {
  # Properties should be returned in the order they appear
  result <- parse_put_annotation('#put zebra:"z", alpha:"a", name:"test", beta:"b"')

  # Check that all properties are present
  expect_equal(result$zebra, "z")
  expect_equal(result$alpha, "a")
  expect_equal(result$name, "test")
  expect_equal(result$beta, "b")
  expect_equal(length(result), 4)
})

# Test the comma-separated parsing function
test_that("parse_comma_separated_pairs() handles basic cases", {
  # Basic case
  result1 <- parse_comma_separated_pairs('name:"test", label:"Test Label"')
  expect_equal(length(result1), 2)
  expect_true(any(grepl('name:"test"', result1)))
  expect_true(any(grepl('label:"Test Label"', result1)))

  # Single pair
  result2 <- parse_comma_separated_pairs('name:"single"')
  expect_equal(length(result2), 1)
  expect_equal(trimws(result2[1]), 'name:"single"')

  # No pairs (empty string)
  result3 <- parse_comma_separated_pairs("")
  expect_equal(length(result3), 0)
})

test_that("parse_comma_separated_pairs() respects quotes", {
  # Commas inside quotes should not split
  result1 <- parse_comma_separated_pairs('name:"test", desc:"A, B, and C", type:"complex"')
  expect_equal(length(result1), 3)
  expect_true(any(grepl("A, B, and C", result1)))

  # Mixed quote types
  result2 <- parse_comma_separated_pairs('name:"test", label:\'Single quotes\', desc:"Double quotes"')
  expect_equal(length(result2), 3)
  expect_true(any(grepl("Single quotes", result2)))
  expect_true(any(grepl("Double quotes", result2)))

  # Nested-like scenarios (but no actual nesting)
  result3 <- parse_comma_separated_pairs('code:"if (x > 0) { print(\\"positive\\") }", desc:"Complex code"')
  expect_equal(length(result3), 2)
  expect_true(any(grepl("positive", result3)))
})

test_that("parse_comma_separated_pairs() handles edge cases", {
  # Extra commas and whitespace
  result1 <- parse_comma_separated_pairs('name:"test",,, label:"Test",  ')
  expect_equal(length(result1), 2) # Empty parts should be filtered out

  # Only commas
  result2 <- parse_comma_separated_pairs(",,,")
  expect_equal(length(result2), 0)

  # Unmatched quotes (should still try to parse)
  result3 <- parse_comma_separated_pairs('name:"test", broken:"unmatched')
  expect_equal(length(result3), 2)
  expect_true(any(grepl("test", result3)))
  expect_true(any(grepl("unmatched", result3)))
})

# Test validation functionality
test_that("validate_annotation() catches missing id", {
  # Missing name property
  props1 <- list(label = "Test", node_type = "process")
  issues1 <- validate_annotation(props1, "test line")
  expect_true(any(grepl("Missing.*id", issues1)))

  # Empty name property
  props2 <- list(name = "", label = "Test", node_type = "process")
  issues2 <- validate_annotation(props2, "test line")
  expect_true(any(grepl("Missing.*empty.*id", issues2)))

  # Valid name property
  props3 <- list(name = "valid_name", label = "Test")
  issues3 <- validate_annotation(props3, "test line")
  expect_false(any(grepl("Missing.*name", issues3)))
})

test_that("validate_annotation() checks node_type values", {
  # Invalid node type
  props1 <- list(name = "test", node_type = "invalid_type")
  issues1 <- validate_annotation(props1, "test line")
  expect_true(any(grepl("Unusual node_type", issues1)))

  # Valid node types
  valid_types <- c("input", "process", "output", "decision", "start", "end")
  for (type in valid_types) {
    props <- list(name = "test", node_type = type)
    issues <- validate_annotation(props, "test line")
    expect_false(any(grepl("Unusual node_type", issues)),
      info = paste("Type", type, "should be valid")
    )
  }

  # Missing node_type (should not generate warning)
  props2 <- list(name = "test", label = "Test")
  issues2 <- validate_annotation(props2, "test line")
  expect_false(any(grepl("node_type", issues2)))
})

test_that("validate_annotation() checks file extensions", {
  # File without extension
  props1 <- list(name = "test", input = "noextension")
  issues1 <- validate_annotation(props1, "test line")
  expect_true(any(grepl("missing extension", issues1)))

  # Multiple files, some without extensions
  props2 <- list(name = "test", input = "file1.csv", output = "noextension")
  issues2 <- validate_annotation(props2, "test line")
  expect_true(any(grepl("missing extension", issues2)))

  # All files with extensions (should pass)
  props3 <- list(name = "test", input = "input.csv", output = "output.json")
  issues3 <- validate_annotation(props3, "test line")
  expect_false(any(grepl("missing extension", issues3)))

  # No file references (should pass)
  props4 <- list(name = "test", label = "Test")
  issues4 <- validate_annotation(props4, "test line")
  expect_false(any(grepl("missing extension", issues4)))
})

test_that("validate_annotation() handles multiple issues", {
  # Multiple validation problems
  props <- list(
    # name missing
    node_type = "invalid_type", # invalid node type
    input = "noextension" # missing file extension
  )

  issues <- validate_annotation(props, "test line")

  # Should catch all three issues
  expect_true(any(grepl("Missing.*id", issues)))
  expect_true(any(grepl("Unusual node_type", issues)))
  expect_true(any(grepl("missing extension", issues)))
  expect_gte(length(issues), 3)
})

# Test the exported validation function
test_that("is_valid_put_annotation() correctly identifies valid annotations", {
  # Valid annotations
  expect_true(is_valid_put_annotation('#put name:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('# put name:"test"'))
  expect_true(is_valid_put_annotation('#put| name:"test", type:"process"'))
  expect_true(is_valid_put_annotation("#put name:'test', label:'Test'"))

  # Valid with complex values
  expect_true(is_valid_put_annotation('#put name:"test", desc:"Complex, description", path:"/path/to/file"'))

  # Invalid annotations
  expect_false(is_valid_put_annotation("#put"))
  expect_false(is_valid_put_annotation("#put invalid"))
  expect_false(is_valid_put_annotation("#put name:noQuotes"))
  expect_false(is_valid_put_annotation("not a put annotation"))
  expect_false(is_valid_put_annotation(""))
  expect_false(is_valid_put_annotation("#comment"))
})

# Test error handling in parsing
test_that("parse_put_annotation() handles malformed input gracefully", {
  # Should not throw errors, just return NULL
  expect_silent(expect_null(parse_put_annotation(NULL)))
  expect_silent(expect_null(parse_put_annotation("")))
  expect_silent(expect_null(parse_put_annotation("malformed")))

  # Very long strings should still work
  long_value <- paste(rep("a", 1000), collapse = "")
  long_annotation <- paste0('#put name:"test", long_value:"', long_value, '"')
  result <- parse_put_annotation(long_annotation)
  expect_equal(result$name, "test")
  expect_equal(nchar(result$long_value), 1000)
})

# Test consistency between parsing and validation
test_that("Parsing and validation work together correctly", {
  # Valid annotation should parse and validate
  valid_annotation <- '#put id:"test_node", label:"Test Node", node_type:"process"'
  parsed <- parse_put_annotation(valid_annotation)
  expect_false(is.null(parsed))
  expect_true(is_valid_put_annotation(valid_annotation))

  issues <- validate_annotation(parsed, valid_annotation)
  expect_equal(length(issues), 0)

  # Invalid annotation should not parse
  invalid_annotation <- "#put invalid syntax"
  parsed_invalid <- parse_put_annotation(invalid_annotation)
  expect_null(parsed_invalid)
  expect_false(is_valid_put_annotation(invalid_annotation))
})

# Performance tests for parsing
test_that("Parsing performs well with many properties", {
  # Create annotation with many properties
  many_props <- paste(paste0("prop", 1:50, ':"value', 1:50, '"'), collapse = ", ")
  annotation <- paste0("#put ", many_props)

  # Should parse without issues
  start_time <- Sys.time()
  result <- parse_put_annotation(annotation)
  end_time <- Sys.time()

  expect_equal(length(result), 50)
  expect_lt(as.numeric(end_time - start_time), 1) # Should take less than 1 second

  # Verify some properties
  expect_equal(result$prop1, "value1")
  expect_equal(result$prop50, "value50")
})
