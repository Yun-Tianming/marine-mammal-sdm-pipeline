# targets pipeline 入口 ----------------------------------------------------------
# 说明：
# 1. 默认读取 config/runs/humpback_cosmonaut.R。
# 2. 可通过环境变量 SDM_CONFIG 指向新的 run config。
# 3. 本文件只定义依赖关系，不会在结构增强阶段自动执行任何建模。

library(targets)
source_files <- list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(source_files, source))

config_path <- Sys.getenv("SDM_CONFIG", unset = sdm_default_config_path())

tar_option_set(
  packages = c(
    "readxl", "dplyr", "tidyr", "stringr", "purrr", "lubridate",
    "sf", "terra", "ggplot2", "biomod2"
  ),
  format = "rds"
)

list(
  tar_target(run_config, sdm_load_config(config_path)),
  tar_target(run_paths, sdm_build_run_paths(run_config)),
  tar_target(phase1_environment, sdm_phase1_environment_check(run_config, run_paths)),
  tar_target(phase2_occurrence_raw, sdm_phase2_standardize_occurrence(run_config, run_paths)),
  tar_target(phase3_occurrence_clean, sdm_phase3_qc_studyarea_predictors(run_config, run_paths, phase2_occurrence_raw)),
  tar_target(phase4_models, sdm_phase4_biomod_dual(run_config, run_paths, phase3_occurrence_clean)),
  tar_target(phase5_outputs, sdm_phase5_plotting(run_config, run_paths, phase4_models))
)