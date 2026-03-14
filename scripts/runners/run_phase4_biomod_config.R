# 第 4 阶段轻量入口：执行 biomod2 双路径建模。
# 注意：本脚本会触发真实建模，不应在默认维护任务中主动运行。
source_files <- list.files("R", pattern = "\\.[Rr]$", full.names = TRUE)
invisible(lapply(source_files, source))
args <- commandArgs(trailingOnly = TRUE)
config_path <- if (length(args) >= 1) args[[1]] else sdm_default_config_path()
config <- sdm_load_config(config_path)
paths <- sdm_build_run_paths(config)
phase2 <- sdm_phase2_standardize_occurrence(config, paths)
phase3 <- sdm_phase3_qc_studyarea_predictors(config, paths, phase2)
sdm_phase4_biomod_dual(config, paths, phase3)