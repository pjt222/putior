# put id:"put_entry", label:"Entry Point - Scan Files", node_type:"start", output:"workflow_data.rds"
#' Scan Source Files for PUT Annotations
#'
#' Scans source files in a directory for PUT annotations that define workflow
#' nodes, inputs, outputs, and metadata. Supports multiple programming languages
#' with their native comment syntax, including single-line and multiline formats.
#'
#' @param path Character string specifying the path to the folder containing files,
#'   or path to a single file
#' @param pattern Character string specifying the file pattern to match.
#'   Default: all supported extensions (see \code{\link{get_supported_extensions}}).
#'   For a subset, specify a pattern (e.g., "\\.js$" for JavaScript only).
#' @param recursive Logical. Should subdirectories be searched recursively?
#'   Default: TRUE
#' @param include_line_numbers Logical. Should line numbers be included in output?
#'   Default: FALSE
#' @param validate Logical. Should annotations be validated for common issues?
#'   Default: TRUE
#' @param log_level Character string specifying log verbosity for this call.
#'   Overrides the global option \code{putior.log_level} when specified.
#'   Options: "DEBUG", "INFO", "WARN", "ERROR". See \code{\link{set_putior_log_level}}.
#'
#' @return A data frame containing file names and all properties found in annotations.
#'   Always includes columns: file_name, file_type, and any properties found in
#'   PUT annotations (typically: id, label, node_type, input, output).
#'   If include_line_numbers is TRUE, also includes line_number.
#'   Note: If output is not specified in an annotation, it defaults to the file name.
#'
#' @section Supported Languages:
#' PUT annotations work with any language by using the appropriate comment prefix:
#' \itemize{
#'   \item **Hash (#)**: R, Python, Shell, Julia, Ruby, Perl, YAML
#'   \item **Dash (--)**: SQL, Lua, Haskell
#'   \item **Slash (//)**: JavaScript, TypeScript, C/C++, Java, Go, Rust, Swift, Kotlin, C#
#'   \item **Percent (%)**: MATLAB, LaTeX
#' }
#'
#' @section PUT Annotation Syntax:
#' PUT annotations can be written in single-line or multiline format.
#' The comment prefix is determined automatically by file extension.
#'
#' **Single-line format (various languages):**
#' \preformatted{
#' # put id:"node1", label:"Process"       # R/Python
#' --put id:"node1", label:"Query"        -- SQL
#' //put id:"node1", label:"Handler"      // JavaScript
#' %put id:"node1", label:"Compute"       % MATLAB
#' }
#'
#' **Multiline format:** Use backslash (\\) for line continuation
#' \preformatted{
#' # put id:"node1", label:"Process Data", \\
#' #    input:"data.csv", \\
#' #    output:"result.csv"
#' }
#'
#' **Benefits of multiline format:**
#' \itemize{
#'   \item Compliance with code style guidelines (styler, lintr)
#'   \item Improved readability for complex workflows
#'   \item Easier maintenance of long file lists
#'   \item Better code organization and documentation
#' }
#'
#' **Syntax rules:**
#' \itemize{
#'   \item End lines with backslash (\\) to continue
#'   \item Each continuation line must start with the appropriate comment marker
#'   \item Properties are automatically joined with proper comma separation
#'   \item Works with all PUT formats: prefix+put, prefix + put, prefix+put|, prefix+put:
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Scan a directory for workflow annotations (recursive by default)
#' workflow <- put("./src/")
#'
#' # Scan top-level only (opt out of recursion)
#' workflow <- put("./project/", recursive = FALSE)
#'
#' # Scan a single file
#' workflow <- put("./script.R")
#'
#' # Include line numbers for debugging
#' workflow <- put("./src/", include_line_numbers = TRUE)
#'
#' # Scan JavaScript/TypeScript files
#' workflow <- put("./frontend/", pattern = "\\.(js|ts|jsx|tsx)$")
#'
#' # Scan SQL files
#' workflow <- put("./sql/", pattern = "\\.sql$")
#'
#' # Single-line PUT annotations (various languages):
#' # R/Python: # put id:"load_data", label:"Load Dataset"
#' # SQL:      --put id:"query", label:"Execute Query"
#' # JS/TS:    //put id:"handler", label:"API Handler"
#' # MATLAB:   %put id:"compute", label:"Compute Results"
#' #
#' # Multiline PUT annotations work the same across languages:
#' # # put id:"complex_process", label:"Complex Processing", \
#' # #    input:"file1.csv,file2.csv", \
#' # #    output:"results.csv"
#' #
#' # --put id:"etl_job", label:"ETL Process", \
#' # --    input:"source_table", \
#' # --    output:"target_table"
#' }
put <- function(path,
                pattern = NULL,
                recursive = TRUE,
                include_line_numbers = FALSE,
                validate = TRUE,
                log_level = NULL) {
  # Set log level for this call if specified
  restore_log_level <- with_log_level(log_level)
  on.exit(restore_log_level(), add = TRUE)

  # Default pattern covers all supported languages
  if (is.null(pattern)) pattern <- build_file_pattern(detection_only = FALSE)

  putior_log("INFO", "Starting PUT annotation scan")
  putior_log("DEBUG", "Scan parameters: path='{path}', pattern='{pattern}', recursive={recursive}")

  # Input validation
  validate_path_arg(path, "put")

  # Handle both files and directories
  if (dir.exists(path)) {
    files <- list.files(
      path = path,
      pattern = pattern,
      full.names = TRUE,
      recursive = recursive
    )
  } else {
    # Single file case — match basename like list.files() does
    if (!grepl(pattern, basename(path))) {
      warning("File does not match pattern '", pattern, "': ", path, call. = FALSE)
      return(as_putior_workflow(empty_result_df(include_line_numbers)))
    }
    files <- path
  }

  if (length(files) == 0) {
    putior_log("WARN", "No files matching pattern '{pattern}' found in: {path}")
    warning(
      "No files matching pattern '", pattern, "' found in: ", path, "\n",
      "Check that:\n",
      "- The directory contains source files with the expected extensions\n",
      "- The pattern matches your file types (default covers all supported extensions)\n",
      "- To limit: pattern = \"\\\\.R$\" or see get_supported_extensions()",
      call. = FALSE
    )
    return(as_putior_workflow(empty_result_df(include_line_numbers)))
  }

  putior_log("INFO", "Found {length(files)} file(s) to scan")
  putior_log("DEBUG", "Files: {paste(basename(files), collapse=', ')}")

  # Process files
  results <- list()
  processing_errors <- character()

  for (file in files) {
    putior_log("DEBUG", "Processing file: {basename(file)}")
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
    warning("Errors processing files:\n", paste(processing_errors, collapse = "\n"),
            call. = FALSE)
  }

  # Convert results to data frame
  if (length(results) > 0) {
    df <- convert_results_to_df(results, include_line_numbers)

    # Check for duplicate IDs if validation is enabled
    if (validate && "id" %in% names(df)) {
      duplicate_ids <- df$id[duplicated(df$id) & !is.na(df$id)]
      if (length(duplicate_ids) > 0) {
        putior_log("WARN", "Duplicate node IDs found: {paste(unique(duplicate_ids), collapse=', ')}")
        warning(
          "Duplicate node IDs found: ", paste(unique(duplicate_ids), collapse = ", "), "\n",
          "Each node must have a unique ID within the workflow.\n",
          "Solutions:\n",
          "- Use unique 'id' values in your PUT annotations\n",
          "- Omit 'id' to enable auto-generation (requires uuid package)\n",
          "Use include_line_numbers = TRUE to locate duplicates.",
          call. = FALSE
        )
      }
    }

    putior_log("INFO", "Scan complete: found {nrow(df)} workflow node(s) in {length(files)} file(s)")
    return(as_putior_workflow(df))
  } else {
    putior_log("INFO", "Scan complete: no PUT annotations found in {length(files)} file(s)")
    as_putior_workflow(empty_result_df(include_line_numbers))
  }
}

