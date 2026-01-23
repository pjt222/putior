#' Detection Pattern Definitions for Auto-Annotation
#'
#' Internal data structures defining patterns for detecting inputs, outputs,
#' and dependencies in source code files across different programming languages.
#'
#' @name detection_patterns
#' @keywords internal
NULL

#' Get Detection Patterns for a Language
#'
#' Returns the detection patterns for identifying inputs, outputs, and
#' dependencies in source code files for a specific programming language.
#'
#' @param language Character string specifying the language. Options:
#'   "r", "python", "sql", "shell", "julia"
#' @param type Optional character string to filter by detection type.
#'   Options: "input", "output", "dependency". If NULL (default), returns all.
#'
#' @return A list of patterns with the following structure:
#'   \itemize{
#'     \item input: List of patterns for detecting file inputs
#'     \item output: List of patterns for detecting file outputs
#'     \item dependency: List of patterns for detecting script dependencies
#'   }
#'   Each pattern contains:
#'   \itemize{
#'     \item regex: Regular expression to match the function call
#'     \item arg_position: Position of the file path argument (1-indexed)
#'     \item arg_name: Named argument for file path (alternative to position)
#'     \item description: Human-readable description
#'   }
#'
#' @export
#'
#' @examples
#' # Get all R patterns
#' patterns <- get_detection_patterns("r")
#'
#' # Get only input patterns for Python
#' input_patterns <- get_detection_patterns("python", type = "input")
#'
#' # Get dependency patterns for R
#' dep_patterns <- get_detection_patterns("r", type = "dependency")
get_detection_patterns <- function(language = "r", type = NULL) {
  language <- tolower(language)

  valid_languages <- c("r", "python", "sql", "shell", "julia")
  if (!language %in% valid_languages) {
    stop("Unsupported language: ", language,
         ". Supported languages: ", paste(valid_languages, collapse = ", "))
  }

  patterns <- switch(language,
    "r" = get_r_patterns(),
    "python" = get_python_patterns(),
    "sql" = get_sql_patterns(),
    "shell" = get_shell_patterns(),
    "julia" = get_julia_patterns()
  )

  if (!is.null(type)) {
    valid_types <- c("input", "output", "dependency")
    if (!type %in% valid_types) {
      stop("Invalid type: ", type,
           ". Valid types: ", paste(valid_types, collapse = ", "))
    }
    return(patterns[[type]])
  }

  return(patterns)
}

