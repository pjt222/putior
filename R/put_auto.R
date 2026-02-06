#' Auto-Annotation Functions for putior
#'
#' Functions for automatically detecting workflow elements from code analysis,
#' generating PUT annotation comments, and merging manual with auto-detected annotations.
#'
#' @name put_auto
NULL

#' Auto-Detect Workflow from Code Analysis
#'
#' Analyzes source code files to automatically detect workflow elements including
#' inputs, outputs, and dependencies without requiring explicit PUT annotations.
#' This is similar to how roxygen2 auto-generates documentation skeletons.
#'
#' @param path Character string specifying the path to the folder containing files,
#'   or path to a single file
#' @param pattern Character string specifying the file pattern to match.
#'   Default: "\\.(R|r|py|sql|sh|jl)$" (R, Python, SQL, shell, Julia files)
#' @param recursive Logical. Should subdirectories be searched recursively?
#'   Default: FALSE
#' @param detect_inputs Logical. Should file inputs be detected? Default: TRUE
#' @param detect_outputs Logical. Should file outputs be detected? Default: TRUE
#' @param detect_dependencies Logical. Should script dependencies (source calls)
#'   be detected? Default: TRUE
#' @param include_line_numbers Logical. Should line numbers be included?
#'   Default: FALSE
#' @param log_level Character string specifying log verbosity for this call.
#'   Overrides the global option \code{putior.log_level} when specified.
#'   Options: "DEBUG", "INFO", "WARN", "ERROR". See \code{\link{set_putior_log_level}}.
#'
#' @return A data frame in the same format as \code{\link{put}()}, containing:
#'   \itemize{
#'     \item file_name: Name of the source file
#'     \item file_path: Full path to the file
#'     \item file_type: File extension (r, py, sql, etc.)
#'     \item id: Auto-generated node identifier (based on file name)
#'     \item label: Human-readable label (file name without extension)
#'     \item input: Comma-separated list of detected input files
#'     \item output: Comma-separated list of detected output files
#'     \item node_type: Inferred node type (input/process/output)
#'   }
#'   This format is directly compatible with \code{\link{put_diagram}()}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Auto-detect workflow from a directory
#' workflow <- put_auto("./src/")
#' put_diagram(workflow)
#'
#' # Auto-detect with line numbers
#' workflow <- put_auto("./scripts/", include_line_numbers = TRUE)
#'
#' # Only detect outputs (useful for finding data products)
#' outputs_only <- put_auto("./analysis/", detect_inputs = FALSE)
#' }
#'
#' @seealso \code{\link{put}} for manual annotation extraction,
#'   \code{\link{put_generate}} for generating annotation comments,
#'   \code{\link{put_merge}} for combining manual and auto-detected annotations
put_auto <- function(path,
                     pattern = "\\.(R|r|py|sql|sh|jl)$",
                     recursive = FALSE,
                     detect_inputs = TRUE,
                     detect_outputs = TRUE,
                     detect_dependencies = TRUE,
                     include_line_numbers = FALSE,
                     log_level = NULL) {
  # Set log level for this call if specified
  restore_log_level <- with_log_level(log_level)
  on.exit(restore_log_level(), add = TRUE)

  putior_log("INFO", "Starting auto-detection scan")
  putior_log("DEBUG", "Auto-detection parameters: path='{path}', detect_inputs={detect_inputs}, detect_outputs={detect_outputs}, detect_dependencies={detect_dependencies}")

  # Input validation
  if (!is.character(path) || length(path) != 1) {
    stop(
      "'path' must be a single character string.\n",
      "Received: ", class(path)[1],
      if (length(path) > 1) paste0(" with ", length(path), " elements") else "",
      ".\n",
      "Example: put_auto(\"./src/\") or put_auto(\"script.R\")",
      call. = FALSE
    )
  }

  if (!file.exists(path)) {
    stop(
      "Path does not exist: '", path, "'\n",
      "Please check:\n",
      "- The path is spelled correctly\n",
      "- The directory or file exists\n",
      "- You have read permissions for this location",
      call. = FALSE
    )
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
      return(as_putior_workflow(empty_auto_result_df(include_line_numbers)))
    }
    files <- path
  }

  if (length(files) == 0) {
    putior_log("WARN", "No files matching pattern '{pattern}' found in: {path}")
    warning("No files matching pattern '", pattern, "' found in: ", path)
    return(as_putior_workflow(empty_auto_result_df(include_line_numbers)))
  }

  putior_log("INFO", "Found {length(files)} file(s) to analyze")

  # Process each file
  results <- list()

  for (file in files) {
    putior_log("DEBUG", "Auto-detecting workflow elements in: {basename(file)}")
    file_result <- detect_workflow_elements(
      file,
      detect_inputs = detect_inputs,
      detect_outputs = detect_outputs,
      detect_dependencies = detect_dependencies,
      include_line_numbers = include_line_numbers
    )

    if (!is.null(file_result)) {
      results[[length(results) + 1]] <- file_result
    }
  }

  # Convert to data frame
  if (length(results) > 0) {
    df <- do.call(rbind, lapply(results, as.data.frame, stringsAsFactors = FALSE))
    rownames(df) <- NULL
    putior_log("INFO", "Auto-detection complete: found {nrow(df)} workflow node(s)")
    return(as_putior_workflow(df))
  } else {
    putior_log("INFO", "Auto-detection complete: no workflow elements detected")
    return(as_putior_workflow(empty_auto_result_df(include_line_numbers)))
  }
}

