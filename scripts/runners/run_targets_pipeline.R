# 轻量入口脚本：运行整个 targets pipeline。
# 用法：Rscript scripts/runners/run_targets_pipeline.R config/runs/humpback_cosmonaut.R

source("R/config.R")
args <- commandArgs(trailingOnly = TRUE)
config_path <- if (length(args) >= 1) normalizePath(args[[1]], winslash = "/", mustWork = TRUE) else sdm_default_config_path()
Sys.setenv(SDM_CONFIG = config_path)

targets::tar_make()