#' Collect a possibly multiline PUT annotation starting at a given line
#'
#' If the line ends with backslash, collects continuation lines following the
#' same comment prefix. Returns the fully assembled annotation string.
#'
#' @param lines Character vector of all file lines
#' @param start_idx Index of the PUT annotation line
#' @param escaped_prefix Regex-escaped comment prefix (e.g., "\\#", "\\/\\/")
#' @param comment_pattern Regex matching any comment line
#' @param put_pattern Regex matching a PUT annotation line
#' @param file_label File name for log messages
#' @return Assembled single-line annotation string
#' @noRd
collect_multiline_annotation <- function(lines, start_idx, escaped_prefix,
                                         comment_pattern, put_pattern,
                                         file_label = "") {
  full_content <- lines[start_idx]

  if (!grepl("\\\\\\s*$", full_content)) {
    return(full_content)
  }

  putior_log("DEBUG", "Multiline annotation detected at line {start_idx} in {file_label}")
  has_continuation <- TRUE
  current_idx <- start_idx

  while (has_continuation && current_idx < length(lines)) {
    full_content <- sub("\\\\\\s*$", " ", full_content)
    current_idx <- current_idx + 1

    if (current_idx > length(lines)) break
    if (grepl(put_pattern, lines[current_idx])) break

    continuation_line <- lines[current_idx]
    if (!grepl(comment_pattern, continuation_line)) break

    continuation <- sub(sprintf("^\\s*%s\\s*", escaped_prefix), "", continuation_line)

    if (nchar(trimws(continuation)) > 0) {
      if (!grepl("^\\s*,", continuation)) {
        full_content <- paste0(full_content, ", ", trimws(continuation))
      } else {
        full_content <- paste0(full_content, trimws(continuation))
      }
    }

    if (nchar(trimws(continuation)) > 0 || grepl("\\\\\\s*$", continuation_line)) {
      has_continuation <- grepl("\\\\\\s*$", continuation_line)
    }
  }

  full_content
}