#' Generate PUT Annotation Comments
#'
#' Analyzes source code files and generates suggested PUT annotation comments
#' based on detected inputs, outputs, and dependencies. This is similar to
#' how roxygen2 generates documentation skeletons.
#'
#' @param path Character string specifying the path to a file or directory
#' @param pattern Character string specifying the file pattern to match.
#'   Default: "\\.(R|r|py|sql|sh|jl)$"
#' @param recursive Logical. Should subdirectories be searched recursively?
#'   Default: FALSE
#' @param output Character string specifying output destination:
#'   \itemize{
#'     \item "console" - Print to console (default)
#'     \item "raw" - Return as string without printing
#'     \item "clipboard" - Copy to clipboard (requires clipr package)
#'     \item "file" - Write to files with .put suffix
#'   }
#' @param insert Logical. If TRUE, insert annotations directly into source files
#'   at the top. Use with caution. Default: FALSE
#' @param style Character string specifying annotation style:
#'   \itemize{
#'     \item "single" - Single-line annotations
#'     \item "multiline" - Multiline annotations with backslash continuation
#'   }
#'   Default: "multiline"
#'
#' @return Invisibly returns a character vector of generated annotations.
#'   Side effects depend on the \code{output} parameter.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Print suggested annotations to console
#' put_generate("./analysis.R")
#'
#' # Copy to clipboard for easy pasting
#' put_generate("./scripts/", output = "clipboard")
#'
#' # Generate multiline style annotations
#' put_generate("./src/", style = "multiline")
#'
#' # Insert annotations directly into files (use with caution)
#' put_generate("./new_script.R", insert = TRUE)
#' }
#'
#' @seealso \code{\link{put_auto}} for direct workflow detection,
#'   \code{\link{put}} for extracting existing annotations
put_generate <- function(path,
                         pattern = "\\.(R|r|py|sql|sh|jl)$",
                         recursive = FALSE,
                         output = "console",
                         insert = FALSE,
                         style = "multiline") {
  # Input validation
  if (!is.character(path) || length(path) != 1) {
    stop(
      "'path' must be a single character string.\n",
      "Received: ", class(path)[1],
      if (length(path) > 1) paste0(" with ", length(path), " elements") else "",
      ".\n",
      "Example: put_generate(\"./src/\") or put_generate(\"script.R\")",
      call. = FALSE
    )
  }

  if (!file.exists(path)) {
    stop(
      "Path does not exist: '", path, "'\n",
      "Please check:\n",
      "- The path is spelled correctly\n",
      "- The directory or file exists\n",
      "- You have read permissions for this location",
      call. = FALSE
    )
  }

  valid_outputs <- c("console", "clipboard", "file", "raw")
  if (!output %in% valid_outputs) {
    stop(
      "Invalid output: '", output, "'\n",
      "Valid options: ", paste(valid_outputs, collapse = ", "), "\n",
      "Examples:\n",
      "  put_generate(path, output = \"console\")   # Print to screen\n",
      "  put_generate(path, output = \"clipboard\") # Copy to clipboard\n",
      "  put_generate(path, output = \"file\")      # Write to .put files\n",
      "  put_generate(path, output = \"raw\")       # Return as string",
      call. = FALSE
    )
  }

  valid_styles <- c("single", "multiline")
  if (!style %in% valid_styles) {
    stop(
      "Invalid style: '", style, "'\n",
      "Valid options: ", paste(valid_styles, collapse = ", "), "\n",
      "- single: One-line annotation format\n",
      "- multiline: Multi-line format with backslash continuation\n",
      "See putior_help(\"annotation\") for syntax examples.",
      call. = FALSE
    )
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
    if (!grepl(pattern, path)) {
      warning("File does not match pattern '", pattern, "': ", path)
      return(invisible(character(0)))
    }
    files <- path
  }

  if (length(files) == 0) {
    warning("No files matching pattern '", pattern, "' found in: ", path)
    return(invisible(character(0)))
  }

  # Generate annotations for each file
  all_annotations <- character()

  for (file in files) {
    annotation <- generate_annotation_for_file(file, style)
    if (!is.null(annotation) && nchar(annotation) > 0) {
      all_annotations <- c(all_annotations, annotation)

      if (insert) {
        insert_annotation_into_file(file, annotation)
      }
    }
  }

  # Handle output
  combined <- paste(all_annotations, collapse = "\n\n")

  switch(output,
    "console" = {
      cat(combined, "\n")
    },
    "raw" = {
      # Return as string without printing
    },
    "clipboard" = {
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(combined)
        message("Annotations copied to clipboard")
      } else {
        warning(
          "clipr package not available for clipboard access.\n",
          "The annotations have been printed to console instead.\n",
          "To enable clipboard support, install with: install.packages(\"clipr\")",
          call. = FALSE
        )
        cat(combined, "\n")
      }
    },
    "file" = {
      # Write to a .put file alongside each source file
      for (i in seq_along(files)) {
        if (i <= length(all_annotations)) {
          put_file <- paste0(files[i], ".put")
          writeLines(all_annotations[i], put_file)
          message("Annotations written to: ", put_file)
        }
      }
    }
  )

  return(invisible(all_annotations))
}

