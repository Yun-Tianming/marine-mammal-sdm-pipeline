# 研究区构建函数 ----------------------------------------------------------------

# 根据配置构建 study area。
# 当前默认方法为 convex hull + buffer，但参数已放到 config，后续可扩展最小包围矩形或自定义 polygon。
sdm_build_study_area <- function(occurrence_df, config) {
  if (!identical(config$study_area$method, "convex_hull_buffer")) {
    stop(sprintf("Unsupported study area method: %s", config$study_area$method), call. = FALSE)
  }

  occ_sf <- sf::st_as_sf(occurrence_df, coords = c("lon", "lat"), crs = 4326, remove = FALSE)
  occ_sf_analysis <- sf::st_transform(occ_sf, config$study_area$analysis_crs)
  buffer_m <- as.numeric(config$study_area$buffer_km) * 1000

  study_area_geom <- occ_sf_analysis |>
    sf::st_union() |>
    sf::st_convex_hull() |>
    sf::st_buffer(dist = buffer_m)

  list(
    occ_sf = occ_sf,
    occ_sf_analysis = occ_sf_analysis,
    convex_hull = sf::st_as_sf(data.frame(id = 1), geometry = sf::st_sfc(sf::st_convex_hull(sf::st_union(occ_sf_analysis)), crs = sf::st_crs(occ_sf_analysis))),
    study_area = sf::st_as_sf(data.frame(id = 1), geometry = sf::st_sfc(study_area_geom, crs = sf::st_crs(occ_sf_analysis)))
  )
}