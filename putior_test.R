args <- R.utils::commandArgs(
  asValues = TRUE,
  defaults = list()
)

args

source("putio.R")

put_src()

test_out <- rnorm(100)

save(
  test_out,
  file = 
    put(
      name = file.path("test_out.RData"),
      type = "o",
      where = file.path("putio.csv")
  )
)
