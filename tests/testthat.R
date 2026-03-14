library(testthat)

source_files <- list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(source_files, source))

test_dir("tests/testthat")