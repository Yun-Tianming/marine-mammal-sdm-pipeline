# 第 1 阶段轻量入口：执行环境检查，不重跑后续分析。
source("R/config.R")
source("R/pipeline_steps.R")
args <- commandArgs(trailingOnly = TRUE)
config_path <- if (length(args) >= 1) args[[1]] else sdm_default_config_path()
config <- sdm_load_config(config_path)
paths <- sdm_build_run_paths(config)
sdm_phase1_environment_check(config, paths)