#' Merge Manual and Auto-Detected Annotations
#'
#' Combines manually written PUT annotations with auto-detected workflow elements,
#' allowing flexible strategies for handling conflicts and supplementing information.
#'
#' @param path Character string specifying the path to a file or directory
#' @param pattern Character string specifying the file pattern to match.
#'   Default: "\\.(R|r|py|sql|sh|jl)$"
#' @param recursive Logical. Should subdirectories be searched recursively?
#'   Default: FALSE
#' @param merge_strategy Character string specifying how to merge:
#'   \itemize{
#'     \item "manual_priority" - Manual annotations override auto-detected (default)
#'     \item "supplement" - Auto fills in missing input/output fields only
#'     \item "union" - Combine all detected I/O from both sources
#'   }
#' @param include_line_numbers Logical. Should line numbers be included?
#'   Default: FALSE
#'
#' @return A data frame in the same format as \code{\link{put}()}, containing
#'   merged workflow information from both manual and auto-detected sources.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Merge with manual annotations taking priority
#' workflow <- put_merge("./src/")
#' put_diagram(workflow)
#'
#' # Supplement manual annotations with auto-detected I/O
#' workflow <- put_merge("./scripts/", merge_strategy = "supplement")
#'
#' # Combine all inputs/outputs from both sources
#' workflow <- put_merge("./analysis/", merge_strategy = "union")
#' }
#'
#' @seealso \code{\link{put}} for manual annotation extraction,
#'   \code{\link{put_auto}} for auto-detection
put_merge <- function(path,
                      pattern = "\\.(R|r|py|sql|sh|jl)$",
                      recursive = FALSE,
                      merge_strategy = "manual_priority",
                      include_line_numbers = FALSE) {
  # Input validation
  valid_strategies <- c("manual_priority", "supplement", "union")
  if (!merge_strategy %in% valid_strategies) {
    stop(
      "Invalid merge_strategy: '", merge_strategy, "'\n",
      "Valid options: ", paste(valid_strategies, collapse = ", "), "\n",
      "- manual_priority: Manual annotations override auto-detected\n",
      "- supplement: Auto fills in missing input/output fields only\n",
      "- union: Combine all detected I/O from both sources",
      call. = FALSE
    )
  }

  # Get manual annotations
  manual <- put(
    path = path,
    pattern = pattern,
    recursive = recursive,
    include_line_numbers = include_line_numbers,
    validate = FALSE
  )

  # Get auto-detected annotations
  auto <- put_auto(
    path = path,
    pattern = pattern,
    recursive = recursive,
    include_line_numbers = include_line_numbers
  )

  # If one is empty, return the other

  if (nrow(manual) == 0 && nrow(auto) == 0) {
    return(as_putior_workflow(empty_auto_result_df(include_line_numbers)))
  }

  if (nrow(manual) == 0) {
    return(auto)
  }

  if (nrow(auto) == 0) {
    return(manual)
  }

  # Merge based on strategy
  merged <- merge_annotations(manual, auto, merge_strategy)

  return(as_putior_workflow(merged))
}

