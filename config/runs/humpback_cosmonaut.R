# 默认运行配置：座头鲸 / 宇航员调查数据 -----------------------------------------
# 中文说明：run config 负责拼装，新增物种或区域时优先改 config 目录。

this_config_file <- if (exists(".__config_file__", inherits = FALSE)) {
  get(".__config_file__", inherits = FALSE)
} else {
  normalizePath("config/runs/humpback_cosmonaut.R", winslash = "/", mustWork = TRUE)
}
config_root <- normalizePath(file.path(dirname(this_config_file), ".."), winslash = "/", mustWork = TRUE)

sys.source(file.path(config_root, "species", "humpback.R"), envir = environment())
sys.source(file.path(config_root, "regions", "cosmonaut.R"), envir = environment())
sys.source(file.path(config_root, "defaults", "biomod_defaults.R"), envir = environment())
sys.source(file.path(config_root, "defaults", "predictor_defaults.R"), envir = environment())

config <- list(
  run_id = "humpback_cosmonaut",
  description = "座头鲸 SDM 默认运行配置，基于宇航员航次观测与现有南极沿岸研究区。",
  species = species_humpback,
  input = list(
    raw_data_dir = "data_raw",
    workbooks = list(
      list(file = file.path("data_raw", "S39宇航员（30-80°）.xlsx"), schema_id = "S39"),
      list(file = file.path("data_raw", "S40宇航员（30-80°）海兽记录表-订.xlsx"), schema_id = "S40")
    ),
    source_schemas = list(
      S39 = list(
        survey_date_raw = "日期（UTC时间）",
        survey_time_raw = "时间（UTC时间）",
        species_cn = "物种名",
        region = NULL,
        lon_raw = "经度",
        lat_raw = "纬度S",
        count_raw = "数量",
        distance_m_raw = NULL,
        lon_default_hemisphere = "E",
        lat_default_hemisphere = "S"
      ),
      S40 = list(
        survey_date_raw = "日期",
        survey_time_raw = "UTC时间",
        species_cn = "中文名",
        region = "海区",
        lon_raw = "经度",
        lat_raw = "纬度",
        count_raw = "数量",
        distance_m_raw = "距离（m）",
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
    run_dir = file.path("outputs", "humpback_cosmonaut"),
    legacy_write = TRUE,
    legacy_note = "legacy compatibility only"
  )
)