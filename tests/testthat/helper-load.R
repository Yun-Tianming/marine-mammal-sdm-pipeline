project_root <- normalizePath(file.path(getwd(), "..", ".."), winslash = "/", mustWork = TRUE)
source_files <- list.files(file.path(project_root, "R"), pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(source_files, source))