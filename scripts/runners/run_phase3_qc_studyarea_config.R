# 第 3 阶段轻量入口：执行质控、study area 与 predictor 栈整理。
source_files <- list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(source_files, source))
args <- commandArgs(trailingOnly = TRUE)
config_path <- if (length(args) >= 1) args[[1]] else sdm_default_config_path()
config <- sdm_load_config(config_path)
paths <- sdm_build_run_paths(config)
phase2 <- sdm_phase2_standardize_occurrence(config, paths)
sdm_phase3_qc_studyarea_predictors(config, paths, phase2)