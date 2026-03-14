# pipeline 阶段封装 -------------------------------------------------------------

# 中文说明：第 1 阶段，环境检查与目录初始化。
sdm_phase1_environment_check <- function(config, run_paths) {
  required_dirs <- c("data_raw", "data_clean", "env_raw", "env_processed", "outputs", "scripts", config$outputs$run_dir)
  for (dir_rel in required_dirs) {
    dir.create(sdm_abs_path(config$project_root, dir_rel), recursive = TRUE, showWarnings = FALSE)
  }

  packages_to_check <- c("biomod2", "terra", "sf", "readxl", "dplyr", "ggplot2", "tidyr", "stringr", "lubridate", "purrr", "targets")
  rscript_ok <- nzchar(Sys.which("Rscript"))
  pkg_status <- data.frame(
    package = packages_to_check,
    available = vapply(packages_to_check, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1)),
    stringsAsFactors = FALSE
  )

  report_path <- sdm_output_path(run_paths, "reports", "environment_check.txt")
  report_lines <- c(
    sprintf("Rscript available: %s", rscript_ok),
    sprintf("Missing packages: %s", paste(pkg_status$package[!pkg_status$available], collapse = ", "))
  )
  writeLines(report_lines, report_path, useBytes = TRUE)

  list(report = report_path, packages = pkg_status)
}

# 中文说明：第 2 阶段，原始 occurrence 标准化与目标物种提取。
sdm_phase2_standardize_occurrence <- function(config, run_paths) {
  raw <- sdm_read_occurrence_workbooks(config)
  extracted <- sdm_extract_target_occurrence(raw$occurrence_tbl, config)

  occurrence_raw_path <- sdm_output_path(run_paths, "tables", "occurrences_raw.csv")
  overview_path <- sdm_output_path(run_paths, "tables", "occurrence_overview.csv")

  sdm_write_csv_bom(extracted$target_tbl, occurrence_raw_path)
  sdm_write_csv_bom(extracted$overview_tbl, overview_path)

  sdm_write_legacy_copy(occurrence_raw_path, sdm_legacy_output_path(run_paths, "occurrence_raw"), config$outputs$legacy_write)
  sdm_write_legacy_copy(overview_path, sdm_legacy_output_path(run_paths, "occurrence_overview"), config$outputs$legacy_write)

  list(
    sheets = raw$sheet_log,
    occurrence_raw = occurrence_raw_path,
    overview = overview_path,
    n_records = nrow(extracted$target_tbl)
  )
}

# 中文说明：第 3 阶段，质控、study area 与 predictor 栈整理。
sdm_phase3_qc_studyarea_predictors <- function(config, run_paths, phase2_result) {
  occ_raw <- sdm_read_csv_utf8(phase2_result$occurrence_raw)
  qc <- sdm_qc_occurrence(occ_raw)
  sa <- sdm_build_study_area(qc$occ_clean, config)

  qc_report_path <- sdm_output_path(run_paths, "tables", "data_qc_report.csv")
  occ_clean_path <- sdm_output_path(run_paths, "tables", "occurrences_clean.csv")
  qc_summary_path <- sdm_output_path(run_paths, "reports", "data_qc_summary.txt")
  study_area_path <- sdm_output_path(run_paths, "rasters", "study_area.gpkg")
  predictors_stack_path <- sdm_output_path(run_paths, "rasters", "predictors_stack.tif")
  predictors_stack_extended_path <- sdm_output_path(run_paths, "rasters", "predictors_stack_extended.tif")

  sdm_write_csv_bom(qc$qc_report, qc_report_path)
  sdm_write_csv_bom(qc$occ_clean, occ_clean_path)
  writeLines(qc$summary_lines, qc_summary_path, useBytes = TRUE)
  sf::st_write(sa$study_area, study_area_path, delete_dsn = TRUE, quiet = TRUE)

  full_stack_run <- sdm_stage_existing_predictor_stack(
    sdm_abs_path(config$project_root, config$predictors$processed_stack),
    predictors_stack_path
  )

  extended_stack_source <- sdm_abs_path(config$project_root, config$predictors$processed_stack_extended)
  extended_stack_run <- if (file.exists(extended_stack_source)) {
    sdm_stage_existing_predictor_stack(extended_stack_source, predictors_stack_extended_path)
  } else {
    NA_character_
  }

  sdm_write_legacy_copy(qc_report_path, sdm_legacy_output_path(run_paths, "qc_report"), config$outputs$legacy_write)
  sdm_write_legacy_copy(occ_clean_path, sdm_legacy_output_path(run_paths, "occurrence_clean"), config$outputs$legacy_write)
  sdm_write_legacy_copy(study_area_path, sdm_legacy_output_path(run_paths, "study_area"), config$outputs$legacy_write)
  sdm_write_legacy_copy(full_stack_run, sdm_legacy_output_path(run_paths, "predictors_stack"), config$outputs$legacy_write)
  if (!is.na(extended_stack_run)) {
    sdm_write_legacy_copy(extended_stack_run, sdm_legacy_output_path(run_paths, "predictors_stack_extended"), config$outputs$legacy_write)
  }

  list(
    occurrence_clean = occ_clean_path,
    qc_report = qc_report_path,
    study_area = study_area_path,
    predictors_stack = full_stack_run,
    predictors_stack_extended = extended_stack_run
  )
}

