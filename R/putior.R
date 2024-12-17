#' Scan R Files for PUT Annotations
#'
#' @param path Character string specifying the path to the folder containing R files
#' @param pattern Character string specifying the file pattern to match (default: "\\.R$")
#'
#' @return A data frame containing file names, node names, and node labels
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming you have R files with #put| annotations in "./analysis/"
#' documentation <- put("./analysis/")
#' }
put <- function(path, pattern = "\\.R$") {
  # Validate input path
  if (!dir.exists(path)) {
    stop("Directory does not exist: ", path)
  }
  
  # Get all R files in the directory
  r_files <- list.files(
    path = path,
    pattern = pattern,
    full.names = TRUE
  )
  
  if (length(r_files) == 0) {
    warning("No R files found in directory: ", path)
    return(data.frame(
      file_name = character(),
      node_name = character(),
      node_label = character(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Initialize results list
  results <- list()
  
  # Process each file
  for (file in r_files) {
    tryCatch({
      # Read the file
      lines <- readLines(file)
      
      # Find lines with #put| annotations
      put_lines <- grep("^\\s*#put\\|", lines, value = TRUE)
      
      if (length(put_lines) > 0) {
        # Process each annotation line
        for (line in put_lines) {
          # Extract the annotation part after #put|
          annotation <- sub("^\\s*#put\\|\\s*", "", line)
          
          # Parse the annotation using regex
          name_match <- regexpr('name:\\s*"([^"]+)"', annotation)
          label_match <- regexpr('label:\\s*"([^"]+)"', annotation)
          
          if (name_match > 0 && label_match > 0) {
            name <- gsub('name:\\s*"|"', '', regmatches(annotation, name_match))
            label <- gsub('label:\\s*"|"', '', regmatches(annotation, label_match))
            
            results[[length(results) + 1]] <- list(
              file_name = basename(file),
              node_name = name,
              node_label = label
            )
          }
        }
      }
    }, error = function(e) {
      warning("Error processing file: ", basename(file), "\n", e$message)
    })
  }
  
  # Convert results to data frame
  if (length(results) > 0) {
    do.call(rbind, lapply(results, data.frame, stringsAsFactors = FALSE))
  } else {
    data.frame(
      file_name = character(),
      node_name = character(),
      node_label = character(),
      stringsAsFactors = FALSE
    )
  }
}

#' Extract PUT Annotation from a Single Line
#'
#' @param line Character string containing a PUT annotation
#' @return Named list containing extracted name and label, or NULL if invalid
#' @keywords internal
parse_put_annotation <- function(line) {
  # Remove the #put| prefix and trim whitespace
  cleaned <- sub("^\\s*#put\\|\\s*", "", line)
  
  # Try to extract name and label using regex
  name_match <- regexpr('name:\\s*"([^"]+)"', cleaned)
  label_match <- regexpr('label:\\s*"([^"]+)"', cleaned)
  
  if (name_match > 0 && label_match > 0) {
    name <- gsub('name:\\s*"|"', '', regmatches(cleaned, name_match))
    label <- gsub('label:\\s*"|"', '', regmatches(cleaned, label_match))
    
    list(
      name = name,
      label = label
    )
  } else {
    NULL
  }
}

# Test helper function - visible for testing but not exported
is_valid_put_annotation <- function(line) {
  grepl("^\\s*#put\\|\\s*name:\\s*\"[^\"]+\"\\s*,\\s*label:\\s*\"[^\"]+\"\\s*$", line)
}