# Tests for new language detection patterns (JavaScript, TypeScript, Go, Rust,
# Java, C, C++, MATLAB, Ruby, Lua)

# Helper function to count patterns
count_patterns <- function(language) {
  patterns <- get_detection_patterns(language)
  input_count <- length(patterns$input)
  output_count <- length(patterns$output)
  dep_count <- length(patterns$dependency)
  c(input = input_count, output = output_count, dependency = dep_count,
    total = input_count + output_count + dep_count)
}

# ============================================================================
# JavaScript Tests
# ============================================================================

test_that("JavaScript patterns exist and are valid", {
  patterns <- get_detection_patterns("javascript")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  # Check we have substantial patterns
  expect_gt(length(patterns$input), 20)
  expect_gt(length(patterns$output), 15)
  expect_gt(length(patterns$dependency), 0)
})

test_that("JavaScript input patterns include key functions", {
  patterns <- get_detection_patterns("javascript", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # Node.js fs
  expect_true("fs.readFileSync" %in% funcs)
  expect_true("fs.readFile" %in% funcs)
  expect_true("fs.createReadStream" %in% funcs)

  # HTTP clients
  expect_true("fetch" %in% funcs)
  expect_true("axios.get" %in% funcs)

  # Database
  expect_true("mongoose.connect" %in% funcs)
  expect_true("new PrismaClient" %in% funcs)

  # Express.js
  expect_true("req.body" %in% funcs)
  expect_true("req.params" %in% funcs)
})

test_that("JavaScript output patterns include key functions", {
  patterns <- get_detection_patterns("javascript", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # Node.js fs
  expect_true("fs.writeFileSync" %in% funcs)
  expect_true("fs.writeFile" %in% funcs)
  expect_true("fs.createWriteStream" %in% funcs)

  # Module exports
  expect_true("module.exports" %in% funcs)
  expect_true("export default" %in% funcs)

  # Express.js
  expect_true("res.send" %in% funcs)
  expect_true("res.json" %in% funcs)
})

test_that("JavaScript patterns match expected code snippets", {
  patterns <- get_detection_patterns("javascript", type = "input")

  # Test fs.readFileSync
  fs_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "fs.readFileSync"))]]
  expect_true(grepl(fs_pattern$regex, "const data = fs.readFileSync('file.txt')"))

  # Test fetch
  fetch_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "fetch"))]]
  expect_true(grepl(fetch_pattern$regex, "fetch('https://api.example.com')"))
})

# ============================================================================
# TypeScript Tests
# ============================================================================

test_that("TypeScript patterns exist and extend JavaScript", {
  ts_patterns <- get_detection_patterns("typescript")
  js_patterns <- get_detection_patterns("javascript")

  expect_type(ts_patterns, "list")
  expect_named(ts_patterns, c("input", "output", "dependency"))

  # TypeScript should have MORE patterns than JavaScript (it extends JS)
  expect_gte(length(ts_patterns$input), length(js_patterns$input))
})

test_that("TypeScript includes TS-specific patterns", {
  patterns <- get_detection_patterns("typescript", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # Type references
  expect_true("/// <reference path>" %in% funcs)
  expect_true("/// <reference types>" %in% funcs)

  # NestJS
  expect_true("@Controller" %in% funcs)
  expect_true("@Body" %in% funcs)

  # TypeORM
  expect_true("new DataSource" %in% funcs)
  expect_true("getRepository" %in% funcs)
})

# ============================================================================
# Go Tests
# ============================================================================

test_that("Go patterns exist and are valid", {
  patterns <- get_detection_patterns("go")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 15)
  expect_gt(length(patterns$output), 10)
})

