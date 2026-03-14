# 输入输出与 occurrence 标准化 ---------------------------------------------------

# 以 UTF-8 BOM 形式写出 CSV，便于 Windows Excel 直接打开。
sdm_write_csv_bom <- function(df, path) {
  tmp <- tempfile(fileext = ".csv")
  utils::write.csv(df, tmp, row.names = FALSE, fileEncoding = "UTF-8", na = "")
  size <- file.info(tmp)$size
  content <- readChar(tmp, nchars = size, useBytes = TRUE)
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(as.raw(c(0xEF, 0xBB, 0xBF)), con)
  writeChar(content, con, eos = NULL, useBytes = TRUE)
}

# 读取 Excel 友好的 CSV。
sdm_read_csv_utf8 <- function(path) {
  read.csv(path, check.names = FALSE, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
}

# 将多物种 / 多数量单元格拆成逐行记录。
sdm_split_species_tokens <- function(x) {
  x_chr <- sdm_trim_na(x)
  if (is.na(x_chr)) {
    return(NA_character_)
  }
  parts <- stringr::str_split(x_chr, "[、，,/;；]+", simplify = FALSE)[[1]]
  parts <- sdm_trim_na(parts)
  parts[!is.na(parts)]
}

sdm_split_count_tokens <- function(x) {
  x_chr <- sdm_trim_na(x)
  if (is.na(x_chr)) {
    return(NA_character_)
  }
  parts <- stringr::str_split(x_chr, "[+、，,/;；]+", simplify = FALSE)[[1]]
  parts <- sdm_trim_na(parts)
  parts[!is.na(parts)]
}

sdm_expand_species_count_rows <- function(df) {
  purrr::pmap_dfr(df, function(source_file, source_sheet, source_row, survey_date_raw, survey_time_raw, species_cn, region, lon_raw, lat_raw, count_raw, distance_m_raw) {
    species_parts <- sdm_split_species_tokens(species_cn)
    count_parts <- sdm_split_count_tokens(count_raw)

    if (length(species_parts) == 1 && length(count_parts) == 1) {
      return(tibble::tibble(
        source_file = source_file,
        source_sheet = source_sheet,
        source_row = source_row,
        survey_date_raw = survey_date_raw,
        survey_time_raw = survey_time_raw,
        species_cn = species_parts,
        region = region,
        lon_raw = lon_raw,
        lat_raw = lat_raw,
        count_raw = count_parts,
        distance_m_raw = distance_m_raw
      ))
    }

    if (length(species_parts) == length(count_parts)) {
      return(tibble::tibble(
        source_file = rep(source_file, length(species_parts)),
        source_sheet = rep(source_sheet, length(species_parts)),
        source_row = rep(source_row, length(species_parts)),
        survey_date_raw = rep(survey_date_raw, length(species_parts)),
        survey_time_raw = rep(survey_time_raw, length(species_parts)),
        species_cn = species_parts,
        region = rep(region, length(species_parts)),
        lon_raw = rep(lon_raw, length(species_parts)),
        lat_raw = rep(lat_raw, length(species_parts)),
        count_raw = count_parts,
        distance_m_raw = rep(distance_m_raw, length(species_parts))
      ))
    }

    stop(
      sprintf(
        "Ambiguous species/count pairing in %s / %s at source row %s: species=\"%s\", count=\"%s\"",
        source_file,
        source_sheet,
        source_row,
        species_cn,
        count_raw
      ),
      call. = FALSE
    )
  })
}

# Excel 序列值与常见日期字符串统一转为 Date。
sdm_parse_date_utc <- function(x) {
  x_chr <- sdm_trim_na(x)
  out <- as.Date(rep(NA_character_, length(x_chr)))

  numeric_value <- suppressWarnings(as.numeric(x_chr))
  is_numeric_date <- !is.na(numeric_value) & !stringr::str_detect(x_chr, "[-./年月]")
  if (any(is_numeric_date, na.rm = TRUE)) {
    out[is_numeric_date] <- as.Date(numeric_value[is_numeric_date], origin = "1899-12-30")
  }

  remain <- which(!is.na(x_chr) & is.na(out))
  if (length(remain) > 0) {
    normalized <- x_chr[remain] |>
      stringr::str_replace_all("[./年]", "-") |>
      stringr::str_replace_all("月", "-") |>
      stringr::str_replace_all("日", "")
    parsed <- suppressWarnings(lubridate::ymd(normalized, quiet = TRUE))
    out[remain] <- as.Date(parsed)
  }

  out
}

# 统一时间列，兼容 Excel 数值时间与 HH:MM:SS 字符串。
sdm_parse_time_utc <- function(x) {
  x_chr <- sdm_trim_na(x)
  out <- rep(NA_character_, length(x_chr))

  numeric_value <- suppressWarnings(as.numeric(x_chr))
  is_numeric_time <- !is.na(numeric_value)
  if (any(is_numeric_time, na.rm = TRUE)) {
    seconds <- round((numeric_value[is_numeric_time] %% 1) * 86400) %% 86400
    out[is_numeric_time] <- format(as.POSIXct(seconds, origin = "1970-01-01", tz = "UTC"), "%H:%M:%S")
  }

  remain <- which(!is.na(x_chr) & is.na(out))
  if (length(remain) > 0) {
    normalized <- stringr::str_replace_all(x_chr[remain], "[：﹕꞉]", ":")
    parsed <- suppressWarnings(lubridate::parse_date_time(normalized, orders = c("HMS", "HM"), tz = "UTC", quiet = TRUE))
    out[remain] <- ifelse(is.na(parsed), NA_character_, format(parsed, "%H:%M:%S"))
  }

  out
}

sdm_parse_count_numeric <- function(x) {
  x_chr <- sdm_trim_na(x)
  x_chr <- stringr::str_replace_all(x_chr, ",", "")
  suppressWarnings(as.numeric(x_chr))
}

sdm_parse_distance_numeric <- function(x) {
  x_chr <- sdm_trim_na(x)
  purrr::map_dbl(x_chr, function(value) {
    if (is.na(value)) {
      return(NA_real_)
    }
    nums <- stringr::str_extract_all(value, "\\d+(?:\\.\\d+)?")[[1]]
    if (length(nums) == 1) {
      return(as.numeric(nums))
    }
    NA_real_
  })
}

# 对解析结果进行核查，避免静默失败。
sdm_validate_parsed <- function(raw, parsed, field_label, source_file, source_sheet, source_row) {
  raw_chr <- sdm_trim_na(raw)
  failed <- which(!is.na(raw_chr) & is.na(parsed))
  if (length(failed) > 0) {
    stop(
      sprintf(
        "Failed to parse %s in %s / %s at source row(s): %s",
        field_label,
        source_file,
        source_sheet,
        paste(source_row[failed], collapse = ", ")
      ),
      call. = FALSE
    )
  }
}

# 按配置读取所有工作簿和工作表，并统一生成 occurrence 原始表。
sdm_read_occurrence_workbooks <- function(config) {
  all_occurrences <- list()
  sheet_log <- list()

  for (book in config$input$workbooks) {
    file_path <- sdm_abs_path(config$project_root, book$file)
    schema <- config$input$source_schemas[[book$schema_id]]
    sheets <- readxl::excel_sheets(file_path)

    for (sheet_name in sheets) {
      raw_sheet <- readxl::read_excel(file_path, sheet = sheet_name, .name_repair = "minimal")
      blank_name_idx <- which(is.na(names(raw_sheet)) | names(raw_sheet) == "")
      if (length(blank_name_idx) > 0) {
        names(raw_sheet)[blank_name_idx] <- paste0("unnamed_", seq_along(blank_name_idx))
      }

      sheet_log[[length(sheet_log) + 1]] <- tibble::tibble(
        source_file = basename(file_path),
        source_sheet = sheet_name
      )

      if (ncol(raw_sheet) == 0 || nrow(raw_sheet) == 0) {
        next
      }

      keep_row <- apply(raw_sheet, 1, function(row) any(!is.na(row) & trimws(as.character(row)) != ""))
      raw_sheet <- raw_sheet[keep_row, , drop = FALSE]
      if (nrow(raw_sheet) == 0) {
        next
      }
      raw_sheet$source_row <- seq_len(nrow(raw_sheet))

      required_fields <- unlist(schema[c("survey_date_raw", "survey_time_raw", "species_cn", "lon_raw", "lat_raw", "count_raw")], use.names = FALSE)
      required_fields <- required_fields[!is.na(required_fields)]
      missing_fields <- setdiff(required_fields, names(raw_sheet))
      if (length(missing_fields) > 0) {
        stop(sprintf("Unrecognized fields in %s / %s. Missing: %s", basename(file_path), sheet_name, paste(missing_fields, collapse = ", ")), call. = FALSE)
      }

      standardized <- raw_sheet |>
        dplyr::transmute(
          source_file = basename(file_path),
          source_sheet = sheet_name,
          source_row,
          survey_date_raw = .data[[schema$survey_date_raw]],
          survey_time_raw = .data[[schema$survey_time_raw]],
          species_cn = sdm_trim_na(.data[[schema$species_cn]]),
          region = if (is.null(schema$region)) NA_character_ else sdm_trim_na(.data[[schema$region]]),
          lon_raw = .data[[schema$lon_raw]],
          lat_raw = .data[[schema$lat_raw]],
          count_raw = .data[[schema$count_raw]],
          distance_m_raw = if (is.null(schema$distance_m_raw)) NA_character_ else sdm_trim_na(.data[[schema$distance_m_raw]])
        ) |>
        sdm_expand_species_count_rows() |>
        dplyr::filter(!is.na(species_cn)) |>
        dplyr::mutate(
          survey_date_utc = sdm_parse_date_utc(survey_date_raw),
          survey_time_utc = sdm_parse_time_utc(survey_time_raw),
          lon = sdm_parse_coord_vector(lon_raw, schema$lon_default_hemisphere),
          lat = sdm_parse_coord_vector(lat_raw, schema$lat_default_hemisphere),
          count = sdm_parse_count_numeric(count_raw),
          distance_m = sdm_parse_distance_numeric(distance_m_raw)
        )

      sdm_validate_parsed(standardized$survey_date_raw, standardized$survey_date_utc, "survey_date_utc", basename(file_path), sheet_name, standardized$source_row)
      sdm_validate_parsed(standardized$survey_time_raw, standardized$survey_time_utc, "survey_time_utc", basename(file_path), sheet_name, standardized$source_row)
      sdm_validate_parsed(standardized$lon_raw, standardized$lon, "lon", basename(file_path), sheet_name, standardized$source_row)
      sdm_validate_parsed(standardized$lat_raw, standardized$lat, "lat", basename(file_path), sheet_name, standardized$source_row)
      sdm_validate_parsed(standardized$count_raw, standardized$count, "count", basename(file_path), sheet_name, standardized$source_row)

      standardized <- standardized |>
        dplyr::transmute(
          source_file,
          source_sheet,
          survey_date_utc = ifelse(is.na(survey_date_utc), NA_character_, format(survey_date_utc, "%Y-%m-%d")),
          survey_time_utc,
          species_cn,
          region,
          lon,
          lat,
          count,
          distance_m_raw,
          distance_m
        )

      all_occurrences[[length(all_occurrences) + 1]] <- standardized
    }
  }

  occurrence_tbl <- dplyr::bind_rows(all_occurrences)
  if (nrow(occurrence_tbl) == 0) {
    stop("No occurrence rows were parsed from the configured workbooks.", call. = FALSE)
  }

  list(
    occurrence_tbl = occurrence_tbl,
    sheet_log = dplyr::bind_rows(sheet_log)
  )
}

# 依据配置中的目标物种筛选 occurrence，并生成概览表。
sdm_extract_target_occurrence <- function(occurrence_tbl, config) {
  target_value <- config$species$target_value
  target_tbl <- occurrence_tbl |>
    dplyr::filter(!is.na(species_cn), stringr::str_squish(species_cn) == target_value) |>
    dplyr::arrange(survey_date_utc, survey_time_utc, source_file, source_sheet)

  overview_tbl <- if (nrow(target_tbl) == 0) {
    tibble::tibble(
      source_file = character(),
      source_sheet = character(),
      target_record_count = integer(),
      total_count = numeric(),
      min_survey_date_utc = character(),
      max_survey_date_utc = character(),
      min_lon = numeric(),
      max_lon = numeric(),
      min_lat = numeric(),
      max_lat = numeric()
    )
  } else {
    target_tbl |>
      dplyr::group_by(source_file, source_sheet) |>
      dplyr::summarise(
        target_record_count = dplyr::n(),
        total_count = sum(count, na.rm = TRUE),
        min_survey_date_utc = min(survey_date_utc, na.rm = TRUE),
        max_survey_date_utc = max(survey_date_utc, na.rm = TRUE),
        min_lon = min(lon, na.rm = TRUE),
        max_lon = max(lon, na.rm = TRUE),
        min_lat = min(lat, na.rm = TRUE),
        max_lat = max(lat, na.rm = TRUE),
        .groups = "drop"
      )
  }

  list(target_tbl = target_tbl, overview_tbl = overview_tbl)
}