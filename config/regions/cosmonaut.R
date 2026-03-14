# Region config: Cosmonaut coastal sector

region_cosmonaut <- list(
  name = "Antarctic coastal sector",
  display_lon = c(10, 90),
  display_lat = c(-72, -58),
  graticule_lon = seq(30, 80, by = 10),
  graticule_lat = seq(-70, -60, by = 2)
)

study_area_cosmonaut <- list(
  method = "convex_hull_buffer",
  analysis_crs = "EPSG:3031",
  buffer_km = 150
)
