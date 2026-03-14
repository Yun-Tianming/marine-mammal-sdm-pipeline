# 配置与输出路径辅助函数 --------------------------------------------------------

# 中文说明：返回项目根目录。
sdm_project_root <- function() {
  normalizePath(".", winslash = "/", mustWork = TRUE)
}

# 中文说明：拼接并标准化路径。
sdm_abs_path <- function(...) {
  normalizePath(file.path(...), winslash = "/", mustWork = FALSE)
}

# 中文说明：返回默认 run config 路径。
sdm_default_config_path <- function(project_root = sdm_project_root()) {
  sdm_abs_path(project_root, "config", "runs", "humpback_cosmonaut.R")
}

# 中文说明：读取 run config，配置文件必须定义对象 config。
sdm_load_config <- function(config_path = sdm_default_config_path()) {
  env <- new.env(parent = baseenv())
  assign(".__config_file__", normalizePath(config_path, winslash = "/", mustWork = TRUE), envir = env)
  sys.source(config_path, envir = env)

  if (!exists("config", envir = env, inherits = FALSE)) {
    stop(sprintf("Config file does not define object `config`: %s", config_path), call. = FALSE)
  }

  cfg <- get("config", envir = env, inherits = FALSE)
  if (!is.list(cfg)) {
    stop(sprintf("Object `config` must be a list: %s", config_path), call. = FALSE)
  }

  cfg$config_path <- sdm_abs_path(config_path)
  cfg$project_root <- sdm_project_root()
  cfg
}

# 中文说明：构建 run_id 级别输出路径。
# 正式输出统一写入 outputs/<run_id>/，旧路径只保留为兼容层。
sdm_build_run_paths <- function(config) {
  root <- config$project_root
  run_dir_rel <- config$outputs$run_dir
  run_dir <- sdm_abs_path(root, run_dir_rel)

  paths <- list(
    root = root,
    run_id = config$run_id,
    formal_output_root = run_dir,
    reports_dir = sdm_abs_path(run_dir, "reports"),
    figures_dir = sdm_abs_path(run_dir, "figures"),
    rasters_dir = sdm_abs_path(run_dir, "rasters"),
    tables_dir = sdm_abs_path(run_dir, "tables"),
    biomod_full_dir = sdm_abs_path(run_dir, "biomod2_full"),
    biomod_matched_dir = sdm_abs_path(run_dir, "biomod2_matched"),
    legacy = list(
      occurrence_raw = sdm_abs_path(root, "data_clean", "humpback_occurrences_raw.csv"),
      occurrence_clean = sdm_abs_path(root, "data_clean", "humpback_occurrences.csv"),
      occurrence_overview = sdm_abs_path(root, "outputs", "humpback_occurrence_overview.csv"),
      qc_report = sdm_abs_path(root, "outputs", "data_qc_report.csv"),
      qc_summary = sdm_abs_path(root, "outputs", "data_qc_summary.txt"),
      study_area = sdm_abs_path(root, "env_processed", "study_area.gpkg"),
      predictors_stack = sdm_abs_path(root, "env_processed", "predictors_stack.tif"),
      predictors_stack_extended = sdm_abs_path(root, "env_processed", "predictors_stack_extended.tif"),
      full_eval = sdm_abs_path(root, "outputs", "full_model_eval_metrics.csv"),
      matched_eval = sdm_abs_path(root, "outputs", "matched_model_eval_metrics.csv"),
      full_varimp = sdm_abs_path(root, "outputs", "full_model_variable_importance.csv"),
      matched_varimp = sdm_abs_path(root, "outputs", "matched_model_variable_importance.csv"),
      full_ensemble = sdm_abs_path(root, "outputs", "full_model_ensemble_suitability.tif"),
      matched_ensemble = sdm_abs_path(root, "outputs", "matched_model_ensemble_suitability.tif")
    )
  )

  dir.create(paths$formal_output_root, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$reports_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$figures_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$rasters_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$tables_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$biomod_full_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(paths$biomod_matched_dir, recursive = TRUE, showWarnings = FALSE)

  paths
}

# 中文说明：返回正式输出路径。
sdm_output_path <- function(run_paths, category, ..., ext = NULL) {
  category_map <- list(
    tables = run_paths$tables_dir,
    reports = run_paths$reports_dir,
    rasters = run_paths$rasters_dir,
    figures = run_paths$figures_dir,
    biomod2_full = run_paths$biomod_full_dir,
    biomod2_matched = run_paths$biomod_matched_dir
  )

  if (!category %in% names(category_map)) {
    stop(sprintf("Unsupported output category: %s", category), call. = FALSE)
  }

  file_name <- if (length(list(...)) == 0) "" else file.path(...)
  if (!is.null(ext) && nzchar(file_name) && !grepl(paste0("\\", ext, "$"), file_name)) {
    file_name <- paste0(file_name, ext)
  }
  sdm_abs_path(category_map[[category]], file_name)
}

# 中文说明：返回 legacy 兼容路径。
sdm_legacy_output_path <- function(run_paths, key) {
  if (!key %in% names(run_paths$legacy)) {
    stop(sprintf("Unsupported legacy output key: %s", key), call. = FALSE)
  }
  run_paths$legacy[[key]]
}

# 中文说明：按需复制兼容文件到历史路径。
sdm_write_legacy_copy <- function(source_path, legacy_path, enabled = TRUE) {
  if (!enabled || !file.exists(source_path)) {
    return(invisible(FALSE))
  }

  dir.create(dirname(legacy_path), recursive = TRUE, showWarnings = FALSE)
  ok <- file.copy(source_path, legacy_path, overwrite = TRUE)
  invisible(ok)
}