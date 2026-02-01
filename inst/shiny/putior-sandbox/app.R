# putior Interactive Sandbox
# A Shiny app for experimenting with PUT annotations and workflow diagrams

library(shiny)
library(putior)

# Check if shinyAce is available for syntax highlighting
has_shinyAce <- requireNamespace("shinyAce", quietly = TRUE)

# Sample code for users to try
sample_r_code <- '# Example R script with PUT annotations
#put label:"Load Data", node_type:"input", output:"data.csv"

# Your R code here
data <- read.csv("source.csv")
write.csv(data, "data.csv")
'

sample_python_code <- '# Example Python script with PUT annotations
#put label:"Process Data", input:"data.csv", output:"results.json"

import pandas as pd
import json

df = pd.read_csv("data.csv")
results = {"count": len(df)}

with open("results.json", "w") as f:
    json.dump(results, f)
'

sample_multi_file <- '# ===== File: 01_fetch.R =====
#put label:"Fetch Data", node_type:"input", output:"raw_data.csv"

# Fetch data from API
data <- fetch_api_data()
write.csv(data, "raw_data.csv")

# ===== File: 02_clean.R =====
#put label:"Clean Data", input:"raw_data.csv", output:"clean_data.csv"

# Clean the data
data <- read.csv("raw_data.csv")
clean_data <- na.omit(data)
write.csv(clean_data, "clean_data.csv")

# ===== File: 03_analyze.R =====
#put label:"Analyze", input:"clean_data.csv", output:"results.rds"

# Run analysis
data <- read.csv("clean_data.csv")
results <- summary(data)
saveRDS(results, "results.rds")

# ===== File: 04_report.R =====
#put label:"Generate Report", node_type:"output", input:"results.rds", output:"report.html"

