# 第 5 阶段轻量入口：执行绘图与结果整理。
source_files <- list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(source_files, source))
args <- commandArgs(trailingOnly = TRUE)
config_path <- if (length(args) >= 1) args[[1]] else sdm_default_config_path()
config <- sdm_load_config(config_path)
paths <- sdm_build_run_paths(config)
sdm_phase5_plotting(config, paths)