#' Get R Detection Patterns
#' @return List of R detection patterns
#' @keywords internal
get_r_patterns <- function() {
  list(
    input = list(
      # Base R read functions
      list(
        regex = "read\\.csv\\s*\\(",
        func = "read.csv",
        arg_position = 1,
        arg_name = "file",
        description = "Base R CSV reader"
      ),
      list(
        regex = "read\\.csv2\\s*\\(",
        func = "read.csv2",
        arg_position = 1,
        arg_name = "file",
        description = "Base R CSV reader (semicolon separated)"
      ),
      list(
        regex = "read\\.table\\s*\\(",
        func = "read.table",
        arg_position = 1,
        arg_name = "file",
        description = "Base R table reader"
      ),
      list(
        regex = "read\\.delim\\s*\\(",
        func = "read.delim",
        arg_position = 1,
        arg_name = "file",
        description = "Base R tab-delimited reader"
      ),
      list(
        regex = "readLines\\s*\\(",
        func = "readLines",
        arg_position = 1,
        arg_name = "con",
        description = "Base R line reader"
      ),
      list(
        regex = "readRDS\\s*\\(",
        func = "readRDS",
        arg_position = 1,
        arg_name = "file",
        description = "Base R RDS reader"
      ),
      list(
        regex = "load\\s*\\(",
        func = "load",
        arg_position = 1,
        arg_name = "file",
        description = "Base R RData loader"
      ),
      list(
        regex = "scan\\s*\\(",
        func = "scan",
        arg_position = 1,
        arg_name = "file",
        description = "Base R scanner"
      ),
      # readr package
      list(
        regex = "read_csv\\s*\\(",
        func = "read_csv",
        arg_position = 1,
        arg_name = "file",
        description = "readr CSV reader"
      ),
      list(
        regex = "read_csv2\\s*\\(",
        func = "read_csv2",
        arg_position = 1,
        arg_name = "file",
        description = "readr CSV reader (semicolon separated)"
      ),
      list(
        regex = "read_tsv\\s*\\(",
        func = "read_tsv",
        arg_position = 1,
        arg_name = "file",
        description = "readr TSV reader"
      ),
      list(
        regex = "read_delim\\s*\\(",
        func = "read_delim",
        arg_position = 1,
        arg_name = "file",
        description = "readr delimited reader"
      ),
      list(
        regex = "read_fwf\\s*\\(",
        func = "read_fwf",
        arg_position = 1,
        arg_name = "file",
        description = "readr fixed-width reader"
      ),
      list(
        regex = "read_rds\\s*\\(",
        func = "read_rds",
        arg_position = 1,
        arg_name = "file",
        description = "readr RDS reader"
      ),
      # data.table package
      list(
        regex = "fread\\s*\\(",
        func = "fread",
        arg_position = 1,
        arg_name = "input",
        description = "data.table fast reader"
      ),
      # Excel readers
      list(
        regex = "read_excel\\s*\\(",
        func = "read_excel",
        arg_position = 1,
        arg_name = "path",
        description = "readxl Excel reader"
      ),
      list(
        regex = "read_xlsx\\s*\\(",
        func = "read_xlsx",
        arg_position = 1,
        arg_name = "path",
        description = "readxl XLSX reader"
      ),
      list(
        regex = "read_xls\\s*\\(",
        func = "read_xls",
        arg_position = 1,
        arg_name = "path",
        description = "readxl XLS reader"
      ),
      list(
        regex = "read\\.xlsx\\s*\\(",
        func = "read.xlsx",
        arg_position = 1,
        arg_name = "file",
        description = "openxlsx Excel reader"
      ),
      # JSON readers
      list(
        regex = "fromJSON\\s*\\(",
        func = "fromJSON",
        arg_position = 1,
        arg_name = "txt",
        description = "jsonlite JSON reader"
      ),
      list(
        regex = "read_json\\s*\\(",
        func = "read_json",
        arg_position = 1,
        arg_name = "path",
        description = "jsonlite JSON reader (file)"
      ),
      # Parquet readers
      list(
        regex = "read_parquet\\s*\\(",
        func = "read_parquet",
        arg_position = 1,
        arg_name = "file",
        description = "arrow Parquet reader"
      ),
      # Feather readers
      list(
        regex = "read_feather\\s*\\(",
        func = "read_feather",
        arg_position = 1,
        arg_name = "file",
        description = "arrow Feather reader"
      ),
      # SPSS/SAS/Stata
      list(
        regex = "read_sav\\s*\\(",
        func = "read_sav",
        arg_position = 1,
        arg_name = "file",
        description = "haven SPSS reader"
      ),
      list(
        regex = "read_sas\\s*\\(",
        func = "read_sas",
        arg_position = 1,
        arg_name = "data_file",
        description = "haven SAS reader"
      ),
      list(
        regex = "read_dta\\s*\\(",
        func = "read_dta",
        arg_position = 1,
        arg_name = "file",
        description = "haven Stata reader"
      ),
      # XML/HTML
      list(
        regex = "read_xml\\s*\\(",
        func = "read_xml",
        arg_position = 1,
        arg_name = "x",
        description = "xml2 XML reader"
      ),
      list(
        regex = "read_html\\s*\\(",
        func = "read_html",
        arg_position = 1,
        arg_name = "x",
        description = "xml2 HTML reader"
      ),
      # YAML
      list(
        regex = "read_yaml\\s*\\(",
        func = "read_yaml",
        arg_position = 1,
        arg_name = "file",
        description = "yaml YAML reader"
      ),
      list(
        regex = "yaml\\.load_file\\s*\\(",
        func = "yaml.load_file",
        arg_position = 1,
        arg_name = "input",
        description = "yaml YAML file loader"
      )
    ),
    output = list(
      # Base R write functions
      list(
        regex = "write\\.csv\\s*\\(",
        func = "write.csv",
        arg_position = 2,
        arg_name = "file",
        description = "Base R CSV writer"
      ),
      list(
        regex = "write\\.csv2\\s*\\(",
        func = "write.csv2",
        arg_position = 2,
        arg_name = "file",
        description = "Base R CSV writer (semicolon separated)"
      ),
      list(
        regex = "write\\.table\\s*\\(",
        func = "write.table",
        arg_position = 2,
        arg_name = "file",
        description = "Base R table writer"
      ),
      list(
        regex = "writeLines\\s*\\(",
        func = "writeLines",
        arg_position = 2,
        arg_name = "con",
        description = "Base R line writer"
      ),
      list(
        regex = "saveRDS\\s*\\(",
        func = "saveRDS",
        arg_position = 2,
        arg_name = "file",
        description = "Base R RDS writer"
      ),
      list(
        regex = "save\\s*\\(",
        func = "save",
        arg_position = NA,
        arg_name = "file",
        description = "Base R RData saver"
      ),
      list(
        regex = "cat\\s*\\([^)]*file\\s*=",
        func = "cat",
        arg_position = NA,
        arg_name = "file",
        description = "Base R cat to file"
      ),
      list(
        regex = "sink\\s*\\(",
        func = "sink",
        arg_position = 1,
        arg_name = "file",
        description = "Base R output sink"
      ),
      # readr package
      list(
        regex = "write_csv\\s*\\(",
        func = "write_csv",
        arg_position = 2,
        arg_name = "file",
        description = "readr CSV writer"
      ),
      list(
        regex = "write_csv2\\s*\\(",
        func = "write_csv2",
        arg_position = 2,
        arg_name = "file",
        description = "readr CSV writer (semicolon)"
      ),
      list(
        regex = "write_tsv\\s*\\(",
        func = "write_tsv",
        arg_position = 2,
        arg_name = "file",
        description = "readr TSV writer"
      ),
      list(
        regex = "write_delim\\s*\\(",
        func = "write_delim",
        arg_position = 2,
        arg_name = "file",
        description = "readr delimited writer"
      ),
      list(
        regex = "write_rds\\s*\\(",
        func = "write_rds",
        arg_position = 2,
        arg_name = "file",
        description = "readr RDS writer"
      ),
      # data.table package
      list(
        regex = "fwrite\\s*\\(",
        func = "fwrite",
        arg_position = 2,
        arg_name = "file",
        description = "data.table fast writer"
      ),
      # Excel writers
      list(
        regex = "write_xlsx\\s*\\(",
        func = "write_xlsx",
        arg_position = 2,
        arg_name = "path",
        description = "writexl XLSX writer"
      ),
      list(
        regex = "write\\.xlsx\\s*\\(",
        func = "write.xlsx",
        arg_position = 2,
        arg_name = "file",
        description = "openxlsx XLSX writer"
      ),
      # JSON writers
      list(
        regex = "toJSON\\s*\\([^)]*file\\s*=",
        func = "toJSON",
        arg_position = NA,
        arg_name = "file",
        description = "jsonlite JSON writer (to file)"
      ),
      list(
        regex = "write_json\\s*\\(",
        func = "write_json",
        arg_position = 2,
        arg_name = "path",
        description = "jsonlite JSON writer"
      ),
      # Parquet writers
      list(
        regex = "write_parquet\\s*\\(",
        func = "write_parquet",
        arg_position = 2,
        arg_name = "sink",
        description = "arrow Parquet writer"
      ),
      # Feather writers
      list(
        regex = "write_feather\\s*\\(",
        func = "write_feather",
        arg_position = 2,
        arg_name = "sink",
        description = "arrow Feather writer"
      ),
      # Graphics output
      list(
        regex = "ggsave\\s*\\(",
        func = "ggsave",
        arg_position = 1,
        arg_name = "filename",
        description = "ggplot2 plot saver"
      ),
      list(
        regex = "pdf\\s*\\(",
        func = "pdf",
        arg_position = 1,
        arg_name = "file",
        description = "Base R PDF device"
      ),
      list(
        regex = "png\\s*\\(",
        func = "png",
        arg_position = 1,
        arg_name = "filename",
        description = "Base R PNG device"
      ),
      list(
        regex = "jpeg\\s*\\(",
        func = "jpeg",
        arg_position = 1,
        arg_name = "filename",
        description = "Base R JPEG device"
      ),
      list(
        regex = "tiff\\s*\\(",
        func = "tiff",
        arg_position = 1,
        arg_name = "filename",
        description = "Base R TIFF device"
      ),
      list(
        regex = "svg\\s*\\(",
        func = "svg",
        arg_position = 1,
        arg_name = "filename",
        description = "Base R SVG device"
      ),
      list(
        regex = "bmp\\s*\\(",
        func = "bmp",
        arg_position = 1,
        arg_name = "filename",
        description = "Base R BMP device"
      ),
      # SPSS/SAS/Stata
      list(
        regex = "write_sav\\s*\\(",
        func = "write_sav",
        arg_position = 2,
        arg_name = "path",
        description = "haven SPSS writer"
      ),
      list(
        regex = "write_sas\\s*\\(",
        func = "write_sas",
        arg_position = 2,
        arg_name = "path",
        description = "haven SAS writer"
      ),
      list(
        regex = "write_dta\\s*\\(",
        func = "write_dta",
        arg_position = 2,
        arg_name = "path",
        description = "haven Stata writer"
      ),
      # XML
      list(
        regex = "write_xml\\s*\\(",
        func = "write_xml",
        arg_position = 2,
        arg_name = "file",
        description = "xml2 XML writer"
      ),
      # YAML
      list(
        regex = "write_yaml\\s*\\(",
        func = "write_yaml",
        arg_position = 2,
        arg_name = "file",
        description = "yaml YAML writer"
      )
    ),
    dependency = list(
      list(
        regex = "source\\s*\\(",
        func = "source",
        arg_position = 1,
        arg_name = "file",
        description = "R source file"
      ),
      list(
        regex = "sys\\.source\\s*\\(",
        func = "sys.source",
        arg_position = 1,
        arg_name = "file",
        description = "R system source file"
      )
    )
  )
}

