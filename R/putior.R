#' Scan R and Python Files for PUT Annotations
#'
#' Scans source files in a directory for PUT annotations that define workflow
#' nodes, inputs, outputs, and metadata. Supports both R and Python files with
#' flexible annotation syntax.
#'
#' @param path Character string specifying the path to the folder containing files,
#'   or path to a single file
#' @param pattern Character string specifying the file pattern to match.
#'   Default: "\\.(R|r|py|sql|sh|jl)$" (R, Python, SQL, shell, Julia files)
#' @param recursive Logical. Should subdirectories be searched recursively?
#'   Default: FALSE
#' @param include_line_numbers Logical. Should line numbers be included in output?
#'   Default: FALSE
#' @param validate Logical. Should annotations be validated for common issues?
#'   Default: TRUE
#'
#' @return A data frame containing file names and all properties found in annotations.
#'   Always includes columns: file_name, file_type, and any properties found in
#'   PUT annotations. If include_line_numbers is TRUE, also includes line_number.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Scan a directory for workflow annotations
#' workflow <- put("./src/")
#'
#' # Scan recursively including subdirectories
#' workflow <- put("./project/", recursive = TRUE)
#'
#' # Scan a single file
#' workflow <- put("./script.R")
#'
#' # Include line numbers for debugging
#' workflow <- put("./src/", include_line_numbers = TRUE)
#'
#' # Example annotations in your source files:
#' # #put name:"load_data", label:"Load Dataset", node_type:"input", output:"data.csv"
#' # #put name:"process", label:"Clean Data", node_type:"process", input:"data.csv", output:"clean.csv"
#' }
put <- function(path,
                pattern = "\\.(R|r|py|sql|sh|jl)$",
                recursive = FALSE,
                include_line_numbers = FALSE,
                validate = TRUE) {
  # Input validation
  if (!is.character(path) || length(path) != 1) {
    stop("'path' must be a single character string")
  }

  if (!file.exists(path)) {
    stop("Path does not exist: ", path)
  }

  # Handle both files and directories
  if (dir.exists(path)) {
    files <- list.files(
      path = path,
      pattern = pattern,
      full.names = TRUE,
      recursive = recursive
    )
  } else {
    # Single file case
    if (!grepl(pattern, path)) {
      warning("File does not match pattern '", pattern, "': ", path)
      return(empty_result_df(include_line_numbers))
    }
    files <- path
  }

  if (length(files) == 0) {
    warning("No files matching pattern '", pattern, "' found in: ", path)
    return(empty_result_df(include_line_numbers))
  }

  # Process files
  results <- list()
  processing_errors <- character()

  for (file in files) {
    file_result <- process_single_file(file, include_line_numbers, validate)

    if (is.character(file_result)) {
      # Error occurred
      processing_errors <- c(processing_errors, file_result)
    } else if (length(file_result) > 0) {
      # Valid results found
      results <- c(results, file_result)
    }
  }

  # Report any errors
  if (length(processing_errors) > 0) {
    warning("Errors processing files:\n", paste(processing_errors, collapse = "\n"))
  }

  # Convert results to data frame
  if (length(results) > 0) {
    convert_results_to_df(results, include_line_numbers)
  } else {
    empty_result_df(include_line_numbers)
  }
}

#' Process a single file for PUT annotations
#' @param file Path to file
#' @param include_line_numbers Whether to include line numbers
#' @param validate Whether to validate annotations
#' @return List of annotation results or error message
#' @keywords internal
process_single_file <- function(file, include_line_numbers, validate) {
  tryCatch(
    {
      # Read file with proper encoding handling
      lines <- readLines(file, warn = FALSE, encoding = "UTF-8")

      # Find PUT annotation lines
      put_line_indices <- grep("^\\s*#\\s*put(\\||\\s+|:)", lines)

      if (length(put_line_indices) == 0) {
        return(list())
      }

      file_ext <- tolower(tools::file_ext(file))
      file_results <- list()

      for (line_idx in put_line_indices) {
        line_content <- lines[line_idx]
        properties <- parse_put_annotation(line_content)

        if (!is.null(properties)) {
          # Add file metadata
          properties$file_name <- basename(file)
          properties$file_path <- file
          properties$file_type <- file_ext

          if (include_line_numbers) {
            properties$line_number <- line_idx
          }

          # Validate if requested
          if (validate) {
            validation_issues <- validate_annotation(properties, line_content)
            if (length(validation_issues) > 0) {
              warning(
                "Validation issues in ", basename(file), " line ", line_idx, ":\n",
                paste(validation_issues, collapse = "\n")
              )
            }
          }

          file_results[[length(file_results) + 1]] <- properties
        } else if (validate) {
          warning(
            "Invalid PUT annotation syntax in ", basename(file), " line ", line_idx, ":\n",
            line_content
          )
        }
      }

      return(file_results)
    },
    error = function(e) {
      return(paste("Error processing", basename(file), ":", e$message))
    }
  )
}