# 中文说明：第 4 阶段，双路径 biomod2 建模。
# 注意：本函数不在本轮自动执行，仅保留为可复用入口。
sdm_phase4_biomod_dual <- function(config, run_paths, phase3_result) {
  occ_all <- sdm_read_csv_utf8(phase3_result$occurrence_clean)
  occ_all$survey_date_utc <- as.Date(occ_all$survey_date_utc)
  occ_matched <- dplyr::filter(occ_all, survey_date_utc >= as.Date("2022-12-01") & survey_date_utc <= as.Date("2023-03-01"))

  full_stack <- sdm_read_predictor_stack(phase3_result$predictors_stack, config$predictors$full)
  full_result <- sdm_run_biomod_pipeline(
    model_label = "full",
    occ_df = occ_all,
    predictor_stack = full_stack,
    candidate_vars = config$predictors$full,
    priority_order = config$predictors$full_priority,
    config = config,
    corr_output = sdm_output_path(run_paths, "tables", "full_model_predictor_correlation.csv"),
    eval_output = sdm_output_path(run_paths, "tables", "full_model_eval_metrics.csv"),
    varimp_output = sdm_output_path(run_paths, "tables", "full_model_variable_importance.csv"),
    ensemble_output = sdm_output_path(run_paths, "rasters", "full_model_ensemble_suitability.tif"),
    summary_output = sdm_output_path(run_paths, "reports", "full_model_summary.txt"),
    biomod_dir = sdm_output_path(run_paths, "biomod2_full")
  )

  matched_result <- NULL
  if (!is.na(phase3_result$predictors_stack_extended) && file.exists(phase3_result$predictors_stack_extended)) {
    extended_stack <- sdm_read_predictor_stack(phase3_result$predictors_stack_extended, config$predictors$extended)
    matched_result <- sdm_run_biomod_pipeline(
      model_label = "matched",
      occ_df = occ_matched,
      predictor_stack = extended_stack,
      candidate_vars = config$predictors$extended,
      priority_order = config$predictors$extended_priority,
      config = config,
      corr_output = sdm_output_path(run_paths, "tables", "matched_model_predictor_correlation.csv"),
      eval_output = sdm_output_path(run_paths, "tables", "matched_model_eval_metrics.csv"),
      varimp_output = sdm_output_path(run_paths, "tables", "matched_model_variable_importance.csv"),
      ensemble_output = sdm_output_path(run_paths, "rasters", "matched_model_ensemble_suitability.tif"),
      summary_output = sdm_output_path(run_paths, "reports", "matched_model_summary.txt"),
      biomod_dir = sdm_output_path(run_paths, "biomod2_matched")
    )
  }

  list(full = full_result, matched = matched_result)
}

# 中文说明：第 5 阶段，绘图与结果整理。
# 正式输出应统一写入 outputs/<run_id>/figures。
sdm_phase5_plotting <- function(config, run_paths, phase4_result = NULL) {
  message(sprintf("Plotting hooks are ready for run_id: %s", config$run_id))
  list(figures_dir = sdm_output_path(run_paths, "figures"))
}