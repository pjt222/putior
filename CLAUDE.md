# CLAUDE.md

This file provides guidance to AI assistants when working with code in this repository.

## Repository Overview

putior is an R package that extracts structured annotations from source code files and generates Mermaid flowchart diagrams for visualizing workflows and data pipelines. It supports 30+ programming languages including R, Python, SQL, JavaScript, TypeScript, Go, Rust, and more, with automatic comment syntax detection.

**Status**: Production-ready, passing all checks, excellent documentation

## Development Environment Setup

### Critical Files for Development
- `.Renviron`: Contains Pandoc path for vignette building: `RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"`
- `.Rprofile`: Contains renv activation and conditional `acquaint` MCP session loading
- **NEVER delete these files** - they are essential for development workflow

### Key Commands
- `devtools::document()` - Regenerate `man/*.Rd` and `NAMESPACE` from the roxygen comments. Use roxygen2 8.1.1 or later (`Config/roxygen2/version` in DESCRIPTION); an older roxygen2 rewrites every family link and the DESCRIPTION field. Never edit `man/*.Rd` by hand.
- `devtools::check()` - Full package check (requires Pandoc configured)
- `R CMD check putior_X.X.X.tar.gz` - Check built package tarball  
- `devtools::spell_check()` - Spell checking (uses inst/WORDLIST)

## Package Structure and Assets

### Hex Sticker Organization
- `inst/hex-sticker/handcrafted/` - Original Draw.io designs (primary display assets)
- `inst/hex-sticker/generated/` - R-generated stickers (development/comparison)
- Main package logos: `man/figures/logo.png|svg` (uses handcrafted versions)
- Favicon files: `pkgdown/favicon/` (all use handcrafted design)

### Self-Documentation Excellence
- Package uses its own PUT annotation system to document internal workflow
- `put('./R/')` extracts putior's own workflow (10 nodes)
- Demonstrates "eating your own dog food" principle
- Self-generated diagram shows: file scanning → annotation processing → validation → parsing → conversion → diagram generation

## File Management Best Practices

### Cleanup Guidelines
**Safe to remove (temporary/generated files):**
- R CMD check directories (`*.Rcheck/`)
- Build artifacts (`*.tar.gz`, `Meta/`, `doc/`)
- Generated sites (`docs/`)
- Cache files (`*.rds` in root)
- RStudio cache (`.Rproj.user/`)

**NEVER remove (critical development files):**
- `.Renviron` - Contains essential environment variables
- `.Rprofile` - Contains development session configuration
- User session data (`.RData`, `.Rhistory`) without explicit permission

### Ignore File Strategy
- `.gitignore`: Excludes user-specific files but preserves package assets
- `.Rbuildignore`: Excludes development files from package builds
- Important: Use specific patterns, avoid overly broad exclusions like `*.png`

## Quality Assurance

### R CMD Check Status
- **Local `--as-cran`** (Windows R 4.6.1, 2026-10-12, at 0ab2303): 0 errors, 0 warnings, 0 notes, including the PDF manual. Re-run at the final 0.2.0 commit before submitting.
- **Win-builder (0.2.0)**: pending. The 0.1.0 results ("1 NOTE, new submission") are out of date; 0.2.0 is an update.
- **R-hub**: no result for 0.2.0. Both `rhub.yaml` runs (22953633249, 22950885436) were cancelled on 2026-03-11.
- All vignettes build successfully with Pandoc
- All tests pass: 4659 expectations in 533 tests (Windows R 4.6.1 inside renv, all Suggests, 2026-10-13)
- Comprehensive multiline PUT annotation support implemented

### Mermaid Output Check (`tests/mermaid/`)
The testthat suite compares strings; it cannot tell whether Mermaid accepts the output. `tests/mermaid/` checks that in headless Chromium, on every Mermaid version in `tests/mermaid/package.json` (11.12.0 = Quarto 1.10/1.11, the oldest major renderer; 11.17.2; 12.1.0 = GitHub; 12.2.0 = pkgdown site and sandbox), with Mermaid's defaults and with the site/sandbox configuration. The `mermaid-check` workflow runs it on pushes to `main` and on pull requests to `main`, and weekly also against npm's newest Mermaid release.

```bash
# from the package root
Rscript tests/mermaid/generate-corpus.R tests/mermaid/corpus   # writes .mmd files + manifest.json
(cd tests/mermaid && npm ci && npx playwright-core install --only-shell chromium)
node tests/mermaid/validate.mjs tests/mermaid/corpus
```

