#' Scan R and Python Files for PUT Annotations
#'
#' @param path Character string specifying the path to the folder containing files
#' @param pattern Character string specifying the file pattern to match (default: "\\.(R|py)$")
#'
#' @return A data frame containing file names and all properties found in annotations
#' @export
#'
#' @examples
#' \dontrun{
#' # R annotation example:
#' # #put name:"node1", label:"Process Data", node_type:"process"
#' #
#' # Python annotation example:
#' # #put name:"py_node1", label:"Load Data", node_type:"input"
#' documentation <- put("./src/")
#' }
put <- function(path, pattern = "\\.(R|py)$") {
  if (!dir.exists(path)) {
    stop("Directory does not exist: ", path)
  }
  
  files <- list.files(
    path = path,
    pattern = pattern,
    full.names = TRUE
  )
  
  if (length(files) == 0) {
    warning("No R or Python files found in directory: ", path)
    return(data.frame(
      file_name = character(),
      file_type = character(),
      stringsAsFactors = FALSE
    ))
  }
  
  results <- list()
  
  for (file in files) {
    tryCatch({
      lines <- readLines(file)
      put_lines <- grep("^\\s*#\\s*put(\\||\\s+)", lines, value = TRUE)
      
      if (length(put_lines) > 0) {
        file_ext <- tolower(tools::file_ext(file))
        
        for (line in put_lines) {
          properties <- parse_put_annotation(line)
          if (!is.null(properties)) {
            properties$file_name <- basename(file)
            properties$file_type <- file_ext
            results[[length(results) + 1]] <- properties
          }
        }
      }
    }, error = function(e) {
      warning("Error processing file: ", basename(file), "\n", e$message)
    })
  }
  
  if (length(results) > 0) {
    # Convert list of property lists to data frame
    result_df <- do.call(rbind, lapply(results, function(x) {
      all_cols <- unique(unlist(lapply(results, names)))
      missing_cols <- setdiff(all_cols, names(x))
      x[missing_cols] <- NA
      as.data.frame(x, stringsAsFactors = FALSE)
    }))
    
    # Ensure consistent column order with file_name and file_type first
    col_order <- c("file_name", "file_type", 
                   sort(setdiff(names(result_df), c("file_name", "file_type"))))
    result_df[, col_order]
  } else {
    data.frame(
      file_name = character(),
      file_type = character(),
      stringsAsFactors = FALSE
    )
  }
}

#' Extract PUT Annotation Properties
#'
#' @param line Character string containing a PUT annotation
#' @return Named list containing all extracted properties, or NULL if invalid
#' @keywords internal
parse_put_annotation <- function(line) {
  # Remove the PUT prefix
  cleaned <- sub("^\\s*#\\s*put(\\||\\s+)\\s*", "", line)
  
  # Split the string into key-value pairs
  pairs <- strsplit(cleaned, "\\s*,\\s*")[[1]]
  
  # Extract all key-value pairs
  properties <- list()
  
  for (pair in pairs) {
    # Match key:"value" pattern
    if (grepl('^\\s*([^:"]+):\\s*"([^"]+)"\\s*$', pair)) {
      key <- sub('^\\s*([^:"]+):\\s*".*$', "\\1", pair)
      value <- sub('^\\s*[^:"]+:\\s*"([^"]+)"\\s*$', "\\1", pair)
      properties[[key]] <- value
    }
  }
  
  # Return NULL if no valid properties were found
  if (length(properties) == 0) {
    NULL
  } else {
    properties
  }
}

# Test helper function - visible for testing but not exported
is_valid_put_annotation <- function(line) {
  # Basic validation that the line contains at least one valid key:"value" pair
  cleaned <- sub("^\\s*#\\s*put(\\||\\s+)\\s*", "", line)
  grepl('([^:"]+):\\s*"[^"]+"(\\s*,\\s*([^:"]+):\\s*"[^"]+")*\\s*$', cleaned)
}