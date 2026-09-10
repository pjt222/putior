#!/usr/bin/env Rscript
# Upload the package to win-builder for R-devel and R-release checks.
#
# Usage: run from the package root -- Rscript dev/cran/winbuilder.R
#
# Results are emailed to the DESCRIPTION maintainer, typically within 15-60
# minutes. Nothing is written locally.

stopifnot(file.exists("DESCRIPTION"))

Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")
options(repos = c(CRAN = "https://cloud.r-project.org"))

cat("Package root:", normalizePath("."), "\n")

cat("\n== check_win_devel ==\n")
devtools::check_win_devel(".", quiet = FALSE)

cat("\n== check_win_release ==\n")
devtools::check_win_release(".", quiet = FALSE)

# DESCRIPTION uses Authors@R with no explicit Maintainer: field, so read the
# cre role out of it rather than a field that would come back NA.
description <- read.dcf("DESCRIPTION")
maintainer <- if ("Maintainer" %in% colnames(description)) {
  description[1, "Maintainer"]
} else {
  authors <- eval(parse(text = description[1, "Authors@R"]))
  creator <- Filter(function(person) "cre" %in% person$role, authors)
  paste(format(creator, include = c("given", "family", "email")), collapse = ", ")
}
cat("\n=== WIN-BUILDER UPLOADS DONE ===\n")
cat("Results will be emailed to the DESCRIPTION maintainer (", maintainer, ")\n", sep = "")
cat("typically within 15-60 minutes.\n")
