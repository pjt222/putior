args <- R.utils::commandArgs(
  asValues = TRUE,
  defaults = list()
)

args

source(file.path("R", "putior.R"))

put_src <- function() {
  if (
    !is.null(args[["interactive"]] #& rstudioapi::isAvailable())
    )) {
    cat("interactive & RStudio\n")
    basename(rstudioapi::documentPath())
  } else {
    cat("Rscript\n")
    basename(args[["files"]])
  }
}

put_src()

test_out <- rnorm(100)

save(
  test_out,
  file = 
    put(
      name = file.path("test", "out.RData"),
      type = "o",
      where = file.path("test", "putio.csv")
  )
)
