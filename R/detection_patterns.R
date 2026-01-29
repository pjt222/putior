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

  valid_languages <- c("r", "python", "sql", "shell", "julia",
                       "javascript", "typescript", "go", "rust",
                       "java", "c", "cpp", "matlab", "ruby", "lua")
  if (!language %in% valid_languages) {
    stop("Unsupported language: ", language,
         ". Supported languages: ", paste(valid_languages, collapse = ", "))
  }

  patterns <- switch(language,
    "r" = get_r_patterns(),
    "python" = get_python_patterns(),
    "sql" = get_sql_patterns(),
    "shell" = get_shell_patterns(),
    "julia" = get_julia_patterns(),
    "javascript" = get_javascript_patterns(),
    "typescript" = get_typescript_patterns(),
    "go" = get_go_patterns(),
    "rust" = get_rust_patterns(),
    "java" = get_java_patterns(),
    "c" = get_c_patterns(),
    "cpp" = get_cpp_patterns(),
    "matlab" = get_matlab_patterns(),
    "ruby" = get_ruby_patterns(),
    "lua" = get_lua_patterns()
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
      ),
      # LLM/AI API Integrations - ellmer package (tidyverse-style LLM interface)
      list(
        regex = "chat\\s*\\(",
        func = "chat",
        arg_position = 1,
        arg_name = "provider",
        description = "ellmer chat interface"
      ),
      list(
        regex = "chat_ollama\\s*\\(",
        func = "chat_ollama",
        arg_position = NA,
        arg_name = "model",
        description = "ellmer Ollama chat"
      ),
      list(
        regex = "chat_openai\\s*\\(",
        func = "chat_openai",
        arg_position = NA,
        arg_name = "model",
        description = "ellmer OpenAI chat"
      ),
      list(
        regex = "chat_claude\\s*\\(",
        func = "chat_claude",
        arg_position = NA,
        arg_name = "model",
        description = "ellmer Claude/Anthropic chat"
      ),
      list(
        regex = "chat_gemini\\s*\\(",
        func = "chat_gemini",
        arg_position = NA,
        arg_name = "model",
        description = "ellmer Google Gemini chat"
      ),
      list(
        regex = "chat_groq\\s*\\(",
        func = "chat_groq",
        arg_position = NA,
        arg_name = "model",
        description = "ellmer Groq chat"
      ),
      list(
        regex = "chat_azure\\s*\\(",
        func = "chat_azure",
        arg_position = NA,
        arg_name = "deployment_id",
        description = "ellmer Azure OpenAI"
      ),
      # tidyllm package
      list(
        regex = "llm_message\\s*\\(",
        func = "llm_message",
        arg_position = 1,
        arg_name = "content",
        description = "tidyllm message"
      ),
      list(
        regex = "send_prompt\\s*\\(",
        func = "send_prompt",
        arg_position = 1,
        arg_name = "prompt",
        description = "tidyllm send prompt"
      ),
      # httr2 calls to LLM APIs
      list(
        regex = "request\\s*\\([^)]*openai\\.com",
        func = "request",
        arg_position = 1,
        arg_name = "base_url",
        description = "httr2 OpenAI API"
      ),
      list(
        regex = "request\\s*\\([^)]*anthropic\\.com",
        func = "request",
        arg_position = 1,
        arg_name = "base_url",
        description = "httr2 Anthropic API"
      ),
      list(
        regex = "request\\s*\\([^)]*api\\.groq\\.com",
        func = "request",
        arg_position = 1,
        arg_name = "base_url",
        description = "httr2 Groq API"
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
      ),
      # LLM/AI Libraries - ollama
      list(
        regex = "ollama\\.chat\\s*\\(",
        func = "ollama.chat",
        arg_position = NA,
        arg_name = "model",
        description = "Ollama chat"
      ),
      list(
        regex = "ollama\\.generate\\s*\\(",
        func = "ollama.generate",
        arg_position = NA,
        arg_name = "model",
        description = "Ollama generate"
      ),
      list(
        regex = "ollama\\.embeddings\\s*\\(",
        func = "ollama.embeddings",
        arg_position = NA,
        arg_name = "model",
        description = "Ollama embeddings"
      ),
      # openai
      list(
        regex = "client\\.chat\\.completions\\.create\\s*\\(",
        func = "client.chat.completions.create",
        arg_position = NA,
        arg_name = "model",
        description = "OpenAI chat (v1 API)"
      ),
      list(
        regex = "client\\.embeddings\\.create\\s*\\(",
        func = "client.embeddings.create",
        arg_position = NA,
        arg_name = "model",
        description = "OpenAI embeddings"
      ),
      list(
        regex = "OpenAI\\s*\\(",
        func = "OpenAI",
        arg_position = NA,
        arg_name = "api_key",
        description = "OpenAI client init"
      ),
      list(
        regex = "openai\\.ChatCompletion\\.create\\s*\\(",
        func = "openai.ChatCompletion.create",
        arg_position = NA,
        arg_name = "model",
        description = "OpenAI chat (legacy API)"
      ),
      # anthropic
      list(
        regex = "anthropic\\.Anthropic\\s*\\(",
        func = "anthropic.Anthropic",
        arg_position = NA,
        arg_name = "api_key",
        description = "Anthropic client"
      ),
      list(
        regex = "Anthropic\\s*\\(",
        func = "Anthropic",
        arg_position = NA,
        arg_name = "api_key",
        description = "Anthropic client init"
      ),
      list(
        regex = "client\\.messages\\.create\\s*\\(",
        func = "client.messages.create",
        arg_position = NA,
        arg_name = "model",
        description = "Anthropic messages"
      ),
      # langchain
      list(
        regex = "ChatOpenAI\\s*\\(",
        func = "ChatOpenAI",
        arg_position = NA,
        arg_name = "model",
        description = "LangChain OpenAI"
      ),
      list(
        regex = "ChatAnthropic\\s*\\(",
        func = "ChatAnthropic",
        arg_position = NA,
        arg_name = "model",
        description = "LangChain Anthropic"
      ),
      list(
        regex = "ChatOllama\\s*\\(",
        func = "ChatOllama",
        arg_position = NA,
        arg_name = "model",
        description = "LangChain Ollama"
      ),
      list(
        regex = "LLMChain\\s*\\(",
        func = "LLMChain",
        arg_position = NA,
        arg_name = "llm",
        description = "LangChain LLM chain"
      ),
      list(
        regex = "ChatGoogleGenerativeAI\\s*\\(",
        func = "ChatGoogleGenerativeAI",
        arg_position = NA,
        arg_name = "model",
        description = "LangChain Google Gemini"
      ),
      # transformers (Hugging Face)
      list(
        regex = "pipeline\\s*\\(['\"]text-generation['\"]",
        func = "pipeline",
        arg_position = 1,
        arg_name = "task",
        description = "Transformers text-gen pipeline"
      ),
      list(
        regex = "AutoModelForCausalLM\\.from_pretrained\\s*\\(",
        func = "AutoModelForCausalLM.from_pretrained",
        arg_position = 1,
        arg_name = "pretrained_model_name_or_path",
        description = "Transformers causal LM"
      ),
      list(
        regex = "AutoTokenizer\\.from_pretrained\\s*\\(",
        func = "AutoTokenizer.from_pretrained",
        arg_position = 1,
        arg_name = "pretrained_model_name_or_path",
        description = "Transformers tokenizer"
      ),
      list(
        regex = "AutoModel\\.from_pretrained\\s*\\(",
        func = "AutoModel.from_pretrained",
        arg_position = 1,
        arg_name = "pretrained_model_name_or_path",
        description = "Transformers auto model"
      ),
      # litellm
      list(
        regex = "litellm\\.completion\\s*\\(",
        func = "litellm.completion",
        arg_position = NA,
        arg_name = "model",
        description = "LiteLLM completion"
      ),
      list(
        regex = "litellm\\.embedding\\s*\\(",
        func = "litellm.embedding",
        arg_position = NA,
        arg_name = "model",
        description = "LiteLLM embedding"
      ),
      # vllm
      list(
        regex = "LLM\\s*\\(['\"]",
        func = "LLM",
        arg_position = 1,
        arg_name = "model",
        description = "vLLM model server"
      ),
      list(
        regex = "vllm\\.LLM\\s*\\(",
        func = "vllm.LLM",
        arg_position = 1,
        arg_name = "model",
        description = "vLLM model server (namespaced)"
      ),
      # google generativeai
      list(
        regex = "genai\\.GenerativeModel\\s*\\(",
        func = "genai.GenerativeModel",
        arg_position = 1,
        arg_name = "model_name",
        description = "Google Generative AI model"
      ),
      list(
        regex = "model\\.generate_content\\s*\\(",
        func = "model.generate_content",
        arg_position = 1,
        arg_name = "contents",
        description = "Google Gemini generate"
      ),
      # groq
      list(
        regex = "Groq\\s*\\(",
        func = "Groq",
        arg_position = NA,
        arg_name = "api_key",
        description = "Groq client init"
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
      ),
      # LLM/AI Model Outputs - Transformers
      list(
        regex = "model\\.save_pretrained\\s*\\(",
        func = "model.save_pretrained",
        arg_position = 1,
        arg_name = "save_directory",
        description = "Transformers save model"
      ),
      list(
        regex = "tokenizer\\.save_pretrained\\s*\\(",
        func = "tokenizer.save_pretrained",
        arg_position = 1,
        arg_name = "save_directory",
        description = "Transformers save tokenizer"
      ),
      list(
        regex = "trainer\\.save_model\\s*\\(",
        func = "trainer.save_model",
        arg_position = 1,
        arg_name = "output_dir",
        description = "Transformers Trainer save"
      ),
      # PyTorch model saving
      list(
        regex = "torch\\.save\\s*\\(",
        func = "torch.save",
        arg_position = 2,
        arg_name = "f",
        description = "PyTorch save model"
      ),
      # ONNX export
      list(
        regex = "torch\\.onnx\\.export\\s*\\(",
        func = "torch.onnx.export",
        arg_position = 2,
        arg_name = "f",
        description = "PyTorch ONNX export"
      ),
      # TensorFlow/Keras model saving
      list(
        regex = "model\\.save\\s*\\(['\"]",
        func = "model.save",
        arg_position = 1,
        arg_name = "filepath",
        description = "Keras save model"
      ),
      list(
        regex = "model\\.save_weights\\s*\\(",
        func = "model.save_weights",
        arg_position = 1,
        arg_name = "filepath",
        description = "Keras save weights"
      ),
      # MLflow
      list(
        regex = "mlflow\\.log_model\\s*\\(",
        func = "mlflow.log_model",
        arg_position = 1,
        arg_name = "artifact_path",
        description = "MLflow log model"
      ),
      list(
        regex = "mlflow\\.sklearn\\.log_model\\s*\\(",
        func = "mlflow.sklearn.log_model",
        arg_position = 1,
        arg_name = "sk_model",
        description = "MLflow log sklearn model"
      ),
      list(
        regex = "mlflow\\.pytorch\\.log_model\\s*\\(",
        func = "mlflow.pytorch.log_model",
        arg_position = 1,
        arg_name = "pytorch_model",
        description = "MLflow log PyTorch model"
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

#' Get JavaScript Detection Patterns
#' @return List of JavaScript detection patterns
#' @keywords internal
get_javascript_patterns <- function() {
  list(
    input = list(
      # Node.js fs module - sync
      list(
        regex = "fs\\.readFileSync\\s*\\(",
        func = "fs.readFileSync",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js sync file reader"
      ),
      list(
        regex = "fs\\.readFile\\s*\\(",
        func = "fs.readFile",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js async file reader"
      ),
      list(
        regex = "fs\\.createReadStream\\s*\\(",
        func = "fs.createReadStream",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js read stream"
      ),
      list(
        regex = "fs\\.promises\\.readFile\\s*\\(",
        func = "fs.promises.readFile",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js promise-based file reader"
      ),
      list(
        regex = "fsPromises\\.readFile\\s*\\(",
        func = "fsPromises.readFile",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js promise-based file reader (alias)"
      ),
      list(
        regex = "fs\\.readdir\\s*\\(",
        func = "fs.readdir",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js directory reader"
      ),
      list(
        regex = "fs\\.readdirSync\\s*\\(",
        func = "fs.readdirSync",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js sync directory reader"
      ),
      # require/import
      list(
        regex = "require\\s*\\(['\"]",
        func = "require",
        arg_position = 1,
        arg_name = "id",
        description = "CommonJS require"
      ),
      list(
        regex = "import\\s+.*\\s+from\\s+['\"]",
        func = "import",
        arg_position = NA,
        arg_name = NULL,
        description = "ES module import"
      ),
      list(
        regex = "import\\s*\\(['\"]",
        func = "import()",
        arg_position = 1,
        arg_name = NULL,
        description = "Dynamic import"
      ),
      # HTTP clients
      list(
        regex = "fetch\\s*\\(",
        func = "fetch",
        arg_position = 1,
        arg_name = "url",
        description = "Fetch API"
      ),
      list(
        regex = "axios\\.get\\s*\\(",
        func = "axios.get",
        arg_position = 1,
        arg_name = "url",
        description = "Axios GET request"
      ),
      list(
        regex = "axios\\.post\\s*\\(",
        func = "axios.post",
        arg_position = 1,
        arg_name = "url",
        description = "Axios POST request"
      ),
      list(
        regex = "axios\\s*\\(",
        func = "axios",
        arg_position = 1,
        arg_name = "config",
        description = "Axios request"
      ),
      list(
        regex = "got\\s*\\(",
        func = "got",
        arg_position = 1,
        arg_name = "url",
        description = "Got HTTP client"
      ),
      list(
        regex = "superagent\\.get\\s*\\(",
        func = "superagent.get",
        arg_position = 1,
        arg_name = "url",
        description = "SuperAgent GET"
      ),
      # JSON parsing from file
      list(
        regex = "JSON\\.parse\\s*\\(\\s*fs\\.",
        func = "JSON.parse(fs)",
        arg_position = NA,
        arg_name = NULL,
        description = "JSON parse from file"
      ),
      # Database clients
      list(
        regex = "mongoose\\.connect\\s*\\(",
        func = "mongoose.connect",
        arg_position = 1,
        arg_name = "uri",
        description = "Mongoose MongoDB connection"
      ),
      list(
        regex = "MongoClient\\.connect\\s*\\(",
        func = "MongoClient.connect",
        arg_position = 1,
        arg_name = "url",
        description = "MongoDB native driver"
      ),
      list(
        regex = "new\\s+MongoClient\\s*\\(",
        func = "new MongoClient",
        arg_position = 1,
        arg_name = "url",
        description = "MongoDB native client"
      ),
      list(
        regex = "knex\\s*\\(",
        func = "knex",
        arg_position = 1,
        arg_name = "config",
        description = "Knex.js query builder"
      ),
      list(
        regex = "new\\s+Sequelize\\s*\\(",
        func = "new Sequelize",
        arg_position = 1,
        arg_name = "database",
        description = "Sequelize ORM"
      ),
      list(
        regex = "prisma\\.\\$connect\\s*\\(",
        func = "prisma.$connect",
        arg_position = NA,
        arg_name = NULL,
        description = "Prisma connect"
      ),
      list(
        regex = "new\\s+PrismaClient\\s*\\(",
        func = "new PrismaClient",
        arg_position = NA,
        arg_name = NULL,
        description = "Prisma client"
      ),
      list(
        regex = "createConnection\\s*\\(",
        func = "createConnection",
        arg_position = 1,
        arg_name = "config",
        description = "MySQL/TypeORM connection"
      ),
      list(
        regex = "createPool\\s*\\(",
        func = "createPool",
        arg_position = 1,
        arg_name = "config",
        description = "MySQL connection pool"
      ),
      list(
        regex = "new\\s+Pool\\s*\\(",
        func = "new Pool",
        arg_position = 1,
        arg_name = "config",
        description = "PostgreSQL pool (pg)"
      ),
      list(
        regex = "new\\s+Client\\s*\\(",
        func = "new Client",
        arg_position = 1,
        arg_name = "config",
        description = "PostgreSQL client (pg)"
      ),
      # Express.js request inputs
      list(
        regex = "req\\.body",
        func = "req.body",
        arg_position = NA,
        arg_name = NULL,
        description = "Express request body"
      ),
      list(
        regex = "req\\.params",
        func = "req.params",
        arg_position = NA,
        arg_name = NULL,
        description = "Express route parameters"
      ),
      list(
        regex = "req\\.query",
        func = "req.query",
        arg_position = NA,
        arg_name = NULL,
        description = "Express query string"
      ),
      list(
        regex = "req\\.file",
        func = "req.file",
        arg_position = NA,
        arg_name = NULL,
        description = "Express file upload (multer)"
      ),
      list(
        regex = "req\\.files",
        func = "req.files",
        arg_position = NA,
        arg_name = NULL,
        description = "Express file uploads (multer)"
      ),
      # Node streams
      list(
        regex = "pipeline\\s*\\(",
        func = "pipeline",
        arg_position = 1,
        arg_name = "source",
        description = "Node.js stream pipeline"
      ),
      # Redis
      list(
        regex = "redis\\.createClient\\s*\\(",
        func = "redis.createClient",
        arg_position = NA,
        arg_name = "options",
        description = "Redis client"
      ),
      list(
        regex = "new\\s+Redis\\s*\\(",
        func = "new Redis",
        arg_position = NA,
        arg_name = "options",
        description = "ioredis client"
      ),
      # CSV parsing
      list(
        regex = "csv-parse|csv-parser|papaparse",
        func = "csv-parse",
        arg_position = NA,
        arg_name = NULL,
        description = "CSV parser library"
      ),
      list(
        regex = "Papa\\.parse\\s*\\(",
        func = "Papa.parse",
        arg_position = 1,
        arg_name = "input",
        description = "PapaParse CSV parser"
      )
    ),
    output = list(
      # Node.js fs module - sync
      list(
        regex = "fs\\.writeFileSync\\s*\\(",
        func = "fs.writeFileSync",
        arg_position = 1,
        arg_name = "file",
        description = "Node.js sync file writer"
      ),
      list(
        regex = "fs\\.writeFile\\s*\\(",
        func = "fs.writeFile",
        arg_position = 1,
        arg_name = "file",
        description = "Node.js async file writer"
      ),
      list(
        regex = "fs\\.createWriteStream\\s*\\(",
        func = "fs.createWriteStream",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js write stream"
      ),
      list(
        regex = "fs\\.promises\\.writeFile\\s*\\(",
        func = "fs.promises.writeFile",
        arg_position = 1,
        arg_name = "file",
        description = "Node.js promise-based file writer"
      ),
      list(
        regex = "fsPromises\\.writeFile\\s*\\(",
        func = "fsPromises.writeFile",
        arg_position = 1,
        arg_name = "file",
        description = "Node.js promise-based file writer (alias)"
      ),
      list(
        regex = "fs\\.appendFile\\s*\\(",
        func = "fs.appendFile",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js file append"
      ),
      list(
        regex = "fs\\.appendFileSync\\s*\\(",
        func = "fs.appendFileSync",
        arg_position = 1,
        arg_name = "path",
        description = "Node.js sync file append"
      ),
      # Module exports
      list(
        regex = "module\\.exports\\s*=",
        func = "module.exports",
        arg_position = NA,
        arg_name = NULL,
        description = "CommonJS export"
      ),
      list(
        regex = "export\\s+default",
        func = "export default",
        arg_position = NA,
        arg_name = NULL,
        description = "ES module default export"
      ),
      list(
        regex = "export\\s+\\{",
        func = "export",
        arg_position = NA,
        arg_name = NULL,
        description = "ES module named export"
      ),
      # Database writes
      list(
        regex = "\\.insertOne\\s*\\(",
        func = "collection.insertOne",
        arg_position = 1,
        arg_name = "doc",
        description = "MongoDB insert one"
      ),
      list(
        regex = "\\.insertMany\\s*\\(",
        func = "collection.insertMany",
        arg_position = 1,
        arg_name = "docs",
        description = "MongoDB insert many"
      ),
      list(
        regex = "\\.updateOne\\s*\\(",
        func = "collection.updateOne",
        arg_position = 1,
        arg_name = "filter",
        description = "MongoDB update one"
      ),
      list(
        regex = "\\.updateMany\\s*\\(",
        func = "collection.updateMany",
        arg_position = 1,
        arg_name = "filter",
        description = "MongoDB update many"
      ),
      list(
        regex = "Model\\.create\\s*\\(",
        func = "Model.create",
        arg_position = 1,
        arg_name = "doc",
        description = "Mongoose/Sequelize create"
      ),
      list(
        regex = "\\.save\\s*\\(",
        func = "model.save",
        arg_position = NA,
        arg_name = NULL,
        description = "Mongoose/Sequelize save"
      ),
      list(
        regex = "prisma\\..*\\.create\\s*\\(",
        func = "prisma.create",
        arg_position = 1,
        arg_name = "data",
        description = "Prisma create"
      ),
      list(
        regex = "prisma\\..*\\.createMany\\s*\\(",
        func = "prisma.createMany",
        arg_position = 1,
        arg_name = "data",
        description = "Prisma create many"
      ),
      # Express.js responses
      list(
        regex = "res\\.send\\s*\\(",
        func = "res.send",
        arg_position = 1,
        arg_name = "body",
        description = "Express send response"
      ),
      list(
        regex = "res\\.json\\s*\\(",
        func = "res.json",
        arg_position = 1,
        arg_name = "obj",
        description = "Express JSON response"
      ),
      list(
        regex = "res\\.download\\s*\\(",
        func = "res.download",
        arg_position = 1,
        arg_name = "path",
        description = "Express file download"
      ),
      list(
        regex = "res\\.sendFile\\s*\\(",
        func = "res.sendFile",
        arg_position = 1,
        arg_name = "path",
        description = "Express send file"
      ),
      list(
        regex = "res\\.render\\s*\\(",
        func = "res.render",
        arg_position = 1,
        arg_name = "view",
        description = "Express render view"
      ),
      # Logging
      list(
        regex = "console\\.log\\s*\\(",
        func = "console.log",
        arg_position = 1,
        arg_name = "data",
        description = "Console log"
      ),
      list(
        regex = "winston\\.log\\s*\\(",
        func = "winston.log",
        arg_position = 1,
        arg_name = "level",
        description = "Winston logger"
      ),
      list(
        regex = "logger\\.info\\s*\\(",
        func = "logger.info",
        arg_position = 1,
        arg_name = "message",
        description = "Logger info"
      ),
      list(
        regex = "pino\\s*\\(",
        func = "pino",
        arg_position = NA,
        arg_name = NULL,
        description = "Pino logger"
      ),
      # CSV output
      list(
        regex = "stringify\\s*\\(",
        func = "csv-stringify",
        arg_position = 1,
        arg_name = "records",
        description = "CSV stringify"
      ),
      list(
        regex = "Papa\\.unparse\\s*\\(",
        func = "Papa.unparse",
        arg_position = 1,
        arg_name = "data",
        description = "PapaParse CSV output"
      )
    ),
    dependency = list(
      list(
        regex = "require\\s*\\(['\"]",
        func = "require",
        arg_position = 1,
        arg_name = "id",
        description = "CommonJS require"
      ),
      list(
        regex = "import\\s+.*\\s+from\\s+['\"]",
        func = "import",
        arg_position = NA,
        arg_name = NULL,
        description = "ES module import"
      ),
      list(
        regex = "import\\s*\\(['\"]",
        func = "import()",
        arg_position = 1,
        arg_name = NULL,
        description = "Dynamic import"
      ),
      list(
        regex = "export\\s+",
        func = "export",
        arg_position = NA,
        arg_name = NULL,
        description = "ES module export"
      )
    )
  )
}

#' Get TypeScript Detection Patterns
#' @return List of TypeScript detection patterns
#' @keywords internal
get_typescript_patterns <- function() {
  # Start with JavaScript patterns as base
  js_patterns <- get_javascript_patterns()

  # Add TypeScript-specific patterns
  ts_input <- c(js_patterns$input, list(
    # Type reference directives
    list(
      regex = "///\\s*<reference\\s+path\\s*=",
      func = "/// <reference path>",
      arg_position = NA,
      arg_name = "path",
      description = "TypeScript path reference"
    ),
    list(
      regex = "///\\s*<reference\\s+types\\s*=",
      func = "/// <reference types>",
      arg_position = NA,
      arg_name = "types",
      description = "TypeScript types reference"
    ),
    # NestJS decorators
    list(
      regex = "@Controller\\s*\\(",
      func = "@Controller",
      arg_position = 1,
      arg_name = "prefix",
      description = "NestJS controller decorator"
    ),
    list(
      regex = "@Get\\s*\\(",
      func = "@Get",
      arg_position = 1,
      arg_name = "path",
      description = "NestJS GET endpoint"
    ),
    list(
      regex = "@Post\\s*\\(",
      func = "@Post",
      arg_position = 1,
      arg_name = "path",
      description = "NestJS POST endpoint"
    ),
    list(
      regex = "@Body\\s*\\(",
      func = "@Body",
      arg_position = NA,
      arg_name = NULL,
      description = "NestJS request body"
    ),
    list(
      regex = "@Param\\s*\\(",
      func = "@Param",
      arg_position = 1,
      arg_name = "property",
      description = "NestJS route parameter"
    ),
    list(
      regex = "@Query\\s*\\(",
      func = "@Query",
      arg_position = 1,
      arg_name = "property",
      description = "NestJS query parameter"
    ),
    # TypeORM
    list(
      regex = "new\\s+DataSource\\s*\\(",
      func = "new DataSource",
      arg_position = 1,
      arg_name = "options",
      description = "TypeORM data source"
    ),
    list(
      regex = "getRepository\\s*\\(",
      func = "getRepository",
      arg_position = 1,
        arg_name = "entity",
      description = "TypeORM repository"
    ),
    list(
      regex = "\\.find\\s*\\(",
      func = "repository.find",
      arg_position = NA,
      arg_name = "options",
      description = "TypeORM find"
    ),
    list(
      regex = "\\.findOne\\s*\\(",
      func = "repository.findOne",
      arg_position = NA,
      arg_name = "options",
      description = "TypeORM find one"
    )
  ))

  ts_output <- c(js_patterns$output, list(
    # NestJS responses
    list(
      regex = "@Injectable\\s*\\(",
      func = "@Injectable",
      arg_position = NA,
      arg_name = NULL,
      description = "NestJS injectable service"
    ),
    # TypeORM write operations
    list(
      regex = "\\.save\\s*\\(",
      func = "repository.save",
      arg_position = 1,
      arg_name = "entity",
      description = "TypeORM save"
    ),
    list(
      regex = "\\.insert\\s*\\(",
      func = "repository.insert",
      arg_position = 1,
      arg_name = "entity",
      description = "TypeORM insert"
    ),
    list(
      regex = "\\.update\\s*\\(",
      func = "repository.update",
      arg_position = 1,
      arg_name = "criteria",
      description = "TypeORM update"
    ),
    list(
      regex = "\\.delete\\s*\\(",
      func = "repository.delete",
      arg_position = 1,
      arg_name = "criteria",
      description = "TypeORM delete"
    )
  ))

  list(
    input = ts_input,
    output = ts_output,
    dependency = js_patterns$dependency
  )
}

#' Get Go Detection Patterns
#' @return List of Go detection patterns
#' @keywords internal
get_go_patterns <- function() {
  list(
    input = list(
      # os package
      list(
        regex = "os\\.Open\\s*\\(",
        func = "os.Open",
        arg_position = 1,
        arg_name = "name",
        description = "Go file open"
      ),
      list(
        regex = "os\\.ReadFile\\s*\\(",
        func = "os.ReadFile",
        arg_position = 1,
        arg_name = "name",
        description = "Go read file"
      ),
      list(
        regex = "ioutil\\.ReadFile\\s*\\(",
        func = "ioutil.ReadFile",
        arg_position = 1,
        arg_name = "filename",
        description = "Go ioutil read file (deprecated)"
      ),
      list(
        regex = "os\\.ReadDir\\s*\\(",
        func = "os.ReadDir",
        arg_position = 1,
        arg_name = "name",
        description = "Go read directory"
      ),
      list(
        regex = "os\\.Stat\\s*\\(",
        func = "os.Stat",
        arg_position = 1,
        arg_name = "name",
        description = "Go file stat"
      ),
      list(
        regex = "os\\.Getenv\\s*\\(",
        func = "os.Getenv",
        arg_position = 1,
        arg_name = "key",
        description = "Go environment variable"
      ),
      # bufio package
      list(
        regex = "bufio\\.NewReader\\s*\\(",
        func = "bufio.NewReader",
        arg_position = 1,
        arg_name = "rd",
        description = "Go buffered reader"
      ),
      list(
        regex = "bufio\\.NewScanner\\s*\\(",
        func = "bufio.NewScanner",
        arg_position = 1,
        arg_name = "r",
        description = "Go scanner"
      ),
      # encoding/json
      list(
        regex = "json\\.NewDecoder\\s*\\(",
        func = "json.NewDecoder",
        arg_position = 1,
        arg_name = "r",
        description = "Go JSON decoder"
      ),
      list(
        regex = "json\\.Unmarshal\\s*\\(",
        func = "json.Unmarshal",
        arg_position = 1,
        arg_name = "data",
        description = "Go JSON unmarshal"
      ),
      # encoding/csv
      list(
        regex = "csv\\.NewReader\\s*\\(",
        func = "csv.NewReader",
        arg_position = 1,
        arg_name = "r",
        description = "Go CSV reader"
      ),
      # database/sql
      list(
        regex = "sql\\.Open\\s*\\(",
        func = "sql.Open",
        arg_position = 1,
        arg_name = "driverName",
        description = "Go SQL connection"
      ),
      list(
        regex = "db\\.Query\\s*\\(",
        func = "db.Query",
        arg_position = 1,
        arg_name = "query",
        description = "Go SQL query"
      ),
      list(
        regex = "db\\.QueryRow\\s*\\(",
        func = "db.QueryRow",
        arg_position = 1,
        arg_name = "query",
        description = "Go SQL query row"
      ),
      list(
        regex = "rows\\.Scan\\s*\\(",
        func = "rows.Scan",
        arg_position = NA,
        arg_name = "dest",
        description = "Go SQL scan"
      ),
      # gorm
      list(
        regex = "gorm\\.Open\\s*\\(",
        func = "gorm.Open",
        arg_position = 1,
        arg_name = "dialector",
        description = "GORM connection"
      ),
      list(
        regex = "\\.Find\\s*\\(",
        func = "db.Find",
        arg_position = 1,
        arg_name = "dest",
        description = "GORM find"
      ),
      list(
        regex = "\\.First\\s*\\(",
        func = "db.First",
        arg_position = 1,
        arg_name = "dest",
        description = "GORM first"
      ),
      list(
        regex = "\\.Where\\s*\\(",
        func = "db.Where",
        arg_position = 1,
        arg_name = "query",
        description = "GORM where"
      ),
      # net/http
      list(
        regex = "http\\.Get\\s*\\(",
        func = "http.Get",
        arg_position = 1,
        arg_name = "url",
        description = "Go HTTP GET"
      ),
      list(
        regex = "http\\.NewRequest\\s*\\(",
        func = "http.NewRequest",
        arg_position = 1,
        arg_name = "method",
        description = "Go HTTP request"
      ),
      list(
        regex = "http\\.DefaultClient\\.Do\\s*\\(",
        func = "http.DefaultClient.Do",
        arg_position = 1,
        arg_name = "req",
        description = "Go HTTP do request"
      ),
      # yaml
      list(
        regex = "yaml\\.Unmarshal\\s*\\(",
        func = "yaml.Unmarshal",
        arg_position = 1,
        arg_name = "in",
        description = "Go YAML unmarshal"
      ),
      # toml
      list(
        regex = "toml\\.Unmarshal\\s*\\(",
        func = "toml.Unmarshal",
        arg_position = 1,
        arg_name = "data",
        description = "Go TOML unmarshal"
      ),
      list(
        regex = "toml\\.DecodeFile\\s*\\(",
        func = "toml.DecodeFile",
        arg_position = 1,
        arg_name = "path",
        description = "Go TOML decode file"
      )
    ),
    output = list(
      # os package
      list(
        regex = "os\\.Create\\s*\\(",
        func = "os.Create",
        arg_position = 1,
        arg_name = "name",
        description = "Go create file"
      ),
      list(
        regex = "os\\.WriteFile\\s*\\(",
        func = "os.WriteFile",
        arg_position = 1,
        arg_name = "name",
        description = "Go write file"
      ),
      list(
        regex = "ioutil\\.WriteFile\\s*\\(",
        func = "ioutil.WriteFile",
        arg_position = 1,
        arg_name = "filename",
        description = "Go ioutil write file (deprecated)"
      ),
      list(
        regex = "os\\.OpenFile\\s*\\(",
        func = "os.OpenFile",
        arg_position = 1,
        arg_name = "name",
        description = "Go open file (with flags)"
      ),
      # bufio package
      list(
        regex = "bufio\\.NewWriter\\s*\\(",
        func = "bufio.NewWriter",
        arg_position = 1,
        arg_name = "w",
        description = "Go buffered writer"
      ),
      # fmt package
      list(
        regex = "fmt\\.Fprintf\\s*\\(",
        func = "fmt.Fprintf",
        arg_position = 1,
        arg_name = "w",
        description = "Go formatted print to writer"
      ),
      list(
        regex = "fmt\\.Fprintln\\s*\\(",
        func = "fmt.Fprintln",
        arg_position = 1,
        arg_name = "w",
        description = "Go print line to writer"
      ),
      # encoding/json
      list(
        regex = "json\\.NewEncoder\\s*\\(",
        func = "json.NewEncoder",
        arg_position = 1,
        arg_name = "w",
        description = "Go JSON encoder"
      ),
      list(
        regex = "json\\.Marshal\\s*\\(",
        func = "json.Marshal",
        arg_position = 1,
        arg_name = "v",
        description = "Go JSON marshal"
      ),
      # encoding/csv
      list(
        regex = "csv\\.NewWriter\\s*\\(",
        func = "csv.NewWriter",
        arg_position = 1,
        arg_name = "w",
        description = "Go CSV writer"
      ),
      # database/sql
      list(
        regex = "db\\.Exec\\s*\\(",
        func = "db.Exec",
        arg_position = 1,
        arg_name = "query",
        description = "Go SQL exec"
      ),
      # gorm
      list(
        regex = "\\.Create\\s*\\(",
        func = "db.Create",
        arg_position = 1,
        arg_name = "value",
        description = "GORM create"
      ),
      list(
        regex = "\\.Save\\s*\\(",
        func = "db.Save",
        arg_position = 1,
        arg_name = "value",
        description = "GORM save"
      ),
      list(
        regex = "\\.Update\\s*\\(",
        func = "db.Update",
        arg_position = 1,
        arg_name = "column",
        description = "GORM update"
      ),
      list(
        regex = "\\.Delete\\s*\\(",
        func = "db.Delete",
        arg_position = 1,
        arg_name = "value",
        description = "GORM delete"
      ),
      # log
      list(
        regex = "log\\.Printf\\s*\\(",
        func = "log.Printf",
        arg_position = 1,
        arg_name = "format",
        description = "Go log printf"
      ),
      list(
        regex = "log\\.Println\\s*\\(",
        func = "log.Println",
        arg_position = NA,
        arg_name = "v",
        description = "Go log println"
      ),
      # yaml
      list(
        regex = "yaml\\.Marshal\\s*\\(",
        func = "yaml.Marshal",
        arg_position = 1,
        arg_name = "in",
        description = "Go YAML marshal"
      )
    ),
    dependency = list(
      list(
        regex = "import\\s+[\"(]",
        func = "import",
        arg_position = NA,
        arg_name = NULL,
        description = "Go import statement"
      )
    )
  )
}

#' Get Rust Detection Patterns
#' @return List of Rust detection patterns
#' @keywords internal
get_rust_patterns <- function() {
  list(
    input = list(
      # std::fs
      list(
        regex = "File::open\\s*\\(",
        func = "File::open",
        arg_position = 1,
        arg_name = "path",
        description = "Rust file open"
      ),
      list(
        regex = "fs::read\\s*\\(",
        func = "fs::read",
        arg_position = 1,
        arg_name = "path",
        description = "Rust read file to bytes"
      ),
      list(
        regex = "fs::read_to_string\\s*\\(",
        func = "fs::read_to_string",
        arg_position = 1,
        arg_name = "path",
        description = "Rust read file to string"
      ),
      list(
        regex = "fs::read_dir\\s*\\(",
        func = "fs::read_dir",
        arg_position = 1,
        arg_name = "path",
        description = "Rust read directory"
      ),
      list(
        regex = "fs::metadata\\s*\\(",
        func = "fs::metadata",
        arg_position = 1,
        arg_name = "path",
        description = "Rust file metadata"
      ),
      # BufReader
      list(
        regex = "BufReader::new\\s*\\(",
        func = "BufReader::new",
        arg_position = 1,
        arg_name = "inner",
        description = "Rust buffered reader"
      ),
      list(
        regex = "\\.read_line\\s*\\(",
        func = "read_line",
        arg_position = 1,
        arg_name = "buf",
        description = "Rust read line"
      ),
      list(
        regex = "\\.read_to_string\\s*\\(",
        func = "read_to_string",
        arg_position = 1,
        arg_name = "buf",
        description = "Rust read to string"
      ),
      list(
        regex = "\\.read_to_end\\s*\\(",
        func = "read_to_end",
        arg_position = 1,
        arg_name = "buf",
        description = "Rust read to end"
      ),
      # serde_json
      list(
        regex = "serde_json::from_reader\\s*\\(",
        func = "serde_json::from_reader",
        arg_position = 1,
        arg_name = "rdr",
        description = "Serde JSON from reader"
      ),
      list(
        regex = "serde_json::from_str\\s*\\(",
        func = "serde_json::from_str",
        arg_position = 1,
        arg_name = "s",
        description = "Serde JSON from string"
      ),
      list(
        regex = "serde_json::from_slice\\s*\\(",
        func = "serde_json::from_slice",
        arg_position = 1,
        arg_name = "v",
        description = "Serde JSON from slice"
      ),
      # csv
      list(
        regex = "csv::Reader::from_path\\s*\\(",
        func = "csv::Reader::from_path",
        arg_position = 1,
        arg_name = "path",
        description = "Rust CSV reader"
      ),
      list(
        regex = "csv::Reader::from_reader\\s*\\(",
        func = "csv::Reader::from_reader",
        arg_position = 1,
        arg_name = "rdr",
        description = "Rust CSV from reader"
      ),
      list(
        regex = "ReaderBuilder::new\\s*\\(\\)",
        func = "ReaderBuilder::new",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust CSV reader builder"
      ),
      # Database - sqlx
      list(
        regex = "sqlx::connect\\s*\\(",
        func = "sqlx::connect",
        arg_position = 1,
        arg_name = "url",
        description = "sqlx database connect"
      ),
      list(
        regex = "Pool::connect\\s*\\(",
        func = "Pool::connect",
        arg_position = 1,
        arg_name = "url",
        description = "sqlx pool connect"
      ),
      list(
        regex = "sqlx::query\\s*\\(",
        func = "sqlx::query",
        arg_position = 1,
        arg_name = "sql",
        description = "sqlx query"
      ),
      list(
        regex = "sqlx::query_as\\s*\\(",
        func = "sqlx::query_as",
        arg_position = 1,
        arg_name = "sql",
        description = "sqlx query as type"
      ),
      list(
        regex = "\\.fetch_all\\s*\\(",
        func = "fetch_all",
        arg_position = 1,
        arg_name = "executor",
        description = "sqlx fetch all"
      ),
      list(
        regex = "\\.fetch_one\\s*\\(",
        func = "fetch_one",
        arg_position = 1,
        arg_name = "executor",
        description = "sqlx fetch one"
      ),
      # diesel
      list(
        regex = "diesel::connection\\s*\\(",
        func = "diesel::connection",
        arg_position = NA,
        arg_name = NULL,
        description = "Diesel connection"
      ),
      list(
        regex = "establish_connection\\s*\\(",
        func = "establish_connection",
        arg_position = NA,
        arg_name = NULL,
        description = "Diesel establish connection"
      ),
      list(
        regex = "\\.load\\s*::<",
        func = "load",
        arg_position = NA,
        arg_name = "conn",
        description = "Diesel load"
      ),
      # reqwest
      list(
        regex = "reqwest::get\\s*\\(",
        func = "reqwest::get",
        arg_position = 1,
        arg_name = "url",
        description = "reqwest GET"
      ),
      list(
        regex = "Client::new\\s*\\(",
        func = "Client::new",
        arg_position = NA,
        arg_name = NULL,
        description = "reqwest client"
      ),
      list(
        regex = "\\.get\\s*\\(['\"]http",
        func = "client.get",
        arg_position = 1,
        arg_name = "url",
        description = "HTTP GET request"
      ),
      # toml
      list(
        regex = "toml::from_str\\s*\\(",
        func = "toml::from_str",
        arg_position = 1,
        arg_name = "s",
        description = "TOML from string"
      ),
      # yaml
      list(
        regex = "serde_yaml::from_reader\\s*\\(",
        func = "serde_yaml::from_reader",
        arg_position = 1,
        arg_name = "rdr",
        description = "Serde YAML from reader"
      ),
      list(
        regex = "serde_yaml::from_str\\s*\\(",
        func = "serde_yaml::from_str",
        arg_position = 1,
        arg_name = "s",
        description = "Serde YAML from string"
      ),
      # env
      list(
        regex = "std::env::var\\s*\\(",
        func = "std::env::var",
        arg_position = 1,
        arg_name = "key",
        description = "Rust environment variable"
      ),
      list(
        regex = "env::var\\s*\\(",
        func = "env::var",
        arg_position = 1,
        arg_name = "key",
        description = "Rust environment variable"
      )
    ),
    output = list(
      # std::fs
      list(
        regex = "File::create\\s*\\(",
        func = "File::create",
        arg_position = 1,
        arg_name = "path",
        description = "Rust create file"
      ),
      list(
        regex = "fs::write\\s*\\(",
        func = "fs::write",
        arg_position = 1,
        arg_name = "path",
        description = "Rust write file"
      ),
      list(
        regex = "fs::copy\\s*\\(",
        func = "fs::copy",
        arg_position = 1,
        arg_name = "from",
        description = "Rust copy file"
      ),
      list(
        regex = "fs::create_dir\\s*\\(",
        func = "fs::create_dir",
        arg_position = 1,
        arg_name = "path",
        description = "Rust create directory"
      ),
      list(
        regex = "fs::create_dir_all\\s*\\(",
        func = "fs::create_dir_all",
        arg_position = 1,
        arg_name = "path",
        description = "Rust create directory recursive"
      ),
      # BufWriter
      list(
        regex = "BufWriter::new\\s*\\(",
        func = "BufWriter::new",
        arg_position = 1,
        arg_name = "inner",
        description = "Rust buffered writer"
      ),
      list(
        regex = "\\.write_all\\s*\\(",
        func = "write_all",
        arg_position = 1,
        arg_name = "buf",
        description = "Rust write all"
      ),
      list(
        regex = "writeln!\\s*\\(",
        func = "writeln!",
        arg_position = 1,
        arg_name = "dst",
        description = "Rust writeln macro"
      ),
      list(
        regex = "write!\\s*\\(",
        func = "write!",
        arg_position = 1,
        arg_name = "dst",
        description = "Rust write macro"
      ),
      # serde_json
      list(
        regex = "serde_json::to_writer\\s*\\(",
        func = "serde_json::to_writer",
        arg_position = 1,
        arg_name = "writer",
        description = "Serde JSON to writer"
      ),
      list(
        regex = "serde_json::to_string\\s*\\(",
        func = "serde_json::to_string",
        arg_position = 1,
        arg_name = "value",
        description = "Serde JSON to string"
      ),
      # csv
      list(
        regex = "csv::Writer::from_path\\s*\\(",
        func = "csv::Writer::from_path",
        arg_position = 1,
        arg_name = "path",
        description = "Rust CSV writer"
      ),
      list(
        regex = "csv::Writer::from_writer\\s*\\(",
        func = "csv::Writer::from_writer",
        arg_position = 1,
        arg_name = "wtr",
        description = "Rust CSV from writer"
      ),
      list(
        regex = "\\.write_record\\s*\\(",
        func = "write_record",
        arg_position = 1,
        arg_name = "record",
        description = "Rust CSV write record"
      ),
      list(
        regex = "\\.serialize\\s*\\(",
        func = "serialize",
        arg_position = 1,
        arg_name = "record",
        description = "Rust CSV serialize"
      ),
      # sqlx/diesel write
      list(
        regex = "sqlx::query!\\s*\\([^)]*INSERT",
        func = "sqlx::query! INSERT",
        arg_position = NA,
        arg_name = NULL,
        description = "sqlx INSERT query"
      ),
      list(
        regex = "sqlx::query!\\s*\\([^)]*UPDATE",
        func = "sqlx::query! UPDATE",
        arg_position = NA,
        arg_name = NULL,
        description = "sqlx UPDATE query"
      ),
      list(
        regex = "diesel::insert_into\\s*\\(",
        func = "diesel::insert_into",
        arg_position = 1,
        arg_name = "target",
        description = "Diesel insert"
      ),
      list(
        regex = "diesel::update\\s*\\(",
        func = "diesel::update",
        arg_position = 1,
        arg_name = "target",
        description = "Diesel update"
      ),
      # logging
      list(
        regex = "println!\\s*\\(",
        func = "println!",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust println"
      ),
      list(
        regex = "eprintln!\\s*\\(",
        func = "eprintln!",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust eprintln"
      ),
      list(
        regex = "log::info!\\s*\\(",
        func = "log::info!",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust log info"
      ),
      list(
        regex = "tracing::info!\\s*\\(",
        func = "tracing::info!",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust tracing info"
      ),
      # yaml/toml
      list(
        regex = "serde_yaml::to_writer\\s*\\(",
        func = "serde_yaml::to_writer",
        arg_position = 1,
        arg_name = "writer",
        description = "Serde YAML to writer"
      ),
      list(
        regex = "toml::to_string\\s*\\(",
        func = "toml::to_string",
        arg_position = 1,
        arg_name = "value",
        description = "TOML to string"
      )
    ),
    dependency = list(
      list(
        regex = "use\\s+[a-zA-Z_]",
        func = "use",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust use statement"
      ),
      list(
        regex = "mod\\s+[a-zA-Z_]",
        func = "mod",
        arg_position = NA,
        arg_name = NULL,
        description = "Rust module declaration"
      ),
      list(
        regex = "include!\\s*\\(",
        func = "include!",
        arg_position = 1,
        arg_name = "file",
        description = "Rust include macro"
      )
    )
  )
}

#' Get Java Detection Patterns
#' @return List of Java detection patterns
#' @keywords internal
get_java_patterns <- function() {
  list(
    input = list(
      # Classic Java I/O
      list(
        regex = "new\\s+FileInputStream\\s*\\(",
        func = "new FileInputStream",
        arg_position = 1,
        arg_name = "file",
        description = "Java FileInputStream"
      ),
      list(
        regex = "new\\s+FileReader\\s*\\(",
        func = "new FileReader",
        arg_position = 1,
        arg_name = "file",
        description = "Java FileReader"
      ),
      list(
        regex = "new\\s+BufferedReader\\s*\\(",
        func = "new BufferedReader",
        arg_position = 1,
        arg_name = "in",
        description = "Java BufferedReader"
      ),
      list(
        regex = "new\\s+Scanner\\s*\\(\\s*new\\s+File",
        func = "new Scanner(File)",
        arg_position = NA,
        arg_name = NULL,
        description = "Java Scanner from File"
      ),
      list(
        regex = "new\\s+ObjectInputStream\\s*\\(",
        func = "new ObjectInputStream",
        arg_position = 1,
        arg_name = "in",
        description = "Java ObjectInputStream"
      ),
      # Java NIO
      list(
        regex = "Files\\.readAllLines\\s*\\(",
        func = "Files.readAllLines",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO read all lines"
      ),
      list(
        regex = "Files\\.readString\\s*\\(",
        func = "Files.readString",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO read string"
      ),
      list(
        regex = "Files\\.readAllBytes\\s*\\(",
        func = "Files.readAllBytes",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO read all bytes"
      ),
      list(
        regex = "Files\\.newBufferedReader\\s*\\(",
        func = "Files.newBufferedReader",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO buffered reader"
      ),
      list(
        regex = "Files\\.newInputStream\\s*\\(",
        func = "Files.newInputStream",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO input stream"
      ),
      list(
        regex = "Files\\.lines\\s*\\(",
        func = "Files.lines",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO lines stream"
      ),
      list(
        regex = "Files\\.list\\s*\\(",
        func = "Files.list",
        arg_position = 1,
        arg_name = "dir",
        description = "Java NIO list directory"
      ),
      # JDBC
      list(
        regex = "DriverManager\\.getConnection\\s*\\(",
        func = "DriverManager.getConnection",
        arg_position = 1,
        arg_name = "url",
        description = "JDBC connection"
      ),
      list(
        regex = "\\.executeQuery\\s*\\(",
        func = "statement.executeQuery",
        arg_position = 1,
        arg_name = "sql",
        description = "JDBC execute query"
      ),
      list(
        regex = "resultSet\\.get",
        func = "resultSet.get",
        arg_position = NA,
        arg_name = NULL,
        description = "JDBC ResultSet getter"
      ),
      list(
        regex = "\\.prepareStatement\\s*\\(",
        func = "connection.prepareStatement",
        arg_position = 1,
        arg_name = "sql",
        description = "JDBC prepared statement"
      ),
      # Jackson
      list(
        regex = "objectMapper\\.readValue\\s*\\(",
        func = "objectMapper.readValue",
        arg_position = 1,
        arg_name = "src",
        description = "Jackson read JSON"
      ),
      list(
        regex = "new\\s+ObjectMapper\\s*\\(",
        func = "new ObjectMapper",
        arg_position = NA,
        arg_name = NULL,
        description = "Jackson ObjectMapper"
      ),
      list(
        regex = "JsonParser",
        func = "JsonParser",
        arg_position = NA,
        arg_name = NULL,
        description = "Jackson JSON parser"
      ),
      # Spring Boot
      list(
        regex = "@RequestBody",
        func = "@RequestBody",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring request body"
      ),
      list(
        regex = "@RequestParam",
        func = "@RequestParam",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring request parameter"
      ),
      list(
        regex = "@PathVariable",
        func = "@PathVariable",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring path variable"
      ),
      list(
        regex = "MultipartFile",
        func = "MultipartFile",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring file upload"
      ),
      list(
        regex = "@RequestPart",
        func = "@RequestPart",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring multipart request"
      ),
      # Spring Data JPA
      list(
        regex = "repository\\.findById\\s*\\(",
        func = "repository.findById",
        arg_position = 1,
        arg_name = "id",
        description = "Spring Data find by ID"
      ),
      list(
        regex = "repository\\.findAll\\s*\\(",
        func = "repository.findAll",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring Data find all"
      ),
      list(
        regex = "repository\\.findBy",
        func = "repository.findBy",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring Data find by"
      ),
      list(
        regex = "JpaRepository",
        func = "JpaRepository",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring JpaRepository"
      ),
      list(
        regex = "CrudRepository",
        func = "CrudRepository",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring CrudRepository"
      ),
      # Hibernate
      list(
        regex = "session\\.get\\s*\\(",
        func = "session.get",
        arg_position = 1,
        arg_name = "entityType",
        description = "Hibernate session get"
      ),
      list(
        regex = "session\\.load\\s*\\(",
        func = "session.load",
        arg_position = 1,
        arg_name = "entityType",
        description = "Hibernate session load"
      ),
      list(
        regex = "entityManager\\.find\\s*\\(",
        func = "entityManager.find",
        arg_position = 1,
        arg_name = "entityClass",
        description = "JPA EntityManager find"
      ),
      list(
        regex = "entityManager\\.createQuery\\s*\\(",
        func = "entityManager.createQuery",
        arg_position = 1,
        arg_name = "qlString",
        description = "JPA create query"
      ),
      # Properties/Config
      list(
        regex = "new\\s+Properties\\s*\\(",
        func = "new Properties",
        arg_position = NA,
        arg_name = NULL,
        description = "Java Properties"
      ),
      list(
        regex = "\\.load\\s*\\(",
        func = "properties.load",
        arg_position = 1,
        arg_name = "inStream",
        description = "Properties load"
      ),
      # Environment
      list(
        regex = "System\\.getenv\\s*\\(",
        func = "System.getenv",
        arg_position = 1,
        arg_name = "name",
        description = "Java environment variable"
      ),
      list(
        regex = "System\\.getProperty\\s*\\(",
        func = "System.getProperty",
        arg_position = 1,
        arg_name = "key",
        description = "Java system property"
      )
    ),
    output = list(
      # Classic Java I/O
      list(
        regex = "new\\s+FileOutputStream\\s*\\(",
        func = "new FileOutputStream",
        arg_position = 1,
        arg_name = "file",
        description = "Java FileOutputStream"
      ),
      list(
        regex = "new\\s+FileWriter\\s*\\(",
        func = "new FileWriter",
        arg_position = 1,
        arg_name = "file",
        description = "Java FileWriter"
      ),
      list(
        regex = "new\\s+BufferedWriter\\s*\\(",
        func = "new BufferedWriter",
        arg_position = 1,
        arg_name = "out",
        description = "Java BufferedWriter"
      ),
      list(
        regex = "new\\s+PrintWriter\\s*\\(",
        func = "new PrintWriter",
        arg_position = 1,
        arg_name = "file",
        description = "Java PrintWriter"
      ),
      list(
        regex = "new\\s+ObjectOutputStream\\s*\\(",
        func = "new ObjectOutputStream",
        arg_position = 1,
        arg_name = "out",
        description = "Java ObjectOutputStream"
      ),
      # Java NIO
      list(
        regex = "Files\\.write\\s*\\(",
        func = "Files.write",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO write"
      ),
      list(
        regex = "Files\\.writeString\\s*\\(",
        func = "Files.writeString",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO write string"
      ),
      list(
        regex = "Files\\.newBufferedWriter\\s*\\(",
        func = "Files.newBufferedWriter",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO buffered writer"
      ),
      list(
        regex = "Files\\.newOutputStream\\s*\\(",
        func = "Files.newOutputStream",
        arg_position = 1,
        arg_name = "path",
        description = "Java NIO output stream"
      ),
      list(
        regex = "Files\\.copy\\s*\\(",
        func = "Files.copy",
        arg_position = 1,
        arg_name = "source",
        description = "Java NIO copy"
      ),
      list(
        regex = "Files\\.createDirectory\\s*\\(",
        func = "Files.createDirectory",
        arg_position = 1,
        arg_name = "dir",
        description = "Java NIO create directory"
      ),
      list(
        regex = "Files\\.createDirectories\\s*\\(",
        func = "Files.createDirectories",
        arg_position = 1,
        arg_name = "dir",
        description = "Java NIO create directories"
      ),
      # JDBC
      list(
        regex = "\\.executeUpdate\\s*\\(",
        func = "statement.executeUpdate",
        arg_position = 1,
        arg_name = "sql",
        description = "JDBC execute update"
      ),
      list(
        regex = "\\.execute\\s*\\(",
        func = "statement.execute",
        arg_position = 1,
        arg_name = "sql",
        description = "JDBC execute"
      ),
      list(
        regex = "preparedStatement\\.execute",
        func = "preparedStatement.execute",
        arg_position = NA,
        arg_name = NULL,
        description = "JDBC prepared execute"
      ),
      # Jackson
      list(
        regex = "objectMapper\\.writeValue\\s*\\(",
        func = "objectMapper.writeValue",
        arg_position = 1,
        arg_name = "file",
        description = "Jackson write JSON"
      ),
      list(
        regex = "objectMapper\\.writeValueAsString\\s*\\(",
        func = "objectMapper.writeValueAsString",
        arg_position = 1,
        arg_name = "value",
        description = "Jackson write as string"
      ),
      list(
        regex = "JsonGenerator",
        func = "JsonGenerator",
        arg_position = NA,
        arg_name = NULL,
        description = "Jackson JSON generator"
      ),
      # Spring Boot responses
      list(
        regex = "ResponseEntity",
        func = "ResponseEntity",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring ResponseEntity"
      ),
      list(
        regex = "@ResponseBody",
        func = "@ResponseBody",
        arg_position = NA,
        arg_name = NULL,
        description = "Spring response body"
      ),
      list(
        regex = "ResponseEntity\\.ok\\s*\\(",
        func = "ResponseEntity.ok",
        arg_position = 1,
        arg_name = "body",
        description = "Spring OK response"
      ),
      # Spring Data JPA
      list(
        regex = "repository\\.save\\s*\\(",
        func = "repository.save",
        arg_position = 1,
        arg_name = "entity",
        description = "Spring Data save"
      ),
      list(
        regex = "repository\\.saveAll\\s*\\(",
        func = "repository.saveAll",
        arg_position = 1,
        arg_name = "entities",
        description = "Spring Data save all"
      ),
      list(
        regex = "repository\\.delete\\s*\\(",
        func = "repository.delete",
        arg_position = 1,
        arg_name = "entity",
        description = "Spring Data delete"
      ),
      # Hibernate
      list(
        regex = "session\\.save\\s*\\(",
        func = "session.save",
        arg_position = 1,
        arg_name = "object",
        description = "Hibernate save"
      ),
      list(
        regex = "session\\.update\\s*\\(",
        func = "session.update",
        arg_position = 1,
        arg_name = "object",
        description = "Hibernate update"
      ),
      list(
        regex = "session\\.persist\\s*\\(",
        func = "session.persist",
        arg_position = 1,
        arg_name = "object",
        description = "Hibernate persist"
      ),
      list(
        regex = "entityManager\\.persist\\s*\\(",
        func = "entityManager.persist",
        arg_position = 1,
        arg_name = "entity",
        description = "JPA persist"
      ),
      list(
        regex = "entityManager\\.merge\\s*\\(",
        func = "entityManager.merge",
        arg_position = 1,
        arg_name = "entity",
        description = "JPA merge"
      ),
      # Logging
      list(
        regex = "logger\\.info\\s*\\(",
        func = "logger.info",
        arg_position = 1,
        arg_name = "msg",
        description = "SLF4J info"
      ),
      list(
        regex = "log\\.info\\s*\\(",
        func = "log.info",
        arg_position = 1,
        arg_name = "msg",
        description = "Logger info"
      ),
      list(
        regex = "log\\.debug\\s*\\(",
        func = "log.debug",
        arg_position = 1,
        arg_name = "msg",
        description = "Logger debug"
      ),
      list(
        regex = "LoggerFactory\\.getLogger\\s*\\(",
        func = "LoggerFactory.getLogger",
        arg_position = 1,
        arg_name = "clazz",
        description = "SLF4J logger factory"
      ),
      list(
        regex = "System\\.out\\.println\\s*\\(",
        func = "System.out.println",
        arg_position = 1,
        arg_name = "x",
        description = "Java println"
      )
    ),
    dependency = list(
      list(
        regex = "import\\s+[a-zA-Z]",
        func = "import",
        arg_position = NA,
        arg_name = NULL,
        description = "Java import statement"
      ),
      list(
        regex = "package\\s+[a-zA-Z]",
        func = "package",
        arg_position = NA,
        arg_name = NULL,
        description = "Java package declaration"
      )
    )
  )
}

#' Get C Detection Patterns
#' @return List of C detection patterns
#' @keywords internal
get_c_patterns <- function() {
  list(
    input = list(
      # stdio.h
      list(
        regex = "fopen\\s*\\([^)]*['\"]r",
        func = "fopen",
        arg_position = 1,
        arg_name = "filename",
        description = "C file open (read)"
      ),
      list(
        regex = "fread\\s*\\(",
        func = "fread",
        arg_position = 4,
        arg_name = "stream",
        description = "C file read"
      ),
      list(
        regex = "fgets\\s*\\(",
        func = "fgets",
        arg_position = 3,
        arg_name = "stream",
        description = "C get string from file"
      ),
      list(
        regex = "fscanf\\s*\\(",
        func = "fscanf",
        arg_position = 1,
        arg_name = "stream",
        description = "C formatted scan from file"
      ),
      list(
        regex = "fgetc\\s*\\(",
        func = "fgetc",
        arg_position = 1,
        arg_name = "stream",
        description = "C get character from file"
      ),
      list(
        regex = "getc\\s*\\(",
        func = "getc",
        arg_position = 1,
        arg_name = "stream",
        description = "C get character"
      ),
      # unistd.h / fcntl.h (POSIX)
      list(
        regex = "open\\s*\\([^)]*O_RDONLY",
        func = "open",
        arg_position = 1,
        arg_name = "pathname",
        description = "POSIX file open (read)"
      ),
      list(
        regex = "read\\s*\\(",
        func = "read",
        arg_position = 1,
        arg_name = "fd",
        description = "POSIX read"
      ),
      # Environment
      list(
        regex = "getenv\\s*\\(",
        func = "getenv",
        arg_position = 1,
        arg_name = "name",
        description = "C get environment variable"
      ),
      # Memory-mapped files
      list(
        regex = "mmap\\s*\\(",
        func = "mmap",
        arg_position = NA,
        arg_name = NULL,
        description = "C memory map"
      ),
      # Directory reading
      list(
        regex = "opendir\\s*\\(",
        func = "opendir",
        arg_position = 1,
        arg_name = "name",
        description = "C open directory"
      ),
      list(
        regex = "readdir\\s*\\(",
        func = "readdir",
        arg_position = 1,
        arg_name = "dirp",
        description = "C read directory"
      )
    ),
    output = list(
      # stdio.h
      list(
        regex = "fopen\\s*\\([^)]*['\"]w",
        func = "fopen",
        arg_position = 1,
        arg_name = "filename",
        description = "C file open (write)"
      ),
      list(
        regex = "fopen\\s*\\([^)]*['\"]a",
        func = "fopen",
        arg_position = 1,
        arg_name = "filename",
        description = "C file open (append)"
      ),
      list(
        regex = "fwrite\\s*\\(",
        func = "fwrite",
        arg_position = 4,
        arg_name = "stream",
        description = "C file write"
      ),
      list(
        regex = "fputs\\s*\\(",
        func = "fputs",
        arg_position = 2,
        arg_name = "stream",
        description = "C put string to file"
      ),
      list(
        regex = "fprintf\\s*\\(",
        func = "fprintf",
        arg_position = 1,
        arg_name = "stream",
        description = "C formatted print to file"
      ),
      list(
        regex = "fputc\\s*\\(",
        func = "fputc",
        arg_position = 2,
        arg_name = "stream",
        description = "C put character to file"
      ),
      list(
        regex = "putc\\s*\\(",
        func = "putc",
        arg_position = 2,
        arg_name = "stream",
        description = "C put character"
      ),
      # unistd.h (POSIX)
      list(
        regex = "open\\s*\\([^)]*O_WRONLY|open\\s*\\([^)]*O_CREAT",
        func = "open",
        arg_position = 1,
        arg_name = "pathname",
        description = "POSIX file open (write)"
      ),
      list(
        regex = "write\\s*\\(",
        func = "write",
        arg_position = 1,
        arg_name = "fd",
        description = "POSIX write"
      ),
      # Standard output
      list(
        regex = "printf\\s*\\(",
        func = "printf",
        arg_position = 1,
        arg_name = "format",
        description = "C printf"
      ),
      list(
        regex = "puts\\s*\\(",
        func = "puts",
        arg_position = 1,
        arg_name = "s",
        description = "C puts"
      )
    ),
    dependency = list(
      list(
        regex = "#include\\s*[<\"]",
        func = "#include",
        arg_position = NA,
        arg_name = NULL,
        description = "C include directive"
      )
    )
  )
}

#' Get C++ Detection Patterns
#' @return List of C++ detection patterns
#' @keywords internal
get_cpp_patterns <- function() {
  # Start with C patterns as base
  c_patterns <- get_c_patterns()

  cpp_input <- c(c_patterns$input, list(
    # fstream
    list(
      regex = "std::ifstream|ifstream",
      func = "ifstream",
      arg_position = 1,
      arg_name = "filename",
      description = "C++ input file stream"
    ),
    list(
      regex = "std::fstream.*std::ios::in|fstream.*ios::in",
      func = "fstream",
      arg_position = 1,
      arg_name = "filename",
      description = "C++ file stream (input)"
    ),
    # istream operations
    list(
      regex = "std::getline\\s*\\(",
      func = "std::getline",
      arg_position = 1,
      arg_name = "is",
      description = "C++ getline"
    ),
    list(
      regex = "std::cin\\s*>>",
      func = "std::cin",
      arg_position = NA,
      arg_name = NULL,
      description = "C++ standard input"
    ),
    list(
      regex = ">>\\s*[a-zA-Z_]",
      func = "operator>>",
      arg_position = NA,
      arg_name = NULL,
      description = "C++ stream extraction"
    ),
    # boost::filesystem
    list(
      regex = "boost::filesystem::ifstream",
      func = "boost::filesystem::ifstream",
      arg_position = 1,
      arg_name = "path",
      description = "Boost input file stream"
    ),
    list(
      regex = "std::filesystem::directory_iterator",
      func = "std::filesystem::directory_iterator",
      arg_position = 1,
      arg_name = "path",
      description = "C++17 directory iterator"
    ),
    # stringstream
    list(
      regex = "std::istringstream|istringstream",
      func = "istringstream",
      arg_position = 1,
      arg_name = "str",
      description = "C++ input string stream"
    ),
    list(
      regex = "std::stringstream|stringstream",
      func = "stringstream",
      arg_position = 1,
      arg_name = "str",
      description = "C++ string stream"
    )
  ))

  cpp_output <- c(c_patterns$output, list(
    # fstream
    list(
      regex = "std::ofstream|ofstream",
      func = "ofstream",
      arg_position = 1,
      arg_name = "filename",
      description = "C++ output file stream"
    ),
    list(
      regex = "std::fstream.*std::ios::out|fstream.*ios::out",
      func = "fstream",
      arg_position = 1,
      arg_name = "filename",
      description = "C++ file stream (output)"
    ),
    # ostream operations
    list(
      regex = "std::cout\\s*<<",
      func = "std::cout",
      arg_position = NA,
      arg_name = NULL,
      description = "C++ standard output"
    ),
    list(
      regex = "std::cerr\\s*<<",
      func = "std::cerr",
      arg_position = NA,
      arg_name = NULL,
      description = "C++ error output"
    ),
    list(
      regex = "<<\\s*std::endl",
      func = "std::endl",
      arg_position = NA,
      arg_name = NULL,
      description = "C++ endl manipulator"
    ),
    # boost::filesystem
    list(
      regex = "boost::filesystem::ofstream",
      func = "boost::filesystem::ofstream",
      arg_position = 1,
      arg_name = "path",
      description = "Boost output file stream"
    ),
    list(
      regex = "std::filesystem::create_directory",
      func = "std::filesystem::create_directory",
      arg_position = 1,
      arg_name = "path",
      description = "C++17 create directory"
    ),
    list(
      regex = "std::filesystem::copy",
      func = "std::filesystem::copy",
      arg_position = 1,
      arg_name = "from",
      description = "C++17 copy file"
    ),
    # stringstream
    list(
      regex = "std::ostringstream|ostringstream",
      func = "ostringstream",
      arg_position = NA,
      arg_name = NULL,
      description = "C++ output string stream"
    )
  ))

  list(
    input = cpp_input,
    output = cpp_output,
    dependency = c(c_patterns$dependency, list(
      list(
        regex = "using\\s+namespace\\s+",
        func = "using namespace",
        arg_position = NA,
        arg_name = NULL,
        description = "C++ using namespace"
      ),
      list(
        regex = "using\\s+[a-zA-Z_]",
        func = "using",
        arg_position = NA,
        arg_name = NULL,
        description = "C++ using declaration"
      )
    ))
  )
}

#' Get MATLAB Detection Patterns
#' @return List of MATLAB detection patterns
#' @keywords internal
get_matlab_patterns <- function() {
  list(
    input = list(
      # Data loading
      list(
        regex = "load\\s*\\(",
        func = "load",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB load data"
      ),
      list(
        regex = "importdata\\s*\\(",
        func = "importdata",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB import data"
      ),
      list(
        regex = "readtable\\s*\\(",
        func = "readtable",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB read table"
      ),
      list(
        regex = "readmatrix\\s*\\(",
        func = "readmatrix",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB read matrix"
      ),
      list(
        regex = "readcell\\s*\\(",
        func = "readcell",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB read cell array"
      ),
      # CSV/Excel
      list(
        regex = "csvread\\s*\\(",
        func = "csvread",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB CSV read"
      ),
      list(
        regex = "xlsread\\s*\\(",
        func = "xlsread",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB Excel read"
      ),
      list(
        regex = "readmatrix\\s*\\([^)]*\\.xlsx",
        func = "readmatrix",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB read Excel"
      ),
      # Text/formatted
      list(
        regex = "textscan\\s*\\(",
        func = "textscan",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB text scan"
      ),
      list(
        regex = "fscanf\\s*\\(",
        func = "fscanf",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB formatted read"
      ),
      list(
        regex = "fread\\s*\\(",
        func = "fread",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB binary read"
      ),
      list(
        regex = "fgetl\\s*\\(",
        func = "fgetl",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB get line"
      ),
      list(
        regex = "fgets\\s*\\(",
        func = "fgets",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB get string"
      ),
      # File open
      list(
        regex = "fopen\\s*\\([^)]*['\"]r",
        func = "fopen",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB file open (read)"
      ),
      # Image/Audio/Video
      list(
        regex = "imread\\s*\\(",
        func = "imread",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB read image"
      ),
      list(
        regex = "audioread\\s*\\(",
        func = "audioread",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB read audio"
      ),
      list(
        regex = "VideoReader\\s*\\(",
        func = "VideoReader",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB video reader"
      ),
      # JSON
      list(
        regex = "jsondecode\\s*\\(",
        func = "jsondecode",
        arg_position = 1,
        arg_name = "text",
        description = "MATLAB JSON decode"
      ),
      list(
        regex = "fileread\\s*\\(",
        func = "fileread",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB file read"
      ),
      # HDF5/netCDF
      list(
        regex = "h5read\\s*\\(",
        func = "h5read",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB HDF5 read"
      ),
      list(
        regex = "ncread\\s*\\(",
        func = "ncread",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB netCDF read"
      )
    ),
    output = list(
      # Data saving
      list(
        regex = "save\\s*\\(",
        func = "save",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB save data"
      ),
      list(
        regex = "writetable\\s*\\(",
        func = "writetable",
        arg_position = 2,
        arg_name = "filename",
        description = "MATLAB write table"
      ),
      list(
        regex = "writematrix\\s*\\(",
        func = "writematrix",
        arg_position = 2,
        arg_name = "filename",
        description = "MATLAB write matrix"
      ),
      list(
        regex = "writecell\\s*\\(",
        func = "writecell",
        arg_position = 2,
        arg_name = "filename",
        description = "MATLAB write cell array"
      ),
      # CSV/Excel
      list(
        regex = "csvwrite\\s*\\(",
        func = "csvwrite",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB CSV write"
      ),
      list(
        regex = "xlswrite\\s*\\(",
        func = "xlswrite",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB Excel write"
      ),
      # Text/formatted
      list(
        regex = "fprintf\\s*\\(",
        func = "fprintf",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB formatted write"
      ),
      list(
        regex = "fwrite\\s*\\(",
        func = "fwrite",
        arg_position = 1,
        arg_name = "fileID",
        description = "MATLAB binary write"
      ),
      # File open
      list(
        regex = "fopen\\s*\\([^)]*['\"]w",
        func = "fopen",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB file open (write)"
      ),
      list(
        regex = "fopen\\s*\\([^)]*['\"]a",
        func = "fopen",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB file open (append)"
      ),
      # Image/Audio/Video
      list(
        regex = "imwrite\\s*\\(",
        func = "imwrite",
        arg_position = 2,
        arg_name = "filename",
        description = "MATLAB write image"
      ),
      list(
        regex = "audiowrite\\s*\\(",
        func = "audiowrite",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB write audio"
      ),
      list(
        regex = "VideoWriter\\s*\\(",
        func = "VideoWriter",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB video writer"
      ),
      # Graphics
      list(
        regex = "print\\s*\\(",
        func = "print",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB print figure"
      ),
      list(
        regex = "saveas\\s*\\(",
        func = "saveas",
        arg_position = 2,
        arg_name = "filename",
        description = "MATLAB save as"
      ),
      list(
        regex = "savefig\\s*\\(",
        func = "savefig",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB save figure"
      ),
      list(
        regex = "exportgraphics\\s*\\(",
        func = "exportgraphics",
        arg_position = 2,
        arg_name = "filename",
        description = "MATLAB export graphics"
      ),
      # JSON
      list(
        regex = "jsonencode\\s*\\(",
        func = "jsonencode",
        arg_position = 1,
        arg_name = "data",
        description = "MATLAB JSON encode"
      ),
      # HDF5/netCDF
      list(
        regex = "h5write\\s*\\(",
        func = "h5write",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB HDF5 write"
      ),
      list(
        regex = "ncwrite\\s*\\(",
        func = "ncwrite",
        arg_position = 1,
        arg_name = "filename",
        description = "MATLAB netCDF write"
      ),
      # Display
      list(
        regex = "disp\\s*\\(",
        func = "disp",
        arg_position = 1,
        arg_name = "X",
        description = "MATLAB display"
      )
    ),
    dependency = list(
      list(
        regex = "run\\s*\\(",
        func = "run",
        arg_position = 1,
        arg_name = "script",
        description = "MATLAB run script"
      ),
      list(
        regex = "addpath\\s*\\(",
        func = "addpath",
        arg_position = 1,
        arg_name = "folderName",
        description = "MATLAB add path"
      )
    )
  )
}

#' Get Ruby Detection Patterns
#' @return List of Ruby detection patterns
#' @keywords internal
get_ruby_patterns <- function() {
  list(
    input = list(
      # Core File operations
      list(
        regex = "File\\.read\\s*\\(",
        func = "File.read",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby file read"
      ),
      list(
        regex = "File\\.open\\s*\\([^)]*['\"]r",
        func = "File.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Ruby file open (read)"
      ),
      list(
        regex = "File\\.readlines\\s*\\(",
        func = "File.readlines",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby read lines"
      ),
      list(
        regex = "File\\.foreach\\s*\\(",
        func = "File.foreach",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby iterate lines"
      ),
      list(
        regex = "File\\.binread\\s*\\(",
        func = "File.binread",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby binary read"
      ),
      # IO operations
      list(
        regex = "IO\\.read\\s*\\(",
        func = "IO.read",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby IO read"
      ),
      list(
        regex = "IO\\.readlines\\s*\\(",
        func = "IO.readlines",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby IO readlines"
      ),
      list(
        regex = "IO\\.foreach\\s*\\(",
        func = "IO.foreach",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby IO foreach"
      ),
      # CSV
      list(
        regex = "CSV\\.read\\s*\\(",
        func = "CSV.read",
        arg_position = 1,
        arg_name = "path",
        description = "Ruby CSV read"
      ),
      list(
        regex = "CSV\\.foreach\\s*\\(",
        func = "CSV.foreach",
        arg_position = 1,
        arg_name = "path",
        description = "Ruby CSV foreach"
      ),
      list(
        regex = "CSV\\.parse\\s*\\(",
        func = "CSV.parse",
        arg_position = 1,
        arg_name = "str",
        description = "Ruby CSV parse"
      ),
      # JSON
      list(
        regex = "JSON\\.parse\\s*\\(",
        func = "JSON.parse",
        arg_position = 1,
        arg_name = "source",
        description = "Ruby JSON parse"
      ),
      list(
        regex = "JSON\\.load\\s*\\(",
        func = "JSON.load",
        arg_position = 1,
        arg_name = "source",
        description = "Ruby JSON load"
      ),
      # YAML
      list(
        regex = "YAML\\.load_file\\s*\\(",
        func = "YAML.load_file",
        arg_position = 1,
        arg_name = "filename",
        description = "Ruby YAML load file"
      ),
      list(
        regex = "YAML\\.safe_load\\s*\\(",
        func = "YAML.safe_load",
        arg_position = 1,
        arg_name = "yaml",
        description = "Ruby YAML safe load"
      ),
      # Marshal
      list(
        regex = "Marshal\\.load\\s*\\(",
        func = "Marshal.load",
        arg_position = 1,
        arg_name = "source",
        description = "Ruby Marshal load"
      ),
      # Database - ActiveRecord
      list(
        regex = "ActiveRecord::Base\\.establish_connection",
        func = "ActiveRecord::Base.establish_connection",
        arg_position = 1,
        arg_name = "config",
        description = "ActiveRecord connection"
      ),
      list(
        regex = "\\.find\\s*\\(",
        func = "Model.find",
        arg_position = 1,
        arg_name = "id",
        description = "ActiveRecord find"
      ),
      list(
        regex = "\\.find_by\\s*\\(",
        func = "Model.find_by",
        arg_position = NA,
        arg_name = "arg",
        description = "ActiveRecord find_by"
      ),
      list(
        regex = "\\.where\\s*\\(",
        func = "Model.where",
        arg_position = 1,
        arg_name = "opts",
        description = "ActiveRecord where"
      ),
      list(
        regex = "\\.all\\b",
        func = "Model.all",
        arg_position = NA,
        arg_name = NULL,
        description = "ActiveRecord all"
      ),
      list(
        regex = "\\.first\\b",
        func = "Model.first",
        arg_position = NA,
        arg_name = NULL,
        description = "ActiveRecord first"
      ),
      # Sequel
      list(
        regex = "Sequel\\.connect\\s*\\(",
        func = "Sequel.connect",
        arg_position = 1,
        arg_name = "url",
        description = "Sequel database connection"
      ),
      # pg (PostgreSQL)
      list(
        regex = "PG\\.connect\\s*\\(",
        func = "PG.connect",
        arg_position = NA,
        arg_name = "options",
        description = "Ruby PostgreSQL connection"
      ),
      # mysql2
      list(
        regex = "Mysql2::Client\\.new\\s*\\(",
        func = "Mysql2::Client.new",
        arg_position = NA,
        arg_name = "options",
        description = "Ruby MySQL connection"
      ),
      # Rails params
      list(
        regex = "params\\[:",
        func = "params[]",
        arg_position = NA,
        arg_name = "key",
        description = "Rails params"
      ),
      # Rails ActiveStorage
      list(
        regex = "blob\\.download",
        func = "blob.download",
        arg_position = NA,
        arg_name = NULL,
        description = "Rails ActiveStorage download"
      ),
      list(
        regex = "\\.attachment\\.download",
        func = "attachment.download",
        arg_position = NA,
        arg_name = NULL,
        description = "Rails attachment download"
      ),
      # HTTP clients
      list(
        regex = "Net::HTTP\\.get\\s*\\(",
        func = "Net::HTTP.get",
        arg_position = 1,
        arg_name = "uri",
        description = "Ruby HTTP GET"
      ),
      list(
        regex = "Faraday\\.get\\s*\\(",
        func = "Faraday.get",
        arg_position = 1,
        arg_name = "url",
        description = "Faraday GET"
      ),
      list(
        regex = "HTTParty\\.get\\s*\\(",
        func = "HTTParty.get",
        arg_position = 1,
        arg_name = "path",
        description = "HTTParty GET"
      ),
      list(
        regex = "RestClient\\.get\\s*\\(",
        func = "RestClient.get",
        arg_position = 1,
        arg_name = "url",
        description = "RestClient GET"
      )
    ),
    output = list(
      # Core File operations
      list(
        regex = "File\\.write\\s*\\(",
        func = "File.write",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby file write"
      ),
      list(
        regex = "File\\.open\\s*\\([^)]*['\"]w",
        func = "File.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Ruby file open (write)"
      ),
      list(
        regex = "File\\.open\\s*\\([^)]*['\"]a",
        func = "File.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Ruby file open (append)"
      ),
      list(
        regex = "File\\.binwrite\\s*\\(",
        func = "File.binwrite",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby binary write"
      ),
      # IO operations
      list(
        regex = "IO\\.write\\s*\\(",
        func = "IO.write",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby IO write"
      ),
      list(
        regex = "IO\\.binwrite\\s*\\(",
        func = "IO.binwrite",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby IO binwrite"
      ),
      # CSV
      list(
        regex = "CSV\\.open\\s*\\(",
        func = "CSV.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Ruby CSV open"
      ),
      list(
        regex = "CSV\\.generate\\s*",
        func = "CSV.generate",
        arg_position = NA,
        arg_name = NULL,
        description = "Ruby CSV generate"
      ),
      # JSON
      list(
        regex = "JSON\\.generate\\s*\\(",
        func = "JSON.generate",
        arg_position = 1,
        arg_name = "obj",
        description = "Ruby JSON generate"
      ),
      list(
        regex = "\\.to_json",
        func = "to_json",
        arg_position = NA,
        arg_name = NULL,
        description = "Ruby to JSON"
      ),
      # YAML
      list(
        regex = "YAML\\.dump\\s*\\(",
        func = "YAML.dump",
        arg_position = 1,
        arg_name = "obj",
        description = "Ruby YAML dump"
      ),
      list(
        regex = "\\.to_yaml",
        func = "to_yaml",
        arg_position = NA,
        arg_name = NULL,
        description = "Ruby to YAML"
      ),
      # Marshal
      list(
        regex = "Marshal\\.dump\\s*\\(",
        func = "Marshal.dump",
        arg_position = 1,
        arg_name = "obj",
        description = "Ruby Marshal dump"
      ),
      # Rails responses
      list(
        regex = "render\\s+json:",
        func = "render json:",
        arg_position = NA,
        arg_name = NULL,
        description = "Rails render JSON"
      ),
      list(
        regex = "render\\s+xml:",
        func = "render xml:",
        arg_position = NA,
        arg_name = NULL,
        description = "Rails render XML"
      ),
      list(
        regex = "send_data\\s*",
        func = "send_data",
        arg_position = 1,
        arg_name = "data",
        description = "Rails send data"
      ),
      list(
        regex = "send_file\\s*",
        func = "send_file",
        arg_position = 1,
        arg_name = "path",
        description = "Rails send file"
      ),
      # Rails ActiveStorage
      list(
        regex = "\\.attach\\s*\\(",
        func = "attach",
        arg_position = NA,
        arg_name = NULL,
        description = "Rails ActiveStorage attach"
      ),
      # ActiveRecord write
      list(
        regex = "\\.create\\s*\\(",
        func = "Model.create",
        arg_position = NA,
        arg_name = "attributes",
        description = "ActiveRecord create"
      ),
      list(
        regex = "\\.create!\\s*\\(",
        func = "Model.create!",
        arg_position = NA,
        arg_name = "attributes",
        description = "ActiveRecord create!"
      ),
      list(
        regex = "\\.save\\b",
        func = "model.save",
        arg_position = NA,
        arg_name = NULL,
        description = "ActiveRecord save"
      ),
      list(
        regex = "\\.save!\\b",
        func = "model.save!",
        arg_position = NA,
        arg_name = NULL,
        description = "ActiveRecord save!"
      ),
      list(
        regex = "\\.update\\s*\\(",
        func = "model.update",
        arg_position = NA,
        arg_name = "attributes",
        description = "ActiveRecord update"
      ),
      list(
        regex = "\\.destroy\\b",
        func = "model.destroy",
        arg_position = NA,
        arg_name = NULL,
        description = "ActiveRecord destroy"
      ),
      # Logging
      list(
        regex = "Rails\\.logger",
        func = "Rails.logger",
        arg_position = NA,
        arg_name = NULL,
        description = "Rails logger"
      ),
      list(
        regex = "Logger\\.new\\s*\\(",
        func = "Logger.new",
        arg_position = 1,
        arg_name = "logdev",
        description = "Ruby Logger"
      ),
      list(
        regex = "puts\\s+",
        func = "puts",
        arg_position = 1,
        arg_name = "obj",
        description = "Ruby puts"
      ),
      list(
        regex = "print\\s+",
        func = "print",
        arg_position = 1,
        arg_name = "obj",
        description = "Ruby print"
      )
    ),
    dependency = list(
      list(
        regex = "require\\s+['\"]",
        func = "require",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby require"
      ),
      list(
        regex = "require_relative\\s+['\"]",
        func = "require_relative",
        arg_position = 1,
        arg_name = "name",
        description = "Ruby require_relative"
      ),
      list(
        regex = "load\\s+['\"]",
        func = "load",
        arg_position = 1,
        arg_name = "filename",
        description = "Ruby load"
      ),
      list(
        regex = "autoload\\s+:",
        func = "autoload",
        arg_position = NA,
        arg_name = NULL,
        description = "Ruby autoload"
      )
    )
  )
}

#' Get Lua Detection Patterns
#' @return List of Lua detection patterns
#' @keywords internal
get_lua_patterns <- function() {
  list(
    input = list(
      # io library
      list(
        regex = "io\\.open\\s*\\([^)]*['\"]r",
        func = "io.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua file open (read)"
      ),
      list(
        regex = "io\\.input\\s*\\(",
        func = "io.input",
        arg_position = 1,
        arg_name = "file",
        description = "Lua set input file"
      ),
      list(
        regex = "io\\.read\\s*\\(",
        func = "io.read",
        arg_position = NA,
        arg_name = "format",
        description = "Lua read"
      ),
      list(
        regex = "io\\.lines\\s*\\(",
        func = "io.lines",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua iterate lines"
      ),
      list(
        regex = "file:read\\s*\\(",
        func = "file:read",
        arg_position = NA,
        arg_name = "format",
        description = "Lua file read method"
      ),
      list(
        regex = "file:lines\\s*\\(",
        func = "file:lines",
        arg_position = NA,
        arg_name = NULL,
        description = "Lua file lines method"
      ),
      # Loading scripts
      list(
        regex = "loadfile\\s*\\(",
        func = "loadfile",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua load file"
      ),
      list(
        regex = "dofile\\s*\\(",
        func = "dofile",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua do file"
      ),
      # Environment
      list(
        regex = "os\\.getenv\\s*\\(",
        func = "os.getenv",
        arg_position = 1,
        arg_name = "varname",
        description = "Lua environment variable"
      )
    ),
    output = list(
      # io library
      list(
        regex = "io\\.open\\s*\\([^)]*['\"]w",
        func = "io.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua file open (write)"
      ),
      list(
        regex = "io\\.open\\s*\\([^)]*['\"]a",
        func = "io.open",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua file open (append)"
      ),
      list(
        regex = "io\\.output\\s*\\(",
        func = "io.output",
        arg_position = 1,
        arg_name = "file",
        description = "Lua set output file"
      ),
      list(
        regex = "io\\.write\\s*\\(",
        func = "io.write",
        arg_position = NA,
        arg_name = NULL,
        description = "Lua write"
      ),
      list(
        regex = "file:write\\s*\\(",
        func = "file:write",
        arg_position = NA,
        arg_name = NULL,
        description = "Lua file write method"
      ),
      list(
        regex = "file:flush\\s*\\(",
        func = "file:flush",
        arg_position = NA,
        arg_name = NULL,
        description = "Lua file flush"
      ),
      # Print
      list(
        regex = "print\\s*\\(",
        func = "print",
        arg_position = NA,
        arg_name = NULL,
        description = "Lua print"
      ),
      list(
        regex = "io\\.stderr:write\\s*\\(",
        func = "io.stderr:write",
        arg_position = NA,
        arg_name = NULL,
        description = "Lua stderr write"
      )
    ),
    dependency = list(
      list(
        regex = "require\\s*['\"]",
        func = "require",
        arg_position = 1,
        arg_name = "modname",
        description = "Lua require"
      ),
      list(
        regex = "dofile\\s*\\(",
        func = "dofile",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua dofile"
      ),
      list(
        regex = "loadfile\\s*\\(",
        func = "loadfile",
        arg_position = 1,
        arg_name = "filename",
        description = "Lua loadfile"
      )
    )
  )
}

# NOTE: list_supported_languages() has been moved to R/language_registry.R
# It now supports a detection_only parameter to distinguish between:
# - Languages with full auto-detection support
# - Languages with annotation parsing only
