#' Language Comment Syntax Registry
#'
#' Internal data structures and functions for managing comment syntax
#' across different programming languages. This enables putior to recognize
#' PUT annotations in languages with different comment styles.
#'
#' @name language_registry
#' @keywords internal
NULL

#' Language Groups by Comment Syntax
#'
#' A list defining programming languages grouped by their single-line comment syntax.
#' Each group contains the comment prefix, supported file extensions, and language names.
#'
#' @format A named list with four groups:
#' \describe{
#'   \item{hash}{Languages using \code{#} for comments (R, Python, Shell, etc.)}
#'   \item{dash}{Languages using \code{--} for comments (SQL, Lua, Haskell)}
#'   \item{slash}{Languages using \code{//} for comments (JavaScript, C, Go, etc.)}
#'   \item{percent}{Languages using \code{\%} for comments (MATLAB, LaTeX)}
#' }
#'
#' @keywords internal
LANGUAGE_GROUPS <- list(
  hash = list(
    prefix = "#",
    extensions = c("r", "py", "sh", "bash", "jl", "rb", "pl", "yaml", "yml", "toml"),
    languages = c("r", "python", "shell", "julia", "ruby", "perl", "yaml", "toml")
  ),
  dash = list(
    prefix = "--",
    extensions = c("sql", "lua", "hs"),
    languages = c("sql", "lua", "haskell")
  ),
  slash = list(
    prefix = "//",
    extensions = c("js", "ts", "jsx", "tsx", "c", "cpp", "h", "hpp", "java", "go",
                   "rs", "swift", "kt", "cs", "php", "scala", "groovy", "d"),
    languages = c("javascript", "typescript", "c", "cpp", "java", "go", "rust",
                  "swift", "kotlin", "csharp", "php", "scala", "groovy", "d")
  ),
  percent = list(
    prefix = "%",
    extensions = c("m", "tex"),
    languages = c("matlab", "latex")
  )
)

#' Get Comment Prefix for File Extension
#'
#' Returns the single-line comment prefix for a given file extension.
#' Falls back to \code{#} for unknown extensions.
#'
#' @param ext Character string of the file extension (without dot)
#' @return Character string of the comment prefix
#'
#' @export
#'
#' @examples
#' get_comment_prefix("r")    # Returns "#"
#' get_comment_prefix("sql")  # Returns "--"
#' get_comment_prefix("js")   # Returns "//"
#' get_comment_prefix("tex")  # Returns "%"
#' get_comment_prefix("xyz")  # Returns "#" (fallback)
get_comment_prefix <- function(ext) {
  ext <- tolower(ext)

  for (group in LANGUAGE_GROUPS) {
    if (ext %in% group$extensions) {
      return(group$prefix)
    }
  }

  # Default fallback to hash for unknown extensions
  return("#")
}

#' Get All Supported File Extensions
#'
#' Returns a character vector of all file extensions supported by putior's
#' annotation parsing system.
#'
#' @return Character vector of supported file extensions (without dots)
#'
#' @export
#'
#' @examples
#' get_supported_extensions()
get_supported_extensions <- function() {
  extensions <- character()
  for (group in LANGUAGE_GROUPS) {
    extensions <- c(extensions, group$extensions)
  }
  unique(extensions)
}

#' Get Language Name from File Extension
#'
#' Converts a file extension to a standardized language name used internally
#' for detection pattern lookup.
#'
#' @param ext Character string of the file extension (without dot)
#' @return Character string of the language name, or NULL if not supported
#'
#' @export
#'
#' @examples
#' ext_to_language("r")     # Returns "r"
#' ext_to_language("py")    # Returns "python"
#' ext_to_language("sql")   # Returns "sql"
#' ext_to_language("js")    # Returns "javascript"
#' ext_to_language("xyz")   # Returns NULL
ext_to_language <- function(ext) {
  ext <- tolower(ext)

  # Direct mappings for languages with detection patterns
  # These are the canonical language names used by get_detection_patterns()
  language_map <- list(
    # Hash group
    "r" = "r",
    "py" = "python",
    "sh" = "shell",
    "bash" = "shell",
    "jl" = "julia",
    "rb" = "ruby",
    "pl" = "perl",
    "yaml" = "yaml",
    "yml" = "yaml",
    "toml" = "toml",

    # Dash group
    "sql" = "sql",
    "lua" = "lua",
    "hs" = "haskell",

    # Slash group
    "js" = "javascript",
    "ts" = "typescript",
    "jsx" = "javascript",
    "tsx" = "typescript",
    "c" = "c",
    "cpp" = "cpp",
    "h" = "c",
    "hpp" = "cpp",
    "java" = "java",
    "go" = "go",
    "rs" = "rust",
    "swift" = "swift",
    "kt" = "kotlin",
    "cs" = "csharp",
    "php" = "php",
    "scala" = "scala",
    "groovy" = "groovy",
    "d" = "d",

    # Percent group
    "m" = "matlab",
    "tex" = "latex"
  )

  if (ext %in% names(language_map)) {
    return(language_map[[ext]])
  }

  return(NULL)
}

#' Get Comment Syntax Group for Extension
#'
#' Returns the name of the comment syntax group for a given file extension.
#'
#' @param ext Character string of the file extension (without dot)
#' @return Character string of the group name ("hash", "dash", "slash", "percent"),
#'   or "hash" if not found (default)
#'
#' @keywords internal
get_comment_group <- function(ext) {
  ext <- tolower(ext)

  for (group_name in names(LANGUAGE_GROUPS)) {
    if (ext %in% LANGUAGE_GROUPS[[group_name]]$extensions) {
      return(group_name)
    }
  }

  return("hash")  # Default
}

#' Build File Pattern for Supported Extensions
#'
#' Builds a regular expression pattern to match all supported file extensions.
#' Useful for the default pattern parameter in \code{\link{put}} and
#' \code{\link{put_auto}}.
#'
#' @param detection_only Logical. If TRUE, only include extensions with
#'   detection pattern support (R, Python, SQL, Shell, Julia). Default: FALSE
#'
#' @return Character string regular expression pattern
#'
#' @keywords internal
build_file_pattern <- function(detection_only = FALSE) {
  if (detection_only) {
    # Only languages with detection pattern support
    exts <- c("R", "r", "py", "sql", "sh", "jl")
  } else {
    # All supported extensions (annotation parsing only)
    exts <- get_supported_extensions()
    # Add uppercase R variant
    exts <- unique(c(exts, "R"))
  }

  paste0("\\.(", paste(exts, collapse = "|"), ")$")
}

#' List All Supported Languages
#'
#' Returns a character vector of all programming languages that can have
#' PUT annotations parsed by putior. Note that detection patterns (for
#' \code{put_auto}) may only be available for a subset of these languages.
#'
#' @param detection_only Logical. If TRUE, only return languages with
#'   detection pattern support. Default: FALSE
#'
#' @return Character vector of supported language names
#'
#' @export
#'
#' @examples
#' # All languages with annotation parsing support
#' list_supported_languages()
#'
#' # Only languages with auto-detection patterns
#' list_supported_languages(detection_only = TRUE)
list_supported_languages <- function(detection_only = FALSE) {
  if (detection_only) {
    # Languages with detection pattern support
    return(c("r", "python", "sql", "shell", "julia"))
  }

  # All languages with annotation parsing support
  languages <- character()
  for (group in LANGUAGE_GROUPS) {
    languages <- c(languages, group$languages)
  }
  unique(languages)
}