#' Get Python Detection Patterns
#' @return List of Python detection patterns
#' @keywords internal
get_python_patterns <- function() {
  list(
    input = list(
      # pandas
      list(
        regex = "pd\\.read_csv\\s*\\(|pandas\\.read_csv\\s*\\(",
        func = "pd.read_csv",
        arg_position = 1,
        arg_name = "filepath_or_buffer",
        description = "pandas CSV reader"
      ),
      list(
        regex = "pd\\.read_excel\\s*\\(|pandas\\.read_excel\\s*\\(",
        func = "pd.read_excel",
        arg_position = 1,
        arg_name = "io",
        description = "pandas Excel reader"
      ),
      list(
        regex = "pd\\.read_json\\s*\\(|pandas\\.read_json\\s*\\(",
        func = "pd.read_json",
        arg_position = 1,
        arg_name = "path_or_buf",
        description = "pandas JSON reader"
      ),
      list(
        regex = "pd\\.read_parquet\\s*\\(|pandas\\.read_parquet\\s*\\(",
        func = "pd.read_parquet",
        arg_position = 1,
        arg_name = "path",
        description = "pandas Parquet reader"
      ),
      list(
        regex = "pd\\.read_feather\\s*\\(|pandas\\.read_feather\\s*\\(",
        func = "pd.read_feather",
        arg_position = 1,
        arg_name = "path",
        description = "pandas Feather reader"
      ),
      list(
        regex = "pd\\.read_pickle\\s*\\(|pandas\\.read_pickle\\s*\\(",
        func = "pd.read_pickle",
        arg_position = 1,
        arg_name = "filepath_or_buffer",
        description = "pandas pickle reader"
      ),
      list(
        regex = "pd\\.read_sql\\s*\\(|pandas\\.read_sql\\s*\\(",
        func = "pd.read_sql",
        arg_position = 1,
        arg_name = "sql",
        description = "pandas SQL reader"
      ),
      list(
        regex = "pd\\.read_html\\s*\\(|pandas\\.read_html\\s*\\(",
        func = "pd.read_html",
        arg_position = 1,
        arg_name = "io",
        description = "pandas HTML reader"
      ),
      # Built-in
      list(
        regex = "open\\s*\\([^)]*['\"]r['\"]|open\\s*\\([^,]+\\)",
        func = "open",
        arg_position = 1,
        arg_name = NULL,
        description = "Python built-in file open (read)"
      ),
      # json
      list(
        regex = "json\\.load\\s*\\(",
        func = "json.load",
        arg_position = 1,
        arg_name = "fp",
        description = "Python JSON loader"
      ),
      # pickle
      list(
        regex = "pickle\\.load\\s*\\(",
        func = "pickle.load",
        arg_position = 1,
        arg_name = "file",
        description = "Python pickle loader"
      ),
      # yaml
      list(
        regex = "yaml\\.safe_load\\s*\\(|yaml\\.load\\s*\\(",
        func = "yaml.load",
        arg_position = 1,
        arg_name = "stream",
        description = "Python YAML loader"
      ),
      # numpy
      list(
        regex = "np\\.load\\s*\\(|numpy\\.load\\s*\\(",
        func = "np.load",
        arg_position = 1,
        arg_name = "file",
        description = "numpy array loader"
      ),
      list(
        regex = "np\\.loadtxt\\s*\\(|numpy\\.loadtxt\\s*\\(",
        func = "np.loadtxt",
        arg_position = 1,
        arg_name = "fname",
        description = "numpy text loader"
      ),
      list(
        regex = "np\\.genfromtxt\\s*\\(|numpy\\.genfromtxt\\s*\\(",
        func = "np.genfromtxt",
        arg_position = 1,
        arg_name = "fname",
        description = "numpy generalized text loader"
      ),
      # PIL/Pillow
      list(
        regex = "Image\\.open\\s*\\(",
        func = "Image.open",
        arg_position = 1,
        arg_name = "fp",
        description = "PIL image opener"
      ),
      # cv2
      list(
        regex = "cv2\\.imread\\s*\\(",
        func = "cv2.imread",
        arg_position = 1,
        arg_name = "filename",
        description = "OpenCV image reader"
      ),
      # polars
      list(
        regex = "pl\\.read_csv\\s*\\(|polars\\.read_csv\\s*\\(",
        func = "pl.read_csv",
        arg_position = 1,
        arg_name = "file",
        description = "polars CSV reader"
      ),
      list(
        regex = "pl\\.read_parquet\\s*\\(|polars\\.read_parquet\\s*\\(",
        func = "pl.read_parquet",
        arg_position = 1,
        arg_name = "source",
        description = "polars Parquet reader"
      )
    ),
    output = list(
      # pandas
      list(
        regex = "\\.to_csv\\s*\\(",
        func = "df.to_csv",
        arg_position = 1,
        arg_name = "path_or_buf",
        description = "pandas CSV writer"
      ),
      list(
        regex = "\\.to_excel\\s*\\(",
        func = "df.to_excel",
        arg_position = 1,
        arg_name = "excel_writer",
        description = "pandas Excel writer"
      ),
      list(
        regex = "\\.to_json\\s*\\(",
        func = "df.to_json",
        arg_position = 1,
        arg_name = "path_or_buf",
        description = "pandas JSON writer"
      ),
      list(
        regex = "\\.to_parquet\\s*\\(",
        func = "df.to_parquet",
        arg_position = 1,
        arg_name = "path",
        description = "pandas Parquet writer"
      ),
      list(
        regex = "\\.to_feather\\s*\\(",
        func = "df.to_feather",
        arg_position = 1,
        arg_name = "path",
        description = "pandas Feather writer"
      ),
      list(
        regex = "\\.to_pickle\\s*\\(",
        func = "df.to_pickle",
        arg_position = 1,
        arg_name = "path",
        description = "pandas pickle writer"
      ),
      # Built-in
      list(
        regex = "open\\s*\\([^)]*['\"]w['\"]",
        func = "open",
        arg_position = 1,
        arg_name = NULL,
        description = "Python built-in file open (write)"
      ),
      # json
      list(
        regex = "json\\.dump\\s*\\(",
        func = "json.dump",
        arg_position = 2,
        arg_name = "fp",
        description = "Python JSON dumper"
      ),
      # pickle
      list(
        regex = "pickle\\.dump\\s*\\(",
        func = "pickle.dump",
        arg_position = 2,
        arg_name = "file",
        description = "Python pickle dumper"
      ),
      # yaml
      list(
        regex = "yaml\\.dump\\s*\\(",
        func = "yaml.dump",
        arg_position = 2,
        arg_name = "stream",
        description = "Python YAML dumper"
      ),
      # numpy
      list(
        regex = "np\\.save\\s*\\(|numpy\\.save\\s*\\(",
        func = "np.save",
        arg_position = 1,
        arg_name = "file",
        description = "numpy array saver"
      ),
      list(
        regex = "np\\.savetxt\\s*\\(|numpy\\.savetxt\\s*\\(",
        func = "np.savetxt",
        arg_position = 1,
        arg_name = "fname",
        description = "numpy text saver"
      ),
      list(
        regex = "np\\.savez\\s*\\(|numpy\\.savez\\s*\\(",
        func = "np.savez",
        arg_position = 1,
        arg_name = "file",
        description = "numpy compressed saver"
      ),
      # matplotlib
      list(
        regex = "plt\\.savefig\\s*\\(|pyplot\\.savefig\\s*\\(",
        func = "plt.savefig",
        arg_position = 1,
        arg_name = "fname",
        description = "matplotlib figure saver"
      ),
      list(
        regex = "\\.savefig\\s*\\(",
        func = "fig.savefig",
        arg_position = 1,
        arg_name = "fname",
        description = "matplotlib figure saver (method)"
      ),
      # PIL/Pillow
      list(
        regex = "\\.save\\s*\\(['\"]",
        func = "Image.save",
        arg_position = 1,
        arg_name = "fp",
        description = "PIL image saver"
      ),
      # cv2
      list(
        regex = "cv2\\.imwrite\\s*\\(",
        func = "cv2.imwrite",
        arg_position = 1,
        arg_name = "filename",
        description = "OpenCV image writer"
      ),
      # polars
      list(
        regex = "\\.write_csv\\s*\\(",
        func = "df.write_csv",
        arg_position = 1,
        arg_name = "file",
        description = "polars CSV writer"
      ),
      list(
        regex = "\\.write_parquet\\s*\\(",
        func = "df.write_parquet",
        arg_position = 1,
        arg_name = "file",
        description = "polars Parquet writer"
      )
    ),
    dependency = list(
      list(
        regex = "import\\s+\\w+|from\\s+\\w+\\s+import",
        func = "import",
        arg_position = NA,
        arg_name = NULL,
        description = "Python module import"
      ),
      list(
        regex = "exec\\s*\\(\\s*open\\s*\\(",
        func = "exec(open())",
        arg_position = 1,
        arg_name = NULL,
        description = "Python exec open pattern"
      ),
      list(
        regex = "runpy\\.run_path\\s*\\(",
        func = "runpy.run_path",
        arg_position = 1,
        arg_name = "file_path",
        description = "Python runpy module"
      )
    )
  )
}