# Internal helper functions

#' Detect workflow elements in a single file
#' @param file Path to source file
#' @param detect_inputs Whether to detect inputs
#' @param detect_outputs Whether to detect outputs
#' @param detect_dependencies Whether to detect dependencies
#' @param include_line_numbers Whether to include line numbers
#' @return Named list with workflow elements
#' @keywords internal
detect_workflow_elements <- function(file,
                                     detect_inputs = TRUE,
                                     detect_outputs = TRUE,
                                     detect_dependencies = TRUE,
                                     include_line_numbers = FALSE) {
  tryCatch({
    # Read file content
    lines <- readLines(file, warn = FALSE, encoding = "UTF-8")
    content <- paste(lines, collapse = "\n")

    # Determine language from file extension
    file_ext <- tolower(tools::file_ext(file))
    language <- ext_to_language(file_ext)

    if (is.null(language)) {
      putior_log("DEBUG", "Unsupported file extension '{file_ext}' for {basename(file)}")
      return(NULL)
    }

    putior_log("DEBUG", "Detected language '{language}' for {basename(file)}")

    # Get detection patterns
    patterns <- get_detection_patterns(language)

    # Detect elements
    inputs <- character()
    outputs <- character()
    dependencies <- character()
    input_lines <- integer()
    output_lines <- integer()

    if (detect_inputs) {
      input_result <- detect_files_from_patterns(content, lines, patterns$input)
      inputs <- input_result$files
      input_lines <- input_result$lines
      if (length(inputs) > 0) {
        putior_log("DEBUG", "Detected {length(inputs)} input(s) in {basename(file)}: {paste(inputs, collapse=', ')}")
      }
    }

    if (detect_outputs) {
      output_result <- detect_files_from_patterns(content, lines, patterns$output)
      outputs <- output_result$files
      output_lines <- output_result$lines
      if (length(outputs) > 0) {
        putior_log("DEBUG", "Detected {length(outputs)} output(s) in {basename(file)}: {paste(outputs, collapse=', ')}")
      }
    }

    if (detect_dependencies) {
      dep_result <- detect_files_from_patterns(content, lines, patterns$dependency)
      dependencies <- dep_result$files
      if (length(dependencies) > 0) {
        putior_log("DEBUG", "Detected {length(dependencies)} dependency(ies) in {basename(file)}")
      }
    }

    # Generate node ID and label from filename
    file_name <- basename(file)
    file_base <- tools::file_path_sans_ext(file_name)
    node_id <- gsub("[^a-zA-Z0-9_]", "_", tolower(file_base))

    # Determine node type based on detected elements
    node_type <- infer_node_type(inputs, outputs)

    # Build result
    result <- list(
      file_name = file_name,
      file_path = file,
      file_type = file_ext,
      id = node_id,
      label = file_base,
      input = if (length(inputs) > 0) paste(unique(inputs), collapse = ",") else NA_character_,
      output = if (length(outputs) > 0) paste(unique(outputs), collapse = ",") else file_name,
      node_type = node_type,
      auto_detected = TRUE
    )

    if (include_line_numbers) {
      result$line_number <- 1L  # Node represents the whole file
    }

    return(result)

  }, error = function(e) {
    warning("Error processing ", basename(file), ": ", e$message)
    return(NULL)
  })
}

