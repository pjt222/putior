# Showcase: Real-World Examples

This showcase demonstrates putior diagrams at different scales, from
simple workflows to complex multi-file pipelines.

## Small Workflows (3-5 nodes)

Perfect for single-purpose scripts or focused analysis tasks.

### Example: Simple ETL Pipeline

A basic extract-transform-load workflow:

``` r
# 01_extract.R
#put label:"Extract Data", node_type:"input", output:"raw_data.csv"

# 02_transform.R
#put label:"Transform Data", input:"raw_data.csv", output:"clean_data.csv"

# 03_load.R
#put label:"Load to Database", node_type:"output", input:"clean_data.csv"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    extract([Extract Data])
    transform[Transform Data]
    load[[Load to Database]]

    %% Connections
    extract --> transform
    transform --> load

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class extract inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class transform processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class load outputStyle
```

### Example: Report Generation

A simple report generation workflow:

``` r
# fetch_metrics.R
#put label:"Fetch Metrics", node_type:"input", output:"metrics.json"

# analyze.R
#put label:"Analyze Trends", input:"metrics.json", output:"analysis.rds"

# report.R
#put label:"Generate Report", node_type:"output", input:"analysis.rds", output:"report.html"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    fetch([Fetch Metrics])
    analyze[Analyze Trends]
    report[[Generate Report]]

    %% Connections
    fetch --> analyze
    analyze --> report

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class fetch inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class analyze processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class report outputStyle
```

## Medium Workflows (10-15 nodes)

Suitable for typical data science projects with multiple processing
stages.

### Example: Machine Learning Pipeline

A complete ML workflow from data collection to model deployment:

``` r
# 01_collect_data.py
#put label:"Collect Raw Data", node_type:"input", output:"raw_data.csv"

# 02_clean_data.R
#put label:"Clean Data", input:"raw_data.csv", output:"clean_data.csv"

# 03_feature_eng.R
#put label:"Feature Engineering", input:"clean_data.csv", output:"features.csv"

# 04_split_data.R
#put label:"Train/Test Split", input:"features.csv", output:"train.csv, test.csv"

# 05_train_model.py
#put label:"Train Model", input:"train.csv", output:"model.pkl"

# 06_evaluate.py
#put label:"Evaluate Model", input:"model.pkl, test.csv", output:"metrics.json"

# 07_hyperparameter.py
#put label:"Hyperparameter Tuning", input:"train.csv", output:"best_params.json"

# 08_retrain.py
#put label:"Retrain with Best Params", input:"train.csv, best_params.json", output:"final_model.pkl"

# 09_validate.R
#put label:"Final Validation", input:"final_model.pkl, test.csv", output:"validation_report.html"

# 10_deploy.sh
#put label:"Deploy Model", node_type:"output", input:"final_model.pkl, validation_report.html"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    collect([Collect Raw Data])
    clean[Clean Data]
    feature[Feature Engineering]
    split[Train/Test Split]
    train[Train Model]
    evaluate[Evaluate Model]
    hyper[Hyperparameter Tuning]
    retrain[Retrain with Best Params]
    validate[Final Validation]
    deploy[[Deploy Model]]

    %% Connections
    collect --> clean
    clean --> feature
    feature --> split
    split --> train
    train --> evaluate
    split --> evaluate
    split --> hyper
    split --> retrain
    hyper --> retrain
    retrain --> validate
    split --> validate
    retrain --> deploy
    validate --> deploy

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class collect inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class clean processStyle
    class feature processStyle
    class split processStyle
    class train processStyle
    class evaluate processStyle
    class hyper processStyle
    class retrain processStyle
    class validate processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class deploy outputStyle
```

### Example: Multi-Source Data Integration

Combining data from multiple sources:

``` r
# sources/fetch_sales.R
#put label:"Fetch Sales API", node_type:"input", output:"sales_raw.json"

# sources/fetch_inventory.R
#put label:"Fetch Inventory DB", node_type:"input", output:"inventory_raw.csv"

# sources/fetch_customers.py
#put label:"Fetch Customer CRM", node_type:"input", output:"customers_raw.csv"

# transform/clean_sales.R
#put label:"Clean Sales", input:"sales_raw.json", output:"sales_clean.csv"

# transform/clean_inventory.R
#put label:"Clean Inventory", input:"inventory_raw.csv", output:"inventory_clean.csv"

# transform/clean_customers.R
#put label:"Clean Customers", input:"customers_raw.csv", output:"customers_clean.csv"

# integrate/merge_data.R
#put label:"Merge All Sources", input:"sales_clean.csv, inventory_clean.csv, customers_clean.csv", output:"integrated_data.csv"

# analyze/business_metrics.R
#put label:"Calculate Metrics", input:"integrated_data.csv", output:"metrics.rds"

# report/dashboard.R
#put label:"Generate Dashboard", node_type:"output", input:"metrics.rds", output:"dashboard.html"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    sales_api([Fetch Sales API])
    inv_db([Fetch Inventory DB])
    cust_crm([Fetch Customer CRM])
    clean_sales[Clean Sales]
    clean_inv[Clean Inventory]
    clean_cust[Clean Customers]
    merge[Merge All Sources]
    metrics[Calculate Metrics]
    dashboard[[Generate Dashboard]]

    %% Connections
    sales_api --> clean_sales
    inv_db --> clean_inv
    cust_crm --> clean_cust
    clean_sales --> merge
    clean_inv --> merge
    clean_cust --> merge
    merge --> metrics
    metrics --> dashboard

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class sales_api inputStyle
    class inv_db inputStyle
    class cust_crm inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class clean_sales processStyle
    class clean_inv processStyle
    class clean_cust processStyle
    class merge processStyle
    class metrics processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class dashboard outputStyle
```

## Large Workflows (20+ nodes)

For enterprise-scale data pipelines and complex analysis systems.

### Example: Complete Analytics Platform

A full analytics platform with multiple parallel processing streams.

