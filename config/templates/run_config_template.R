# 通用 run config 模板
# 用法：复制到 config/runs/<your_run_id>.R，然后按注释替换。

config <- list(
  run_id = "your_run_id",
  description = "请填写本次运行的说明。",

  species = list(
    target_name_cn = "目标物种中文名",
    target_name_en = "Target species English name",
    target_value = "用于 occurrence 筛选的标准物种名"
  ),

  input = list(
    raw_data_dir = "data_raw",
    workbooks = list(
      list(file = "data_raw/your_file_1.xlsx", schema_id = "schema_a")
    ),
    source_schemas = list(
      schema_a = list(
        survey_date_raw = "日期列名",
        survey_time_raw = "时间列名",
        species_cn = "物种列名",
        region = "区域列名或 NULL",
        lon_raw = "经度列名",
        lat_raw = "纬度列名",
        count_raw = "数量列名",
        distance_m_raw = "距离列名或 NULL",
        lon_default_hemisphere = "E",
        lat_default_hemisphere = "S"
      )
    )
  ),

  region = list(
    name = "display region name",
    display_lon = c(0, 100),
    display_lat = c(-75, -55),
    graticule_lon = seq(10, 90, by = 10),
    graticule_lat = seq(-70, -60, by = 2)
  ),

  study_area = list(
    method = "convex_hull_buffer",
    analysis_crs = "EPSG:3031",
    buffer_km = 150
  ),

  predictors = list(
    full = c("bathymetry", "slope"),
    extended = c("bathymetry", "slope"),
    full_priority = c("bathymetry", "slope"),
    extended_priority = c("bathymetry", "slope"),
    raw_bathymetry = "env_raw/marspec/MS_bathy_5m_lonlat.tif",
    processed_stack = "env_processed/predictors_stack.tif",
    processed_stack_extended = "env_processed/predictors_stack_extended.tif"
  ),

  pseudo_absence = list(
    strategy = "random_background",
    multiplier = 5L,
    min_n = 300L,
    max_n = 1000L
  ),

  biomod2 = list(
    models = c("GLM", "GAM", "GBM", "RF", "SRE"),
    cv_strategy = "random",
    cv_nb_rep = 3L,
    cv_perc = 0.8,
    metric_eval = c("TSS", "ROC"),
    var_import = 3L,
    correlation_threshold = 0.9,
    ensemble_algo = "EMmean",
    metric_select = "ROC",
    metric_select_thresh = 0.7,
    seed = 20260314L,
    nb_cpu = 1L
  ),

  outputs = list(
    base_dir = "outputs",
    run_dir = file.path("outputs", "your_run_id"),
    legacy_write = FALSE
  )
)