#' Get SQL Detection Patterns
#' @return List of SQL detection patterns
#' @keywords internal
get_sql_patterns <- function() {
  list(
    input = list(
      list(
        regex = "FROM\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
        func = "FROM",
        arg_position = 1,
        arg_name = "table",
        description = "SQL FROM clause (table reference)"
      ),
      list(
        regex = "JOIN\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
        func = "JOIN",
        arg_position = 1,
        arg_name = "table",
        description = "SQL JOIN clause (table reference)"
      ),
      list(
        regex = "LOAD\\s+DATA\\s+INFILE\\s+['\"]([^'\"]+)['\"]",
        func = "LOAD DATA INFILE",
        arg_position = 1,
        arg_name = "file",
        description = "MySQL load data from file"
      ),
      list(
        regex = "COPY\\s+\\w+\\s+FROM\\s+['\"]([^'\"]+)['\"]",
        func = "COPY FROM",
        arg_position = 1,
        arg_name = "file",
        description = "PostgreSQL copy from file"
      )
    ),
    output = list(
      list(
        regex = "INTO\\s+OUTFILE\\s+['\"]([^'\"]+)['\"]",
        func = "INTO OUTFILE",
        arg_position = 1,
        arg_name = "file",
        description = "MySQL export to file"
      ),
      list(
        regex = "COPY\\s+\\(.*\\)\\s+TO\\s+['\"]([^'\"]+)['\"]",
        func = "COPY TO",
        arg_position = 1,
        arg_name = "file",
        description = "PostgreSQL copy to file"
      ),
      list(
        regex = "CREATE\\s+TABLE\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
        func = "CREATE TABLE",
        arg_position = 1,
        arg_name = "table",
        description = "SQL create table"
      ),
      list(
        regex = "INSERT\\s+INTO\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
        func = "INSERT INTO",
        arg_position = 1,
        arg_name = "table",
        description = "SQL insert into table"
      )
    ),
    dependency = list()  # SQL doesn't typically have file dependencies
  )
}