#' Detect files from pattern list
#' @param content Full file content as single string
#' @param lines File content as line vector
#' @param pattern_list List of detection patterns
#' @return List with files and lines vectors
#' @keywords internal
detect_files_from_patterns <- function(content, lines, pattern_list) {
  files <- character()
  line_nums <- integer()

  for (pattern_def in pattern_list) {
    # Search each line for the pattern and extract file arguments
    for (i in seq_along(lines)) {
      line <- lines[i]

      if (grepl(pattern_def$regex, line, ignore.case = TRUE, perl = TRUE)) {
        # Found a match - now extract the file path from this line
        extracted <- extract_file_path_from_line(line, pattern_def)

        if (!is.null(extracted) && length(extracted) > 0) {
          for (file_path in extracted) {
            if (is_likely_file_path(file_path)) {
              files <- c(files, file_path)
              line_nums <- c(line_nums, i)
            }
          }
        }
      }
    }
  }

  list(files = unique(files), lines = unique(line_nums))
}

#' Extract file path from a line containing a matched function call
#' @param line The line containing the function call
#' @param pattern_def The pattern definition
#' @return Character vector of extracted file paths
#' @keywords internal
extract_file_path_from_line <- function(line, pattern_def) {
  files <- character()

  # Strategy 1: Extract all quoted strings from the line
  # This captures file paths in function arguments like read.csv("file.csv")
  quoted_pattern <- '["\']([^"\']+)["\']'
  matches <- gregexpr(quoted_pattern, line, perl = TRUE)

  if (matches[[1]][1] != -1) {
    matched_strings <- regmatches(line, matches)[[1]]
    for (match_str in matched_strings) {
      # Remove quotes
      file_path <- gsub('^["\']|["\']$', '', match_str)
      if (nchar(file_path) > 0) {
        files <- c(files, file_path)
      }
    }
  }

  return(files)
}

#' Extract file path from a matched string (legacy function)
#' @param match_str The matched string containing the function call
#' @param pattern_def The pattern definition
#' @return Extracted file path or NULL
#' @keywords internal
extract_file_path <- function(match_str, pattern_def) {
  # Try to extract quoted string (file path)
  # Match both single and double quotes
  quoted_pattern <- '["\']([^"\']+)["\']'
  quoted_match <- regmatches(match_str, regexpr(quoted_pattern, match_str, perl = TRUE))

  if (length(quoted_match) > 0 && nchar(quoted_match) > 0) {
    # Remove quotes
    file_path <- gsub('^["\']|["\']$', '', quoted_match)
    return(file_path)
  }

  # Try to extract variable/path without quotes (for some patterns)
  # This handles cases like: from table_name
  unquoted_pattern <- "\\s+([a-zA-Z_][a-zA-Z0-9_./\\-]*)"
  unquoted_match <- regmatches(match_str, regexpr(unquoted_pattern, match_str, perl = TRUE))

  if (length(unquoted_match) > 0 && nchar(unquoted_match) > 0) {
    return(trimws(unquoted_match))
  }

  return(NULL)
}

#' Check if a string looks like a file path
#' @param str String to check
#' @return Logical
#' @keywords internal
is_likely_file_path <- function(str) {
  if (is.null(str) || nchar(str) == 0) {
    return(FALSE)
  }

  # Check for file extension
  has_extension <- grepl("\\.[a-zA-Z0-9]{1,10}$", str)

  # Check for path separators
  has_path_sep <- grepl("[/\\\\]", str)

  # Check it's not too short or just an extension
  reasonable_length <- nchar(str) >= 3

  # Check it's not a URL (unless it's a file:// URL)
  not_url <- !grepl("^https?://|^ftp://", str, ignore.case = TRUE)

  # Check for common non-file patterns to exclude
  not_excluded <- !grepl("^(TRUE|FALSE|NULL|NA|NaN|Inf)$", str, ignore.case = TRUE)

  return((has_extension || has_path_sep) && reasonable_length && not_url && not_excluded)
}

#' Infer node type from inputs and outputs
#' @param inputs Detected input files
#' @param outputs Detected output files
#' @return Character string of node type
#' @keywords internal
infer_node_type <- function(inputs, outputs) {
  has_inputs <- length(inputs) > 0
  has_outputs <- length(outputs) > 0

  if (!has_inputs && has_outputs) {
    return("input")  # Data source/generator

  } else if (has_inputs && !has_outputs) {
    return("output")  # Final consumer
  } else if (has_inputs && has_outputs) {
    return("process")  # Transformation
  } else {
    return("process")  # Default
  }
}

