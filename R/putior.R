put_src <- function() {
  if (!is.null(args[["interactive"]] & rstudioapi::isAvailable())) {
    cat("interactive & RStudio\n")
    basename(rstudioapi::documentPath())
  } else {
    cat("Rscript\n")
    basename(args[["files"]])
  }
}

put <- function(
  name = NULL, # file name / path of input or output
  type = NULL, # input, output
  where = NULL # path to csv storage
) {
  # TODO check for unique name, read 'where' if exists
  # TODO restrict type to either 'i' or 'o'
  # TODO restrict where to csv
  write.table(
    x = data.frame(
      # "uuid" = uuid::UUIDgenerate(),
      "date_creation" = as.character(Sys.Date()),
      "src" = put_src(), # from
      "name" = basename(name), # to
      "type" = type # direction
    ),
    file = where,
    sep = ",",
    row.names = FALSE,
    col.names = FALSE,
    append = TRUE
  )

  name
}