test_that("Go input patterns include key functions", {
  patterns <- get_detection_patterns("go", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # os package
  expect_true("os.Open" %in% funcs)
  expect_true("os.ReadFile" %in% funcs)

  # bufio
  expect_true("bufio.NewReader" %in% funcs)
  expect_true("bufio.NewScanner" %in% funcs)

  # encoding/json
  expect_true("json.NewDecoder" %in% funcs)

  # database/sql
  expect_true("sql.Open" %in% funcs)

  # gorm
  expect_true("gorm.Open" %in% funcs)

  # net/http
  expect_true("http.Get" %in% funcs)
})

test_that("Go output patterns include key functions", {
  patterns <- get_detection_patterns("go", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # os package
  expect_true("os.Create" %in% funcs)
  expect_true("os.WriteFile" %in% funcs)

  # encoding/json
  expect_true("json.NewEncoder" %in% funcs)

  # fmt
  expect_true("fmt.Fprintf" %in% funcs)

  # gorm
  expect_true("db.Create" %in% funcs)
})

test_that("Go patterns match expected code snippets", {
  patterns <- get_detection_patterns("go", type = "input")

  # Test os.Open
  os_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "os.Open"))]]
  expect_true(grepl(os_pattern$regex, 'f, err := os.Open("file.txt")'))

  # Test json.NewDecoder
  json_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "json.NewDecoder"))]]
  expect_true(grepl(json_pattern$regex, "json.NewDecoder(r.Body)"))
})

# ============================================================================
# Rust Tests
# ============================================================================

test_that("Rust patterns exist and are valid", {
  patterns <- get_detection_patterns("rust")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 20)
  expect_gt(length(patterns$output), 15)
})

test_that("Rust input patterns include key functions", {
  patterns <- get_detection_patterns("rust", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # std::fs
  expect_true("File::open" %in% funcs)
  expect_true("fs::read_to_string" %in% funcs)

  # serde_json
  expect_true("serde_json::from_reader" %in% funcs)

  # csv
  expect_true("csv::Reader::from_path" %in% funcs)

  # sqlx
  expect_true("sqlx::connect" %in% funcs)

  # reqwest
  expect_true("reqwest::get" %in% funcs)
})

test_that("Rust output patterns include key functions", {
  patterns <- get_detection_patterns("rust", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # std::fs
  expect_true("File::create" %in% funcs)
  expect_true("fs::write" %in% funcs)

  # serde_json
  expect_true("serde_json::to_writer" %in% funcs)

  # csv
  expect_true("csv::Writer::from_path" %in% funcs)

  # logging
  expect_true("println!" %in% funcs)
})

test_that("Rust patterns match expected code snippets", {
  patterns <- get_detection_patterns("rust", type = "input")

  # Test File::open
  file_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "File::open"))]]
  expect_true(grepl(file_pattern$regex, 'let f = File::open("file.txt")?;'))
})

# ============================================================================
# Java Tests
# ============================================================================

test_that("Java patterns exist and are valid", {
  patterns <- get_detection_patterns("java")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 25)
  expect_gt(length(patterns$output), 20)
})

test_that("Java input patterns include key functions", {
  patterns <- get_detection_patterns("java", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # Classic I/O
  expect_true("new FileInputStream" %in% funcs)
  expect_true("new BufferedReader" %in% funcs)

  # NIO
  expect_true("Files.readAllLines" %in% funcs)
  expect_true("Files.readString" %in% funcs)

  # JDBC
  expect_true("DriverManager.getConnection" %in% funcs)

  # Jackson
  expect_true("objectMapper.readValue" %in% funcs)

  # Spring Boot
  expect_true("@RequestBody" %in% funcs)
  expect_true("@PathVariable" %in% funcs)

  # Spring Data
  expect_true("repository.findById" %in% funcs)

  # Hibernate
  expect_true("session.get" %in% funcs)
})

test_that("Java output patterns include key functions", {
  patterns <- get_detection_patterns("java", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # Classic I/O
  expect_true("new FileOutputStream" %in% funcs)
  expect_true("new BufferedWriter" %in% funcs)

  # NIO
  expect_true("Files.write" %in% funcs)
  expect_true("Files.writeString" %in% funcs)

  # Jackson
  expect_true("objectMapper.writeValue" %in% funcs)

  # Spring
  expect_true("ResponseEntity" %in% funcs)
  expect_true("repository.save" %in% funcs)

  # Logging
  expect_true("logger.info" %in% funcs)
})

test_that("Java patterns match expected code snippets", {
  patterns <- get_detection_patterns("java", type = "input")

  # Test Files.readAllLines
  files_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "Files.readAllLines"))]]
  expect_true(grepl(files_pattern$regex, 'List<String> lines = Files.readAllLines(path);'))

  # Test @RequestBody
  rb_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "@RequestBody"))]]
  expect_true(grepl(rb_pattern$regex, "public void create(@RequestBody User user)"))
})

