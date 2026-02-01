# Quick Reference

## Quickest Start

``` r
put("./src/") |> put_diagram()
```

## Annotation Syntax

    #put id:"node_id", label:"Description", node_type:"process", input:"in.csv", output:"out.csv"

| Field       | Required | Default   | Description                              |
|-------------|----------|-----------|------------------------------------------|
| `label`     | **Yes**  | \-        | Human-readable name                      |
| `id`        | No       | UUID      | Unique identifier                        |
| `node_type` | No       | `process` | `input`, `process`, `output`, `decision` |
| `input`     | No       | \-        | Comma-separated input files              |
| `output`    | No       | filename  | Comma-separated output files             |

**Multiline**: End lines with `\` for continuation.

## Comment Prefixes

Find your language:

    #put  →  R, Python, Shell, Julia, Ruby, YAML, Perl, TOML
    --put →  SQL, Lua
    //put →  JavaScript, TypeScript, Go, Rust, Java, C, C++, Swift
    %put  →  MATLAB, LaTeX

## Core Functions

| Function                                                                      | Purpose              | Example                  |
|-------------------------------------------------------------------------------|----------------------|--------------------------|
| [`put()`](https://pjt222.github.io/putior/reference/put.md)                   | Extract annotations  | `put("./src/")`          |
| [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)   | Generate Mermaid     | `put_diagram(workflow)`  |
| [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)         | Auto-detect workflow | `put_auto("./src/")`     |
| [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md) | Suggest annotations  | `put_generate("./src/")` |
| [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)       | Merge manual + auto  | `put_merge("./src/")`    |

## Common Patterns

**Basic**

``` r
put("./src/") |> put_diagram()
```

**Customize**

``` r
put_diagram(wf, theme = "dark", direction = "LR")
put_diagram(wf, show_artifacts = FALSE)       # Hide data files
put_diagram(wf, show_source_info = TRUE)      # Show file info
```

**Save**

``` r
put_diagram(wf, output = "workflow.md")
```

**Debug**

``` r
put("./", log_level = "DEBUG")
```

## Themes and Direction

| Theme     | Use Case                  |
|-----------|---------------------------|
| `light`   | Bright colors (default)   |
| `dark`    | Dark mode UIs             |
| `minimal` | Print-friendly, grayscale |
| `github`  | README files              |

**Directions**: `TB` (default), `LR`, `BT`, `RL`

## Node Types

| Type       | Shape     | Use For           |
|------------|-----------|-------------------|
| `input`    | Stadium   | Data loading      |
| `process`  | Rectangle | Transformations   |
| `output`   | Stadium   | Reports, exports  |
| `decision` | Diamond   | Conditional logic |

## See Also

[Quick Start](https://pjt222.github.io/putior/articles/quick-start.md)
\| [Annotation
Guide](https://pjt222.github.io/putior/articles/annotation-guide.md) \|
[API
Reference](https://pjt222.github.io/putior/articles/api-reference.md)
