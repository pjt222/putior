# putior 0.1.0

* Initial CRAN submission
* Added `put()` function for extracting workflow annotations from source code files
* Added `put_diagram()` function for creating Mermaid flowchart diagrams
* Added `is_valid_put_annotation()` for validating annotation syntax
* Support for multiple programming languages: R, Python, SQL, Shell, and Julia
* Automatic UUID generation when `id` field is omitted from annotations
* Automatic output defaulting to file name when `output` field is omitted
* Renamed annotation field from `name` to `id` for better graph theory alignment
* Five built-in themes for diagrams: light, dark, auto, minimal, and github
* Automatic file flow tracking between workflow steps
* Comprehensive vignette with examples
* Full test coverage for all major functions