# ============================================================================
# C Tests
# ============================================================================

test_that("C patterns exist and are valid", {
  patterns <- get_detection_patterns("c")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 8)
  expect_gt(length(patterns$output), 8)
})

test_that("C input patterns include key functions", {
  patterns <- get_detection_patterns("c", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # stdio.h
  expect_true("fopen" %in% funcs)
  expect_true("fread" %in% funcs)
  expect_true("fgets" %in% funcs)
  expect_true("fscanf" %in% funcs)

  # POSIX
  expect_true("read" %in% funcs)

  # Environment
  expect_true("getenv" %in% funcs)
})

test_that("C output patterns include key functions", {
  patterns <- get_detection_patterns("c", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # stdio.h
  expect_true("fwrite" %in% funcs)
  expect_true("fputs" %in% funcs)
  expect_true("fprintf" %in% funcs)
  expect_true("printf" %in% funcs)

  # POSIX
  expect_true("write" %in% funcs)
})

# ============================================================================
# C++ Tests
# ============================================================================

test_that("C++ patterns exist and extend C", {
  cpp_patterns <- get_detection_patterns("cpp")
  c_patterns <- get_detection_patterns("c")

  expect_type(cpp_patterns, "list")

  # C++ should have more patterns than C
  expect_gt(length(cpp_patterns$input), length(c_patterns$input))
  expect_gt(length(cpp_patterns$output), length(c_patterns$output))
})

test_that("C++ includes C++ specific patterns", {
  patterns <- get_detection_patterns("cpp", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # fstream
  expect_true("ifstream" %in% funcs)

  # std operations
  expect_true("std::getline" %in% funcs)
  expect_true("std::cin" %in% funcs)

  # filesystem
  expect_true("std::filesystem::directory_iterator" %in% funcs)
})

test_that("C++ output includes C++ specific patterns", {
  patterns <- get_detection_patterns("cpp", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # fstream
  expect_true("ofstream" %in% funcs)

  # std operations
  expect_true("std::cout" %in% funcs)
  expect_true("std::cerr" %in% funcs)

  # filesystem
  expect_true("std::filesystem::create_directory" %in% funcs)
})

# ============================================================================
# MATLAB Tests
# ============================================================================

test_that("MATLAB patterns exist and are valid", {
  patterns <- get_detection_patterns("matlab")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 15)
  expect_gt(length(patterns$output), 15)
})

test_that("MATLAB input patterns include key functions", {
  patterns <- get_detection_patterns("matlab", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # Data loading
  expect_true("load" %in% funcs)
  expect_true("importdata" %in% funcs)
  expect_true("readtable" %in% funcs)
  expect_true("readmatrix" %in% funcs)

  # Image/Audio/Video
  expect_true("imread" %in% funcs)
  expect_true("audioread" %in% funcs)
  expect_true("VideoReader" %in% funcs)

  # Scientific data
  expect_true("h5read" %in% funcs)
  expect_true("ncread" %in% funcs)
})

test_that("MATLAB output patterns include key functions", {
  patterns <- get_detection_patterns("matlab", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # Data saving
  expect_true("save" %in% funcs)
  expect_true("writetable" %in% funcs)
  expect_true("writematrix" %in% funcs)

  # Image/Audio/Video
  expect_true("imwrite" %in% funcs)
  expect_true("audiowrite" %in% funcs)
  expect_true("VideoWriter" %in% funcs)

  # Graphics
  expect_true("savefig" %in% funcs)
  expect_true("exportgraphics" %in% funcs)
})

test_that("MATLAB patterns match expected code snippets", {
  patterns <- get_detection_patterns("matlab", type = "input")

  # Test readtable
  rt_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "readtable"))]]
  expect_true(grepl(rt_pattern$regex, "T = readtable('data.csv')"))
})

# ============================================================================
# Ruby Tests
# ============================================================================

test_that("Ruby patterns exist and are valid", {
  patterns <- get_detection_patterns("ruby")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 25)
  expect_gt(length(patterns$output), 20)
})

