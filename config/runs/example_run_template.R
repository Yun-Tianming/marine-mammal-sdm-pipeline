# 示例 run config：仅供复制和改名，不会自动触发分析 ------------------------------
# 说明：
# 1. 本文件演示如何基于 species / regions / defaults 进行轻量拼装。
# 2. 请复制后改名为实际 run_id，再替换输入文件和目标物种。

this_config_file <- if (exists(".__config_file__", inherits = FALSE)) {
  get(".__config_file__", inherits = FALSE)
} else {
  normalizePath("config/runs/example_run_template.R", winslash = "/", mustWork = TRUE)
}
config_root <- normalizePath(file.path(dirname(this_config_file), ".."), winslash = "/", mustWork = TRUE)

sys.source(file.path(config_root, "species", "humpback.R"), envir = environment())
sys.source(file.path(config_root, "regions", "cosmonaut.R"), envir = environment())
sys.source(file.path(config_root, "defaults", "biomod_defaults.R"), envir = environment())
sys.source(file.path(config_root, "defaults", "predictor_defaults.R"), envir = environment())

config <- list(
  run_id = "example_run_template",
  description = "示例 run config，用于演示如何拼装一个新的运行配置。",
  species = species_humpback,
  input = list(
    raw_data_dir = "data_raw",
    workbooks = list(
      list(file = file.path("data_raw", "your_occurrence_file.xlsx"), schema_id = "schema_a")
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
  region = region_cosmonaut,
  study_area = study_area_cosmonaut,
  predictors = predictor_defaults,
  pseudo_absence = pseudo_absence_defaults,
  biomod2 = biomod_defaults,
  outputs = list(
    base_dir = "outputs",
    run_dir = file.path("outputs", "example_run_template"),
    legacy_write = FALSE,
    legacy_note = "example template only"
  )
)