# Generate report
results <- readRDS("results.rds")
rmarkdown::render("template.Rmd", output_file = "report.html")
'

ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .mermaid {
        text-align: center;
        padding: 20px;
        background-color: #f8f9fa;
        border-radius: 8px;
        margin: 10px 0;
      }
      .code-editor {
        font-family: 'Fira Code', 'Consolas', monospace;
        font-size: 13px;
      }
      .header-title {
        color: #0054AD;
        margin-bottom: 5px;
      }
      .header-subtitle {
        color: #666;
        font-size: 14px;
        margin-bottom: 20px;
      }
      .btn-primary {
        background-color: #0054AD;
        border-color: #0054AD;
      }
      .btn-primary:hover {
        background-color: #003d7a;
        border-color: #003d7a;
      }
      pre.mermaid-code {
        background-color: #f4f4f4;
        padding: 15px;
        border-radius: 5px;
        overflow-x: auto;
        font-size: 12px;
      }
      .help-text {
        color: #666;
        font-size: 12px;
        margin-top: 5px;
      }
    ")),
    # Include Mermaid.js
    tags$script(src = "https://cdn.jsdelivr.net/npm/mermaid@10.9.3/dist/mermaid.min.js"),
    tags$script(HTML("
      mermaid.initialize({
        startOnLoad: false,
        theme: 'default',
        flowchart: {
          htmlLabels: true,
          curve: 'linear'
        }
      });

      Shiny.addCustomMessageHandler('renderMermaid', function(code) {
        var container = document.getElementById('mermaid-container');
        container.innerHTML = '';

        var div = document.createElement('div');
        div.className = 'mermaid';
        div.textContent = code;
        container.appendChild(div);

        mermaid.init(undefined, div);
      });

      // Copy to clipboard function
      Shiny.addCustomMessageHandler('copyToClipboard', function(text) {
        navigator.clipboard.writeText(text).then(function() {
          // Show success notification
          var btn = document.getElementById('copy_mermaid');
          var originalText = btn.textContent;
          btn.textContent = 'Copied!';
          btn.classList.add('btn-success');
          btn.classList.remove('btn-secondary');
          setTimeout(function() {
            btn.textContent = originalText;
            btn.classList.remove('btn-success');
            btn.classList.add('btn-secondary');
          }, 2000);
        }).catch(function(err) {
          console.error('Failed to copy text: ', err);
          alert('Failed to copy to clipboard. Please copy manually.');
        });
      });
    "))
  ),

  titlePanel(
    div(
      h2("putior Interactive Sandbox", class = "header-title"),
      p("Experiment with PUT annotations and see workflow diagrams in real-time", class = "header-subtitle")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      width = 5,

      # Template selection
      selectInput("template", "Start with a template:",
        choices = c(
          "Empty" = "empty",
          "Simple R Script" = "r_simple",
          "Python Script" = "python",
          "Multi-File Workflow" = "multi"
        ),
        selected = "multi"
      ),

      # Code input - use shinyAce if available for syntax highlighting
      if (has_shinyAce) {
        shinyAce::aceEditor(
          "code",
          value = sample_multi_file,
          mode = "r",
          theme = "tomorrow",
          height = "400px",
          fontSize = 13,
          showLineNumbers = TRUE,
          highlightActiveLine = TRUE,
          placeholder = "Paste your annotated code here..."
        )
      } else {
        textAreaInput("code", "Annotated Code:",
          value = sample_multi_file,
          rows = 20,
          width = "100%",
          placeholder = "Paste your annotated code here..."
        )
      },
      p("Use '# ===== File: filename.R =====' to simulate multiple files", class = "help-text"),

      hr(),

      # Diagram options
      h4("Diagram Options"),

      fluidRow(
        column(6,
          selectInput("theme", "Theme:",
            choices = c("github", "light", "dark", "auto", "minimal"),
            selected = "github"
          )
        ),
        column(6,
          selectInput("direction", "Direction:",
            choices = c("TD" = "TD", "LR" = "LR", "BT" = "BT", "RL" = "RL"),
            selected = "TD"
          )
        )
      ),

      fluidRow(
        column(6,
          checkboxInput("show_artifacts", "Show Artifacts", FALSE)
        ),
        column(6,
          checkboxInput("show_files", "Show File Names", FALSE)
        )
      ),

      fluidRow(
        column(6,
          checkboxInput("style_nodes", "Style Nodes", TRUE)
        ),
        column(6,
          checkboxInput("show_boundaries", "Workflow Boundaries", TRUE)
        )
      ),

      hr(),

      # Action buttons
      actionButton("generate", "Generate Diagram", class = "btn-primary btn-lg", width = "100%"),

      br(), br(),

      downloadButton("download_md", "Download Mermaid Code", width = "100%"),

      br(), br(),

      actionButton("copy_mermaid", "Copy Mermaid to Clipboard",
                   class = "btn-secondary", width = "100%",
                   icon = icon("clipboard"))
    ),

    mainPanel(
      width = 7,

      tabsetPanel(
        tabPanel("Diagram",
          br(),
          div(id = "mermaid-container", class = "mermaid"),
          br(),
          verbatimTextOutput("status")
        ),

        tabPanel("Mermaid Code",
          br(),
          verbatimTextOutput("mermaid_code")
        ),

        tabPanel("Extracted Workflow",
          br(),
          tableOutput("workflow_table")
        ),

        tabPanel("Help",
          br(),
          h4("PUT Annotation Syntax"),
          pre('#put label:"Step Name", node_type:"input", output:"file.csv"'),

          h5("Required Fields"),
          tags$ul(
            tags$li(tags$code("label"), " - Human-readable description of the step")
          ),

          h5("Optional Fields (with defaults)"),
          tags$ul(
            tags$li(tags$code("id"), " - Unique identifier (auto-generated if omitted)"),
            tags$li(tags$code("node_type"), " - input, process (default), output, decision, start, end"),
            tags$li(tags$code("input"), " - Comma-separated input files"),
            tags$li(tags$code("output"), " - Comma-separated output files (defaults to filename)")
          ),

          h4("Multi-File Simulation"),
          p("To simulate multiple files, use this format:"),
          pre("# ===== File: script_name.R ====="),
          p("Each section will be treated as a separate file."),

          h4("Node Types"),
          tags$ul(
            tags$li(tags$code("input"), " - Data sources (stadium shape)"),
            tags$li(tags$code("process"), " - Transformations (rectangle)"),
            tags$li(tags$code("output"), " - Final results (subroutine shape)"),
            tags$li(tags$code("decision"), " - Branching logic (diamond)"),
            tags$li(tags$code("start"), " / ", tags$code("end"), " - Workflow boundaries")
          ),

          h4("Links"),
          tags$ul(
            tags$li(tags$a(href = "https://pjt222.github.io/putior/", "putior Documentation", target = "_blank")),
            tags$li(tags$a(href = "https://github.com/pjt222/putior", "GitHub Repository", target = "_blank")),
            tags$li(tags$a(href = "https://mermaid.js.org/", "Mermaid.js Documentation", target = "_blank"))
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {

  # Template loader
  observeEvent(input$template, {
    code <- switch(input$template,
      "empty" = "#put label:\"My Step\"\n\n# Your code here\n",
      "r_simple" = sample_r_code,
      "python" = sample_python_code,
      "multi" = sample_multi_file
    )
    # Update editor - works for both shinyAce and textAreaInput
    if (has_shinyAce) {
      shinyAce::updateAceEditor(session, "code", value = code)
    } else {
      updateTextAreaInput(session, "code", value = code)
    }
  })

  # Parse code into simulated files
  parse_code_to_files <- function(code) {
    # Split by file markers
    file_pattern <- "# ===== File: ([^=]+) ====="

    # Find all file markers
    matches <- gregexpr(file_pattern, code, perl = TRUE)
    file_names <- regmatches(code, matches)[[1]]
    file_names <- gsub("# ===== File: | =====", "", file_names)
    file_names <- trimws(file_names)

    if (length(file_names) == 0) {
      # No file markers, treat as single file
      return(list(list(name = "script.R", content = code)))
    }

    # Split content by markers
    parts <- strsplit(code, file_pattern, perl = TRUE)[[1]]
    parts <- parts[parts != ""]  # Remove empty parts

    # Match file names to content
    files <- list()
    for (i in seq_along(file_names)) {
      if (i <= length(parts)) {
        files[[i]] <- list(
          name = file_names[i],
          content = trimws(parts[i + 1])  # +1 because first part is before any marker
        )
      }
    }

    return(files)
  }

  # Extract workflow from code
  workflow_data <- reactive({
    req(input$code)

    tryCatch({
      files <- parse_code_to_files(input$code)

      # Create temp directory with files
      temp_dir <- tempdir()
      sandbox_dir <- file.path(temp_dir, "putior_sandbox")
      if (dir.exists(sandbox_dir)) {
        unlink(sandbox_dir, recursive = TRUE)
      }
      dir.create(sandbox_dir)

      # Write each file
      for (f in files) {
        file_path <- file.path(sandbox_dir, f$name)
        writeLines(f$content, file_path)
      }

      # Extract workflow
      workflow <- put(sandbox_dir, validate = FALSE)

      # Cleanup
      unlink(sandbox_dir, recursive = TRUE)

      return(workflow)
    }, error = function(e) {
      return(NULL)
    })
  })

  # Generate mermaid code
  mermaid_code <- reactive({
    req(workflow_data())

    workflow <- workflow_data()
    if (is.null(workflow) || nrow(workflow) == 0) {
      return(NULL)
    }

    tryCatch({
      code <- put_diagram(
        workflow,
        output = "raw",
        direction = input$direction,
        theme = input$theme,
        show_artifacts = input$show_artifacts,
        show_files = input$show_files,
        style_nodes = input$style_nodes,
        show_workflow_boundaries = input$show_boundaries
      )
      return(code)
    }, error = function(e) {
      return(NULL)
    })
  })

  # Generate diagram on button click
  observeEvent(input$generate, {
    code <- mermaid_code()
    if (!is.null(code)) {
      session$sendCustomMessage("renderMermaid", code)
    }
  })

  # Status output
  output$status <- renderText({
    workflow <- workflow_data()
    if (is.null(workflow)) {
      return("No annotations found. Add #put comments to your code.")
    }
    paste0("Found ", nrow(workflow), " workflow node(s)")
  })

  # Mermaid code output
  output$mermaid_code <- renderText({
    code <- mermaid_code()
    if (is.null(code)) {
      return("Generate a diagram first to see the Mermaid code.")
    }
    code
  })

  # Workflow table
  output$workflow_table <- renderTable({
    workflow <- workflow_data()
    if (is.null(workflow) || nrow(workflow) == 0) {
      return(data.frame(Message = "No annotations found"))
    }

    # Select and rename columns for display
    cols_to_show <- c("file_name", "id", "label", "node_type", "input", "output")
    cols_available <- intersect(cols_to_show, names(workflow))

    workflow[, cols_available, drop = FALSE]
  }, striped = TRUE, hover = TRUE, bordered = TRUE)

  # Copy to clipboard handler

  observeEvent(input$copy_mermaid, {
    code <- mermaid_code()
    if (!is.null(code)) {
      session$sendCustomMessage("copyToClipboard", code)
    }
  })

  # Download handler
  output$download_md <- downloadHandler(
    filename = function() {
      paste0("workflow-", Sys.Date(), ".md")
    },
    content = function(file) {
      code <- mermaid_code()
      if (is.null(code)) {
        writeLines("No diagram generated", file)
      } else {
        content <- paste0(
          "# Workflow Diagram\n\n",
          "Generated with [putior](https://github.com/pjt222/putior)\n\n",
          "```mermaid\n",
          code,
          "\n```\n"
        )
        writeLines(content, file)
      }
    }
  )

  # Auto-generate on load
  observe({
    # Small delay to let the page load
    invalidateLater(500, session)
    isolate({
      code <- mermaid_code()
      if (!is.null(code)) {
        session$sendCustomMessage("renderMermaid", code)
      }
    })
  })
}

shinyApp(ui = ui, server = server)
