# putior Interactive Sandbox
# A Shiny app for experimenting with PUT annotations and workflow diagrams

library(shiny)
library(putior)

# Check if shinyAce is available for syntax highlighting
has_shinyAce <- requireNamespace("shinyAce", quietly = TRUE)

# Sample code for users to try
sample_r_code <- '# Example R script with PUT annotations
# put label:"Load Data", node_type:"input", output:"data.csv"

# Your R code here
data <- read.csv("source.csv")
write.csv(data, "data.csv")
'

sample_python_code <- '# Example Python script with PUT annotations
# put label:"Process Data", input:"data.csv", output:"results.json"

import pandas as pd
import json

df = pd.read_csv("data.csv")
results = {"count": len(df)}

with open("results.json", "w") as f:
    json.dump(results, f)
'

sample_multi_file <- '# ===== File: 01_fetch.R =====
# put label:"Fetch Data", node_type:"input", output:"raw_data.csv"

# Fetch data from API
data <- fetch_api_data()
write.csv(data, "raw_data.csv")

# ===== File: 02_clean.R =====
# put label:"Clean Data", input:"raw_data.csv", output:"clean_data.csv"

# Clean the data
data <- read.csv("raw_data.csv")
clean_data <- na.omit(data)
write.csv(clean_data, "clean_data.csv")

# ===== File: 03_analyze.R =====
# put label:"Analyze", input:"clean_data.csv", output:"results.rds"

# Run analysis
data <- read.csv("clean_data.csv")
results <- summary(data)
saveRDS(results, "results.rds")

# ===== File: 04_report.R =====
# put label:"Generate Report", node_type:"output", input:"results.rds", output:"report.html"

# Generate report
results <- readRDS("results.rds")
rmarkdown::render("template.Rmd", output_file = "report.html")
'

