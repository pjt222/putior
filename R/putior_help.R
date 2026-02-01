#' Quick Reference Help for putior
#'
#' Provides quick-reference help for common putior tasks and syntax.
#' Call without arguments to see available topics.
#'
#' @param topic Character string specifying the help topic. Options:
#'   \itemize{
#'     \item NULL (default) - Show available topics
#'     \item "annotation" or "annotations" - Show annotation syntax reference
#'     \item "themes" - Show available diagram themes
#'     \item "languages" - Show supported languages and comment prefixes
#'     \item "node_types" - Show available node types
#'     \item "patterns" - Show how to use detection patterns
#'     \item "examples" - Show quick examples
#'     \item "skills" - Show AI assistant skills reference
#'   }
#'
#' @return Invisibly returns NULL. Prints help content to the console.
#'
#' @export
#'
#' @examples
#' # Show available topics
#' putior_help()
#'
#' # Show annotation syntax
#' putior_help("annotation")
#'
#' # Show supported languages
#' putior_help("languages")
#'
#' # Show available themes
#' putior_help("themes")
#'
#' # Show node types
#' putior_help("node_types")
#'
#' # Show detection patterns info
#' putior_help("patterns")
#'
#' # Show quick examples
#' putior_help("examples")
#'
#' # Show AI assistant skills reference
#' putior_help("skills")
putior_help <- function(topic = NULL) {
  if (is.null(topic)) {
    show_help_topics()
  } else {
    topic <- tolower(trimws(topic))

    switch(topic,
      "annotation" = ,
      "annotations" = show_annotation_help(),
      "themes" = show_themes_help(),
      "languages" = ,
      "language" = show_languages_help(),
      "node_types" = ,
      "node_type" = ,
      "nodes" = show_node_types_help(),
      "patterns" = ,
      "pattern" = ,
      "detection" = show_patterns_help(),
      "examples" = ,
      "example" = show_examples_help(),
      "skills" = ,
      "skill" = show_skills_summary(),
      {
        cat("Unknown topic: '", topic, "'\n\n", sep = "")
        show_help_topics()
      }
    )
  }

  invisible(NULL)
}

#' Show available help topics
#' @noRd
show_help_topics <- function() {
  cat("\n")
  cat("=== putior Quick Reference ===\n")
  cat("\n")
  cat("Available topics:\n")
  cat("\n")
  cat("  putior_help(\"annotation\")   - PUT annotation syntax reference\n")
  cat("  putior_help(\"themes\")       - Available diagram themes\n")
  cat("  putior_help(\"languages\")    - Supported languages & comment prefixes\n")
  cat("  putior_help(\"node_types\")   - Available node types for styling\n")
  cat("  putior_help(\"patterns\")     - Auto-detection patterns\n")
  cat("  putior_help(\"examples\")     - Quick usage examples\n")
  cat("  putior_help(\"skills\")       - AI assistant skills reference\n")
  cat("\n")
  cat("For full documentation, see: ?put, ?put_diagram, ?put_auto\n")
  cat("\n")
}

#' Show annotation syntax help
#' @noRd
show_annotation_help <- function() {
  cat("\n")
  cat("=== PUT Annotation Syntax ===\n")
  cat("\n")
  cat("SINGLE-LINE FORMAT:\n")
  cat("  #put id:\"node_id\", label:\"Description\", node_type:\"process\"\n")
  cat("\n")
  cat("MULTILINE FORMAT (use backslash for continuation):\n")
  cat("  #put id:\"node_id\", label:\"Description\", \\\n")
  cat("  #    input:\"data.csv\", \\\n")
  cat("  #    output:\"result.csv\"\n")
  cat("\n")
  cat("AVAILABLE PROPERTIES:\n")
  cat("  id          - Unique node identifier (auto-generated if omitted)\n")
  cat("  label       - Human-readable description (shown in diagram)\n")
  cat("  node_type   - Node styling: input, process, output, decision, start, end\n")
  cat("  input       - Input files (comma-separated for multiple)\n")
  cat("  output      - Output files (comma-separated for multiple)\n")
  cat("\n")
  cat("INPUT/OUTPUT SYNTAX:\n")
  cat("  Single file:    input:\"data.csv\"\n")
  cat("  Multiple files: input:\"data1.csv, data2.csv, data3.csv\"\n")
  cat("  Internal var:   output:\"my_var.internal\"  (in-memory, not saved)\n")
  cat("\n")
  cat("COMMENT PREFIX BY LANGUAGE:\n")
  cat("  R/Python:   #put id:\"x\", label:\"y\"\n")
  cat("  SQL:        --put id:\"x\", label:\"y\"\n")
  cat("  JavaScript: //put id:\"x\", label:\"y\"\n")
  cat("  MATLAB:     %put id:\"x\", label:\"y\"\n")
  cat("\n")
}