#' Get Shell Detection Patterns
#' @return List of shell detection patterns
#' @keywords internal
get_shell_patterns <- function() {
  list(
    input = list(
      list(
        regex = "cat\\s+([^|>]+)",
        func = "cat",
        arg_position = 1,
        arg_name = "file",
        description = "Shell cat command"
      ),
      list(
        regex = "<\\s*([^<>\\s]+)",
        func = "<",
        arg_position = 1,
        arg_name = "file",
        description = "Shell input redirection"
      ),
      list(
        regex = "read\\s+.*<\\s*([^\\s]+)",
        func = "read <",
        arg_position = 1,
        arg_name = "file",
        description = "Shell read from file"
      ),
      list(
        regex = "source\\s+([^\\s;|]+)",
        func = "source",
        arg_position = 1,
        arg_name = "file",
        description = "Shell source command"
      ),
      list(
        regex = "\\.\\s+([^\\s;|]+)",
        func = ".",
        arg_position = 1,
        arg_name = "file",
        description = "Shell dot command"
      )
    ),
    output = list(
      list(
        regex = ">\\s*([^>\\s]+)",
        func = ">",
        arg_position = 1,
        arg_name = "file",
        description = "Shell output redirection"
      ),
      list(
        regex = ">>\\s*([^>\\s]+)",
        func = ">>",
        arg_position = 1,
        arg_name = "file",
        description = "Shell append redirection"
      ),
      list(
        regex = "tee\\s+([^|\\s]+)",
        func = "tee",
        arg_position = 1,
        arg_name = "file",
        description = "Shell tee command"
      )
    ),
    dependency = list(
      list(
        regex = "source\\s+([^\\s;|]+)",
        func = "source",
        arg_position = 1,
        arg_name = "file",
        description = "Shell source command"
      ),
      list(
        regex = "\\.\\s+([^\\s;|]+)",
        func = ".",
        arg_position = 1,
        arg_name = "file",
        description = "Shell dot command"
      ),
      list(
        regex = "bash\\s+([^\\s;|]+)",
        func = "bash",
        arg_position = 1,
        arg_name = "file",
        description = "Bash script execution"
      ),
      list(
        regex = "sh\\s+([^\\s;|]+)",
        func = "sh",
        arg_position = 1,
        arg_name = "file",
        description = "Shell script execution"
      )
    )
  )
}