# NOTE: ext_to_language() function has been moved to R/language_registry.R
# It now supports additional languages: JavaScript, TypeScript, C/C++, Java, Go, Rust, etc.

#' Generate annotation text for a single file
#' @param file Path to source file
#' @param style Annotation style ("single" or "multiline")
#' @return Annotation string
#' @keywords internal
generate_annotation_for_file <- function(file, style = "multiline") {
  # Detect workflow elements
  elements <- detect_workflow_elements(file, include_line_numbers = FALSE)

  if (is.null(elements)) {
    return(NULL)
  }

  # Build annotation parts
  file_name <- basename(file)
  file_ext <- tolower(tools::file_ext(file))

  # Get the appropriate comment prefix for this file type
  comment_prefix <- get_comment_prefix(file_ext)

  parts <- list()

  parts$id <- paste0('id:"', elements$id, '"')
  parts$label <- paste0('label:"', elements$label, '"')

  if (!is.na(elements$node_type) && elements$node_type != "") {
    parts$node_type <- paste0('node_type:"', elements$node_type, '"')
  }

  if (!is.na(elements$input) && elements$input != "") {
    parts$input <- paste0('input:"', elements$input, '"')
  }

  if (!is.na(elements$output) && elements$output != "" && elements$output != file_name) {
    parts$output <- paste0('output:"', elements$output, '"')
  }

  # Format based on style, using the appropriate comment prefix
  if (style == "single") {
    annotation <- paste0(comment_prefix, "put ", paste(unlist(parts), collapse = ", "))
  } else {
    # Multiline format
    annotation_lines <- c(
      paste0(comment_prefix, " Suggested annotations for: ", file_name),
      paste0(comment_prefix, "put ", parts$id, ", ", parts$label, ", \\")
    )

    remaining <- parts[!names(parts) %in% c("id", "label")]
    for (i in seq_along(remaining)) {
      if (i < length(remaining)) {
        annotation_lines <- c(annotation_lines, paste0(comment_prefix, "    ", remaining[[i]], ", \\"))
      } else {
        annotation_lines <- c(annotation_lines, paste0(comment_prefix, "    ", remaining[[i]]))
      }
    }

    annotation <- paste(annotation_lines, collapse = "\n")
  }

  return(annotation)
}

#' Insert annotation at top of file
#' @param file Path to source file
#' @param annotation Annotation text to insert
#' @keywords internal
insert_annotation_into_file <- function(file, annotation) {
  tryCatch({
    # Read existing content
    content <- readLines(file, warn = FALSE, encoding = "UTF-8")

    # Get the appropriate comment prefix for this file type
    file_ext <- tolower(tools::file_ext(file))
    comment_prefix <- get_comment_prefix(file_ext)
    escaped_prefix <- gsub("([.|()\\^{}+$*?]|\\[|\\])", "\\\\\\1", comment_prefix)

    # Check if file already has PUT annotation (using the appropriate prefix)
    put_pattern <- sprintf("^\\s*%s\\s*put", escaped_prefix)
    has_put <- any(grepl(put_pattern, content, ignore.case = FALSE))

    if (has_put) {
      message("Skipping ", basename(file), " - already has PUT annotation")
      return(invisible(NULL))
    }

    # Find insertion point (after any shebang or initial comments)
    # Build pattern to match header comments using the file's comment prefix
    header_comment_pattern <- sprintf("^%s", escaped_prefix)
    insert_line <- 1
    for (i in seq_along(content)) {
      line <- content[i]
      # Skip shebang, roxygen comments (R-specific), and file header comments
      if (grepl("^#!", line) ||
          grepl("^#'", line) ||
          (i <= 3 && grepl(header_comment_pattern, line))) {
        insert_line <- i + 1
      } else {
        break
      }
    }

    # Insert annotation
    new_content <- c(
      content[seq_len(insert_line - 1)],
      "",
      annotation,
      "",
      content[seq(insert_line, length(content))]
    )

    # Write back
    writeLines(new_content, file)
    message("Inserted annotation into: ", basename(file))

  }, error = function(e) {
    warning("Failed to insert annotation into ", basename(file), ": ", e$message)
  })
}