#' Show themes help
#' @noRd
show_themes_help <- function() {
  cat("\n")
  cat("=== Available Diagram Themes ===\n")
  cat("\n")
  cat("Use with: put_diagram(workflow, theme = \"theme_name\")\n")
  cat("\n")

  themes <- get_diagram_themes()

  for (theme_name in names(themes)) {
    cat("  ", format(theme_name, width = 10), " - ", themes[[theme_name]], "\n", sep = "")
  }

  cat("\n")
  cat("Example:\n")
  cat("  workflow <- put(\"./src/\")\n")
  cat("  put_diagram(workflow, theme = \"github\")\n")
  cat("\n")
}

#' Show languages help
#' @noRd
show_languages_help <- function() {
  cat("\n")
  cat("=== Supported Languages ===\n")
  cat("\n")
  cat("putior supports 30+ programming languages with automatic comment detection.\n")
  cat("\n")
  cat("COMMENT PREFIXES:\n")
  cat("\n")
  cat("  #   (hash)    R, Python, Shell, Julia, Ruby, Perl, YAML, TOML\n")
  cat("                Extensions: .R, .py, .sh, .bash, .jl, .rb, .pl, .yaml, .yml, .toml\n")
  cat("\n")
  cat("  --  (dash)    SQL, Lua, Haskell\n")
  cat("                Extensions: .sql, .lua, .hs\n")
  cat("\n")
  cat("  //  (slash)   JavaScript, TypeScript, C, C++, Java, Go, Rust, Swift,\n")
  cat("                Kotlin, C#, PHP, Scala, Groovy, D\n")
  cat("                Extensions: .js, .ts, .jsx, .tsx, .c, .cpp, .h, .hpp,\n")
  cat("                            .java, .go, .rs, .swift, .kt, .cs, .php, .scala\n")
  cat("\n")
  cat("  %   (percent) MATLAB, LaTeX\n")
  cat("                Extensions: .m, .tex\n")
  cat("\n")
  cat("HELPER FUNCTIONS:\n")
  cat("  get_comment_prefix(\"sql\")     # Returns \"--\"\n")
  cat("  get_supported_extensions()    # All supported extensions\n")
  cat("  list_supported_languages()    # All supported languages\n")
  cat("\n")
}

#' Show node types help
#' @noRd
show_node_types_help <- function() {
  cat("\n")
  cat("=== Available Node Types ===\n")
  cat("\n")
  cat("Use with: #put id:\"x\", label:\"y\", node_type:\"type\"\n")
  cat("\n")
  cat("TYPE        SHAPE           TYPICAL USE\n")
  cat("----------- --------------- ----------------------------------\n")
  cat("input       ([ stadium ])   Data sources, API inputs\n")
  cat("process     [ rectangle ]   Data processing, transformations\n")
  cat("output      [[ subroutine ]]  Final outputs, exports\n")
  cat("decision    { diamond }     Conditional branching\n")
  cat("start       ([ stadium ])   Workflow entry point (special styling)\n")
  cat("end         ([ stadium ])   Workflow exit point (special styling)\n")
  cat("artifact    [( cylinder )]  Data files (auto-created with show_artifacts)\n")
  cat("\n")
  cat("WORKFLOW BOUNDARIES:\n")
  cat("  Use node_type:\"start\" and node_type:\"end\" to mark workflow entry/exit.\n")
  cat("  Enable special styling with: put_diagram(workflow, show_workflow_boundaries = TRUE)\n")
  cat("\n")
  cat("Example:\n")
  cat("  #put id:\"begin\", label:\"Start Pipeline\", node_type:\"start\"\n")
  cat("  #put id:\"load\", label:\"Load Data\", node_type:\"input\", output:\"raw.csv\"\n")
  cat("  #put id:\"done\", label:\"Complete\", node_type:\"end\", input:\"final.csv\"\n")
  cat("\n")
}