*Note: This complex subgraph diagram uses advanced Mermaid features
(named subgraphs) that
[`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
doesn’t generate natively. For enterprise workflows with complex
groupings, you can combine putior-generated diagrams with hand-crafted
Mermaid extensions.*

``` mermaid
flowchart TD
    subgraph Data_Sources [Data Sources]
        web_logs([Web Logs])
        app_events([App Events])
        crm_data([CRM Data])
        finance_data([Finance Data])
    end

    subgraph Ingestion [Ingestion Layer]
        parse_logs[Parse Web Logs]
        parse_events[Parse App Events]
        extract_crm[Extract CRM]
        extract_finance[Extract Finance]
    end

    subgraph Transformation [Transformation Layer]
        clean_logs[Clean Logs]
        clean_events[Clean Events]
        clean_crm[Clean CRM]
        clean_finance[Clean Finance]

        enrich_logs[Enrich with Geo]
        enrich_events[Add Session Info]
        join_customer[Join Customer Data]
    end

    subgraph Analytics [Analytics Layer]
        user_behavior[User Behavior Analysis]
        conversion_funnel[Conversion Funnel]
        revenue_analysis[Revenue Analysis]
        cohort_analysis[Cohort Analysis]
        ab_testing[A/B Test Results]
    end

    subgraph Output [Output Layer]
        exec_dashboard[[Executive Dashboard]]
        marketing_report[[Marketing Report]]
        finance_report[[Finance Report]]
        data_warehouse[[Data Warehouse]]
    end

    web_logs --> parse_logs
    app_events --> parse_events
    crm_data --> extract_crm
    finance_data --> extract_finance

    parse_logs --> clean_logs
    parse_events --> clean_events
    extract_crm --> clean_crm
    extract_finance --> clean_finance

    clean_logs --> enrich_logs
    clean_events --> enrich_events
    clean_crm --> join_customer
    clean_finance --> revenue_analysis

    enrich_logs --> user_behavior
    enrich_events --> user_behavior
    enrich_events --> conversion_funnel
    join_customer --> cohort_analysis
    join_customer --> ab_testing

    user_behavior --> exec_dashboard
    conversion_funnel --> marketing_report
    revenue_analysis --> finance_report
    cohort_analysis --> exec_dashboard
    ab_testing --> marketing_report

    user_behavior --> data_warehouse
    revenue_analysis --> data_warehouse
    cohort_analysis --> data_warehouse

    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d

    class web_logs,app_events,crm_data,finance_data inputStyle
    class parse_logs,parse_events,extract_crm,extract_finance processStyle
    class clean_logs,clean_events,clean_crm,clean_finance processStyle
    class enrich_logs,enrich_events,join_customer processStyle
    class user_behavior,conversion_funnel,revenue_analysis,cohort_analysis,ab_testing processStyle
    class exec_dashboard,marketing_report,finance_report,data_warehouse outputStyle
```

## Multi-Language Workflows

putior excels at documenting polyglot data pipelines with **automatic
comment syntax detection** for 30+ languages.

### Language-Specific Comment Syntax

| Comment Style | Languages                                 | Example                        |
|---------------|-------------------------------------------|--------------------------------|
| `#put`        | R, Python, Shell, Julia, Ruby, YAML       | `#put label:"Process Data"`    |
| `--put`       | SQL, Lua, Haskell                         | `--put label:"Query Database"` |
| `//put`       | JavaScript, TypeScript, C, Go, Rust, Java | `//put label:"Transform JSON"` |
| `%put`        | MATLAB, LaTeX                             | `%put label:"Compute Matrix"`  |

### JavaScript/TypeScript Example

``` javascript
// api_handler.js
//put label:"API Handler", node_type:"input", output:"api_response.json"
const response = await fetch('/api/data');
const data = await response.json();

//put label:"Data Validation", input:"api_response.json", output:"validated.json"
const validated = validateSchema(data);
```

### Go Example

``` go
// processor.go
//put label:"Data Processor", input:"input.json", output:"output.json"
func ProcessData(input []byte) ([]byte, error) {
    // Processing logic
}
```

### MATLAB Example

``` matlab
% signal_analysis.m
%put label:"Signal Processing", node_type:"input", output:"signal_data.mat"
data = load('raw_signal.mat');

%put label:"FFT Analysis", input:"signal_data.mat", output:"frequency_spectrum.mat"
spectrum = fft(data.signal);
```

### Example: R + Python + SQL Pipeline

Each language uses its native comment syntax:

``` sql
-- extract.sql (SQL uses -- comments)
--put label:"SQL Extract", node_type:"input", output:"raw_query_results.csv"
SELECT * FROM sales WHERE date > '2024-01-01';
```

``` python
# transform.py (Python uses # comments)
#put label:"Python Transform", input:"raw_query_results.csv", output:"transformed.parquet"
import pandas as pd
df = pd.read_csv("raw_query_results.csv")
```

``` r
# analyze.R (R uses # comments)
#put label:"R Statistical Analysis", input:"transformed.parquet", output:"stats.rds"
library(arrow)
data <- read_parquet("transformed.parquet")
```

``` r
# visualize.R
#put label:"R Visualization", input:"stats.rds", output:"plots.pdf"

# report.py
#put label:"Python Report Gen", node_type:"output", input:"stats.rds, plots.pdf", output:"final_report.html"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    sql([SQL Extract])
    python_transform[Python Transform]
    r_stats[R Statistical Analysis]
    r_viz[R Visualization]
    python_report[[Python Report Gen]]

    %% Connections
    sql --> python_transform
    python_transform --> r_stats
    r_stats --> r_viz
    r_stats --> python_report
    r_viz --> python_report

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class sql inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class python_transform processStyle
    class r_stats processStyle
    class r_viz processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class python_report outputStyle
```

## Domain-Specific Examples

Real-world workflows from various data science domains.

### Bioinformatics Pipeline

A genomics analysis workflow processing FASTA sequences:

``` r
# sequences/fetch_sequences.R
#put label:"Fetch FASTA Sequences", node_type:"input", output:"raw_sequences.fasta"

# sequences/quality_control.py
#put label:"Quality Control", input:"raw_sequences.fasta", output:"filtered_sequences.fasta, qc_report.html"

# alignment/run_blast.sh
#put label:"BLAST Alignment", input:"filtered_sequences.fasta", output:"blast_results.xml"

# alignment/parse_blast.R
#put label:"Parse BLAST Results", input:"blast_results.xml", output:"alignments.csv"

# analysis/differential_expression.R
#put label:"Differential Expression", input:"alignments.csv", output:"de_results.rds"

# analysis/pathway_analysis.R
#put label:"Pathway Enrichment", input:"de_results.rds", output:"pathways.csv"

# report/bioinformatics_report.R
#put label:"Generate Report", node_type:"output", input:"de_results.rds, pathways.csv, qc_report.html", output:"analysis_report.html"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    fetch([Fetch FASTA Sequences])
    qc[Quality Control]
    blast[BLAST Alignment]
    parse[Parse BLAST Results]
    de[Differential Expression]
    pathway[Pathway Enrichment]
    report[[Generate Report]]

    %% Connections
    fetch --> qc
    qc --> blast
    blast --> parse
    parse --> de
    de --> pathway
    de --> report
    pathway --> report
    qc --> report

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class fetch inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class qc processStyle
    class blast processStyle
    class parse processStyle
    class de processStyle
    class pathway processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class report outputStyle
```

### Financial Analysis Pipeline

Portfolio analysis and risk assessment workflow:

``` r
# data/fetch_market_data.py
#put label:"Fetch Market Data", node_type:"input", output:"market_prices.parquet"

# data/fetch_holdings.R
#put label:"Load Portfolio Holdings", node_type:"input", output:"holdings.csv"

# analysis/calculate_returns.R
#put label:"Calculate Returns", input:"market_prices.parquet, holdings.csv", output:"returns.rds"

# analysis/risk_metrics.R
#put label:"Compute Risk Metrics", input:"returns.rds", output:"var_results.rds, sharpe_ratios.csv"

# analysis/attribution.py
#put label:"Performance Attribution", input:"returns.rds, holdings.csv", output:"attribution.json"

# optimization/portfolio_optimize.R
#put label:"Portfolio Optimization", input:"returns.rds, var_results.rds", output:"optimal_weights.csv"

# report/risk_dashboard.R
#put label:"Risk Dashboard", node_type:"output", input:"var_results.rds, sharpe_ratios.csv, attribution.json, optimal_weights.csv", output:"risk_report.html"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    market([Fetch Market Data])
    holdings([Load Portfolio Holdings])
    returns[Calculate Returns]
    risk[Compute Risk Metrics]
    attrib[Performance Attribution]
    optimize[Portfolio Optimization]
    dashboard[[Risk Dashboard]]

    %% Connections
    market --> returns
    holdings --> returns
    returns --> risk
    returns --> attrib
    holdings --> attrib
    returns --> optimize
    risk --> optimize
    risk --> dashboard
    attrib --> dashboard
    optimize --> dashboard

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class market inputStyle
    class holdings inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class returns processStyle
    class risk processStyle
    class attrib processStyle
    class optimize processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class dashboard outputStyle
```

### Web Scraping Pipeline

Data extraction from web sources:

``` r
# scrape/fetch_urls.py
#put label:"Fetch URL List", node_type:"input", output:"target_urls.txt"

# scrape/scrape_pages.py
#put label:"Scrape Web Pages", input:"target_urls.txt", output:"raw_html.json"

# extract/parse_html.py
#put label:"Parse HTML Content", input:"raw_html.json", output:"extracted_text.json"

# extract/extract_entities.py
#put label:"Named Entity Recognition", input:"extracted_text.json", output:"entities.csv"

# transform/clean_data.R
#put label:"Clean and Normalize", input:"entities.csv", output:"clean_entities.csv"

# transform/deduplicate.R
#put label:"Remove Duplicates", input:"clean_entities.csv", output:"unique_entities.csv"

# load/save_to_db.py
#put label:"Load to Database", node_type:"output", input:"unique_entities.csv"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    urls([Fetch URL List])
    scrape[Scrape Web Pages]
    parse[Parse HTML Content]
    ner[Named Entity Recognition]
    clean[Clean and Normalize]
    dedup[Remove Duplicates]
    db[[Load to Database]]

    %% Connections
    urls --> scrape
    scrape --> parse
    parse --> ner
    ner --> clean
    clean --> dedup
    dedup --> db

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class urls inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class scrape processStyle
    class parse processStyle
    class ner processStyle
    class clean processStyle
    class dedup processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class db outputStyle
```

### Multi-Language ML Pipeline

A realistic ML workflow using R for data prep, Python for training, and
R for reporting:

``` r
# data/load_raw_data.R
#put label:"Load Raw Data (R)", node_type:"input", output:"raw_data.rds"

# data/eda_analysis.R
#put label:"Exploratory Analysis (R)", input:"raw_data.rds", output:"eda_report.html, data_summary.json"

# preprocessing/feature_engineering.R
#put label:"Feature Engineering (R)", input:"raw_data.rds, data_summary.json", output:"features.parquet"

# preprocessing/split_data.R
#put label:"Train/Test Split (R)", input:"features.parquet", output:"train.parquet, test.parquet"

# training/train_model.py
#put label:"Train XGBoost (Python)", input:"train.parquet", output:"model.pkl, training_metrics.json"

# training/hyperparameter_search.py
#put label:"Hyperparameter Tuning (Python)", input:"train.parquet", output:"best_params.json"

# training/final_model.py
#put label:"Final Model Training (Python)", input:"train.parquet, best_params.json", output:"final_model.pkl"

# evaluation/model_evaluation.py
#put label:"Model Evaluation (Python)", input:"final_model.pkl, test.parquet", output:"predictions.csv, eval_metrics.json"

# reporting/model_report.R
#put label:"Model Report (R)", node_type:"output", input:"eval_metrics.json, training_metrics.json, eda_report.html", output:"final_report.html"

# deployment/export_model.py
#put label:"Export for Production (Python)", node_type:"output", input:"final_model.pkl", output:"model_artifact.tar.gz"
```

**Generated Diagram:**

``` mermaid
flowchart TD
    load([Load Raw Data - R])
    eda[Exploratory Analysis - R]
    features[Feature Engineering - R]
    split[Train/Test Split - R]
    train[Train XGBoost - Python]
    hyper[Hyperparameter Tuning - Python]
    final[Final Model Training - Python]
    evaluate[Model Evaluation - Python]
    report[[Model Report - R]]
    deploy_export[[Export for Production - Python]]

    %% Connections
    load --> eda
    load --> features
    eda --> features
    features --> split
    split --> train
    split --> hyper
    split --> final
    hyper --> final
    final --> evaluate
    split --> evaluate
    evaluate --> report
    train --> report
    eda --> report
    final --> deploy_export

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class load inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class eda processStyle
    class features processStyle
    class split processStyle
    class train processStyle
    class hyper processStyle
    class final processStyle
    class evaluate processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class report outputStyle
    class deploy_export outputStyle
```

This example demonstrates: - **R for data handling**: Loading, EDA,
feature engineering, splitting - **Python for ML**: XGBoost training,
hyperparameter search, evaluation - **R for reporting**: Combining
results into a final report - **Python for deployment**: Packaging model
artifacts

------------------------------------------------------------------------

## Tips for Large Workflows

When working with complex workflows:

1.  **Use meaningful IDs**: Choose IDs that reflect the step’s purpose
2.  **Group related files**: Organize scripts into subdirectories
3.  **Use subgraphs**: Group related nodes with
    `show_source_info = TRUE, source_info_style = "subgraph"`
4.  **Consider direction**: Use `direction = "LR"` for wide workflows,
    `direction = "TD"` for deep ones
5.  **Show artifacts selectively**: Use `show_artifacts = TRUE` only
    when data lineage matters

``` r
# For large workflows, consider:
put_diagram(workflow,
  direction = "LR",              # Left-to-right for wide pipelines
  show_source_info = TRUE,       # Show file names
  source_info_style = "subgraph",# Group by file
  theme = "minimal"              # Clean look for complex diagrams
)
```

## Try It Yourself

Run the built-in examples:

``` r
# Basic example
source(system.file("examples", "reprex.R", package = "putior"))

# Data science workflow
source(system.file("examples", "data-science-workflow.R", package = "putior"))

# Self-documentation (putior documents itself!)
source(system.file("examples", "self-documentation.R", package = "putior"))
```
