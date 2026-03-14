# predictor 处理函数 ------------------------------------------------------------

# 将现有 predictors stack 复制到 run_id 输出目录。
# 当前重构阶段不重新下载环境变量，只复用已经处理好的栅格文件。
sdm_stage_existing_predictor_stack <- function(source_path, target_path) {
  if (!file.exists(source_path)) {
    stop(sprintf("Predictor stack not found: %s", source_path), call. = FALSE)
  }

  dir.create(dirname(target_path), recursive = TRUE, showWarnings = FALSE)
  file.copy(source_path, target_path, overwrite = TRUE)
  target_path
}

# 读取并校验 predictor 栈是否包含预期图层。
sdm_read_predictor_stack <- function(path, expected_layers = NULL) {
  if (!file.exists(path)) {
    stop(sprintf("Predictor stack not found: %s", path), call. = FALSE)
  }

  r <- terra::rast(path)
  if (!is.null(expected_layers)) {
    missing_layers <- setdiff(expected_layers, names(r))
    if (length(missing_layers) > 0) {
      stop(sprintf("Predictor stack missing layers: %s", paste(missing_layers, collapse = ", ")), call. = FALSE)
    }
  }
  r
}