- A case fails on an R error while generating it, a parse or render error, an SVG that does not draw exactly the nodes Mermaid parsed, or nodes that differ from what putior defined (phantom, merged or lost nodes, `class`/`click` lines for undefined ids, duplicate subgraph ids), fewer parsed edges than `-->` lines, nodes drawn in another look than the frontmatter sets (Mermaid 11.17.2 and later record it in `data-look`), labels in a case's `wide_texts` drawn 120px wide or less although the frontmatter wraps at 200px, an SVG `<title>`/`<desc>` that does not show the case's title/accDescr as written, or when no HTML label shows one of the case's `expected_texts` as written.
- A case with `must_fail` (an `add_case()` argument) is over one of Mermaid's limits on purpose and must fail with only those problem kinds; it counts like a known failure, and drawing fails the check (#56).
- Give a case `expected_texts` (an `add_case()` argument) when its labels could be misread: the node checks do not notice a changed label, and a node whose definition Mermaid drops still appears through its edges, with its id as label (#89). A label with a double quote goes in single quotes in its annotation, as `chain_fixture()` writes them (#91).
- Known bugs are listed in `tests/mermaid/expected-failures.json` with their issue and the problem kinds they cause (`generate`, `parse`, `render`, `nodes`, `edges`, `subgraphs`, `text`, `look`, `wrap`). A problem of another kind in a listed case still fails. When a fix makes a listed case pass, the check fails until the entry is removed, so a fix PR removes its entries.
- The Mermaid pins of the site, the sandbox and the asset scripts (`inst/cheatsheet/generate-diagrams.R`, `inst/examples/create-demo-gif.R`, which run a pinned mermaid-cli through `npx`) must be versions in `package.json`; the check fails otherwise.
- Add a case for every diagram option or edge case that changes the generated Mermaid. The whole directory is in `.Rbuildignore` (no Node.js on CRAN).
- From WSL, run the generator with Windows `Rscript.exe` from the package root, so that renv's project library is used (it calls `pkgload::load_all()` when pkgload is installed), and the checker with WSL's Node.

### Documentation Quality
- Vignette rating: **9.2/10** - Exceptional quality
- **8 vignettes**:
  - `quick-start.Rmd` - First diagram in 2 minutes (< 200 lines)
  - `annotation-guide.Rmd` - Complete syntax reference, multiline annotations, best practices
  - `quick-reference.Rmd` - Printable cheat sheet (< 100 lines)
  - `features-tour.Rmd` - Advanced features guide (auto-annotation, interactive diagrams, logging)
  - `api-reference.Rmd` - Complete function documentation with parameter tables
  - `showcase.Rmd` - Real-world examples (ETL, ML, bioinformatics, finance, web scraping)
  - `troubleshooting.Rmd` - Common problems and their fixes
  - `ai-integration.Rmd` - Using putior from AI assistants (guide, MCP, ACP)
- Complete self-documentation workflow
- README diagrams are generated: `inst/examples/update-readme.R` replaces the ```` ```mermaid ```` block after each `<!-- putior-diagram: <name> -->` marker (`tldr`, `pipeline`, `self-documentation`); the pipeline diagram is built from the example files shown in the README itself. The `update-readme` workflow runs it on pushes to `main` that change `R/` and commits README.md if it changed; a missing marker fails the workflow. A PR that changes diagram output should run it too (inside renv: `pkgload::load_all(); source("inst/examples/update-readme.R")`), so README.md changes in the same PR

### CI/CD Considerations
- GitHub Actions does not use renv: `r-lib/actions/setup-r-dependencies` installs DESCRIPTION's dependencies from CRAN (all of them, mcptools included, are on CRAN)
- `.Rprofile` loads the development-only `acquaint` MCP session only if it is installed, so it never breaks a session that lacks it
- Spell check passes cleanly with comprehensive WORDLIST

## Development Dependencies vs Package Dependencies

### Package Dependencies (in DESCRIPTION & renv.lock)
- DESCRIPTION lists only what putior needs (Imports) or can use (Suggests)
- renv.lock is wider: renv's implicit snapshot also records the development tools the repo uses (roxygen2, devtools, rcmdcheck, pkgdown, testthat) and the packages that the scripts in `inst/` (examples, hex sticker) use, such as magick and showtext
- All dependencies are from CRAN (no GitHub packages), including mcptools
- renv.lock is for **Windows R 4.6.1** (the R that RStudio uses) and renv 1.3.1, refreshed 2026-10-13. After pulling a lockfile change, run `renv::restore()` in RStudio. Keep it current: `renv::update()`, then `renv::snapshot()`, from Windows R in the project (not with `--no-init-file`, which bypasses renv)
- WSL's R (`/opt/R/<version>` via rig) is not used for renv, docs or checks; it only serves Linux-side probes
- If a fresh checkout stops with "Failed to find an renv installation", look at renv's own entry in the global cache (`C:/Users/<you>/AppData/Local/R/cache/R/renv/cache/v5/windows/R-4.6/x86_64-w64-mingw32/renv/<version>/`). An empty entry, as `renv::upgrade()` left on 2026-10-13, makes the bootstrap copy nothing; delete it and renv downloads itself instead

### Development-Only Tools (NOT in renv.lock)
- **acquaint**: MCP session for AI-assisted development, loaded conditionally in `.Rprofile` if installed
- **btw**: Development helper, not a package dependency
- **rsyslog**: Linux-only logging backend
- renv ignores these via `renv/settings.json` (`ignored.packages`: acquaint, btw, rsyslog)

## Recent Major Accomplishments

1. **Multiline annotation support** - Implemented backslash continuation syntax
2. **Hex sticker organization** - Clean separation of handcrafted vs generated assets
3. **Development environment restoration** - Proper `.Renviron`/`.Rprofile` setup
4. **File structure cleanup** - Removed 4.2MB of temporary files while preserving essentials
5. **CI/CD fixes** - Resolved GitHub Actions failures with conditional package loading
6. **Documentation excellence** - High-quality vignettes and self-documentation
7. **Spelling compliance** - Complete WORDLIST for technical terms and proper names
8. **Clean renv.lock** - Removed development-only GitHub dependencies to eliminate credential warnings
9. **Variable reference feature** - Comprehensive example demonstrating `.internal` extension usage
10. **Metadata Display (Issue #3)** - Show source file info in diagram nodes with `show_source_info` parameter
11. **Clickable Hyperlinks (Issue #4)** - Make nodes clickable with `enable_clicks` and `click_protocol` parameters
12. **Auto-Annotation Feature (Issue #5)** - Automatic workflow detection from code analysis (roxygen2-style)
13. **Structured Logging** - Optional logger package integration for debugging annotation parsing and diagram generation
14. **Documentation Suite (Issues #5-9)** - Features Tour, API Reference, and expanded Showcase vignettes
15. **Shiny Sandbox Enhancements (Issue #7)** - Copy-to-clipboard button and optional shinyAce syntax highlighting
16. **LLM Detection Patterns (Issue #10)** - 54 patterns for modern AI/ML libraries (ellmer, langchain, transformers, etc.)
17. **Multi-Language Comment Syntax** - Support for 30+ languages with automatic comment prefix detection (`#`, `--`, `//`, `%`)
18. **Full Language Detection Patterns** - Added auto-detection patterns for 10 new languages (JS, TS, Go, Rust, Java, C, C++, MATLAB, Ruby, Lua), bringing total to 18 languages with 902 patterns
19. **MCP Server Integration** - Expose putior functions as MCP tools for AI assistants (Claude Code, Claude Desktop)
20. **ACP Server Integration** - Expose putior as an ACP agent for inter-agent communication via REST API
21. **Colorblind-Safe Themes** - Added 4 viridis family themes (viridis, magma, plasma, cividis) for accessibility
22. **WGSL Shader Language Support (Issue #31)** - Register `.wgsl` with `//` comments, 17 auto-detection patterns for GPU bindings, textures, samplers, and naga-oil/WESL imports
23. **GitHub Mermaid Rendering Fix (Issue #32)** - Removed unsupported `<small>` HTML tags from `show_source_info` output
24. **Pipe Character Escaping (Issue #33)** - Escape `|` in node labels using Mermaid `#124;` entity to prevent parsing errors
25. **Recursive Scanning Default (Issue #34)** - `put()`, `put_auto()`, `put_generate()`, `put_merge()` now default to `recursive = TRUE` (breaking change)
26. **Dockerfile Support (Issue #35)** - Handle extensionless files via `.FILENAME_MAP`, 13 detection patterns for FROM/COPY/ADD/EXPOSE/VOLUME/CMD/RUN, `resolve_language_from_file()` helper
27. **Makefile Support (Issue #36)** - Add Makefile/GNUmakefile to `.FILENAME_MAP`, 10 detection patterns for include/wildcard/target rules/install/shell commands

## MCP Server Integration

### Overview
putior exposes its functionality as MCP (Model Context Protocol) tools, enabling AI assistants like Claude Code and Claude Desktop to directly call workflow annotation and diagram generation functions.

### Quick Setup

**Claude Code (WSL/Linux/macOS):**
```bash
claude mcp add putior -- Rscript -e "putior::putior_mcp_server()"
```

**Claude Desktop (Windows):**
Add to `%APPDATA%\Claude\claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "putior": {
      "command": "Rscript",
      "args": ["-e", "putior::putior_mcp_server()"]
    }
  }
}
```

### Available MCP Tools (16 tools)

**Core Workflow:**
| Tool | Description |
|------|-------------|
| `put` | Scan files for PUT annotations |
| `put_diagram` | Scan a path and return its Mermaid diagram (`source`: annotations, auto or merge) |
| `put_auto` | Auto-detect workflow from code |
| `put_generate` | Generate annotation suggestions |
| `put_merge` | Merge manual + auto annotations |

**Reference/Discovery:**
| Tool | Description |
|------|-------------|
| `get_comment_prefix` | Get comment prefix for extension |
| `get_supported_extensions` | List supported extensions |
| `list_supported_languages` | List supported languages |
| `get_detection_patterns` | Get auto-detection patterns |
| `get_diagram_themes` | List available themes |
| `putior_guide` | AI assistant documentation |
| `putior_help` | Quick reference help |
| `set_putior_log_level` | Configure logging |

**Utilities:**
| Tool | Description |
|------|-------------|
| `is_valid_put_annotation` | Validate annotation syntax |
| `split_file_list` | Parse file lists |
| `ext_to_language` | Extension to language name |

### Usage Examples

**From Claude Code:**
```
Use the put tool to scan ./R/ for PUT annotations
Use the put_diagram tool on ./R/ to get the Mermaid diagram
```

**Programmatic access:**
```r
# Start MCP server (runs until terminated)
putior::putior_mcp_server()

# Get tool definitions for custom integration
tools <- putior::putior_mcp_tools()

# Get specific tools only
tools <- putior_mcp_tools(include = c("put", "put_diagram"))
```

### Warnings
R warnings never reach an MCP client over stdio (mcptools' server loop never returns to the top level). `mcp_reply()` in `R/mcp.R` runs each tool that can warn with `collect_warnings()` (`R/zzz.R`) and, when R warned, returns a list of two `ellmer::ContentText` items: the result unchanged, then `format_warning_block()` (at most 20 warnings, each cut to 1,000 characters). For `put_diagram` the block is Mermaid comment lines with `%%{` written as `%% {`, because Mermaid applies a `%%{...}%%` directive even inside a comment line (measured), and Claude Code joins content items without a separator. Errors carry the warnings raised before them in their message.

### Dependencies
- **mcptools** (>= 1.0.0): MCP server framework - `install.packages("mcptools")`; older versions turn a reply with warnings (a list of content items) into "<object>" text, so `putior_mcp_server()` checks the version
- **ellmer**: Tool definition - `install.packages("ellmer")`
- Both are in Suggests (optional) - MCP functions fail gracefully with helpful messages if not installed

### Key Files
- `R/mcp.R` - MCP server and tool definitions
- `tests/testthat/test-mcp.R` - MCP tests

## ACP Server Integration

### Overview
putior also exposes its functionality as an ACP (Agent Communication Protocol) agent, enabling other AI agents to discover and call putior capabilities via REST API. This complements the MCP integration by enabling inter-agent communication.

**MCP vs ACP:**
- **MCP**: Model-to-tool communication (Claude ↔ putior functions)
- **ACP**: Agent-to-agent communication (other AI agents ↔ putior agent)

### Quick Setup

**Start ACP Server:**
```r
# Start ACP server on default port (8080)
putior::putior_acp_server()

# Custom host/port; another host than a loopback one needs a token (#111)
putior::putior_acp_server(host = "0.0.0.0", port = 9000, root = "~/projects",
                          token = Sys.getenv("PUTIOR_ACP_TOKEN"))
```

### ACP Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/agents` | GET | Discover this agent (returns manifest) |
| `/runs` | POST | Execute a putior operation |
| `/runs/:run_id` | GET | Get status/results of a previous run |

`extract_path()` takes, best first: a quoted value that starts like a path, an unquoted word that starts like one (`/x`, `./`, `../`, `~/`, `D:/x`, `C:\x`; not a lone `/`, `\`, `~` or drive), an existing word with a slash, an existing quoted value, then any other quoted value except theme and direction names; it reads only the first 10,000 characters (cut at a word) and looks up on disk only words with a slash and quoted values. Without a path, a scan reads the server's working directory and says so (#109). **Security (#111):** requests may scan only `root` (default `getwd()`; `confine_acp_path()` resolves symlinks, rejects paths outside; `acp_outside_excludes()` keeps a recursive scan from following links out; `sanitize_acp_path()` rejects `..`, control characters and `//`/`\\` network paths before any file access); `token` (>= 16 chars, no spaces) requires `Authorization: Bearer <token>` on `/runs` (`acp_authorized()`), and a non-loopback `host` refuses to start without one; without a token only loopback `Host` headers are answered (`acp_host_allowed()`, DNS rebinding); `acp_runs_header_handler()` checks Host, token, `Content-Type: application/json` and a 1 MB limit before the body is read (plumber2 0.2.0's `max_request_size` had no effect); messages show the root as `<root>`; run ids are `run_` + 32 hex chars from `openssl::rand_bytes()`. The live-server tests (`start_acp_server()` in test-acp.R, off CRAN) send real HTTP requests (#113). A run's output gets a second `text/plain` part with the warnings R raised (`collect_warnings()`, shared with the MCP server). A path with `..` or control characters ends the run with "Error: ACP path rejected: ..." instead of scanning `.`.

### Testing with curl

```bash
# Discover agents
curl http://localhost:8080/agents

# Execute a scan operation
curl -X POST http://localhost:8080/runs \
  -H "Content-Type: application/json" \
  -d '{"input": [{"role": "user", "parts": [{"content": "scan ./R/"}]}]}'

# Execute diagram generation
curl -X POST http://localhost:8080/runs \
  -H "Content-Type: application/json" \
  -d '{"input": [{"role": "user", "parts": [{"content": "generate diagram for ./R/"}]}]}'

# Get help
curl -X POST http://localhost:8080/runs \
  -H "Content-Type: application/json" \
  -d '{"input": [{"role": "user", "parts": [{"content": "help with annotations"}]}]}'
```

### Supported Operations

The ACP agent understands natural language requests:

| Operation | Example Messages |
|-----------|------------------|
| scan | "scan ./R/ for PUT annotations", "extract annotations" |
| diagram | "generate a diagram", "visualize workflow", "create flowchart" |
| auto | "auto-detect workflow", "use put_auto" |
| generate | "generate annotation suggestions", "suggest annotations" |
| merge | "merge annotations", "combine manual and auto" |
| help | "help with syntax", "how to use putior" |
| guide | "what are your capabilities", "what can you do" |

### Agent Manifest

```r
# Get the agent manifest programmatically
manifest <- putior::putior_acp_manifest()
print(manifest$name)  # "putior"
print(manifest$metadata$capabilities)
print(manifest$metadata$operations)
```

### Dependencies
- **plumber2**: REST API framework - `install.packages("plumber2")`
- In Suggests (optional) - ACP server fails gracefully with helpful message if not installed

### Key Files
- `R/acp.R` - ACP server and endpoint handlers
- `tests/testthat/test-acp.R` - ACP tests

## Multi-Language Comment Syntax Support

### Overview
putior now automatically detects the correct comment prefix based on file extension:

| Comment Style | Languages | Extensions |
|---------------|-----------|------------|
| `# put` | R, Python, Shell, Julia, Ruby, Perl, YAML, TOML, Dockerfile, Makefile | `.R`, `.py`, `.sh`, `.jl`, `.rb`, `.pl`, `.yaml`, `Dockerfile`, `Makefile` |
| `-- put` | SQL, Lua, Haskell | `.sql`, `.lua`, `.hs` |
| `// put` | JavaScript, TypeScript, C, C++, Java, Go, Rust, Swift, Kotlin, C#, PHP, Scala, WGSL | `.js`, `.ts`, `.c`, `.cpp`, `.java`, `.go`, `.rs`, `.wgsl` |
| `% put` | MATLAB, LaTeX | `.m`, `.tex` |
| `* put` (block) | All `//`-prefix languages inside `/* */` or `/** */` blocks | Same as `//` group |

### Block Comment Support
Languages in the `//` group also support PUT annotations inside block comments (`/* */` and `/** */`). Use `* put` as the line prefix inside the block body. Single-line block comments (`/* put ... */`) and annotations on the opening line (`/** put ... */`) are also supported. This enables JSDoc-style documentation patterns.

### Key Functions
```r
# Get comment prefix for an extension
get_comment_prefix("sql")  # Returns "--"
get_comment_prefix("js")   # Returns "//"
get_comment_prefix("m")    # Returns "%"

# List all supported extensions
get_supported_extensions()

# List all supported languages
list_supported_languages()              # All languages
list_supported_languages(detection_only = TRUE)  # Only with auto-detection patterns
```

### Example Annotations
```sql
-- query.sql
-- put id:"load_data", label:"Load Customer Data", output:"customers"
SELECT * FROM customers;
```

```javascript
// process.js
// put id:"transform", label:"Transform JSON", input:"data.json", output:"output.json"
const transformed = data.map(process);
```

```matlab
% analysis.m
% put id:"compute", label:"Statistical Analysis", input:"data.mat", output:"results.mat"
results = compute_statistics(data);
```

### Key Files
- `R/language_registry.R` - Language groups and comment prefix detection
- `R/detection_patterns.R` - Auto-detection patterns for 18 languages
- `tests/testthat/test-language-registry.R` - Tests for multi-language support
- `tests/testthat/test-new-language-patterns.R` - Tests for new language detection patterns

## Auto-Detection Pattern Coverage

### Overview
putior supports auto-detection of file inputs, outputs, and dependencies for 18 programming languages with **902 patterns total**.

### Languages with Auto-Detection (18 languages)

| Language | Total | Key Libraries/Frameworks |
|----------|-------|--------------------------|
| R | 124 | readr, data.table, DBI, arrow, ellmer, sparklyr |
| Python | 159 | pandas, numpy, sqlalchemy, transformers, langchain |
| JavaScript | 71 | Node.js fs, Express.js, mongoose, Prisma, axios |
| TypeScript | 88 | All JS + NestJS, TypeORM, decorators |
| Java | 73 | NIO, JDBC, Jackson, Spring Boot, Hibernate |
| Ruby | 64 | File, CSV, YAML, Rails, ActiveRecord, Sequel |
| Rust | 60 | std::fs, serde, sqlx, diesel, reqwest |
| Go | 44 | os, bufio, database/sql, gorm, net/http |
| C++ | 44 | All C + fstream, boost, std::filesystem |
| MATLAB | 44 | readtable, imread, h5read, VideoReader |
| Julia | 27 | CSV.jl, DataFrames, JLD2, Arrow.jl |
| C | 24 | stdio.h, POSIX, mmap |
| Lua | 20 | io library, loadfile, dofile |
| WGSL | 17 | uniform/storage bindings, textures, samplers, naga-oil imports |
| Dockerfile | 13 | FROM, COPY, ADD, EXPOSE, VOLUME, CMD, RUN variants |
| Shell | 12 | cat, redirects, source |
| Makefile | 10 | include, wildcard, target rules, install, shell commands |
| SQL | 8 | FROM, JOIN, COPY |

### Usage
```r
# Get patterns for any supported language
patterns <- get_detection_patterns("javascript")  # or "go", "rust", "wgsl", "dockerfile", "makefile", etc.

# List languages with detection support
list_supported_languages(detection_only = TRUE)
#> [1] "r" "python" "sql" "shell" "julia" "javascript" "typescript"
#> [8] "go" "rust" "java" "c" "cpp" "matlab" "ruby" "lua"
#> [16] "wgsl" "dockerfile" "makefile"
```

### Key Implementation Insights

**1. Pattern Inheritance Architecture**
- TypeScript patterns extend JavaScript patterns (call `get_javascript_patterns()` as base)
- C++ patterns extend C patterns (same approach)
- This reduces duplication and ensures consistency
- New language-specific patterns are appended to the base list

**2. Framework-Specific Patterns are High-Value**
- Generic file I/O patterns (e.g., `fopen`) catch basic usage
- Framework patterns (Spring Boot, Rails, Express) catch real-world code
- ORM patterns (Hibernate, ActiveRecord, Prisma, GORM) are particularly valuable for data workflows
- Web framework request/response patterns help track API data flow

**3. Pattern Structure Consistency**
Each pattern has the same structure across all languages:
```r
list(
  regex = "pattern_to_match",      # Regex for code detection
  func = "function_name",          # Human-readable function name
  arg_position = 1,                # Position of file argument (or NA)
  arg_name = "file",               # Named argument (or NULL)
  description = "Brief description"
)
```

**4. Three Pattern Categories per Language**
- **input**: File/data reading operations
- **output**: File/data writing operations
- **dependency**: Module/import statements (for tracking script relationships)

**5. Regex Design Principles**
- Use `\\s*\\(` to match function calls with optional whitespace
- Use `['\"]` to match either quote style
- For method chains, use `\\.method\\s*\\(` pattern
- Escape special regex characters: `\\.`, `\\$`, `\\[`

**6. Testing Strategy**
- Test that patterns exist for expected functions
- Test that regex compiles without error
- Test that patterns match realistic code snippets
- Test pattern counts to catch accidental deletions

## Auto-Annotation Feature (GitHub Issue #5)

### Overview
Automatic detection of workflow elements from code analysis, similar to how roxygen2 auto-generates documentation skeletons. Two primary modes:

1. **Direct detection**: `put_auto()` analyzes code and produces workflow data without requiring annotations
2. **Comment generation**: `put_generate()` creates `# put` annotation text for persistent documentation

### Core Functions

#### `put_auto()` - Auto-detect workflow from code
```r
# Analyze code to detect inputs/outputs automatically
workflow <- put_auto("./src/")
put_diagram(workflow)

# Control what to detect
workflow <- put_auto("./src/",
                     detect_inputs = TRUE,
                     detect_outputs = TRUE,
                     detect_dependencies = TRUE)
```

#### `put_generate()` - Generate annotation comments (roxygen2-style)
```r
# Print suggested annotations to console
put_generate("./src/")

# Copy to clipboard for pasting
put_generate("./src/", output = "clipboard")

# Single-line or multiline style
put_generate("./src/", style = "multiline")
put_generate("./src/", style = "single")
```

#### `put_merge()` - Combine manual + auto annotations
```r
# Manual annotations override auto-detected
workflow <- put_merge("./src/", merge_strategy = "manual_priority")

# Auto fills in missing input/output fields
workflow <- put_merge("./src/", merge_strategy = "supplement")

# Combine all detected I/O from both sources
workflow <- put_merge("./src/", merge_strategy = "union")
```

#### `get_detection_patterns()` - View/customize patterns
```r
# Get all R patterns
patterns <- get_detection_patterns("r")

# Get only input patterns for Python
input_patterns <- get_detection_patterns("python", type = "input")
```

### Supported Detection Patterns

**R Language:**
- Inputs: `read.csv`, `read_csv`, `readRDS`, `load`, `fread`, `read_excel`, `fromJSON`, `read_parquet`, etc.
- Outputs: `write.csv`, `saveRDS`, `ggsave`, `pdf`, `png`, `write_parquet`, etc.
- Dependencies: `source()`, `sys.source()`

**Python:**
- Inputs: `pd.read_csv`, `pd.read_excel`, `json.load`, `pickle.load`, `np.load`, etc.
- Outputs: `.to_csv`, `.to_excel`, `json.dump`, `plt.savefig`, etc.

**Also supported:** SQL, Shell, Julia, WGSL, and 10 more (see table above)

### Workflow Integration
```
Source Files ──┬──> put()      ──> Manual Annotations ─┬─> put_merge() ──> put_diagram()
               │                                       │
               └──> put_auto() ──> Auto Annotations  ──┘
```

### Use Cases
1. **Quick Visualization**: `put_auto()` for instant workflow diagrams without any annotations
2. **Skeleton Generation**: `put_generate()` to create annotation templates for new files
3. **Hybrid Workflow**: `put_merge()` for manual control over key files with auto-fill for rest
4. **Project Onboarding**: Instantly understand data flow in unfamiliar codebases

### Reference
- **Example**: `inst/examples/auto-annotation-example.R`
- **Tests**: `tests/testthat/test-put_auto.R`, `tests/testthat/test-put_generate.R`

## Logging System

### Overview
putior includes optional structured logging via the `logger` package for debugging annotation parsing, workflow detection, and diagram generation.

### Key Characteristics
- **Optional dependency**: `logger` in Suggests, not Imports
- **Silent degradation**: Package works without logger installed
- **No user-facing errors** if logger is missing

### Log Levels
| Level | Purpose |
|-------|---------|
| DEBUG | Fine-grained operations (file-by-file, pattern matching) |
| INFO | Progress milestones (scan started, nodes found, diagram complete) |
| WARN | Issues that don't stop execution (validation issues) - **default** |
| ERROR | Fatal issues (via existing `stop()` calls) |

### Configuration

**Global option:**
```r
# Set for entire session
options(putior.log_level = "DEBUG")

# Or use the helper function
set_putior_log_level("DEBUG")
```

**Per-call override:**
```r
# Override for a single call
workflow <- put("./R/", log_level = "DEBUG")
put_diagram(workflow, log_level = "INFO")
```

### Key Files
- `R/logging.R` - Logging infrastructure
- `R/zzz.R` - Package initialization
- `tests/testthat/test-logging.R` - Logging tests

## LLM Detection Patterns (GitHub Issue #10)

### Overview
putior auto-detects modern AI/ML library usage for workflow visualization. This enables automatic documentation of LLM-powered data pipelines.

### Supported Libraries

**R Patterns (15 patterns):**
| Library | Functions |
|---------|-----------|
| ellmer | `chat()`, `chat_openai()`, `chat_claude()`, `chat_ollama()`, `chat_gemini()`, `chat_groq()`, `chat_azure()` |
| tidyllm | `llm_message()`, `send_prompt()` |
| httr2 | API requests to OpenAI, Anthropic, Groq |

**Python Input Patterns (27 patterns):**
| Library | Functions |
|---------|-----------|
| ollama | `ollama.chat()`, `ollama.generate()`, `ollama.embeddings()` |
| openai | `OpenAI()`, `client.chat.completions.create()`, `client.embeddings.create()` |
| anthropic | `Anthropic()`, `client.messages.create()` |
| langchain | `ChatOpenAI()`, `ChatAnthropic()`, `ChatOllama()`, `LLMChain()`, `ChatGoogleGenerativeAI()` |
| transformers | `pipeline()`, `AutoModelForCausalLM.from_pretrained()`, `AutoTokenizer.from_pretrained()` |
| litellm | `litellm.completion()`, `litellm.embedding()` |
| vllm | `LLM()`, `vllm.LLM()` |
| google | `genai.GenerativeModel()`, `model.generate_content()` |
| groq | `Groq()` |

**Python Output Patterns (12 patterns):**
| Category | Functions |
|----------|-----------|
| Transformers | `model.save_pretrained()`, `tokenizer.save_pretrained()`, `trainer.save_model()` |
| PyTorch | `torch.save()`, `torch.onnx.export()` |
| Keras | `model.save()`, `model.save_weights()` |
| MLflow | `mlflow.log_model()`, `mlflow.sklearn.log_model()`, `mlflow.pytorch.log_model()` |

### Key Insights from Implementation
1. **Pattern specificity matters**: LLM client patterns (e.g., `OpenAI()`) are generic enough to catch initialization but specific enough to avoid false positives
2. **Output patterns for models**: Model saving is as important as inference for tracking ML workflows
3. **Multi-provider support**: Modern codebases often use multiple LLM providers - ellmer in R abstracts this nicely
4. **Transformers ecosystem**: The Hugging Face transformers library has consistent patterns (`from_pretrained`, `save_pretrained`) that are easy to detect

### Reference
- **Tests**: `tests/testthat/test-llm-patterns.R` (467 tests)
- **Patterns**: `R/detection_patterns.R` (search for "LLM/AI")

## Variable Reference Implementation (GitHub Issue #2)

### Key Concepts for `.internal` Extension
- **Purpose**: Track in-memory variables and objects during script execution
- **Usage**: `.internal` variables are **outputs only**, never inputs between scripts
- **Data Flow**: Use persistent files (RData, CSV, etc.) for inter-script communication
- **Example**: `output:'my_variable.internal, my_data.RData'`

### Critical Rules
1. **`.internal` variables exist only during script execution** → Cannot be inputs to other scripts
2. **Persistent files enable inter-script data flow** → Use saved files as inputs/outputs between scripts  
3. **Connected workflows require file-based dependencies** → Each script's file outputs become inputs to subsequent scripts
4. **Document computational steps** → Use `.internal` to show what variables are created within each script

### Example Implementation
```r
# Script 1: Creates variable and saves it
# put output:'data.internal, data.RData'
data <- process_something()
save(data, file = 'data.RData')

# Script 2: Uses saved file, creates new variable
# put input:'data.RData', output:'results.internal, results.csv'
load('data.RData')  # NOT 'data.internal'
results <- analyze(data)
write.csv(results, 'results.csv')
```

### Reference
- **Example**: `inst/examples/variable-reference-example.R`
- **GitHub Issues**: #2 (original discussion), #3 (metadata), #4 (hyperlinks)

## Interactive Diagram Features (GitHub Issues #3 & #4)

### Metadata Display (show_source_info)
Displays source file information in diagram nodes to help users identify where each workflow step is defined.

**Parameters:**
- `show_source_info = TRUE/FALSE` (default: FALSE) - Enable/disable source info display
- `source_info_style = "inline"/"subgraph"` (default: "inline") - How to display the info

**Usage:**
```r
# Inline style - shows file name below node label
put_diagram(workflow, show_source_info = TRUE)

# Subgraph style - groups nodes by source file
put_diagram(workflow, show_source_info = TRUE, source_info_style = "subgraph")
```

### Clickable Hyperlinks (enable_clicks)
Makes diagram nodes clickable to open source files directly in your preferred editor.

**Parameters:**
- `enable_clicks = TRUE/FALSE` (default: FALSE) - Enable/disable clickable nodes
- `click_protocol = "vscode"/"file"` (default: "vscode") - URL protocol

**Supported Protocols:**
- `"vscode"` - VS Code (vscode://file/path:line)
- `"file"` - Standard file:// protocol
- No `"rstudio"`: RStudio has no URL scheme for opening files (#101); `"rstudio"` warns and gives file:// links

**Usage:**
```r
# Enable VS Code clicks
put_diagram(workflow, enable_clicks = TRUE)

# Use file:// links
put_diagram(workflow, enable_clicks = TRUE, click_protocol = "file")

# Combine with source info
put_diagram(workflow, show_source_info = TRUE, enable_clicks = TRUE)
```

**Notes:**
- Line numbers are included when available from annotations (vscode:// links jump to the line; file:// links cannot)
- Artifact nodes (data files) are excluded from click directives
- Both features are backward compatible (off by default)

### Reference
- **Example**: `inst/examples/interactive-diagrams-example.R`

## Diagram Themes

### Available Themes (9 total)

**Standard Themes:**
| Theme | Description |
|-------|-------------|
| `light` | Default light theme with bright colors |
| `dark` | Dark theme for dark mode environments |
| `auto` | GitHub-adaptive with solid colors |
| `minimal` | Grayscale professional, print-friendly |
| `github` | Optimized for GitHub README files |

**Colorblind-Safe Themes (Viridis Family):**
| Theme | Palette | Best For |
|-------|---------|----------|
| `viridis` | Purple→Blue→Green→Yellow | General accessibility |
| `magma` | Purple→Red→Yellow | Print, high contrast |
| `plasma` | Purple→Pink→Orange→Yellow | Presentations |
| `cividis` | Blue→Gray→Yellow | Deuteranopia/protanopia |

### Usage
```r
# Standard themes
put_diagram(workflow, theme = "github")

# Colorblind-safe themes
put_diagram(workflow, theme = "viridis")
put_diagram(workflow, theme = "cividis")  # Maximum accessibility

# List all available themes
get_diagram_themes()
```

### Key Characteristics
- Viridis themes are perceptually uniform (equal steps appear equally different)
- All viridis themes tested for deuteranopia, protanopia, and tritanopia
- Cividis avoids red-green entirely, making it optimal for red-green colorblindness
- Artifact nodes use neutral gray across all themes for consistency

### Mermaid Configuration (#54)
`put_diagram()` writes a `config:` block into the diagram's frontmatter by default (`mermaid_config = "classic"`): dagre layout, classic look, `flowchart.wrappingWidth: 200`, `flowchart.minNodeWidth: 0`. It keeps Mermaid 11's drawing on Mermaid 12 renderers such as GitHub (12.1.0 since 2026-10-07), which otherwise draw the "neo" look with 120px label wrapping. It never sets `theme`: a frontmatter theme overrides the host's light/dark theme. `mermaid_config = "none"` gives the old output; a named list is written as given (minus `theme`).

### Reference
- **Example**: `inst/examples/theme-examples.R`
- **Key File**: `R/put_diagram.R` (functions: `get_theme_colors()`, `get_diagram_themes()`)

## Interactive Sandbox (Shiny App)

### Overview
putior includes an interactive Shiny app for experimenting with PUT annotations without writing files.

### Launch
```r
run_sandbox()  # Requires shiny package
```

### Features
- Paste or type annotated code
- **Syntax highlighting** via shinyAce (optional, degrades gracefully)
- Simulate multiple files using `# ===== File: name.R =====` markers
- Customize diagram settings (theme, direction, artifacts, etc.)
- View extracted workflow data
- Export generated Mermaid code
- **Copy to clipboard button** for quick Mermaid code export

### Location
- **App**: `inst/shiny/putior-sandbox/app.R`
- **Dependencies**: shiny (required), shinyAce (optional, in Suggests)

## Quarto Integration

### Overview
putior diagrams can be embedded in Quarto (`.qmd`) documents for reproducible reports and dashboards using native Mermaid chunk support.

### Quarto Availability
Quarto is bundled with RStudio. To render `.qmd` files:
- **RStudio**: Use the "Render" button or `quarto::quarto_render()`
- **Command line (Windows/WSL)**: Use Quarto CLI from RStudio's bundled installation:
  ```bash
  # From WSL
  "/mnt/c/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe" render file.qmd
  ```

### Key Technique: `knitr::knit_child()`

**Challenge**: Quarto's native `{mermaid}` chunks are static and cannot directly use dynamically generated R content.

**Solution**: Use `knitr::knit_child()` to dynamically generate a native `{mermaid}` chunk from R code:

1. **Visible chunk** (with code folding): Generates mermaid code and stores in variable
2. **Hidden chunk** (`output: asis`, `echo: false`): Uses `knit_child()` to process a dynamically created mermaid chunk

This approach:
- Uses Quarto's native Mermaid support (no CDN required)
- Maintains code folding for the R code
- Produces proper Mermaid diagrams with Quarto's built-in styling

### Usage Pattern
```r
# Chunk 1: Generate code (visible, foldable)
workflow <- put("./R/")
mermaid_code <- put_diagram(workflow, output = "raw")
```

```r
# Chunk 2: Output as native mermaid chunk (hidden)
#| output: asis
#| echo: false
mermaid_chunk <- paste0("```{mermaid}\n", mermaid_code, "\n```")
cat(knitr::knit_child(text = mermaid_chunk, quiet = TRUE))
```

### Reference
- **Example**: `inst/examples/quarto-example.qmd`

## GitHub Pages Deployment

### Current Configuration
- **Deployment Method**: Branch-based deployment from `gh-pages` branch
- **Workflow**: `.github/workflows/pkgdown-gh-pages.yaml` 
- **Important**: Development mode is disabled in `_pkgdown.yml` to ensure proper root-level deployment

### Key Settings
- `_pkgdown.yml`: Development mode must be disabled/commented out:
  ```yaml
  # development:
  #   mode: auto
  ```
- GitHub Pages Settings: Deploy from `gh-pages` branch (NOT GitHub Actions)
- Site URL: https://pjt222.github.io/putior/

### Deployment Workflow
1. Changes pushed to main branch trigger `pkgdown-gh-pages` workflow
2. Workflow builds pkgdown site with `pkgdown::build_site_github_pages()`
3. JamesIves/github-pages-deploy-action deploys `docs/` folder to `gh-pages` branch
4. GitHub Pages serves the site from `gh-pages` branch root

### Troubleshooting
- **404 Error**: Check if development mode is enabled in `_pkgdown.yml` (causes site to build in `dev/` subdirectory)
- **Deployment Issues**: Ensure GitHub Pages is set to deploy from `gh-pages` branch, not GitHub Actions
- **Build Failures**: Check workflow logs for pkgdown build errors

## Package Readiness
✅ **Production ready** - All checks passing  
✅ **CRAN submission ready** - Comprehensive documentation and testing  
✅ **Self-documenting** - Demonstrates own capabilities effectively  
✅ **Clean codebase** - Well-organized file structure and ignore patterns
✅ **GitHub Pages deployed** - Documentation site live at https://pjt222.github.io/putior/

## CRAN Release Tooling and Build Output

Release helper scripts live in `dev/cran/` (`build-and-check.R`,
`check-tarball.R`, `winbuilder.R`). Run each from the **package root**:
`Rscript dev/cran/<name>.R`. They assert `file.exists("DESCRIPTION")` and use
paths relative to `.` — no absolute `D:/dev/p/...`.

Build output stays inside the repo: the tarball at the package root (covered by
`/*.tar.gz` in `.gitignore`, `^.*\.tar\.gz$` in `.Rbuildignore`), throwaway
`.rds`/logs in `dev/cran/out/` (gitignored). `dev/` is excluded from the tarball
via `^dev$` in `.Rbuildignore`.

Never set `pkgbuild::build(dest_path = ...)` or a `saveRDS` target outside this
repo. See the temp-file policy in `../CLAUDE.md` — a prior release wrote its
build dir, tarball, logs and check `.rds` into `/mnt/d/dev/p`, which is what
that policy now forbids.

## Development Best Practices References
Development guides available for reference when needed (read on demand, not preloaded):
- `../agent-almanac/guides/r-package-development.md`
- `../agent-almanac/guides/setting-up-your-environment.md`
- `../agent-almanac/guides/quick-reference.md`

## Team Activation (when user requests a team)

A Claude Code session has a single implicit team; `TeamCreate` is on a deprecation path and is not offered in ordinary interactive sessions (checked against Claude Code v2.1.202, 2026-07-07). When the user asks to activate or use a team: (1) read the team definition from `/mnt/d/dev/p/agent-almanac/teams/<team-name>.md`, (2) spawn each listed member as a subagent with the Agent tool, following the team's lead and coordination shape, (3) coordinate them with `SendMessage`. Use `TeamCreate` only where `ToolSearch("select:TeamCreate")` actually offers it.

Available teams are listed in `/mnt/d/dev/p/agent-almanac/teams/_registry.yml`.