# Parse editor text into simulated files, split at "# ===== File: name ====="
# markers. Defined at top level (not inside server) so tests can evaluate it.
#
# A marker is one whole line: "#", at least three "=", "File:", the name, and
# an optional closing run of "=", with any spaces or tabs in between (#53). A
# name that is empty, ".", ".." or only "=" does not make a marker. Text
# before the first marker is ignored (with a note); text without any marker
# is one script.
#
# Names are made safe to write on Windows too: trailing dots and spaces are
# dropped (Windows drops them) and the characters < > : " | ? * and control
# characters become "_" (a ":" would otherwise write an NTFS stream). Each
# file gets a `folder`: "" normally, or "copy_2", "copy_3", ... when its name
# repeats an earlier one (ignoring case, as Windows and macOS do), so that the
# server writes both files and put(), which scans subfolders, finds both under
# their own names. The "notes" attribute lists these cases for the status line.
parse_code_to_files <- function(code) {
  code_lines <- strsplit(code, "\r\n|\r|\n")[[1]]
  marker_pattern <- "^[ \t]*#[ \t]*={3,}[ \t]*File:[ \t]*(.+?)(?:[ \t]*=+)?[ \t]*$"
  marker_matches <- regmatches(code_lines, regexec(marker_pattern, code_lines, perl = TRUE))
  marker_names <- vapply(marker_matches, function(match) {
    if (length(match) == 0) NA_character_ else basename(trimws(match[2]))
  }, character(1))
  # Windows drops trailing dots and spaces, so "a.R." would be written as "a.R"
  marker_names <- sub("[. ]+$", "", marker_names)
  is_marker <- !is.na(marker_names) & nzchar(marker_names) &
    !marker_names %in% c(".", "..") & !grepl("^=+$", marker_names)
  marker_rows <- which(is_marker)

  if (length(marker_rows) == 0) {
    # No file markers, treat as single file
    return(list(list(name = "script.R", folder = "", content = code)))
  }

  notes <- character()
  if (marker_rows[1] > 1 && any(nzchar(trimws(code_lines[seq_len(marker_rows[1] - 1)])))) {
    notes <- c(notes, "Text before the first file marker is ignored.")
  }

  last_rows <- c(marker_rows[-1] - 1, length(code_lines))
  files <- lapply(seq_along(marker_rows), function(file_index) {
    body_rows <- marker_rows[file_index] + seq_len(last_rows[file_index] - marker_rows[file_index])
    list(
      name = marker_names[marker_rows[file_index]],
      folder = "",
      content = trimws(paste(code_lines[body_rows], collapse = "\n"))
    )
  })

  for (file_index in seq_along(files)) {
    typed_name <- files[[file_index]]$name
    safe_name <- gsub("[<>:\"|?*[:cntrl:]]", "_", typed_name)
    if (!identical(safe_name, typed_name)) {
      notes <- c(notes, paste0(
        "File name ", typed_name, " has characters that file names cannot ",
        "contain; it is used as ", safe_name, "."
      ))
      files[[file_index]]$name <- safe_name
    }
  }

  all_names <- tolower(vapply(files, function(file) file$name, character(1)))
  seen_names <- character()
  for (file_index in seq_along(files)) {
    file_name <- files[[file_index]]$name
    repeat_count <- sum(seen_names == tolower(file_name))
    if (repeat_count > 0) {
      # A folder name that no file uses
      folder <- paste0("copy_", repeat_count + 1)
      while (tolower(folder) %in% all_names) {
        folder <- paste0(folder, "_")
      }
      files[[file_index]]$folder <- folder
      notes <- c(notes, paste0(
        "Repeated file name ", file_name, ": the later file is kept as ",
        folder, "/", file_name, "."
      ))
    }
    seen_names <- c(seen_names, tolower(file_name))
  }

  attr(files, "notes") <- notes
  files
}

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
    # Include Mermaid.js. Keep this pin and its integrity hash in sync with
    # _pkgdown.yml.
    tags$script(
      src = "https://cdn.jsdelivr.net/npm/mermaid@12.2.0/dist/mermaid.min.js",
      integrity = "sha384-8xUhuLNMjW/cI2Dacg3DR4WliYznvIg0LVG1stctThKD/YVrJFI9TNCFxft5NYgp",
      crossorigin = "anonymous"
    ),
    tags$script(HTML("
      // Mermaid comes from jsdelivr. If it did not load (no network, a
      // blocked CDN, a wrong integrity hash), the preview says so instead of
      // staying blank. The copy button has its own script below, so it works
      // without Mermaid (#64).
      var mermaidAvailable = typeof mermaid !== 'undefined';

      // Mermaid 12 defaults to the ELK layout, the neo look and the
      // redux-color theme, wraps labels at 120px and makes nodes at least
      // 120px wide. Keep Mermaid 11's classic rendering, which putior's
      // themes are made for and which GitLab, Quarto and VS Code still show.
      if (mermaidAvailable) {
        mermaid.initialize({
          startOnLoad: false,
          // Stays 'strict' (Mermaid's default): 'loose' would make
          // enable_clicks links work, but also let click callbacks run
          // pasted code's JavaScript (#47)
          securityLevel: 'strict',
          layout: 'dagre',
          look: 'classic',
          theme: 'default',
          flowchart: {
            htmlLabels: true,
            curve: 'linear',
            wrappingWidth: 200,
            minNodeWidth: 0
          }
        });
      } else {
        console.error('Mermaid did not load from cdn.jsdelivr.net');
      }

      function renderMermaidCode(code) {
        var container = document.getElementById('mermaid-container');
        container.innerHTML = '';

        if (!mermaidAvailable) {
          var message = document.createElement('p');
          message.className = 'mermaid-unavailable';
          message.textContent = 'Could not load Mermaid from cdn.jsdelivr.net, ' +
            'so the diagram cannot be drawn here. ' +
            'The Mermaid Code tab and the copy button still work.';
          container.appendChild(message);
          return;
        }

        var div = document.createElement('div');
        div.className = 'mermaid';
        div.textContent = code;
        container.appendChild(div);

        // On a syntax error Mermaid draws its error diagram, with the
        // message, into the div; the rejection only needs logging.
        mermaid.run({ nodes: [div] }).catch(function(err) {
          console.error('Mermaid render failed: ', err);
        });
      }

      // Mermaid measures text with the browser's layout, so a diagram
      // rendered while the Diagram tab is hidden collapses to an empty
      // 16px box. Keep code that arrives while the preview is hidden and
      // render it once the preview is visible again.
      var pendingMermaidCode = null;

      // Draw in the next frame, not inside the ResizeObserver callback, so the
      // size change it causes is not reported as a resize loop. The pending
      // code is read and cleared only in that frame, and only if the preview
      // is still visible, so a newer diagram is never replaced by an older
      // one and a preview hidden again before the frame keeps its code.
      var renderFrameRequested = false;

      function renderPendingMermaidCode() {
        if (pendingMermaidCode === null || renderFrameRequested) {
          return;
        }
        renderFrameRequested = true;
        window.requestAnimationFrame(function() {
          renderFrameRequested = false;
          var container = document.getElementById('mermaid-container');
          if (pendingMermaidCode !== null && container && container.offsetParent !== null) {
            var code = pendingMermaidCode;
            pendingMermaidCode = null;
            renderMermaidCode(code);
          }
        });
      }

      Shiny.addCustomMessageHandler('renderMermaid', function(code) {
        var container = document.getElementById('mermaid-container');
        if (container.offsetParent === null) {
          pendingMermaidCode = code;
          return;
        }
        pendingMermaidCode = null;
        renderMermaidCode(code);
      });

      // The preview becomes visible when its tab is shown, or when it gets a
      // size again after being hidden some other way, such as a collapsed
      // RStudio Viewer pane (#64).
      $(document).on('shown.bs.tab', renderPendingMermaidCode);
      $(function() {
        var container = document.getElementById('mermaid-container');
        if (container && typeof ResizeObserver !== 'undefined') {
          new ResizeObserver(renderPendingMermaidCode).observe(container);
        }
      });
    ")),
    tags$script(HTML("
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
          pre('# put label:"Step Name", node_type:"input", output:"file.csv"'),

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
      "empty" = "# put label:\"My Step\"\n\n# Your code here\n",
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

  # Split the editor text into simulated files
  parsed_files <- reactive({
    req(input$code)
    parse_code_to_files(input$code)
  })

  # Write the simulated files and scan them. A file that cannot be written
  # (a name or path that the file system rejects) is left out with a note,
  # instead of emptying the whole workflow.
  workflow_result <- reactive({
    files <- parsed_files()
    write_notes <- character()

    workflow <- tryCatch({

      # Create temp directory with files
      temp_dir <- tempdir()
      sandbox_dir <- file.path(temp_dir, "putior_sandbox")
      if (dir.exists(sandbox_dir)) {
        unlink(sandbox_dir, recursive = TRUE)
      }
      dir.create(sandbox_dir)

      # Write each file. Names are base names and folders are copy_<n>, so
      # nothing is written outside sandbox_dir.
      for (f in files) {
        written <- tryCatch({
          file_dir <- file.path(sandbox_dir, f$folder)
          dir.create(file_dir, showWarnings = FALSE, recursive = TRUE)
          writeLines(f$content, file.path(file_dir, basename(f$name)))
          TRUE
        }, warning = function(w) FALSE, error = function(e) FALSE)
        if (!written) {
          write_notes <- c(write_notes, paste0(
            "File ", f$name, " could not be written and is left out."
          ))
        }
      }

      # Extract workflow
      scanned_workflow <- put(sandbox_dir, validate = FALSE)

      # Cleanup
      unlink(sandbox_dir, recursive = TRUE)

      scanned_workflow
    }, error = function(e) {
      NULL
    })

    list(workflow = workflow, notes = write_notes)
  })
  workflow_data <- reactive(workflow_result()$workflow)

  # Generate mermaid code. Keep the error message, if there is one, so the
  # status line can say why no diagram appears instead of leaving it blank.
  diagram_result <- reactive({
    req(workflow_data())

    workflow <- workflow_data()
    if (is.null(workflow) || nrow(workflow) == 0) {
      return(list(code = NULL, error = NULL))
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
      list(code = code, error = NULL)
    }, error = function(e) {
      list(code = NULL, error = conditionMessage(e))
    })
  })
  mermaid_code <- reactive(diagram_result()$code)

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
      status <- "No annotations found. Add # put comments to your code."
    } else {
      status <- paste0("Found ", nrow(workflow), " workflow node(s)")
      diagram_error <- diagram_result()$error
      if (!is.null(diagram_error)) {
        status <- paste0(status, ", but the diagram could not be drawn:\n", diagram_error)
      }
    }
    # Repeated, renamed or unwritable file names (#53)
    file_notes <- c(attr(parsed_files(), "notes"), workflow_result()$notes)
    if (length(file_notes) > 0) {
      status <- paste(c(status, file_notes), collapse = "\n")
    }
    status
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

  # Live preview: render the initial diagram once the template has loaded,
  # then re-render when an edit changes the generated Mermaid code. Debounced
  # so typing does not re-render on every keystroke. Nothing is sent while the
  # app is idle, and an edit that leaves the code identical (possible when the
  # annotations set explicit ids) does not re-render. The Generate button
  # still forces a re-render of the current code.
  debounced_mermaid_code <- debounce(mermaid_code, 500)
  last_rendered_code <- NULL
  observe({
    code <- debounced_mermaid_code()
    if (!is.null(code) && !identical(code, last_rendered_code)) {
      last_rendered_code <<- code
      session$sendCustomMessage("renderMermaid", code)
    }
  })
}

shinyApp(ui = ui, server = server)