#' Merge manual and auto-detected annotations
#' @param manual Data frame of manual annotations
#' @param auto Data frame of auto-detected annotations
#' @param strategy Merge strategy
#' @return Merged data frame
#' @keywords internal
merge_annotations <- function(manual, auto, strategy) {
  # Ensure auto_detected column exists
  if (!"auto_detected" %in% names(manual)) {
    manual$auto_detected <- FALSE
  }
  if (!"auto_detected" %in% names(auto)) {
    auto$auto_detected <- TRUE
  }

  # Get all column names
  all_cols <- union(names(manual), names(auto))

  # Add missing columns to both
  for (col in setdiff(all_cols, names(manual))) {
    manual[[col]] <- NA
  }
  for (col in setdiff(all_cols, names(auto))) {
    auto[[col]] <- NA
  }

  # Reorder columns
  manual <- manual[, all_cols]
  auto <- auto[, all_cols]

  switch(strategy,
    "manual_priority" = {
      # Keep manual annotations, add auto-detected for files without manual annotations
      manual_files <- manual$file_name
      auto_new <- auto[!auto$file_name %in% manual_files, ]
      result <- rbind(manual, auto_new)
    },
    "supplement" = {
      # For files with manual annotations, fill in missing input/output from auto
      manual_files <- manual$file_name
      auto_lookup <- auto[auto$file_name %in% manual_files, ]

      for (i in seq_len(nrow(manual))) {
        file_name <- manual$file_name[i]
        auto_row <- auto_lookup[auto_lookup$file_name == file_name, ]

        if (nrow(auto_row) > 0) {
          # Supplement missing input
          if ((is.na(manual$input[i]) || manual$input[i] == "") &&
              !is.na(auto_row$input[1]) && auto_row$input[1] != "") {
            manual$input[i] <- auto_row$input[1]
          }
          # Supplement missing output
          if ((is.na(manual$output[i]) || manual$output[i] == manual$file_name[i]) &&
              !is.na(auto_row$output[1]) && auto_row$output[1] != "" &&
              auto_row$output[1] != file_name) {
            manual$output[i] <- auto_row$output[1]
          }
        }
      }

      # Add auto-detected for files without manual annotations
      auto_new <- auto[!auto$file_name %in% manual_files, ]
      result <- rbind(manual, auto_new)
    },
    "union" = {
      # Combine all I/O from both sources
      manual_files <- manual$file_name

      for (i in seq_len(nrow(manual))) {
        file_name <- manual$file_name[i]
        auto_row <- auto[auto$file_name == file_name, ]

        if (nrow(auto_row) > 0) {
          # Union inputs
          manual_inputs <- if (!is.na(manual$input[i])) {
            strsplit(manual$input[i], ",")[[1]]
          } else {
            character()
          }
          auto_inputs <- if (!is.na(auto_row$input[1])) {
            strsplit(auto_row$input[1], ",")[[1]]
          } else {
            character()
          }
          all_inputs <- unique(trimws(c(manual_inputs, auto_inputs)))
          if (length(all_inputs) > 0) {
            manual$input[i] <- paste(all_inputs, collapse = ",")
          }

          # Union outputs
          manual_outputs <- if (!is.na(manual$output[i])) {
            strsplit(manual$output[i], ",")[[1]]
          } else {
            character()
          }
          auto_outputs <- if (!is.na(auto_row$output[1])) {
            strsplit(auto_row$output[1], ",")[[1]]
          } else {
            character()
          }
          all_outputs <- unique(trimws(c(manual_outputs, auto_outputs)))
          if (length(all_outputs) > 0) {
            manual$output[i] <- paste(all_outputs, collapse = ",")
          }
        }
      }

      # Add auto-detected for files without manual annotations
      auto_new <- auto[!auto$file_name %in% manual_files, ]
      result <- rbind(manual, auto_new)
    }
  )

  rownames(result) <- NULL
  return(result)
}

#' Create empty result data frame for put_auto
#' @param include_line_numbers Whether to include line_number column
#' @return Empty data frame with correct structure
#' @keywords internal
empty_auto_result_df <- function(include_line_numbers = FALSE) {
  cols <- list(
    file_name = character(),
    file_path = character(),
    file_type = character(),
    id = character(),
    label = character(),
    input = character(),
    output = character(),
    node_type = character(),
    auto_detected = logical()
  )

  if (include_line_numbers) {
    cols$line_number <- integer()
  }

  data.frame(cols, stringsAsFactors = FALSE)
}