# put id:"process_file", label:"Process Single File", node_type:"process", input:"source_files", output:"annotations.rds"
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
      putior_log("DEBUG", "Read {length(lines)} lines from {basename(file)}")

      # Resolve language, extension, and comment prefix from file path
      resolved <- resolve_language_from_file(file)
      file_ext <- resolved$ext
      comment_prefix <- resolved$comment_prefix

      # Escape special regex characters in the prefix (e.g., // -> \/\/)
      escaped_prefix <- gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", comment_prefix)

      # Build regex pattern dynamically: <prefix>put or <prefix> put or <prefix>put| or <prefix>put:
      put_pattern <- sprintf("^\\s*%s\\s*put(\\||\\s+|:)", escaped_prefix)

      # Find PUT annotation lines
      put_line_indices <- grep(put_pattern, lines)

      if (length(put_line_indices) == 0) {
        putior_log("DEBUG", "No PUT annotations found in {basename(file)}")
        return(list())
      }

      putior_log("DEBUG", "Found {length(put_line_indices)} PUT annotation(s) in {basename(file)} (prefix: '{comment_prefix}')")

      file_results <- list()

      # Build comment line pattern for continuation lines (matches the comment prefix)
      comment_line_pattern <- sprintf("^\\s*%s", escaped_prefix)

      for (i in seq_along(put_line_indices)) {
        line_idx <- put_line_indices[i]
        line_content <- lines[line_idx]

        full_content <- collect_multiline_annotation(
          lines, line_idx, escaped_prefix, comment_line_pattern, put_pattern,
          basename(file)
        )

        properties <- parse_put_annotation(full_content)

        if (!is.null(properties)) {
          # Add file metadata
          properties$file_name <- basename(file)
          properties$file_path <- file
          properties$file_type <- file_ext

          if (include_line_numbers) {
            properties$line_number <- line_idx
          }
          
          # Default output to file_name if not specified
          if (is.null(properties$output) || properties$output == "") {
            properties$output <- basename(file)
          }

          # Validate if requested
          if (validate) {
            validation_issues <- validate_annotation(properties, full_content)
            if (length(validation_issues) > 0) {
              warning(
                "Validation issues in ", basename(file), " line ", line_idx, ":\n",
                paste(validation_issues, collapse = "\n"),
                call. = FALSE
              )
            }
          }

          file_results[[length(file_results) + 1]] <- properties
        } else if (validate) {
          warning(
            "Invalid PUT annotation syntax in ", basename(file), " line ", line_idx, ":\n",
            "  ", full_content, "\n",
            "Expected format: # put id:\"node_id\", label:\"Description\"\n",
            "See putior_help(\"annotation\") for syntax details.",
            call. = FALSE
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

# put id:"validate", label:"Validate Annotations", node_type:"process", input:"annotations.rds", output:"validated_annotations.rds"
#' Validate PUT annotation for common issues
#' @param properties List of annotation properties
#' @param line_content Original line content
#' @return Character vector of validation issues
#' @keywords internal
validate_annotation <- function(properties, line_content) {
  issues <- character()

  # Check for empty id (but not missing - missing ids are auto-generated)
  if (!is.null(properties$id) && properties$id == "") {
    issues <- c(issues, "Empty 'id' property - either omit id for auto-generation or provide a valid value")
  }

  # Note: Duplicate ID checking is done at the put() function level
  # Check for valid node_type values
  if (!is.null(properties$node_type)) {
    if (!properties$node_type %in% .VALID_NODE_TYPES) {
      issues <- c(issues, paste(
        "Unusual node_type:", properties$node_type,
        "(expected one of:", paste(.VALID_NODE_TYPES, collapse = ", "), ")"
      ))
    }
  }

  # Check for file extension consistency
  if (!is.null(properties$input) || !is.null(properties$output)) {
    files_mentioned <- c(properties$input, properties$output)
    files_mentioned <- files_mentioned[!is.na(files_mentioned)]

    for (file_ref in files_mentioned) {
      individual_refs <- trimws(strsplit(file_ref, ",")[[1]])
      for (single_ref in individual_refs) {
        if (nchar(single_ref) > 0 && !grepl("\\.", single_ref) &&
            !single_ref %in% names(.FILENAME_MAP)) {
          issues <- c(issues, paste("File reference missing extension:", single_ref))
        }
      }
    }
  }

  return(issues)
}

# put id:"parser", label:"Parse Annotation Syntax", node_type:"process", input:"annotations.rds", output:"properties.rds"
#' Extract PUT Annotation Properties
#'
#' Parses a single line containing a PUT annotation and extracts key-value pairs.
#' Supports flexible syntax with optional spaces and pipe separators.
#' Handles multiple comment prefix styles: # (hash), -- (dash), // (slash), % (percent).
#'
#' @param line Character string containing a PUT annotation
#' @return Named list containing all extracted properties, or NULL if invalid
#' @keywords internal
#'
parse_put_annotation <- function(line) {
  # Handle NULL input
  if (is.null(line) || length(line) == 0) {
    return(NULL)
  }

  # Convert to character if not already
  line <- as.character(line)

  # Remove the PUT prefix - handle all comment styles:
  # - Hash: #put, # put, #put|, #put:
  # - Dash: --put, -- put, --put|, --put:
  # - Slash: //put, // put, //put|, //put:
  # - Percent: %put, % put, %put|, %put:
  cleaned <- sub("^\\s*(#|--|//|%)\\s*put(\\||\\s+|:)\\s*", "", line, ignore.case = FALSE)

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
    # Generate UUID if id is missing (not if it's empty)
    if (is.null(properties$id) && requireNamespace("uuid", quietly = TRUE)) {
      properties$id <- uuid::UUIDgenerate()
    }
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

# put id:"convert_df", label:"Convert to Data Frame", node_type:"process", input:"properties.rds", output:"workflow_data.rds"
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

#' Add putior_workflow class to a data frame
#' @param df Data frame to class
#' @return Data frame with "putior_workflow" class prepended
#' @keywords internal
as_putior_workflow <- function(df) {
  class(df) <- c("putior_workflow", class(df))
  df
}

#' Print a putior workflow
#'
#' Displays a concise summary of a putior workflow data frame.
#'
#' @param x A putior_workflow object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns x
#' @export
print.putior_workflow <- function(x, ...) {
  n <- nrow(x)
  if (n == 0) {
    cat("putior workflow: 0 nodes\n")
    return(invisible(x))
  }
  files <- unique(x$file_name)
  n_files <- length(files[!is.na(files)])
  cat("putior workflow:", n, "node(s) from", n_files, "file(s)\n")

  # Show node summary
  if ("node_type" %in% names(x)) {
    types <- table(x$node_type, useNA = "no")
    if (length(types) > 0) {
      cat("  Node types:", paste(paste0(names(types), " (", types, ")"), collapse = ", "), "\n")
    }
  }

  # Print as data frame
  cat("\n")
  print.data.frame(x, ...)
  invisible(x)
}

#' Summarize a putior workflow
#'
#' Provides a structured summary of a putior workflow data frame.
#'
#' @param object A putior_workflow object
#' @param ... Additional arguments (ignored)
#' @return Invisibly returns a list with summary information
#' @export
summary.putior_workflow <- function(object, ...) {
  n <- nrow(object)
  files <- unique(object$file_name)
  n_files <- length(files[!is.na(files)])

  cat("putior workflow summary\n")
  cat("  Nodes:", n, "\n")
  cat("  Files:", n_files, "\n")

  if (n > 0) {
    if ("node_type" %in% names(object)) {
      types <- table(object$node_type, useNA = "no")
      if (length(types) > 0) {
        cat("  Node types:\n")
        for (type_name in names(types)) {
          cat("    ", type_name, ": ", types[[type_name]], "\n", sep = "")
        }
      }
    }

    # Count connections (nodes with both input and output)
    has_input <- !is.na(object$input) & object$input != ""
    has_output <- !is.na(object$output) & object$output != ""
    cat("  Nodes with inputs:", sum(has_input), "\n")
    cat("  Nodes with outputs:", sum(has_output), "\n")
  }

  invisible(list(
    n_nodes = n,
    n_files = n_files,
    node_types = if ("node_type" %in% names(object)) table(object$node_type) else NULL
  ))
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
#' is_valid_put_annotation('# put id:"test", label:"Test"') # TRUE
#' is_valid_put_annotation("# put invalid syntax") # FALSE
is_valid_put_annotation <- function(line) {
  result <- parse_put_annotation(line)
  !is.null(result) && length(result) > 0
}

#' Launch putior Interactive Sandbox
#'
#' Opens an interactive Shiny application for experimenting with PUT annotations
#' and workflow diagrams. Users can paste or type annotated code, adjust diagram
#' settings, and see real-time diagram generation without installing the package
#' locally.
#'
#' @details
#' The sandbox app allows you to:
#' \itemize{
#'   \item Enter annotated code with PUT comments
#'   \item Simulate multiple files using file markers
#'   \item Customize diagram appearance (theme, direction, etc.)
#'   \item View extracted workflow data
#'   \item Copy or download generated Mermaid code
#' }
#'
#' @return Launches the Shiny app in the default browser. Returns invisibly.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Launch the interactive sandbox
#' run_sandbox()
#' }
#'
#' @seealso \code{\link{put}}, \code{\link{put_diagram}}
run_sandbox <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop(
      "The 'shiny' package is required for the interactive sandbox.\n",
      "Install it with: install.packages(\"shiny\")\n",
      "For optional syntax highlighting, also install: install.packages(\"shinyAce\")",
      call. = FALSE
    )
  }

  app_dir <- system.file("shiny", "putior-sandbox", package = "putior")

  if (app_dir == "") {
    stop(
      "Could not find the sandbox app.\n",
      "This may indicate a corrupted package installation.\n",
      "Try reinstalling putior with: install.packages(\"putior\")",
      call. = FALSE
    )
  }

  shiny::runApp(app_dir, launch.browser = TRUE)
}
