# 坐标与通用字符串处理函数 ------------------------------------------------------

# 统一清洗空字符、全角空格和伪 NA 字符串。
sdm_trim_na <- function(x) {
  x_chr <- as.character(x)
  x_chr <- stringr::str_replace_all(x_chr, "[\u00A0\u3000]", " ")
  x_chr <- stringr::str_squish(x_chr)
  x_chr[x_chr %in% c("", "NA", "NaN", "NULL")] <- NA_character_
  x_chr
}

# 解析单个坐标值，兼容十进制度、度分、度分秒和带方向字符的表达。
sdm_parse_coord_value <- function(value, default_hemisphere = NA_character_) {
  value_chr <- sdm_trim_na(value)
  if (is.na(value_chr)) {
    return(NA_real_)
  }

  normalized <- value_chr |>
    stringr::str_replace_all("[‘’ʼʹ′]", "'") |>
    stringr::str_replace_all("[“”ʺ″]", '"') |>
    stringr::str_replace_all("[º˚]", "°") |>
    stringr::str_squish()

  sign <- if (stringr::str_detect(normalized, "^[[:space:]]*-")) -1 else 1

  if (stringr::str_detect(normalized, "[Ss南纬南]")) {
    sign <- -1
  } else if (stringr::str_detect(normalized, "[Ww西经西]")) {
    sign <- -1
  } else if (stringr::str_detect(normalized, "[Nn北纬北Ee东经东]")) {
    sign <- 1
  } else if (!is.na(default_hemisphere)) {
    sign <- if (default_hemisphere %in% c("S", "W")) -1 else 1
  }

  numeric_parts <- stringr::str_extract_all(normalized, "\\d+(?:\\.\\d+)?")[[1]]
  if (length(numeric_parts) == 0) {
    return(NA_real_)
  }

  numeric_parts <- as.numeric(numeric_parts)
  decimal <- if (length(numeric_parts) == 1) {
    numeric_parts[1]
  } else if (length(numeric_parts) == 2) {
    numeric_parts[1] + numeric_parts[2] / 60
  } else {
    numeric_parts[1] + numeric_parts[2] / 60 + numeric_parts[3] / 3600
  }

  sign * decimal
}

# 批量解析坐标列。
sdm_parse_coord_vector <- function(x, default_hemisphere) {
  purrr::map_dbl(x, sdm_parse_coord_value, default_hemisphere = default_hemisphere)
}