#' Validate PUT annotation for common issues
#' @param properties List of annotation properties
#' @param line_content Original line content
#' @return Character vector of validation issues
#' @keywords internal
validate_annotation <- function(properties, line_content) {
  issues <- character()

  # Check for required properties (can be customized)
  if (is.null(properties$name) || properties$name == "") {
    issues <- c(issues, "Missing or empty 'name' property")
  }

  # Check for duplicate names (would need to be done at higher level)
  # Check for valid node_type values
  if (!is.null(properties$node_type)) {
    valid_types <- c("input", "process", "output", "decision", "start", "end")
    if (!properties$node_type %in% valid_types) {
      issues <- c(issues, paste(
        "Unusual node_type:", properties$node_type,
        "(expected one of:", paste(valid_types, collapse = ", "), ")"
      ))
    }
  }

  # Check for file extension consistency
  if (!is.null(properties$input) || !is.null(properties$output)) {
    files_mentioned <- c(properties$input, properties$output)
    files_mentioned <- files_mentioned[!is.na(files_mentioned)]

    for (file_ref in files_mentioned) {
      if (!grepl("\\.", file_ref)) {
        issues <- c(issues, paste("File reference missing extension:", file_ref))
      }
    }
  }

  return(issues)
}

#' Extract PUT Annotation Properties
#'
#' Parses a single line containing a PUT annotation and extracts key-value pairs.
#' Supports flexible syntax with optional spaces and pipe separators.
#'
#' @param line Character string containing a PUT annotation
#' @return Named list containing all extracted properties, or NULL if invalid
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' parse_put_annotation('#put name:"test", label:"Test Node"')
#' parse_put_annotation('# put name:"test", node_type:"process"')
#' parse_put_annotation('#put| name:"test", input:"data.csv"')
#' }
parse_put_annotation <- function(line) {
  # Handle NULL input
  if (is.null(line) || length(line) == 0) {
    return(NULL)
  }

  # Convert to character if not already
  line <- as.character(line)

  # Remove the PUT prefix (more flexible regex)
  cleaned <- sub("^\\s*#\\s*put(\\||\\s+|:)\\s*", "", line, ignore.case = FALSE)

  # Handle edge case of empty annotation
  if (is.null(cleaned) || length(cleaned) == 0 || nchar(trimws(cleaned)) == 0) {
    return(NULL)
  }

  # Improved parsing to handle edge cases
  # Split on commas, but not commas inside quotes
  pairs <- parse_comma_separated_pairs(cleaned)

  # Extract all key-value pairs
  properties <- list()

  for (pair in pairs) {
    pair <- trimws(pair)

    # Match key:"value" or key:'value' pattern
    if (grepl('^([^:"\']+):\\s*["\']([^"\']*)["\']\\s*$', pair)) {
      key <- sub('^([^:"\']+):\\s*["\'].*$', "\\1", pair)
      value <- sub('^[^:"\']+:\\s*["\']([^"\']*)["\']\\s*$', "\\1", pair)

      # Clean up key but preserve value whitespace
      key <- trimws(key)
      # Don't trim value - preserve internal whitespace as specified by user

      if (nchar(key) > 0) {
        properties[[key]] <- value
      }
    }
  }

  # Return NULL if no valid properties were found
  if (length(properties) == 0) {
    NULL
  } else {
    properties
  }
}

