# Changelog

## putior 0.2.0

### Breaking Changes

- Renamed `putior_skills()` to
  [`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md).
  The function, its MCP tool (`putior_guide`), and its ACP operation
  (`guide`) all use the new name. `putior_help("skills")` still works as
  an alias for backward compatibility. The inst file was renamed from
  `SKILLS.md` to `GUIDE.md`, and the vignette from `skills.Rmd` to
  `ai-integration.Rmd`.

- [`put()`](https://pjt222.github.io/putior/reference/put.md),
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md),
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md),
  and
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  now default to `recursive = TRUE` (previously `FALSE`). Directory
  scans now include subdirectories by default. Pass `recursive = FALSE`
  for the old behavior.
  ([\#34](https://github.com/pjt222/putior/issues/34))

- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  output now starts with a frontmatter block that keeps Mermaid 11’s
  drawing on Mermaid 12 renderers that set a theme: GitHub has drawn
  Mermaid 12’s “neo” look, with labels wrapped at 120px, since it moved
  to Mermaid 12.1.0 in October 2026. The block sets the dagre layout,
  the classic look, a 200px wrapping width and no minimum node width; it
  sets no theme, so the page’s light or dark theme still applies.
  Mermaid 9.3.0 to 11.17.2 draw the same with or without it. The new
  argument `mermaid_config` takes `"classic"` (the default), `"none"`
  for the previous output, or a named list written as the configuration.
  The title, if any, shares the frontmatter. The MCP `put_diagram` tool
  has the same argument. Mermaid reads the frontmatter only at the very
  start of the diagram code, and versions before 9.3.0 not at all: text
  in front of it, such as an `%%{init}%%` line, makes the diagram fail
  to parse, so use `mermaid_config` instead, or `"none"` for such hosts.
  ([\#54](https://github.com/pjt222/putior/issues/54))

- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  output now also carries accessibility metadata for screen readers,
  right after the `flowchart` line: `accTitle` with the `title`, if one
  is given, and `accDescr` with a summary such as “Workflow with 4 steps
  and 3 data files.” (`.internal` variables are not counted as files).
  Mermaid puts them into the SVG’s `<title>` and `<desc>`; the
  frontmatter title alone does not (Mermaid 10.5.0 and later). The title
  is escaped so that Mermaid shows it as written: like labels, plus `<`
  and `%%{`, which Mermaid’s sanitizer and directive handling would
  change. Mermaid reads these lines from 9.1.0 on; for an older renderer
  use `accessibility = FALSE` together with `mermaid_config = "none"`.
  The MCP `put_diagram` tool has the same argument.
  [`?put_diagram`](https://pjt222.github.io/putior/reference/put_diagram.md)
  and `GUIDE.md` now list the Mermaid versions that putior supports and
  that its CI tests. A decision node with the id `accDescr` is now
  written as `node_accDescr`: `accDescr{` started an accDescr block, and
  the node lost its shape and label.
  ([\#50](https://github.com/pjt222/putior/issues/50))

- With `show_artifacts = TRUE`,
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  now draws each data hop once, through the file’s node
  (`script --> file --> script`). Before, it also drew a direct edge
  between the two scripts, so every hop appeared twice and the diagram
  had about 1.5 times the edges it needed, which brings Mermaid’s
  500-edge limit closer. A script that another script reads (such as
  `utils.R`) has no file node and keeps its direct edge.
  `artifact_edges = "both"` draws the direct edges as before; the MCP
  `put_diagram` tool has the same argument.
  ([\#55](https://github.com/pjt222/putior/issues/55))

### Bug Fixes

- Click links (`enable_clicks = TRUE`) now use the path the scan
  recorded (`file_path`) instead of the file’s base name, which was
  resolved against the working directory at the time the diagram was
  made. Absolute Unix paths give `vscode://file/home/...` and
  `file:///home/...` instead of a doubled or quadrupled slash, UNC paths
  (`//server/share/...`) give `vscode://file//server/...` and
  `file://server/...`, and a relative path to a missing file is made
  absolute. Paths are percent-encoded, and tooltips escaped like labels:
  a quote in a file name made the diagram fail to parse, and a name such
  as `direction LR.R` made Mermaid drop the click line. The docs now say
  that Mermaid keeps click links only with `securityLevel: "loose"`, so
  they do not work on GitHub, GitLab or in Quarto with default settings.
  The pkgdown site and the sandbox stay `"strict"`, because `"loose"`
  would also let click callbacks run JavaScript.
  ([\#47](https://github.com/pjt222/putior/issues/47))

- Fixed `show_source_info = TRUE` using `<small>` HTML tags that are
  unsupported by GitHub’s Mermaid renderer. Source file names are now
  shown without HTML formatting tags.
  ([\#32](https://github.com/pjt222/putior/issues/32))

- Fixed pipe characters (`|`) in node labels breaking Mermaid diagram
  parsing. Pipes are now escaped using the `#124;` entity.
  ([\#33](https://github.com/pjt222/putior/issues/33))

- [`put()`](https://pjt222.github.io/putior/reference/put.md) now gives
  annotations without an `id` a fallback id (`node_1`, `node_2`, …) when
  the uuid package is not installed. Before, such annotations had no id:
  if none had one,
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  failed with a misleading “missing required column(s): id” error, and
  if only some had one, it silently dropped the others. This broke the
  quick-start example and the sandbox templates for anyone without uuid.
  The sandbox now also shows diagram errors in its status line instead
  of a blank preview.
  ([\#58](https://github.com/pjt222/putior/issues/58))

- Fixed logging, which wrote nothing with logger 0.3 or later: every log
  call failed inside logger and the error was hidden. The
  `putior.log_level` option, set by
  [`set_putior_log_level()`](https://pjt222.github.io/putior/reference/set_putior_log_level.md)
  or for one call by the `log_level` argument, is now the only
  threshold, and an invalid `log_level` is an error. With logger
  installed, WARN-level messages now appear on stderr next to the
  matching R warnings.
  ([\#70](https://github.com/pjt222/putior/issues/70))

- Fixed single-line block comment annotations (`/* put ... */`) silently
  losing their last property, which could drop an output and its edge.
  ([\#72](https://github.com/pjt222/putior/issues/72))

- [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  no longer merges a manual annotation and an auto-detected file into
  one node when their ids meet: auto-detected rows get a suffix when
  their id (also in its Mermaid form, where `1` is `node_1`) is already
  used, so an unannotated `node_1.R` next to an annotation with the
  fallback id `node_1` stays separate. It also matches manual and
  auto-detected rows by file path, so an annotated `x/load.R` no longer
  hides an unannotated `y/load.R`, and with
  `merge_strategy = "supplement"` or `"union"` no longer takes the
  inputs and outputs detected in the other file.
  ([\#74](https://github.com/pjt222/putior/issues/74))

- Annotation values may now contain the other kind of quote:
  `label:"Don't panic"` and `label:'Say "hi"'` keep their labels.
  Before, [`put()`](https://pjt222.github.io/putior/reference/put.md)
  dropped any value with a quote character in it, without a warning, and
  the node showed its id instead; the troubleshooting vignette even
  recommended `label:"Load 'raw' data"`. There are still no escapes, so
  a value cannot contain its own kind of quote, and backslashes in
  Windows paths stay as they are. A property that
  [`put()`](https://pjt222.github.io/putior/reference/put.md) cannot
  read is now named in its validation warning (with `validate = TRUE`,
  the default) instead of being dropped silently, and
  [`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)
  returns `FALSE` for such a line. An annotation that ends with a
  continuation `\` (without a comma before it) on the last line of the
  file no longer loses its last property.
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  wraps a value that contains a double quote in single quotes, so that
  [`put()`](https://pjt222.github.io/putior/reference/put.md) reads its
  suggestions back unchanged.
  ([\#91](https://github.com/pjt222/putior/issues/91))

- A comment may now follow the values of an annotation, as the
  [`put()`](https://pjt222.github.io/putior/reference/put.md) help page,
  the vignettes and the cheatsheet have always shown
  (`# put id:"a", label:"Load" # first step`). Before, the comment made
  the last property unreadable, and it was dropped. Outside quotes,
  whitespace followed by `#`, `--`, `//` or `%` after a value starts the
  comment. In a multiline annotation, a comment may also come before the
  continuation `\` of a line.
  ([\#91](https://github.com/pjt222/putior/issues/91))

- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  gives every node one Mermaid id and uses it in the node definition,
  edges, `class` lines and click directives. Before, edges to an
  artifact whose path has two punctuation characters in a row (such as
  `./raw data (v2).csv`) used a different id than the artifact node, so
  Mermaid drew an extra unlabeled node and left the artifact
  unconnected. Annotation ids that differ only in punctuation (`a-b` and
  `a_b`) were merged into one node with a self-loop; they now stay two
  nodes (`a_b`, `a_b_2`) and
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  warns. Two data files whose names differ only in punctuation get two
  artifact nodes.
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  and
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md),
  which derive ids from file names, now give files that would share an
  id (`a-b.R` and `a_b.R`, `end.R` and `node_end.R`, or `load.R` in two
  folders) distinct ids (`load`, `load_2`).
  `put_generate(output = "file")` now writes each annotation next to the
  file it belongs to; when a file in between gave no annotation, the
  next one went into the wrong `.put` file.
  ([\#46](https://github.com/pjt222/putior/issues/46))

- Node ids that are Mermaid keywords (`end`, `graph`, `flowchart`,
  `subgraph`, `style`, `class`, `classDef`, `click`, `linkStyle`,
  `call`, `href`, `interpolate`, and the link targets `_self`, `_blank`,
  `_parent`, `_top`) made the whole diagram fail to parse. They are now
  written as `node_end` and so on. `id:"end"` is a natural name for a
  pipeline’s last step.
  ([\#45](https://github.com/pjt222/putior/issues/45))

- With `source_info_style = "subgraph"`, subgraph ids are now
  `file_<name>` and never equal a node id. Before, a file `load.R` with
  a node `id:"load"` failed to render (“would create a cycle”) on
  Mermaid 11, and on Mermaid 12, which GitHub uses, the node silently
  disappeared. Files with the same name in different folders now get one
  subgraph each instead of sharing one, and the subgraph label then
  includes as much of the folder path as it takes to tell them apart
  (`x/load.R`, `a/x/load.R`).
  ([\#45](https://github.com/pjt222/putior/issues/45),
  [\#46](https://github.com/pjt222/putior/issues/46))

- With `show_files = TRUE`, edge labels are now quoted and escaped like
  node labels (`-->|"raw data (v2).csv"|`). A file name with parentheses
  or other special characters made the diagram fail to parse.
  ([\#45](https://github.com/pjt222/putior/issues/45))

- The `title` of
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  is now written as a quoted YAML string. A title with `:` (such as
  `"ETL: stage 1"`) made the diagram fail to parse, and text after `#`
  was dropped as a YAML comment.
  ([\#45](https://github.com/pjt222/putior/issues/45))

- A `#` in a label that Mermaid would read as a character entity is now
  escaped as `#35;`. Mermaid decodes `#<name>;` and `#<digits>;`, so a
  label such as
  `Step `[`#35`](https://github.com/pjt222/putior/issues/35)`;` was
  shown as `Step #`. A plain `#` (`C#`,
  `item `[`#1`](https://github.com/pjt222/putior/issues/1)) is left
  alone.
  [`?put_diagram`](https://pjt222.github.io/putior/reference/put_diagram.md)
  now describes how labels and ids are written.
  ([\#45](https://github.com/pjt222/putior/issues/45))

- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  and the MCP and ACP servers accept `direction = "TB"`, Mermaid’s
  synonym for `"TD"`. GUIDE.md named `TB` as the default, but `"TB"` was
  rejected with an error.
  ([\#79](https://github.com/pjt222/putior/issues/79))

- Labels that contain Mermaid syntax are now written so that Mermaid
  shows them as written. Mermaid read a line with `direction`,
  whitespace and `TB`, `BT`, `RL` or `LR` (and `TD` from Mermaid 11.17.2
  on), as in “Change direction LR to TB”, as a direction statement and
  dropped it: the node lost its label, and with
  `source_info_style = "subgraph"` a file named `direction LR.R` made
  the diagram fail to parse. That whitespace is now written as an entity
  (`direction#32;LR`). The same rule spans line breaks, so an edge to an
  id ending in `direction` (`wind_direction`) followed by an edge from
  an id starting with `LR` (`LR_prep`) lost both edges; such an edge now
  ends with `;`. On a line where `style` or `classDef` comes before it,
  in the label or in the node id, a `:` followed by an escaped
  character, as in `style:"bold"` (written `style:#quot;bold#quot;`), is
  now written as `#58;`: Mermaid removed the last `;` of such a line and
  showed `style:"bold#quot`.
  ([\#89](https://github.com/pjt222/putior/issues/89))

- A `%%{` in a node, edge or subgraph label is now written with its
  first `%` as `#37;`, so that Mermaid shows it as written. Mermaid
  removes `%%{...}%%` directives from the whole diagram text before it
  parses it, so a label such as “Budget 50%%{x: draft” was cut short or
  made the diagram fail to parse, and with a later `}%%` the text in
  between was lost.
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  now also warns when the `title` contains a `<`: the drawn title then
  shows HTML entities such as `&lt;`, `&gt;` and `&amp;` and drops text
  that looks like an HTML tag, and no escape avoids that. The `accTitle`
  line shows the title as written.
  ([\#98](https://github.com/pjt222/putior/issues/98))

- A label with U+2028 or U+2029 (line and paragraph separator) followed
  by `%%` made the diagram fail to parse: Mermaid removes comment lines
  with a JavaScript regex that treats these characters as line ends.
  They are now written as spaces, as line breaks are. The title, the
  accTitle line and click tooltips already replaced them, except in the
  C locale; they now do so there too.
  ([\#104](https://github.com/pjt222/putior/issues/104))

- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  now warns when a drawn label contains a `<` before a letter, `/`, `!`
  or `?`, such as `n<threshold` or `<draft>`: Mermaid draws labels as
  HTML and reads it as the start of a tag, so the text up to the next
  `>` disappears (`a<b and c>d` shows “ad”). The docs show `&lt;` for a
  `<` that should show (`\lt` in `$$...$$` math). The tags `br`, `b`,
  `i`, `em`, `strong`, `sub`, `sup`, `code` and `span` still count as
  intended HTML. ([\#102](https://github.com/pjt222/putior/issues/102))

### New Features

#### MCP Server Integration

- Added
  [`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
  to expose putior functions as MCP tools for AI assistants
- Added
  [`putior_mcp_tools()`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)
  to get/filter tool definitions for custom MCP integrations
- 16 tools available: `put`, `put_diagram`, `put_auto`, `put_generate`,
  `put_merge`, `get_comment_prefix`, `get_supported_extensions`,
  `list_supported_languages`, `get_detection_patterns`,
  `get_diagram_themes`, `putior_guide`, `putior_help`,
  `set_putior_log_level`, `is_valid_put_annotation`, `split_file_list`,
  `ext_to_language`
- Supports Claude Code, Claude Desktop, and other MCP-compatible clients
- Tools return JSON (workflow data as one object per node) or plain
  text. They print nothing, because with the stdio transport stdout is
  the protocol channel, and never write files or the clipboard, so every
  tool except `set_putior_log_level` is read-only. The `put_diagram`
  tool scans a `path` and returns the Mermaid code.
  ([\#65](https://github.com/pjt222/putior/issues/65))
- The `put_diagram` tool takes a `source` argument: `annotations` (the
  default) scans with
  [`put()`](https://pjt222.github.io/putior/reference/put.md), `auto`
  draws the workflow that
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  detects, and `merge` combines both like
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md),
  with `merge_strategy`. When a scan finds nothing and R warned (the
  directory is empty, no file matches `pattern`, a file cannot be read),
  the scan tools now fail with R’s warnings instead of returning `[]` or
  empty text: the warnings never reached the client. When nothing
  warned, `put_diagram` says what is missing for its `source`: no
  annotations (and it suggests `source = "auto"`), or no file that
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  can analyze. ([\#73](https://github.com/pjt222/putior/issues/73))
- An argument that a client sends as `null` gets its default. Before,
  most arguments of the scan and diagram tools and of
  `list_supported_languages` then stopped the call with “argument is of
  length zero”.
- R warnings now reach the client. Over stdio they never did: they were
  written to stderr when the server stopped, so a `<` in a title or
  label, a diagram over Mermaid’s limits or an invalid annotation went
  unnoticed. A tool that warned returns the warnings (at most 20) as a
  second text item after its unchanged result. For `put_diagram` they
  are Mermaid comment lines, so the diagram still renders when a client
  joins both items, and a `%%{` in a quoted label cannot act as a
  directive. An error lists the warnings raised before it. The MCP
  server needs mcptools 1.0.0 or later, which passes such a list on;
  older versions turned it into “
  ” text.
- [`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
  serves only its 16 tools. mcptools’ tools for choosing a running R
  session (`list_r_sessions`, `select_r_session`) were on as well, so
  clients saw 18 tools, and a call could run in a user’s live R session
  instead of the server’s own process.

#### ACP Server Integration

- Added
  [`putior_acp_server()`](https://pjt222.github.io/putior/reference/putior_acp_server.md)
  to expose putior as an ACP agent for inter-agent communication via
  REST API
- Added
  [`putior_acp_manifest()`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md)
  for agent discovery
- Supports natural language requests for all core operations
- Input path sanitization to prevent directory traversal attacks. A path
  with `..` or control characters ends the run with an error; it used to
  be replaced by `.` with a warning in the server log, so the run
  scanned the server’s working directory. An unquoted `../` path is now
  recognized, so it is rejected too instead of being ignored.
- Unquoted paths in a request work: `scan ./R/` read the path as `./R/`,
  with the space in front, and reported that it does not exist.
- Warnings that R raises during a run (invalid annotations, a `<` in a
  label, …) come as a second `text/plain` part of the output; the server
  only logged them.
- A scan whose annotations name no input (or no label) is listed; the
  run stopped with “missing value where TRUE/FALSE needed”.

#### Multi-Language Comment Syntax (30+ Languages)

- Added support for 30+ programming languages with automatic comment
  prefix detection
- Comment styles: `#` (R, Python, Shell, etc.), `--` (SQL, Lua,
  Haskell), `//` (JavaScript, TypeScript, C/C++, Go, Rust, Java, etc.),
  `%` (MATLAB, LaTeX)
- Added
  [`get_comment_prefix()`](https://pjt222.github.io/putior/reference/get_comment_prefix.md),
  [`get_supported_extensions()`](https://pjt222.github.io/putior/reference/get_supported_extensions.md),
  [`ext_to_language()`](https://pjt222.github.io/putior/reference/ext_to_language.md)
- Added
  [`list_supported_languages()`](https://pjt222.github.io/putior/reference/list_supported_languages.md)
  to enumerate all supported languages

#### Auto-Detection Patterns (18 Languages, 902 Patterns)

- Full auto-detection for: R, Python, SQL, Shell, Julia, JavaScript,
  TypeScript, Go, Rust, Java, C, C++, MATLAB, Ruby, Lua, WGSL,
  Dockerfile, Makefile
- Pattern inheritance: TypeScript extends JavaScript, C++ extends C
- Single authoritative language registry (`R/language_registry.R`)

#### LLM Detection Patterns

- 54 patterns for modern AI/ML libraries across R and Python
- R: ellmer, tidyllm, httr2 (API requests)
- Python: ollama, openai, anthropic, langchain, transformers, litellm,
  vllm, google generative AI, groq

#### Auto-Annotation Feature

- Added
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  for automatic workflow detection from code analysis
- Added
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  for generating PUT annotation comments (roxygen2-style)
  - Now supports `output = "raw"` for programmatic access
- Added
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  for combining manual and auto-detected annotations
  - Three merge strategies: “manual_priority”, “supplement”, “union”

#### Colorblind-Safe Themes

- Added 4 viridis family themes for accessibility:
  - `viridis`: Purple-blue-green-yellow (general accessibility)
  - `magma`: Purple-red-yellow (high contrast, print-friendly)
  - `plasma`: Purple-pink-orange-yellow (presentations)
  - `cividis`: Blue-gray-yellow (deuteranopia/protanopia optimized)
- All themes perceptually uniform and tested for color vision
  deficiencies

#### Custom Theme API

- Added
  [`put_theme()`](https://pjt222.github.io/putior/reference/put_theme.md)
  for creating custom color palettes
  ([\#39](https://github.com/pjt222/putior/issues/39))
- New `palette` parameter on
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  accepts `putior_theme` objects
- Override individual node types (input, process, output, decision,
  artifact, start, end)
- Base theme inheritance — customize only what you need. An override
  keeps every key it does not set from the `base` theme’s style for that
  node type, including the text color and the border width (3px for
  start and end nodes, 1px for artifacts); earlier development versions
  dropped the unset keys and forced a 2px border
  ([\#61](https://github.com/pjt222/putior/issues/61)). If an override
  changes how light `fill` is, set `color` too, so the label stays
  readable

#### Block Comment Annotations

- Added PUT annotation support inside `/* */` and `/** */` block
  comments ([\#37](https://github.com/pjt222/putior/issues/37))
- Use `* put` as line prefix inside block bodies for all `//`-prefix
  languages
- Supports single-line block comments and JSDoc-style patterns

#### File Exclusion

- Added `exclude` parameter to
  [`put()`](https://pjt222.github.io/putior/reference/put.md),
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md),
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md),
  and
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  for regex-based file exclusion
  ([\#38](https://github.com/pjt222/putior/issues/38))

#### WGSL Shader Language Support

- Registered `.wgsl` with `//` comment prefix
  ([\#31](https://github.com/pjt222/putior/issues/31))
- 17 auto-detection patterns for GPU bindings, textures, samplers, and
  naga-oil imports

#### Dockerfile Support

- Handle extensionless Dockerfile via `.FILENAME_MAP`
  ([\#35](https://github.com/pjt222/putior/issues/35))
- 13 detection patterns for FROM, COPY, ADD, EXPOSE, VOLUME, CMD, RUN

#### Makefile Support

- Handle Makefile and GNUmakefile via `.FILENAME_MAP`
  ([\#36](https://github.com/pjt222/putior/issues/36))
- 10 detection patterns for include, wildcard, target rules, install,
  shell commands

#### Metadata Display

- Added `show_source_info` parameter to
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  for displaying source file information in diagram nodes
- Added `source_info_style` parameter with “inline” and “subgraph”
  display options

#### Clickable Hyperlinks

- Added `enable_clicks` parameter to
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  for making nodes clickable
- Added `click_protocol` parameter: “vscode” or “file”. The development
  version also offered “rstudio”, which was removed before release:
  RStudio has no URL scheme for opening files, so `rstudio://` links did
  nothing. `click_protocol = "rstudio"` now warns and writes `file://`
  links. ([\#101](https://github.com/pjt222/putior/issues/101))
- Click tooltips name the line (“Open a.R at line 3”) only for
  `vscode://` links, which open that line; `file://` links have no line
  number.
- Click directives include line numbers when available

#### Structured Logging

- Optional `logger` package integration for debugging annotation parsing
- Log levels: DEBUG, INFO, WARN (default), ERROR
- Added
  [`set_putior_log_level()`](https://pjt222.github.io/putior/reference/set_putior_log_level.md)
  for configuration
- Per-call override via `log_level` parameter on core functions

#### S3 Workflow Class

- Workflow data frames now have `putior_workflow` S3 class
- Added
  [`print.putior_workflow()`](https://pjt222.github.io/putior/reference/print.putior_workflow.md)
  for concise workflow summaries
- Added
  [`summary.putior_workflow()`](https://pjt222.github.io/putior/reference/summary.putior_workflow.md)
  for structured summary information

#### Interactive Sandbox

- New
  [`run_sandbox()`](https://pjt222.github.io/putior/reference/run_sandbox.md)
  opens an interactive Shiny app for trying PUT annotations: paste or
  type annotated code, simulate several files, and see the workflow
  diagram update as you edit (needs the shiny package)
- Added copy-to-clipboard button for quick Mermaid code export
- Added optional shinyAce syntax highlighting (graceful degradation)
- The sandbox loads Mermaid 12.2.0 from jsdelivr, pinned with a
  Subresource Integrity hash
  ([\#48](https://github.com/pjt222/putior/issues/48)). It draws
  diagrams in Mermaid 11’s classic style (dagre layout, classic look,
  200px label wrapping, no minimum node width), which putior’s themes
  are made for and which GitLab, Quarto and VS Code show. GitHub moved
  to Mermaid 12 in October 2026 and draws putior diagrams in the neo
  look with labels wrapped at 120px
  ([\#54](https://github.com/pjt222/putior/issues/54)). A diagram with a
  syntax error shows Mermaid’s error message. Mermaid 12 needs a current
  browser (ES2024; Safari 17.4 or later)
- File markers (`# ===== File: name.R =====`) are read one line at a
  time, with any spaces or tabs around them, at least three `=` and an
  optional closing run, so an unclosed marker no longer takes the next
  file with it and a name containing `=` is recognized. When two
  simulated files have the same name (ignoring case), both are kept, the
  later one in a `copy_2/` folder, and the status line says so; so does
  text before the first marker, which is ignored. File names are made
  safe to write on Windows (trailing dots dropped, characters such as
  `:` or `?` replaced), and a file that still cannot be written is left
  out with a note instead of emptying the whole diagram
  ([\#53](https://github.com/pjt222/putior/issues/53))
- If Mermaid cannot be loaded from jsdelivr (no network, a blocked CDN),
  the preview says so instead of staying blank, and the copy button and
  the Mermaid Code tab still work. A diagram that changes while the
  preview is hidden is drawn as soon as the preview is visible again,
  whether its tab is shown or a collapsed pane is opened
  ([\#64](https://github.com/pjt222/putior/issues/64))

#### Documentation

- Documented all valid `node_type` values across vignettes and reference
  ([\#40](https://github.com/pjt222/putior/issues/40))
- 8 comprehensive vignettes including quick-start, annotation guide,
  features tour, API reference, showcase, troubleshooting,
  quick-reference, and AI integration
- Professional cheat sheet (`inst/cheatsheet/putior-cheatsheet.qmd`)
- 20 example files in `inst/examples/`
- [`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md)
  and
  [`putior_help()`](https://pjt222.github.io/putior/reference/putior_help.md)
  for in-session reference

#### New Helper Functions

- [`resolve_label()`](https://pjt222.github.io/putior/reference/resolve_label.md)
  internal helper to reduce code duplication in diagram generation
- `sanitize_acp_path()` for ACP input validation
- [`normalize_path_for_url()`](https://pjt222.github.io/putior/reference/normalize_path_for_url.md)
  for cross-platform path handling
- [`generate_click_url()`](https://pjt222.github.io/putior/reference/generate_click_url.md)
  for creating protocol-specific URLs
- [`generate_click_directives()`](https://pjt222.github.io/putior/reference/generate_click_directives.md)
  for Mermaid click action generation
- [`generate_file_subgraphs()`](https://pjt222.github.io/putior/reference/generate_file_subgraphs.md)
  for file-based node grouping

### Bug Fixes

- Fixed ACP
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  called with invalid `output = "raw"` (now supported)
- Fixed MCP theme enum missing viridis family themes
- Fixed documentation using deprecated `name` instead of `id` in
  examples
- Fixed ACP theme extraction regex missing colorblind-safe themes
- Replaced unsafe `1:nrow()` loops with `seq_len(nrow())` to handle
  empty data frames
- Moved `%||%` operator from `acp.R` to `zzz.R` for shared access

### Improvements

- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  warns when a diagram is over Mermaid’s default limits of 500 edges
  (`maxEdges`) or 50,000 characters (`maxTextSize`). Renderers such as
  GitHub, GitLab and Quarto then show an error or an empty placeholder,
  and the diagram cannot raise either limit itself. The size is counted
  as `mermaid.render()` counts it (without the frontmatter and comments,
  with the newline that ends a code block), and the Mermaid check
  confirms both limits at the boundary. Hosts that use `mermaid.run()`,
  such as pkgdown sites, count up to a few characters less, so the
  warning there can come a little early, never late. The warning names
  the options;
  [`?put_diagram`](https://pjt222.github.io/putior/reference/put_diagram.md)
  and the troubleshooting vignette describe both limits. Large diagrams
  are also much faster to generate: a 500-step chain took about two
  minutes, because every input looked through every step’s outputs, and
  now takes about two seconds.
  ([\#56](https://github.com/pjt222/putior/issues/56))
- Consolidated language detection list into single authoritative
  registry (`.LANGUAGES_WITH_DETECTION` in `language_registry.R`)
- Standardized `output` parameter across
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md),
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md),
  and
  [`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md)
  – all now support “raw”
- Extracted duplicated label resolution into
  [`resolve_label()`](https://pjt222.github.io/putior/reference/resolve_label.md)
  helper
- Added input path sanitization to ACP server endpoints

### Backward Compatibility

- All new parameters default to FALSE/previous behavior
- Existing code continues to work unchanged
- `putior_workflow` class inherits from `data.frame`, preserving
  compatibility

## putior 0.1.0

CRAN release: 2025-06-19

- Initial CRAN submission
- Added [`put()`](https://pjt222.github.io/putior/reference/put.md)
  function for extracting workflow annotations from source code files
- Added
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  function for creating Mermaid flowchart diagrams
- Added
  [`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)
  for validating annotation syntax
- Support for multiple programming languages: R, Python, SQL, Shell, and
  Julia
- Multiline annotation support with backslash continuation syntax for
  better code style compliance
- Automatic UUID generation when `id` field is omitted from annotations
- Automatic output defaulting to file name when `output` field is
  omitted
- Renamed annotation field from `name` to `id` for better graph theory
  alignment
- Five built-in themes for diagrams: light, dark, auto, minimal, and
  github
- Automatic file flow tracking between workflow steps
- Comprehensive vignette with examples
- Full test coverage for all major functions
