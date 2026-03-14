# Shared predictor defaults

predictor_defaults <- list(
  full = c("bathymetry", "slope", "sst", "chlorophyll_a", "sea_ice_concentration"),
  extended = c("bathymetry", "slope", "sst", "chlorophyll_a", "sea_ice_concentration", "mlotst", "so", "zos"),
  full_priority = c("bathymetry", "slope", "sst", "chlorophyll_a", "sea_ice_concentration"),
  extended_priority = c("bathymetry", "slope", "sst", "chlorophyll_a", "mlotst", "so", "zos", "sea_ice_concentration"),
  raw_bathymetry = "env_raw/marspec/MS_bathy_5m_lonlat.tif",
  processed_stack = "env_processed/predictors_stack.tif",
  processed_stack_extended = "env_processed/predictors_stack_extended.tif"
)

pseudo_absence_defaults <- list(
  strategy = "random_background",
  multiplier = 5L,
  min_n = 300L,
  max_n = 1000L
)
