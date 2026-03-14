# Recommended runner: execute the full targets pipeline.
source("R/config.R")
args <- commandArgs(trailingOnly = TRUE)
config_path <- if (length(args) >= 1) normalizePath(args[[1]], winslash = "/", mustWork = TRUE) else sdm_default_config_path()
Sys.setenv(SDM_CONFIG = config_path)
targets::tar_make()