test_that("Ruby input patterns include key functions", {
  patterns <- get_detection_patterns("ruby", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # File operations
  expect_true("File.read" %in% funcs)
  expect_true("File.readlines" %in% funcs)

  # CSV/JSON/YAML
  expect_true("CSV.read" %in% funcs)
  expect_true("JSON.parse" %in% funcs)
  expect_true("YAML.load_file" %in% funcs)

  # ActiveRecord
  expect_true("Model.find" %in% funcs)
  expect_true("Model.where" %in% funcs)

  # Rails
  expect_true("params[]" %in% funcs)

  # HTTP clients
  expect_true("Net::HTTP.get" %in% funcs)
  expect_true("HTTParty.get" %in% funcs)
})

test_that("Ruby output patterns include key functions", {
  patterns <- get_detection_patterns("ruby", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # File operations
  expect_true("File.write" %in% funcs)

  # JSON/YAML
  expect_true("JSON.generate" %in% funcs)
  expect_true("YAML.dump" %in% funcs)

  # Rails responses
  expect_true("render json:" %in% funcs)
  expect_true("send_file" %in% funcs)

  # ActiveRecord
  expect_true("Model.create" %in% funcs)
  expect_true("model.save" %in% funcs)

  # Logging
  expect_true("Rails.logger" %in% funcs)
})

test_that("Ruby patterns match expected code snippets", {
  patterns <- get_detection_patterns("ruby", type = "input")

  # Test File.read
  file_pattern <- patterns[[which(sapply(patterns, function(p) p$func == "File.read"))]]
  expect_true(grepl(file_pattern$regex, "content = File.read('config.yml')"))
})

# ============================================================================
# Lua Tests
# ============================================================================

test_that("Lua patterns exist and are valid", {
  patterns <- get_detection_patterns("lua")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gt(length(patterns$input), 5)
  expect_gt(length(patterns$output), 5)
})

test_that("Lua input patterns include key functions", {
  patterns <- get_detection_patterns("lua", type = "input")
  funcs <- sapply(patterns, function(p) p$func)

  # io library
  expect_true("io.open" %in% funcs)
  expect_true("io.read" %in% funcs)
  expect_true("io.lines" %in% funcs)

  # File loading
  expect_true("loadfile" %in% funcs)
  expect_true("dofile" %in% funcs)
})

test_that("Lua output patterns include key functions", {
  patterns <- get_detection_patterns("lua", type = "output")
  funcs <- sapply(patterns, function(p) p$func)

  # io library
  expect_true("io.write" %in% funcs)
  expect_true("file:write" %in% funcs)

  # Print
  expect_true("print" %in% funcs)
})

# ============================================================================
# WGSL Tests
# ============================================================================

test_that("WGSL patterns exist and are valid", {
  patterns <- get_detection_patterns("wgsl")

  expect_type(patterns, "list")
  expect_named(patterns, c("input", "output", "dependency"))

  expect_gte(length(patterns$input), 8)
  expect_gte(length(patterns$output), 3)
  expect_gte(length(patterns$dependency), 2)
})

test_that("WGSL input patterns include key constructs", {
  patterns <- get_detection_patterns("wgsl", type = "input")
  funcs <- vapply(patterns, function(p) p$func, character(1))

  expect_true("var<uniform>" %in% funcs)
  expect_true("var<storage, read>" %in% funcs)
  expect_true("texture_2d" %in% funcs)
  expect_true("texture_cube" %in% funcs)
  expect_true("sampler" %in% funcs)
  expect_true("textureSample" %in% funcs)
  expect_true("textureLoad" %in% funcs)
  expect_true("@location (input)" %in% funcs)
})

test_that("WGSL output patterns include key constructs", {
  patterns <- get_detection_patterns("wgsl", type = "output")
  funcs <- vapply(patterns, function(p) p$func, character(1))

  expect_true("var<storage, read_write>" %in% funcs)
  expect_true("texture_storage (write)" %in% funcs)
  expect_true("textureStore" %in% funcs)
  expect_true("@location (output)" %in% funcs)
})

test_that("WGSL dependency patterns include import mechanisms", {
  patterns <- get_detection_patterns("wgsl", type = "dependency")
  funcs <- vapply(patterns, function(p) p$func, character(1))

  expect_true("#import (naga-oil)" %in% funcs)
  expect_true("@import" %in% funcs)
})

test_that("WGSL patterns match expected code snippets", {
  input_patterns <- get_detection_patterns("wgsl", type = "input")
  output_patterns <- get_detection_patterns("wgsl", type = "output")
  dep_patterns <- get_detection_patterns("wgsl", type = "dependency")

  # Test var<uniform>
  uniform_pattern <- input_patterns[[which(
    vapply(input_patterns, function(p) p$func, character(1)) == "var<uniform>"
  )]]
  expect_true(grepl(uniform_pattern$regex,
    "@group(0) @binding(0) var<uniform> camera: CameraUniform;"))

  # Test var<storage, read>
  storage_r_pattern <- input_patterns[[which(
    vapply(input_patterns, function(p) p$func, character(1)) == "var<storage, read>"
  )]]
  expect_true(grepl(storage_r_pattern$regex,
    "@group(0) @binding(1) var<storage, read> particles: array<Particle>;"))

  # Test var<storage, read_write>
  storage_rw_pattern <- output_patterns[[which(
    vapply(output_patterns, function(p) p$func, character(1)) == "var<storage, read_write>"
  )]]
  expect_true(grepl(storage_rw_pattern$regex,
    "@group(0) @binding(2) var<storage, read_write> output_buf: array<f32>;"))

  # Test textureStore
  store_pattern <- output_patterns[[which(
    vapply(output_patterns, function(p) p$func, character(1)) == "textureStore"
  )]]
  expect_true(grepl(store_pattern$regex,
    "textureStore(output_texture, coords, color);"))

  # Test @location (input)
  loc_in_pattern <- input_patterns[[which(
    vapply(input_patterns, function(p) p$func, character(1)) == "@location (input)"
  )]]
  expect_true(grepl(loc_in_pattern$regex,
    "@location(0) position: vec3<f32>,"))

  # Test @location (output)
  loc_out_pattern <- output_patterns[[which(
    vapply(output_patterns, function(p) p$func, character(1)) == "@location (output)"
  )]]
  expect_true(grepl(loc_out_pattern$regex,
    "-> @location(0) vec4<f32>"))

  # Test #import (naga-oil)
  import_pattern <- dep_patterns[[which(
    vapply(dep_patterns, function(p) p$func, character(1)) == "#import (naga-oil)"
  )]]
  expect_true(grepl(import_pattern$regex,
    "#import bevy_pbr::mesh_functions"))

  # Test textureSample
  sample_pattern <- input_patterns[[which(
    vapply(input_patterns, function(p) p$func, character(1)) == "textureSample"
  )]]
  expect_true(grepl(sample_pattern$regex,
    "let color = textureSample(diffuse_texture, diffuse_sampler, uv);"))
})

# ============================================================================
# Cross-language validation tests
# ============================================================================

test_that("All new languages have valid regex patterns", {
  new_languages <- c("javascript", "typescript", "go", "rust",
                     "java", "c", "cpp", "matlab", "ruby", "lua",
                     "wgsl")

  for (lang in new_languages) {
    patterns <- get_detection_patterns(lang)

    # Test all input patterns
    for (p in patterns$input) {
      result <- tryCatch(
        grepl(p$regex, "test string"),
        error = function(e) NULL
      )
      expect_false(is.null(result),
                   label = paste("Valid regex in", lang, "input:", p$func))
    }

    # Test all output patterns
    for (p in patterns$output) {
      result <- tryCatch(
        grepl(p$regex, "test string"),
        error = function(e) NULL
      )
      expect_false(is.null(result),
                   label = paste("Valid regex in", lang, "output:", p$func))
    }

    # Test all dependency patterns
    for (p in patterns$dependency) {
      result <- tryCatch(
        grepl(p$regex, "test string"),
        error = function(e) NULL
      )
      expect_false(is.null(result),
                   label = paste("Valid regex in", lang, "dependency:", p$func))
    }
  }
})

test_that("All patterns have required fields", {
  new_languages <- c("javascript", "typescript", "go", "rust",
                     "java", "c", "cpp", "matlab", "ruby", "lua",
                     "wgsl")

  for (lang in new_languages) {
    patterns <- get_detection_patterns(lang)
    all_patterns <- c(patterns$input, patterns$output, patterns$dependency)

    for (p in all_patterns) {
      expect_true(!is.null(p$regex),
                  info = paste("Missing regex in", lang, "for", p$func))
      expect_true(!is.null(p$func),
                  info = paste("Missing func in", lang))
      expect_true(!is.null(p$description),
                  info = paste("Missing description in", lang, "for", p$func))
    }
  }
})

test_that("Pattern counts are reasonable", {
  # Check approximate counts match expectations
  js_count <- count_patterns("javascript")
  expect_gt(js_count["total"], 40, label = "JavaScript total patterns")

  ts_count <- count_patterns("typescript")
  expect_gt(ts_count["total"], js_count["total"], label = "TypeScript extends JavaScript")

  go_count <- count_patterns("go")
  expect_gt(go_count["total"], 25, label = "Go total patterns")

  rust_count <- count_patterns("rust")
  expect_gt(rust_count["total"], 30, label = "Rust total patterns")

  java_count <- count_patterns("java")
  expect_gt(java_count["total"], 45, label = "Java total patterns")

  c_count <- count_patterns("c")
  expect_gt(c_count["total"], 15, label = "C total patterns")

  cpp_count <- count_patterns("cpp")
  expect_gt(cpp_count["total"], c_count["total"], label = "C++ extends C")

  matlab_count <- count_patterns("matlab")
  expect_gt(matlab_count["total"], 20, label = "MATLAB total patterns")

  ruby_count <- count_patterns("ruby")
  expect_gt(ruby_count["total"], 35, label = "Ruby total patterns")

  lua_count <- count_patterns("lua")
  expect_gt(lua_count["total"], 10, label = "Lua total patterns")

  wgsl_count <- count_patterns("wgsl")
  expect_gt(wgsl_count["total"], 10, label = "WGSL total patterns")
})

# ============================================================================
# Language registry update tests
# ============================================================================

test_that("list_supported_languages includes new languages with detection_only=TRUE", {
  langs_with_detection <- list_supported_languages(detection_only = TRUE)

  # Check new languages are included
  expect_true("javascript" %in% langs_with_detection)
  expect_true("typescript" %in% langs_with_detection)
  expect_true("go" %in% langs_with_detection)
  expect_true("rust" %in% langs_with_detection)
  expect_true("java" %in% langs_with_detection)
  expect_true("c" %in% langs_with_detection)
  expect_true("cpp" %in% langs_with_detection)
  expect_true("matlab" %in% langs_with_detection)
  expect_true("ruby" %in% langs_with_detection)
  expect_true("lua" %in% langs_with_detection)
  expect_true("wgsl" %in% langs_with_detection)

  # Should have 16 total languages with detection support
  expect_equal(length(langs_with_detection), 16)
})

test_that("build_file_pattern includes new extensions with detection_only=TRUE", {
  pattern <- build_file_pattern(detection_only = TRUE)

  # Check key extensions are included
  expect_true(grepl("js", pattern))
  expect_true(grepl("ts", pattern))
  expect_true(grepl("go", pattern))
  expect_true(grepl("rs", pattern))
  expect_true(grepl("java", pattern))
  expect_true(grepl("cpp", pattern))
  expect_true(grepl("rb", pattern))
  expect_true(grepl("lua", pattern))
  expect_true(grepl("wgsl", pattern))
})

test_that("get_detection_patterns rejects invalid languages", {
  expect_error(get_detection_patterns("invalid_language"))
  expect_error(get_detection_patterns("cobol"))
  expect_error(get_detection_patterns("fortran"))
})

test_that("get_detection_patterns accepts all valid languages", {
  all_languages <- c("r", "python", "sql", "shell", "julia",
                     "javascript", "typescript", "go", "rust",
                     "java", "c", "cpp", "matlab", "ruby", "lua",
                     "wgsl")

  for (lang in all_languages) {
    result <- tryCatch(
      get_detection_patterns(lang),
      error = function(e) NULL
    )
    expect_false(is.null(result), label = paste("Language:", lang))
    expect_type(result, "list")
  }
})

# ============================================================================
# Total pattern count summary
# ============================================================================

test_that("Total pattern count is substantial", {
  all_languages <- c("r", "python", "sql", "shell", "julia",
                     "javascript", "typescript", "go", "rust",
                     "java", "c", "cpp", "matlab", "ruby", "lua",
                     "wgsl")

  total <- 0
  for (lang in all_languages) {
    total <- total + count_patterns(lang)["total"]
  }

  # Should have 600+ patterns total across all languages
  expect_gt(total, 600, label = "Total patterns across all languages")
})
