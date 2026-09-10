#!/usr/bin/env Rscript
# Build the source tarball, then run `R CMD check --as-cran` against it.
#
# Usage: run from the package root -- Rscript dev/cran/build-and-check.R
#
# The tarball lands at the package root. .gitignore (/*.tar.gz) and
# .Rbuildignore (^.*\.tar\.gz$) already cover it there, so it never needs to be
# written outside the repo.

stopifnot(file.exists("DESCRIPTION"))

Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")
Sys.setenv("_R_CHECK_CRAN_INCOMING_REMOTE_" = "FALSE")
options(repos = c(CRAN = "https://cloud.r-project.org"))

cat("Package root:", normalizePath("."), "\n")

tarball <- pkgbuild::build(".", dest_path = ".", manual = FALSE,
                           vignettes = TRUE, quiet = FALSE)
cat("BUILT_TARBALL:", tarball, "\n")

result <- rcmdcheck::rcmdcheck(tarball, args = "--as-cran",
                               error_on = "never", quiet = FALSE)

dir.create("dev/cran/out", recursive = TRUE, showWarnings = FALSE)
saveRDS(result, "dev/cran/out/build-and-check-result.rds")

cat("\n\n##### STRUCTURED SUMMARY #####\n")
cat("ERRORS:", length(result$errors), "| WARNINGS:", length(result$warnings),
    "| NOTES:", length(result$notes), "\n")
cat("\n--- ERRORS ---\n");   for (item in result$errors)   cat(item, "\n\n")
cat("\n--- WARNINGS ---\n"); for (item in result$warnings) cat(item, "\n\n")
cat("\n--- NOTES ---\n");    for (item in result$notes)    cat(item, "\n\n")
cat("=== DONE ===\n")
