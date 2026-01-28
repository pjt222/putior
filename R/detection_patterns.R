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
      ),
      # Database connections - DBI
      list(
        regex = "dbConnect\\s*\\(",
        func = "dbConnect",
        arg_position = 1,
        arg_name = "drv",
        description = "DBI database connection"
      ),
      list(
        regex = "DBI::dbConnect\\s*\\(",
        func = "DBI::dbConnect",
        arg_position = 1,
        arg_name = "drv",
        description = "DBI database connection (namespaced)"
      ),
      list(
        regex = "dbReadTable\\s*\\(",
        func = "dbReadTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI read table"
      ),
      list(
        regex = "DBI::dbReadTable\\s*\\(",
        func = "DBI::dbReadTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI read table (namespaced)"
      ),
      list(
        regex = "dbGetQuery\\s*\\(",
        func = "dbGetQuery",
        arg_position = 2,
        arg_name = "statement",
        description = "DBI get query results"
      ),
      list(
        regex = "DBI::dbGetQuery\\s*\\(",
        func = "DBI::dbGetQuery",
        arg_position = 2,
        arg_name = "statement",
        description = "DBI get query results (namespaced)"
      ),
      list(
        regex = "dbFetch\\s*\\(",
        func = "dbFetch",
        arg_position = 1,
        arg_name = "res",
        description = "DBI fetch results"
      ),
      list(
        regex = "dbSendQuery\\s*\\(",
        func = "dbSendQuery",
        arg_position = 2,
        arg_name = "statement",
        description = "DBI send query"
      ),
      # ODBC/RODBC
      list(
        regex = "odbcConnect\\s*\\(",
        func = "odbcConnect",
        arg_position = 1,
        arg_name = "dsn",
        description = "RODBC connection"
      ),
      list(
        regex = "odbcDriverConnect\\s*\\(",
        func = "odbcDriverConnect",
        arg_position = 1,
        arg_name = "connection",
        description = "RODBC driver connection"
      ),
      list(
        regex = "sqlQuery\\s*\\(",
        func = "sqlQuery",
        arg_position = 2,
        arg_name = "query",
        description = "RODBC SQL query"
      ),
      list(
        regex = "sqlFetch\\s*\\(",
        func = "sqlFetch",
        arg_position = 2,
        arg_name = "sqtable",
        description = "RODBC fetch table"
      ),
      # pool package (connection pooling)
      list(
        regex = "dbPool\\s*\\(",
        func = "dbPool",
        arg_position = 1,
        arg_name = "drv",
        description = "pool database connection pool"
      ),
      # Specific database packages
      list(
        regex = "dbplyr::tbl\\s*\\(",
        func = "dbplyr::tbl",
        arg_position = 2,
        arg_name = "from",
        description = "dbplyr table reference"
      ),
      list(
        regex = "tbl\\s*\\([^)]*,\\s*['\"]",
        func = "tbl",
        arg_position = 2,
        arg_name = "from",
        description = "dplyr/dbplyr table reference"
      ),
      # DuckDB (R)
      list(
        regex = "duckdb\\s*\\(",
        func = "duckdb",
        arg_position = 1,
        arg_name = "dbdir",
        description = "DuckDB driver"
      ),
      list(
        regex = "duckdb::duckdb\\s*\\(",
        func = "duckdb::duckdb",
        arg_position = 1,
        arg_name = "dbdir",
        description = "DuckDB driver (namespaced)"
      ),
      list(
        regex = "duckdb_read_csv\\s*\\(",
        func = "duckdb_read_csv",
        arg_position = 2,
        arg_name = "files",
        description = "DuckDB read CSV"
      ),
      list(
        regex = "duckdb::duckdb_read_csv\\s*\\(",
        func = "duckdb::duckdb_read_csv",
        arg_position = 2,
        arg_name = "files",
        description = "DuckDB read CSV (namespaced)"
      ),
      # MonetDBLite
      list(
        regex = "monetdblite\\s*\\(",
        func = "monetdblite",
        arg_position = 1,
        arg_name = "dbdir",
        description = "MonetDBLite connection"
      ),
      # Spark/sparklyr
      list(
        regex = "spark_connect\\s*\\(",
        func = "spark_connect",
        arg_position = NA,
        arg_name = "master",
        description = "sparklyr Spark connection"
      ),
      list(
        regex = "spark_read_csv\\s*\\(",
        func = "spark_read_csv",
        arg_position = 2,
        arg_name = "path",
        description = "sparklyr read CSV"
      ),
      list(
        regex = "spark_read_parquet\\s*\\(",
        func = "spark_read_parquet",
        arg_position = 2,
        arg_name = "path",
        description = "sparklyr read Parquet"
      ),
      list(
        regex = "spark_read_json\\s*\\(",
        func = "spark_read_json",
        arg_position = 2,
        arg_name = "path",
        description = "sparklyr read JSON"
      ),
      list(
        regex = "spark_read_jdbc\\s*\\(",
        func = "spark_read_jdbc",
        arg_position = NA,
        arg_name = "options",
        description = "sparklyr JDBC read"
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
      ),
      # Database outputs - DBI
      list(
        regex = "dbWriteTable\\s*\\(",
        func = "dbWriteTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI write table"
      ),
      list(
        regex = "DBI::dbWriteTable\\s*\\(",
        func = "DBI::dbWriteTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI write table (namespaced)"
      ),
      list(
        regex = "dbExecute\\s*\\(",
        func = "dbExecute",
        arg_position = 2,
        arg_name = "statement",
        description = "DBI execute statement"
      ),
      list(
        regex = "DBI::dbExecute\\s*\\(",
        func = "DBI::dbExecute",
        arg_position = 2,
        arg_name = "statement",
        description = "DBI execute statement (namespaced)"
      ),
      list(
        regex = "dbAppendTable\\s*\\(",
        func = "dbAppendTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI append to table"
      ),
      list(
        regex = "dbCreateTable\\s*\\(",
        func = "dbCreateTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI create table"
      ),
      list(
        regex = "dbRemoveTable\\s*\\(",
        func = "dbRemoveTable",
        arg_position = 2,
        arg_name = "name",
        description = "DBI remove table"
      ),
      # RODBC outputs
      list(
        regex = "sqlSave\\s*\\(",
        func = "sqlSave",
        arg_position = 2,
        arg_name = "tablename",
        description = "RODBC save table"
      ),
      list(
        regex = "sqlUpdate\\s*\\(",
        func = "sqlUpdate",
        arg_position = 2,
        arg_name = "tablename",
        description = "RODBC update table"
      ),
      list(
        regex = "sqlDrop\\s*\\(",
        func = "sqlDrop",
        arg_position = 2,
        arg_name = "sqtable",
        description = "RODBC drop table"
      ),
      # dbplyr/dplyr database writes
      list(
        regex = "copy_to\\s*\\(",
        func = "copy_to",
        arg_position = 3,
        arg_name = "name",
        description = "dplyr copy to database"
      ),
      list(
        regex = "compute\\s*\\(",
        func = "compute",
        arg_position = 2,
        arg_name = "name",
        description = "dplyr compute to database"
      ),
      list(
        regex = "rows_insert\\s*\\(",
        func = "rows_insert",
        arg_position = 1,
        arg_name = "x",
        description = "dplyr rows insert"
      ),
      list(
        regex = "rows_update\\s*\\(",
        func = "rows_update",
        arg_position = 1,
        arg_name = "x",
        description = "dplyr rows update"
      ),
      list(
        regex = "rows_upsert\\s*\\(",
        func = "rows_upsert",
        arg_position = 1,
        arg_name = "x",
        description = "dplyr rows upsert"
      ),
      # DuckDB outputs (R)
      list(
        regex = "duckdb_register\\s*\\(",
        func = "duckdb_register",
        arg_position = 2,
        arg_name = "name",
        description = "DuckDB register data frame"
      ),
      list(
        regex = "duckdb::duckdb_register\\s*\\(",
        func = "duckdb::duckdb_register",
        arg_position = 2,
        arg_name = "name",
        description = "DuckDB register data frame (namespaced)"
      ),
      # sparklyr outputs
      list(
        regex = "spark_write_csv\\s*\\(",
        func = "spark_write_csv",
        arg_position = 2,
        arg_name = "path",
        description = "sparklyr write CSV"
      ),
      list(
        regex = "spark_write_parquet\\s*\\(",
        func = "spark_write_parquet",
        arg_position = 2,
        arg_name = "path",
        description = "sparklyr write Parquet"
      ),
      list(
        regex = "spark_write_json\\s*\\(",
        func = "spark_write_json",
        arg_position = 2,
        arg_name = "path",
        description = "sparklyr write JSON"
      ),
      list(
        regex = "spark_write_jdbc\\s*\\(",
        func = "spark_write_jdbc",
        arg_position = NA,
        arg_name = "options",
        description = "sparklyr JDBC write"
      ),
      list(
        regex = "spark_write_table\\s*\\(",
        func = "spark_write_table",
        arg_position = 2,
        arg_name = "name",
        description = "sparklyr write table"
      ),
      list(
        regex = "sdf_copy_to\\s*\\(",
        func = "sdf_copy_to",
        arg_position = 3,
        arg_name = "name",
        description = "sparklyr copy to Spark"
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
      ),
      # Database connections - SQLAlchemy
      list(
        regex = "create_engine\\s*\\(",
        func = "create_engine",
        arg_position = 1,
        arg_name = "url",
        description = "SQLAlchemy engine creation"
      ),
      list(
        regex = "sqlalchemy\\.create_engine\\s*\\(",
        func = "sqlalchemy.create_engine",
        arg_position = 1,
        arg_name = "url",
        description = "SQLAlchemy engine creation (namespaced)"
      ),
      list(
        regex = "engine\\.execute\\s*\\(",
        func = "engine.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "SQLAlchemy execute query"
      ),
      list(
        regex = "session\\.query\\s*\\(",
        func = "session.query",
        arg_position = 1,
        arg_name = "entities",
        description = "SQLAlchemy ORM query"
      ),
      # psycopg2 (PostgreSQL)
      list(
        regex = "psycopg2\\.connect\\s*\\(",
        func = "psycopg2.connect",
        arg_position = 1,
        arg_name = "dsn",
        description = "psycopg2 PostgreSQL connection"
      ),
      list(
        regex = "pg\\.connect\\s*\\(",
        func = "pg.connect",
        arg_position = 1,
        arg_name = "dsn",
        description = "psycopg2 PostgreSQL connection (alias)"
      ),
      # sqlite3
      list(
        regex = "sqlite3\\.connect\\s*\\(",
        func = "sqlite3.connect",
        arg_position = 1,
        arg_name = "database",
        description = "sqlite3 connection"
      ),
      # mysql-connector
      list(
        regex = "mysql\\.connector\\.connect\\s*\\(",
        func = "mysql.connector.connect",
        arg_position = NA,
        arg_name = "database",
        description = "MySQL connector connection"
      ),
      list(
        regex = "MySQLdb\\.connect\\s*\\(",
        func = "MySQLdb.connect",
        arg_position = NA,
        arg_name = "db",
        description = "MySQLdb connection"
      ),
      list(
        regex = "pymysql\\.connect\\s*\\(",
        func = "pymysql.connect",
        arg_position = NA,
        arg_name = "database",
        description = "PyMySQL connection"
      ),
      # pyodbc
      list(
        regex = "pyodbc\\.connect\\s*\\(",
        func = "pyodbc.connect",
        arg_position = 1,
        arg_name = "connstring",
        description = "pyodbc connection"
      ),
      # cursor operations (read)
      list(
        regex = "cursor\\.execute\\s*\\([^)]*SELECT",
        func = "cursor.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "Database cursor SELECT query"
      ),
      list(
        regex = "cursor\\.fetchall\\s*\\(",
        func = "cursor.fetchall",
        arg_position = NA,
        arg_name = NULL,
        description = "Database cursor fetch all"
      ),
      list(
        regex = "cursor\\.fetchone\\s*\\(",
        func = "cursor.fetchone",
        arg_position = NA,
        arg_name = NULL,
        description = "Database cursor fetch one"
      ),
      list(
        regex = "cursor\\.fetchmany\\s*\\(",
        func = "cursor.fetchmany",
        arg_position = 1,
        arg_name = "size",
        description = "Database cursor fetch many"
      ),
      # asyncpg (async PostgreSQL)
      list(
        regex = "asyncpg\\.connect\\s*\\(",
        func = "asyncpg.connect",
        arg_position = 1,
        arg_name = "dsn",
        description = "asyncpg async PostgreSQL connection"
      ),
      list(
        regex = "asyncpg\\.create_pool\\s*\\(",
        func = "asyncpg.create_pool",
        arg_position = 1,
        arg_name = "dsn",
        description = "asyncpg connection pool"
      ),
      # SQLModel / databases
      list(
        regex = "Database\\s*\\(",
        func = "Database",
        arg_position = 1,
        arg_name = "url",
        description = "databases async database"
      ),
      # MongoDB
      list(
        regex = "MongoClient\\s*\\(",
        func = "MongoClient",
        arg_position = 1,
        arg_name = "host",
        description = "pymongo MongoDB client"
      ),
      list(
        regex = "pymongo\\.MongoClient\\s*\\(",
        func = "pymongo.MongoClient",
        arg_position = 1,
        arg_name = "host",
        description = "pymongo MongoDB client (namespaced)"
      ),
      # Redis
      list(
        regex = "redis\\.Redis\\s*\\(",
        func = "redis.Redis",
        arg_position = NA,
        arg_name = "host",
        description = "redis-py Redis connection"
      ),
      list(
        regex = "redis\\.from_url\\s*\\(",
        func = "redis.from_url",
        arg_position = 1,
        arg_name = "url",
        description = "redis-py from URL"
      ),
      # DuckDB
      list(
        regex = "duckdb\\.connect\\s*\\(",
        func = "duckdb.connect",
        arg_position = 1,
        arg_name = "database",
        description = "DuckDB connection"
      ),
      list(
        regex = "duckdb\\.read_csv\\s*\\(",
        func = "duckdb.read_csv",
        arg_position = 1,
        arg_name = "path",
        description = "DuckDB read CSV"
      ),
      list(
        regex = "duckdb\\.read_parquet\\s*\\(",
        func = "duckdb.read_parquet",
        arg_position = 1,
        arg_name = "path",
        description = "DuckDB read Parquet"
      ),
      list(
        regex = "duckdb\\.read_json\\s*\\(",
        func = "duckdb.read_json",
        arg_position = 1,
        arg_name = "path",
        description = "DuckDB read JSON"
      ),
      list(
        regex = "\\.sql\\s*\\(",
        func = "con.sql",
        arg_position = 1,
        arg_name = "query",
        description = "DuckDB SQL query"
      ),
      # Neo4j
      list(
        regex = "GraphDatabase\\.driver\\s*\\(",
        func = "GraphDatabase.driver",
        arg_position = 1,
        arg_name = "uri",
        description = "Neo4j driver connection"
      ),
      list(
        regex = "neo4j\\.GraphDatabase\\.driver\\s*\\(",
        func = "neo4j.GraphDatabase.driver",
        arg_position = 1,
        arg_name = "uri",
        description = "Neo4j driver connection (namespaced)"
      ),
      list(
        regex = "session\\.run\\s*\\([^)]*MATCH",
        func = "session.run",
        arg_position = 1,
        arg_name = "query",
        description = "Neo4j Cypher MATCH query"
      ),
      list(
        regex = "tx\\.run\\s*\\([^)]*MATCH",
        func = "tx.run",
        arg_position = 1,
        arg_name = "query",
        description = "Neo4j transaction MATCH query"
      ),
      # py2neo (Neo4j)
      list(
        regex = "py2neo\\.Graph\\s*\\(",
        func = "py2neo.Graph",
        arg_position = 1,
        arg_name = "uri",
        description = "py2neo Graph connection"
      ),
      list(
        regex = "graph\\.run\\s*\\(",
        func = "graph.run",
        arg_position = 1,
        arg_name = "cypher",
        description = "py2neo Cypher query"
      ),
      # ArangoDB
      list(
        regex = "ArangoClient\\s*\\(",
        func = "ArangoClient",
        arg_position = NA,
        arg_name = "hosts",
        description = "python-arango client"
      ),
      list(
        regex = "arango\\.ArangoClient\\s*\\(",
        func = "arango.ArangoClient",
        arg_position = NA,
        arg_name = "hosts",
        description = "python-arango client (namespaced)"
      ),
      list(
        regex = "client\\.db\\s*\\(",
        func = "client.db",
        arg_position = 1,
        arg_name = "name",
        description = "ArangoDB database connection"
      ),
      list(
        regex = "db\\.aql\\.execute\\s*\\(",
        func = "db.aql.execute",
        arg_position = 1,
        arg_name = "query",
        description = "ArangoDB AQL query"
      ),
      list(
        regex = "collection\\.find\\s*\\(",
        func = "collection.find",
        arg_position = 1,
        arg_name = "filters",
        description = "ArangoDB collection find"
      ),
      # ClickHouse
      list(
        regex = "clickhouse_connect\\.get_client\\s*\\(",
        func = "clickhouse_connect.get_client",
        arg_position = NA,
        arg_name = "host",
        description = "ClickHouse client connection"
      ),
      list(
        regex = "Client\\s*\\([^)]*host\\s*=",
        func = "Client",
        arg_position = NA,
        arg_name = "host",
        description = "ClickHouse client"
      ),
      # Cassandra
      list(
        regex = "Cluster\\s*\\(",
        func = "Cluster",
        arg_position = 1,
        arg_name = "contact_points",
        description = "Cassandra cluster connection"
      ),
      list(
        regex = "cassandra\\.cluster\\.Cluster\\s*\\(",
        func = "cassandra.cluster.Cluster",
        arg_position = 1,
        arg_name = "contact_points",
        description = "Cassandra cluster connection (namespaced)"
      ),
      # Elasticsearch
      list(
        regex = "Elasticsearch\\s*\\(",
        func = "Elasticsearch",
        arg_position = 1,
        arg_name = "hosts",
        description = "Elasticsearch client"
      ),
      list(
        regex = "elasticsearch\\.Elasticsearch\\s*\\(",
        func = "elasticsearch.Elasticsearch",
        arg_position = 1,
        arg_name = "hosts",
        description = "Elasticsearch client (namespaced)"
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
      ),
      # Database outputs - pandas
      list(
        regex = "\\.to_sql\\s*\\(",
        func = "df.to_sql",
        arg_position = 1,
        arg_name = "name",
        description = "pandas DataFrame to SQL table"
      ),
      # SQLAlchemy outputs
      list(
        regex = "session\\.add\\s*\\(",
        func = "session.add",
        arg_position = 1,
        arg_name = "instance",
        description = "SQLAlchemy ORM add"
      ),
      list(
        regex = "session\\.add_all\\s*\\(",
        func = "session.add_all",
        arg_position = 1,
        arg_name = "instances",
        description = "SQLAlchemy ORM add all"
      ),
      list(
        regex = "session\\.commit\\s*\\(",
        func = "session.commit",
        arg_position = NA,
        arg_name = NULL,
        description = "SQLAlchemy session commit"
      ),
      list(
        regex = "session\\.bulk_insert_mappings\\s*\\(",
        func = "session.bulk_insert_mappings",
        arg_position = 1,
        arg_name = "mapper",
        description = "SQLAlchemy bulk insert"
      ),
      # cursor outputs
      list(
        regex = "cursor\\.execute\\s*\\([^)]*INSERT",
        func = "cursor.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "Database cursor INSERT"
      ),
      list(
        regex = "cursor\\.execute\\s*\\([^)]*UPDATE",
        func = "cursor.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "Database cursor UPDATE"
      ),
      list(
        regex = "cursor\\.execute\\s*\\([^)]*DELETE",
        func = "cursor.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "Database cursor DELETE"
      ),
      list(
        regex = "cursor\\.execute\\s*\\([^)]*CREATE",
        func = "cursor.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "Database cursor CREATE"
      ),
      list(
        regex = "cursor\\.executemany\\s*\\(",
        func = "cursor.executemany",
        arg_position = 1,
        arg_name = "sql",
        description = "Database cursor execute many"
      ),
      list(
        regex = "connection\\.commit\\s*\\(",
        func = "connection.commit",
        arg_position = NA,
        arg_name = NULL,
        description = "Database connection commit"
      ),
      # Neo4j outputs
      list(
        regex = "session\\.run\\s*\\([^)]*CREATE",
        func = "session.run",
        arg_position = 1,
        arg_name = "query",
        description = "Neo4j Cypher CREATE"
      ),
      list(
        regex = "session\\.run\\s*\\([^)]*MERGE",
        func = "session.run",
        arg_position = 1,
        arg_name = "query",
        description = "Neo4j Cypher MERGE"
      ),
      list(
        regex = "session\\.run\\s*\\([^)]*DELETE",
        func = "session.run",
        arg_position = 1,
        arg_name = "query",
        description = "Neo4j Cypher DELETE"
      ),
      list(
        regex = "session\\.run\\s*\\([^)]*SET",
        func = "session.run",
        arg_position = 1,
        arg_name = "query",
        description = "Neo4j Cypher SET"
      ),
      list(
        regex = "graph\\.create\\s*\\(",
        func = "graph.create",
        arg_position = 1,
        arg_name = "subgraph",
        description = "py2neo create nodes/relationships"
      ),
      list(
        regex = "graph\\.push\\s*\\(",
        func = "graph.push",
        arg_position = 1,
        arg_name = "subgraph",
        description = "py2neo push changes"
      ),
      # ArangoDB outputs
      list(
        regex = "collection\\.insert\\s*\\(",
        func = "collection.insert",
        arg_position = 1,
        arg_name = "document",
        description = "ArangoDB insert document"
      ),
      list(
        regex = "collection\\.update\\s*\\(",
        func = "collection.update",
        arg_position = 1,
        arg_name = "document",
        description = "ArangoDB update document"
      ),
      list(
        regex = "collection\\.delete\\s*\\(",
        func = "collection.delete",
        arg_position = 1,
        arg_name = "document",
        description = "ArangoDB delete document"
      ),
      list(
        regex = "collection\\.import_bulk\\s*\\(",
        func = "collection.import_bulk",
        arg_position = 1,
        arg_name = "documents",
        description = "ArangoDB bulk import"
      ),
      # MongoDB outputs
      list(
        regex = "collection\\.insert_one\\s*\\(",
        func = "collection.insert_one",
        arg_position = 1,
        arg_name = "document",
        description = "MongoDB insert one"
      ),
      list(
        regex = "collection\\.insert_many\\s*\\(",
        func = "collection.insert_many",
        arg_position = 1,
        arg_name = "documents",
        description = "MongoDB insert many"
      ),
      list(
        regex = "collection\\.update_one\\s*\\(",
        func = "collection.update_one",
        arg_position = 1,
        arg_name = "filter",
        description = "MongoDB update one"
      ),
      list(
        regex = "collection\\.update_many\\s*\\(",
        func = "collection.update_many",
        arg_position = 1,
        arg_name = "filter",
        description = "MongoDB update many"
      ),
      list(
        regex = "collection\\.delete_one\\s*\\(",
        func = "collection.delete_one",
        arg_position = 1,
        arg_name = "filter",
        description = "MongoDB delete one"
      ),
      list(
        regex = "collection\\.delete_many\\s*\\(",
        func = "collection.delete_many",
        arg_position = 1,
        arg_name = "filter",
        description = "MongoDB delete many"
      ),
      list(
        regex = "collection\\.bulk_write\\s*\\(",
        func = "collection.bulk_write",
        arg_position = 1,
        arg_name = "requests",
        description = "MongoDB bulk write"
      ),
      # Redis outputs
      list(
        regex = "redis\\.set\\s*\\(|r\\.set\\s*\\(",
        func = "redis.set",
        arg_position = 1,
        arg_name = "name",
        description = "Redis set key"
      ),
      list(
        regex = "redis\\.hset\\s*\\(|r\\.hset\\s*\\(",
        func = "redis.hset",
        arg_position = 1,
        arg_name = "name",
        description = "Redis hash set"
      ),
      list(
        regex = "redis\\.lpush\\s*\\(|r\\.lpush\\s*\\(",
        func = "redis.lpush",
        arg_position = 1,
        arg_name = "name",
        description = "Redis list push"
      ),
      list(
        regex = "redis\\.sadd\\s*\\(|r\\.sadd\\s*\\(",
        func = "redis.sadd",
        arg_position = 1,
        arg_name = "name",
        description = "Redis set add"
      ),
      # DuckDB outputs
      list(
        regex = "\\.execute\\s*\\([^)]*INSERT",
        func = "con.execute",
        arg_position = 1,
        arg_name = "query",
        description = "DuckDB INSERT"
      ),
      list(
        regex = "\\.execute\\s*\\([^)]*CREATE",
        func = "con.execute",
        arg_position = 1,
        arg_name = "query",
        description = "DuckDB CREATE"
      ),
      list(
        regex = "duckdb\\.write_parquet\\s*\\(",
        func = "duckdb.write_parquet",
        arg_position = 1,
        arg_name = "path",
        description = "DuckDB write Parquet"
      ),
      # Elasticsearch outputs
      list(
        regex = "es\\.index\\s*\\(",
        func = "es.index",
        arg_position = NA,
        arg_name = "index",
        description = "Elasticsearch index document"
      ),
      list(
        regex = "es\\.bulk\\s*\\(",
        func = "es.bulk",
        arg_position = 1,
        arg_name = "body",
        description = "Elasticsearch bulk operation"
      ),
      list(
        regex = "helpers\\.bulk\\s*\\(",
        func = "helpers.bulk",
        arg_position = 1,
        arg_name = "client",
        description = "Elasticsearch helpers bulk"
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