#' Get Julia Detection Patterns
#' @return List of Julia detection patterns
#' @keywords internal
get_julia_patterns <- function() {
  list(
    input = list(
      # CSV.jl
      list(
        regex = "CSV\\.read\\s*\\(",
        func = "CSV.read",
        arg_position = 1,
        arg_name = "source",
        description = "CSV.jl reader"
      ),
      list(
        regex = "CSV\\.File\\s*\\(",
        func = "CSV.File",
        arg_position = 1,
        arg_name = "source",
        description = "CSV.jl file constructor"
      ),
      # DataFrames
      list(
        regex = "DataFrame\\s*\\(\\s*CSV",
        func = "DataFrame(CSV)",
        arg_position = 1,
        arg_name = NULL,
        description = "DataFrame from CSV"
      ),
      # Base Julia
      list(
        regex = "open\\s*\\([^)]*['\"]r['\"]|open\\s*\\([^,]+\\)\\s*do",
        func = "open",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia open for reading"
      ),
      list(
        regex = "read\\s*\\(",
        func = "read",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia read"
      ),
      list(
        regex = "readlines\\s*\\(",
        func = "readlines",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia readlines"
      ),
      list(
        regex = "readdlm\\s*\\(",
        func = "readdlm",
        arg_position = 1,
        arg_name = "source",
        description = "Julia delimited reader"
      ),
      # JSON
      list(
        regex = "JSON\\.parsefile\\s*\\(",
        func = "JSON.parsefile",
        arg_position = 1,
        arg_name = "filename",
        description = "JSON.jl file parser"
      ),
      # JLD2
      list(
        regex = "@load\\s+",
        func = "@load",
        arg_position = 1,
        arg_name = "filename",
        description = "JLD2 macro loader"
      ),
      list(
        regex = "load\\s*\\(",
        func = "load",
        arg_position = 1,
        arg_name = "filename",
        description = "JLD2 load function"
      ),
      # BSON
      list(
        regex = "BSON\\.load\\s*\\(",
        func = "BSON.load",
        arg_position = 1,
        arg_name = "filename",
        description = "BSON.jl loader"
      ),
      # Arrow
      list(
        regex = "Arrow\\.Table\\s*\\(",
        func = "Arrow.Table",
        arg_position = 1,
        arg_name = "source",
        description = "Arrow.jl table reader"
      ),
      # Parquet
      list(
        regex = "read_parquet\\s*\\(",
        func = "read_parquet",
        arg_position = 1,
        arg_name = "filename",
        description = "Parquet.jl reader"
      )
    ),
    output = list(
      # CSV.jl
      list(
        regex = "CSV\\.write\\s*\\(",
        func = "CSV.write",
        arg_position = 1,
        arg_name = "file",
        description = "CSV.jl writer"
      ),
      # Base Julia
      list(
        regex = "open\\s*\\([^)]*['\"]w['\"]",
        func = "open",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia open for writing"
      ),
      list(
        regex = "write\\s*\\(",
        func = "write",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia write"
      ),
      list(
        regex = "writedlm\\s*\\(",
        func = "writedlm",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia delimited writer"
      ),
      # JSON
      list(
        regex = "JSON\\.print\\s*\\(",
        func = "JSON.print",
        arg_position = 1,
        arg_name = "io",
        description = "JSON.jl printer"
      ),
      # JLD2
      list(
        regex = "@save\\s+",
        func = "@save",
        arg_position = 1,
        arg_name = "filename",
        description = "JLD2 macro saver"
      ),
      list(
        regex = "save\\s*\\(",
        func = "save",
        arg_position = 1,
        arg_name = "filename",
        description = "JLD2 save function"
      ),
      # BSON
      list(
        regex = "BSON\\.bson\\s*\\(",
        func = "BSON.bson",
        arg_position = 1,
        arg_name = "filename",
        description = "BSON.jl writer"
      ),
      # Arrow
      list(
        regex = "Arrow\\.write\\s*\\(",
        func = "Arrow.write",
        arg_position = 1,
        arg_name = "file",
        description = "Arrow.jl writer"
      ),
      # Parquet
      list(
        regex = "write_parquet\\s*\\(",
        func = "write_parquet",
        arg_position = 1,
        arg_name = "filename",
        description = "Parquet.jl writer"
      ),
      # Plots.jl
      list(
        regex = "savefig\\s*\\(",
        func = "savefig",
        arg_position = 1,
        arg_name = "filename",
        description = "Plots.jl figure saver"
      )
    ),
    dependency = list(
      list(
        regex = "include\\s*\\(",
        func = "include",
        arg_position = 1,
        arg_name = "filename",
        description = "Julia include"
      ),
      list(
        regex = "using\\s+\\w+",
        func = "using",
        arg_position = NA,
        arg_name = NULL,
        description = "Julia using statement"
      ),
      list(
        regex = "import\\s+\\w+",
        func = "import",
        arg_position = NA,
        arg_name = NULL,
        description = "Julia import statement"
      )
    )
  )
}

#' List Supported Languages for Auto-Detection
#'
#' Returns a character vector of programming languages supported by the
#' auto-detection feature.
#'
#' @return Character vector of supported language identifiers
#' @export
#'
#' @examples
#' list_supported_languages()
list_supported_languages <- function() {
  c("r", "python", "sql", "shell", "julia")
}
