# Quick Reference Help for putior

Provides quick-reference help for common putior tasks and syntax. Call
without arguments to see available topics.

## Usage

``` r
putior_help(topic = NULL)
```

## Arguments

- topic:

  Character string specifying the help topic. Options:

  - NULL (default) - Show available topics

  - "annotation" or "annotations" - Show annotation syntax reference

  - "themes" - Show available diagram themes

  - "languages" - Show supported languages and comment prefixes

  - "node_types" - Show available node types

  - "patterns" - Show how to use detection patterns

  - "examples" - Show quick examples

  - "skills" - Show AI assistant skills reference

## Value

Invisibly returns NULL. Prints help content to the console.

## Examples

``` r
# Show available topics
putior_help()
#> 
#> === putior Quick Reference ===
#> 
#> Available topics:
#> 
#>   putior_help("annotation")   - PUT annotation syntax reference
#>   putior_help("themes")       - Available diagram themes
#>   putior_help("languages")    - Supported languages & comment prefixes
#>   putior_help("node_types")   - Available node types for styling
#>   putior_help("patterns")     - Auto-detection patterns
#>   putior_help("examples")     - Quick usage examples
#>   putior_help("skills")       - AI assistant skills reference
#> 
#> For full documentation, see: ?put, ?put_diagram, ?put_auto
#> 

# Show annotation syntax
putior_help("annotation")
#> 
#> === PUT Annotation Syntax ===
#> 
#> SINGLE-LINE FORMAT:
#>   # put id:"node_id", label:"Description", node_type:"process"
#> 
#> MULTILINE FORMAT (use backslash for continuation):
#>   # put id:"node_id", label:"Description", \
#>   #     input:"data.csv", \
#>   #     output:"result.csv"
#> 
#> AVAILABLE PROPERTIES:
#>   id          - Unique node identifier (auto-generated if omitted)
#>   label       - Human-readable description (shown in diagram)
#>   node_type   - Node styling: input, process, output, decision, start, end
#>   input       - Input files (comma-separated for multiple)
#>   output      - Output files (comma-separated for multiple)
#> 
#> INPUT/OUTPUT SYNTAX:
#>   Single file:    input:"data.csv"
#>   Multiple files: input:"data1.csv, data2.csv, data3.csv"
#>   Internal var:   output:"my_var.internal"  (in-memory, not saved)
#> 
#> COMMENT PREFIX BY LANGUAGE:
#>   R/Python:   # put id:"x", label:"y"
#>   SQL:        -- put id:"x", label:"y"
#>   JavaScript: // put id:"x", label:"y"
#>   MATLAB:     % put id:"x", label:"y"
#> 

# Show supported languages
putior_help("languages")
#> 
#> === Supported Languages ===
#> 
#> putior supports 30+ programming languages with automatic comment detection.
#> 
#> COMMENT PREFIXES:
#> 
#>   #   (hash)    R, Python, Shell, Julia, Ruby, Perl, YAML, TOML
#>                 Extensions: .R, .py, .sh, .bash, .jl, .rb, .pl, .yaml, .yml, .toml
#> 
#>   --  (dash)    SQL, Lua, Haskell
#>                 Extensions: .sql, .lua, .hs
#> 
#>   //  (slash)   JavaScript, TypeScript, C, C++, Java, Go, Rust, Swift,
#>                 Kotlin, C#, PHP, Scala, Groovy, D
#>                 Extensions: .js, .ts, .jsx, .tsx, .c, .cpp, .h, .hpp,
#>                             .java, .go, .rs, .swift, .kt, .cs, .php, .scala
#> 
#>   %   (percent) MATLAB, LaTeX
#>                 Extensions: .m, .tex
#> 
#> HELPER FUNCTIONS:
#>   get_comment_prefix("sql")     # Returns "--"
#>   get_supported_extensions()    # All supported extensions
#>   list_supported_languages()    # All supported languages
#> 

# Show available themes
putior_help("themes")
#> 
#> === Available Diagram Themes ===
#> 
#> Use with: put_diagram(workflow, theme = "theme_name")
#> 
#>   light      - Default light theme with bright colors - perfect for documentation sites
#>   dark       - Dark theme with muted colors - ideal for dark mode environments and terminals
#>   auto       - GitHub-adaptive theme with solid colors that work in both light and dark modes
#>   minimal    - Grayscale professional theme - print-friendly and great for business documents
#>   github     - Optimized specifically for GitHub README files with maximum mermaid compatibility
#>   viridis    - Colorblind-safe theme (purple-blue-green-yellow) - perceptually uniform, accessible
#>   magma      - Colorblind-safe warm theme (purple-red-yellow) - high contrast, print-friendly
#>   plasma     - Colorblind-safe vibrant theme (purple-pink-yellow) - bold colors for presentations
#>   cividis    - Colorblind-safe theme optimized for deuteranopia/protanopia (blue-yellow only)
#> 
#> Example:
#>   workflow <- put("./src/")
#>   put_diagram(workflow, theme = "github")
#> 

# Show node types
putior_help("node_types")
#> 
#> === Available Node Types ===
#> 
#> Use with: # put id:"x", label:"y", node_type:"type"
#> 
#> TYPE        SHAPE           TYPICAL USE
#> ----------- --------------- ----------------------------------
#> input       ([ stadium ])   Data sources, API inputs
#> process     [ rectangle ]   Data processing, transformations
#> output      [[ subroutine ]]  Final outputs, exports
#> decision    { diamond }     Conditional branching
#> start       ([ stadium ])   Workflow entry point (special styling)
#> end         ([ stadium ])   Workflow exit point (special styling)
#> artifact    [( cylinder )]  Data files (auto-created with show_artifacts)
#> 
#> WORKFLOW BOUNDARIES:
#>   Use node_type:"start" and node_type:"end" to mark workflow entry/exit.
#>   Enable special styling with: put_diagram(workflow, show_workflow_boundaries = TRUE)
#> 
#> Example:
#>   # put id:"begin", label:"Start Pipeline", node_type:"start"
#>   # put id:"load", label:"Load Data", node_type:"input", output:"raw.csv"
#>   # put id:"done", label:"Complete", node_type:"end", input:"final.csv"
#> 

# Show detection patterns info
putior_help("patterns")
#> 
#> === Detection Patterns for Auto-Annotation ===
#> 
#> putior can automatically detect inputs and outputs from code analysis.
#> 
#> LANGUAGES WITH AUTO-DETECTION:
#>    r, python, sql, shell, julia, javascript, typescript, go, rust, java, c, cpp, matlab, ruby, lua 
#> 
#> PATTERN TYPES:
#>   input      - Functions that read data (read_csv, pd.read_excel, etc.)
#>   output     - Functions that write data (write.csv, ggsave, etc.)
#>   dependency - Functions that source other scripts (source(), etc.)
#> 
#> USAGE:
#>   # View patterns for a language
#>   get_detection_patterns("r")
#>   get_detection_patterns("python", type = "input")
#> 
#>   # Auto-detect workflow from code (no annotations needed)
#>   workflow <- put_auto("./src/")
#>   put_diagram(workflow)
#> 
#>   # Generate annotation suggestions
#>   put_generate("./src/")
#> 
#>   # Merge manual annotations with auto-detected
#>   workflow <- put_merge("./src/")
#> 
#> LLM/AI PATTERNS INCLUDED:
#>   R:      ellmer, tidyllm, httr2 (OpenAI/Anthropic APIs)
#>   Python: openai, anthropic, langchain, transformers, ollama, litellm
#> 

# Show quick examples
putior_help("examples")
#> 
#> === Quick Examples ===
#> 
#> BASIC WORKFLOW:
#>   # 1. Add PUT annotations to your source files:
#>   # put id:"load", label:"Load Data", output:"data.csv"
#>   # put id:"process", label:"Process", input:"data.csv", output:"clean.csv"
#>   # put id:"analyze", label:"Analyze", input:"clean.csv"
#> 
#>   # 2. Scan and visualize:
#>   workflow <- put("./src/")
#>   put_diagram(workflow)
#> 
#> SHOW DATA ARTIFACTS:
#>   put_diagram(workflow, show_artifacts = TRUE)
#> 
#> GITHUB README OPTIMIZED:
#>   put_diagram(workflow, theme = "github", show_artifacts = TRUE)
#> 
#> INTERACTIVE DIAGRAMS:
#>   # Show source file info in nodes
#>   put_diagram(workflow, show_source_info = TRUE)
#> 
#>   # Make nodes clickable (opens in VS Code)
#>   put_diagram(workflow, enable_clicks = TRUE)
#> 
#> AUTO-DETECTION (no annotations needed):
#>   workflow <- put_auto("./src/")
#>   put_diagram(workflow)
#> 
#> GENERATE ANNOTATION SUGGESTIONS:
#>   put_generate("./src/")             # Print to console
#>   put_generate("./src/", output = "clipboard")  # Copy to clipboard
#> 
#> LAUNCH INTERACTIVE SANDBOX:
#>   run_sandbox()
#> 
#> ENABLE DEBUG LOGGING:
#>   set_putior_log_level("DEBUG")
#>   workflow <- put("./src/")
#> 

# Show AI assistant skills reference
putior_help("skills")
#> 
#> === AI Assistant Skills Reference ===
#> 
#> putior includes comprehensive skills documentation for AI coding assistants.
#> 
#> ACCESS METHODS:
#>   putior_skills()                    # Show full skills reference
#>   putior_skills("quick-start")       # Show quick start section
#>   putior_skills(output = "raw")      # Get raw markdown
#>   putior_skills(output = "clipboard") # Copy to clipboard
#> 
#> AVAILABLE TOPICS:
#>   quick-start  - Essential 3 commands
#>   syntax       - PUT annotation format
#>   languages    - 30+ language comment prefixes
#>   functions    - Core function reference
#>   patterns     - Auto-detection patterns
#>   examples     - Common usage patterns
#> 
#> RAW FILE ACCESS:
#>   system.file("SKILLS.md", package = "putior")
#> 
```