#' Show patterns help
#' @noRd
show_patterns_help <- function() {
  cat("\n")
  cat("=== Detection Patterns for Auto-Annotation ===\n")
  cat("\n")
  cat("putior can automatically detect inputs and outputs from code analysis.\n")
  cat("\n")
  cat("LANGUAGES WITH AUTO-DETECTION:\n")

  detection_langs <- list_supported_languages(detection_only = TRUE)
  cat("  ", paste(detection_langs, collapse = ", "), "\n")

  cat("\n")
  cat("PATTERN TYPES:\n")
  cat("  input      - Functions that read data (read_csv, pd.read_excel, etc.)\n")
  cat("  output     - Functions that write data (write.csv, ggsave, etc.)\n")
  cat("  dependency - Functions that source other scripts (source(), etc.)\n")
  cat("\n")
  cat("USAGE:\n")
  cat("  # View patterns for a language\n")
  cat("  get_detection_patterns(\"r\")\n")
  cat("  get_detection_patterns(\"python\", type = \"input\")\n")
  cat("\n")
  cat("  # Auto-detect workflow from code (no annotations needed)\n")
  cat("  workflow <- put_auto(\"./src/\")\n")
  cat("  put_diagram(workflow)\n")
  cat("\n")
  cat("  # Generate annotation suggestions\n")
  cat("  put_generate(\"./src/\")\n")
  cat("\n")
  cat("  # Merge manual annotations with auto-detected\n")
  cat("  workflow <- put_merge(\"./src/\")\n")
  cat("\n")
  cat("LLM/AI PATTERNS INCLUDED:\n")
  cat("  R:      ellmer, tidyllm, httr2 (OpenAI/Anthropic APIs)\n")
  cat("  Python: openai, anthropic, langchain, transformers, ollama, litellm\n")
  cat("\n")
}

#' Show examples help
#' @noRd
show_examples_help <- function() {
  cat("\n")
  cat("=== Quick Examples ===\n")
  cat("\n")
  cat("BASIC WORKFLOW:\n")
  cat("  # 1. Add PUT annotations to your source files:\n")
  cat("  #put id:\"load\", label:\"Load Data\", output:\"data.csv\"\n")
  cat("  #put id:\"process\", label:\"Process\", input:\"data.csv\", output:\"clean.csv\"\n")
  cat("  #put id:\"analyze\", label:\"Analyze\", input:\"clean.csv\"\n")
  cat("\n")
  cat("  # 2. Scan and visualize:\n")
  cat("  workflow <- put(\"./src/\")\n")
  cat("  put_diagram(workflow)\n")
  cat("\n")
  cat("SHOW DATA ARTIFACTS:\n")
  cat("  put_diagram(workflow, show_artifacts = TRUE)\n")
  cat("\n")
  cat("GITHUB README OPTIMIZED:\n")
  cat("  put_diagram(workflow, theme = \"github\", show_artifacts = TRUE)\n")
  cat("\n")
  cat("INTERACTIVE DIAGRAMS:\n")
  cat("  # Show source file info in nodes\n")
  cat("  put_diagram(workflow, show_source_info = TRUE)\n")
  cat("\n")
  cat("  # Make nodes clickable (opens in VS Code)\n")
  cat("  put_diagram(workflow, enable_clicks = TRUE)\n")
  cat("\n")
  cat("AUTO-DETECTION (no annotations needed):\n")
  cat("  workflow <- put_auto(\"./src/\")\n")
  cat("  put_diagram(workflow)\n")
  cat("\n")
  cat("GENERATE ANNOTATION SUGGESTIONS:\n")
  cat("  put_generate(\"./src/\")             # Print to console\n")
  cat("  put_generate(\"./src/\", output = \"clipboard\")  # Copy to clipboard\n")
  cat("\n")
  cat("LAUNCH INTERACTIVE SANDBOX:\n")
  cat("  run_sandbox()\n")
  cat("\n")
  cat("ENABLE DEBUG LOGGING:\n")
  cat("  set_putior_log_level(\"DEBUG\")\n")
  cat("  workflow <- put(\"./src/\")\n")
  cat("\n")
}