#' Parse comma-separated pairs while respecting quotes
#' @param text Text to parse
#' @return Character vector of pairs
#' @keywords internal
parse_comma_separated_pairs <- function(text) {
  # Handle NULL or empty input
  if (is.null(text) || length(text) == 0 || nchar(text) == 0) {
    return(character(0))
  }

  # Simple implementation - could be improved for complex cases
  # This handles most common cases correctly
  pairs <- character()
  current_pair <- ""
  in_quotes <- FALSE
  quote_char <- ""

  for (i in seq_len(nchar(text))) {
    char <- substr(text, i, i)

    if (!in_quotes && (char == '"' || char == "'")) {
      in_quotes <- TRUE
      quote_char <- char
      current_pair <- paste0(current_pair, char)
    } else if (in_quotes && char == quote_char) {
      in_quotes <- FALSE
      quote_char <- ""
      current_pair <- paste0(current_pair, char)
    } else if (!in_quotes && char == ",") {
      if (nchar(trimws(current_pair)) > 0) {
        pairs <- c(pairs, current_pair)
      }
      current_pair <- ""
    } else {
      current_pair <- paste0(current_pair, char)
    }
  }

  # Add the last pair
  if (nchar(trimws(current_pair)) > 0) {
    pairs <- c(pairs, current_pair)
  }

  return(pairs)
}
#' Parse comma-separated pairs while respecting quotes
#' @param text Text to parse
#' @return Character vector of pairs
#' @keywords internal
parse_comma_separated_pairs <- function(text) {
  # Simple implementation - could be improved for complex cases
  # This handles most common cases correctly
  pairs <- character()
  current_pair <- ""
  in_quotes <- FALSE
  quote_char <- ""

  for (i in seq_len(nchar(text))) {
    char <- substr(text, i, i)

    if (!in_quotes && (char == '"' || char == "'")) {
      in_quotes <- TRUE
      quote_char <- char
      current_pair <- paste0(current_pair, char)
    } else if (in_quotes && char == quote_char) {
      in_quotes <- FALSE
      quote_char <- ""
      current_pair <- paste0(current_pair, char)
    } else if (!in_quotes && char == ",") {
      if (nchar(trimws(current_pair)) > 0) {
        pairs <- c(pairs, current_pair)
      }
      current_pair <- ""
    } else {
      current_pair <- paste0(current_pair, char)
    }
  }

  # Add the last pair
  if (nchar(trimws(current_pair)) > 0) {
    pairs <- c(pairs, current_pair)
  }

  return(pairs)
}

#' Convert results list to data frame
#' @param results List of annotation results
#' @param include_line_numbers Whether line numbers are included
#' @return Data frame
#' @keywords internal
convert_results_to_df <- function(results, include_line_numbers) {
  # Get all unique column names
  all_cols <- unique(unlist(lapply(results, names)))

  # Ensure consistent column order
  standard_cols <- c("file_name", "file_path", "file_type")
  if (include_line_numbers) {
    standard_cols <- c(standard_cols, "line_number")
  }

  other_cols <- sort(setdiff(all_cols, standard_cols))
  col_order <- c(standard_cols, other_cols)

  # Convert to data frame
  result_df <- do.call(rbind, lapply(results, function(x) {
    missing_cols <- setdiff(col_order, names(x))
    x[missing_cols] <- NA
    as.data.frame(x[col_order], stringsAsFactors = FALSE)
  }))

  # Clean row names
  rownames(result_df) <- NULL

  return(result_df)
}

#' Create empty result data frame
#' @param include_line_numbers Whether to include line_number column
#' @return Empty data frame with correct structure
#' @keywords internal
empty_result_df <- function(include_line_numbers = FALSE) {
  cols <- list(
    file_name = character(),
    file_path = character(),
    file_type = character()
  )

  if (include_line_numbers) {
    cols$line_number <- integer()
  }

  data.frame(cols, stringsAsFactors = FALSE)
}

# Exported utility functions

#' Validate PUT annotation syntax
#'
#' Test helper function to validate PUT annotation syntax
#'
#' @param line Character string containing a PUT annotation
#' @return Logical indicating if the annotation is valid
#' @export
#'
#' @examples
#' is_valid_put_annotation('#put name:"test", label:"Test"') # TRUE
#' is_valid_put_annotation("#put invalid syntax") # FALSE
is_valid_put_annotation <- function(line) {
  result <- parse_put_annotation(line)
  !is.null(result) && length(result) > 0
}
