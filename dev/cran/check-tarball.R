#!/usr/bin/env Rscript
# Run `R CMD check --as-cran` against an already-built tarball.
#
# Usage: run from the package root -- Rscript dev/cran/check-tarball.R
#
# The tarball is expected at the package root (where pkgbuild::build() puts it,
# and where putior_0.1.0.tar.gz already lives). Version comes from DESCRIPTION
# so this does not rot across releases.

stopifnot(file.exists("DESCRIPTION"))

Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")
# Keep all LOCAL CRAN incoming checks; disable only the flaky REMOTE fetch that 404'd.
Sys.setenv("_R_CHECK_CRAN_INCOMING_REMOTE_" = "FALSE")
options(repos = c(CRAN = "https://cloud.r-project.org"))

# R CMD check builds the PDF manual with pdflatex. If pdflatex is not on PATH
# but TinyTeX is installed, put TinyTeX's bin directory on PATH so the manual
# is checked locally instead of failing with "pdflatex is not available".
if (!nzchar(Sys.which("pdflatex")) && requireNamespace("tinytex", quietly = TRUE)) {
  tinytex_root <- tinytex::tinytex_root(error = FALSE)
  if (nzchar(tinytex_root)) {
    tinytex_bin_dirs <- list.dirs(file.path(tinytex_root, "bin"), recursive = FALSE)
    Sys.setenv(PATH = paste(c(tinytex_bin_dirs, Sys.getenv("PATH")),
                            collapse = .Platform$path.sep))
  }
}
cat("pdflatex:", Sys.which("pdflatex"), "\n")

version <- read.dcf("DESCRIPTION", fields = "Version")[[1]]
tarball <- sprintf("putior_%s.tar.gz", version)
stopifnot(file.exists(tarball))
cat("Checking:", tarball, "\n")

result <- rcmdcheck::rcmdcheck(tarball, args = "--as-cran",
                               error_on = "never", quiet = FALSE)

dir.create("dev/cran/out", recursive = TRUE, showWarnings = FALSE)
saveRDS(result, "dev/cran/out/check-tarball-result.rds")

cat("\n\n##### STRUCTURED SUMMARY #####\n")
cat("ERRORS:", length(result$errors), "| WARNINGS:", length(result$warnings),
    "| NOTES:", length(result$notes), "\n")
cat("\n--- ERRORS ---\n");   for (item in result$errors)   cat(item, "\n\n")
cat("\n--- WARNINGS ---\n"); for (item in result$warnings) cat(item, "\n\n")
cat("\n--- NOTES ---\n");    for (item in result$notes)    cat(item, "\n\n")
cat("=== DONE ===\n")
