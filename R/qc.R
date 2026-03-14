# occurrence 质控函数 -----------------------------------------------------------

# 从距离原始字段中提取单一数值，便于后续做 parseable 统计。
sdm_extract_numeric <- function(x) {
  x_chr <- trimws(as.character(x))
  x_chr[x_chr %in% c("", "NA")] <- NA_character_
  nums <- stringr::str_extract_all(x_chr, "\\d+(?:\\.\\d+)?")
  vapply(nums, function(v) {
    if (length(v) == 1) as.numeric(v) else NA_real_
  }, numeric(1))
}

# 对 occurrence 表执行基础质控。
# 当前规则延续已有项目逻辑：缺失日期、缺失坐标、重复记录、方向错误、非正数量等会被标记。
sdm_qc_occurrence <- function(occurrence_df) {
  occ_raw <- occurrence_df
  occ_raw$record_id <- seq_len(nrow(occ_raw))
  occ_raw$distance_parseable_numeric <- sdm_extract_numeric(occ_raw$distance_m_raw)

  lon_range_ref <- range(occ_raw$lon, na.rm = TRUE)
  lat_range_ref <- range(occ_raw$lat, na.rm = TRUE)

  occ_qc <- occ_raw |>
    dplyr::mutate(
      missing_date = is.na(survey_date_utc) | survey_date_utc == "",
      missing_time = is.na(survey_time_utc) | survey_time_utc == "",
      missing_lon = is.na(lon),
      missing_lat = is.na(lat),
      missing_coord = missing_lon | missing_lat,
      missing_count = is.na(count),
      duplicate_exact = duplicated(dplyr::across(c(source_file, source_sheet, survey_date_utc, survey_time_utc, species_cn, region, lon, lat, count, distance_m_raw, distance_m))),
      coord_invalid_range = (!missing_lon & (lon < -180 | lon > 180)) | (!missing_lat & (lat < -90 | lat > 90)),
      coord_direction_issue = (!missing_lon & lon < 0) | (!missing_lat & lat > 0),
      coord_outside_survey_region = (!missing_lon & (lon < lon_range_ref[1] - 5 | lon > lon_range_ref[2] + 5)) |
        (!missing_lat & (lat < lat_range_ref[1] - 5 | lat > lat_range_ref[2] + 5)),
      count_nonpositive = !is.na(count) & count <= 0,
      count_outlier = !is.na(count) & count > (stats::quantile(count, 0.75, na.rm = TRUE) + 3 * stats::IQR(count, na.rm = TRUE)),
      distance_raw_present = !is.na(distance_m_raw) & distance_m_raw != "",
      distance_numeric_parseable = !is.na(distance_parseable_numeric),
      drop_reason = dplyr::case_when(
        missing_date ~ "missing_date",
        missing_coord ~ "missing_coord",
        missing_count ~ "missing_count",
        coord_invalid_range ~ "coord_invalid_range",
        coord_direction_issue ~ "coord_direction_issue",
        coord_outside_survey_region ~ "coord_outside_survey_region",
        count_nonpositive ~ "count_nonpositive",
        duplicate_exact ~ "duplicate_exact",
        TRUE ~ ""
      ),
      keep_record = drop_reason == ""
    )

  qc_report <- occ_qc |>
    dplyr::select(
      record_id, source_file, source_sheet, survey_date_utc, survey_time_utc,
      species_cn, region, lon, lat, count, distance_m_raw, distance_m,
      missing_date, missing_time, missing_coord, missing_count,
      duplicate_exact, coord_invalid_range, coord_direction_issue,
      coord_outside_survey_region, count_nonpositive, count_outlier,
      distance_raw_present, distance_numeric_parseable, keep_record, drop_reason
    )

  occ_clean <- occ_qc |>
    dplyr::filter(keep_record) |>
    dplyr::distinct(source_file, source_sheet, survey_date_utc, survey_time_utc, species_cn, region, lon, lat, count, distance_m_raw, distance_m, .keep_all = TRUE) |>
    dplyr::arrange(survey_date_utc, survey_time_utc, source_file, source_sheet, lon, lat) |>
    dplyr::select(source_file, source_sheet, survey_date_utc, survey_time_utc, species_cn, region, lon, lat, count, distance_m_raw, distance_m)

  summary_lines <- c(
    sprintf("Input records: %d", nrow(occ_raw)),
    sprintf("Retained records: %d", nrow(occ_clean)),
    sprintf("Removed records: %d", nrow(occ_raw) - nrow(occ_clean)),
    sprintf("Missing survey_date_utc: %d", sum(occ_qc$missing_date)),
    sprintf("Missing survey_time_utc: %d", sum(occ_qc$missing_time)),
    sprintf("Missing coordinates: %d", sum(occ_qc$missing_coord)),
    sprintf("Missing count: %d", sum(occ_qc$missing_count)),
    sprintf("Exact duplicate records: %d", sum(occ_qc$duplicate_exact)),
    sprintf("Coordinate invalid range: %d", sum(occ_qc$coord_invalid_range)),
    sprintf("Coordinate direction issue: %d", sum(occ_qc$coord_direction_issue)),
    sprintf("Coordinate outside survey region: %d", sum(occ_qc$coord_outside_survey_region)),
    sprintf("Non-positive count: %d", sum(occ_qc$count_nonpositive)),
    sprintf("Count outlier: %d", sum(occ_qc$count_outlier)),
    sprintf("Distance raw present: %d", sum(occ_qc$distance_raw_present)),
    sprintf("Distance numeric parseable: %d", sum(occ_qc$distance_numeric_parseable))
  )

  list(qc_report = qc_report, occ_clean = occ_clean, summary_lines = summary_lines)
}