# Example run config template

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
  description = "Example run config that shows how to assemble a new run without modifying core functions.",
  species = species_humpback,
  input = list(
    raw_data_dir = "data_raw",
    workbooks = list(
      list(file = file.path("data_raw", "your_occurrence_file.xlsx"), schema_id = "schema_a")
    ),
    source_schemas = list(
      schema_a = list(
        survey_date_raw = "Date column",
        survey_time_raw = "Time column",
        species_cn = "Species column",
        region = "Region column or NULL",
        lon_raw = "Longitude column",
        lat_raw = "Latitude column",
        count_raw = "Count column",
        distance_m_raw = "Distance column or NULL",
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
