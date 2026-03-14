# biomod2 建模函数 --------------------------------------------------------------

# 将相关矩阵转成长表，便于后续保存和审阅。
sdm_melt_correlation <- function(cor_mat, selected_vars, threshold) {
  as.data.frame(as.table(cor_mat), stringsAsFactors = FALSE) |>
    dplyr::rename(var1 = Var1, var2 = Var2, correlation = Freq) |>
    dplyr::mutate(
      abs_correlation = abs(correlation),
      selected_var1 = var1 %in% selected_vars,
      selected_var2 = var2 %in% selected_vars,
      above_threshold = abs_correlation >= threshold
    ) |>
    dplyr::arrange(var1, var2)
}

# 按优先级和阈值筛选变量。
sdm_select_predictors <- function(r, priority_order, threshold = 0.9, sample_size = 20000) {
  vals <- terra::spatSample(r[[priority_order]], size = min(sample_size, terra::ncell(r)), method = "random", na.rm = TRUE, as.df = TRUE)
  cor_mat <- stats::cor(vals, use = "complete.obs", method = "pearson")

  selected <- character(0)
  dropped <- tibble::tibble(variable = character(), dropped_because_of = character(), correlation = numeric())

  for (v in priority_order) {
    if (length(selected) == 0) {
      selected <- c(selected, v)
      next
    }
    cors <- abs(cor_mat[v, selected])
    max_cor <- max(cors, na.rm = TRUE)
    if (is.finite(max_cor) && max_cor >= threshold) {
      culprit <- selected[which.max(cors)]
      dropped <- dplyr::bind_rows(dropped, tibble::tibble(variable = v, dropped_because_of = culprit, correlation = unname(cor_mat[v, culprit])))
    } else {
      selected <- c(selected, v)
    }
  }

  list(cor_mat = cor_mat, selected = selected, dropped = dropped)
}

# presence-only 数据转为 biomod2 所需的 presence + pseudo-absence 输入。
sdm_prepare_model_input <- function(occ_df, predictor_stack, pseudo_absence_cfg) {
  occ_sf <- sf::st_as_sf(occ_df, coords = c("lon", "lat"), crs = 4326)
  occ_sf <- sf::st_transform(occ_sf, terra::crs(predictor_stack))
  pres_xy <- sf::st_coordinates(occ_sf)
  pres_cells <- terra::cellFromXY(predictor_stack[[1]], pres_xy)
  keep <- !is.na(pres_cells)

  occ_kept <- occ_df[keep, , drop = FALSE]
  pres_xy <- pres_xy[keep, , drop = FALSE]
  pres_cells <- pres_cells[keep]

  available_cells <- which(!is.na(terra::values(predictor_stack[[1]])))
  pa_pool <- setdiff(available_cells, unique(pres_cells))
  pa_n <- min(
    pseudo_absence_cfg$max_n,
    max(pseudo_absence_cfg$min_n, as.integer(nrow(occ_kept) * pseudo_absence_cfg$multiplier)),
    length(pa_pool)
  )
  if (pa_n < 50) {
    stop("Not enough background cells to generate pseudo-absences.", call. = FALSE)
  }

  pa_cells <- sample(pa_pool, pa_n)
  pa_xy <- as.data.frame(terra::xyFromCell(predictor_stack[[1]], pa_cells))
  colnames(pa_xy) <- c("X", "Y")

  xy <- rbind(data.frame(X = pres_xy[, 1], Y = pres_xy[, 2]), pa_xy)
  resp <- c(rep(1, nrow(pres_xy)), rep(0, nrow(pa_xy)))

  list(occ_kept = occ_kept, xy = xy, resp = resp, pseudoabsence_n = pa_n)
}

# 将已有 phase4 的核心逻辑函数化，便于 targets 或独立脚本复用。
sdm_run_biomod_pipeline <- function(model_label,
                                    occ_df,
                                    predictor_stack,
                                    candidate_vars,
                                    priority_order,
                                    config,
                                    corr_output,
                                    eval_output,
                                    varimp_output,
                                    ensemble_output,
                                    summary_output,
                                    biomod_dir) {
  threshold <- config$biomod2$correlation_threshold
  selection <- sdm_select_predictors(predictor_stack, priority_order = priority_order, threshold = threshold)
  selected_vars <- selection$selected
  corr_df <- sdm_melt_correlation(selection$cor_mat, selected_vars, threshold)
  sdm_write_csv_bom(corr_df, corr_output)

  model_input <- sdm_prepare_model_input(occ_df, predictor_stack[[selected_vars]], config$pseudo_absence)

  modeling_error <- NULL
  successful_algorithms <- character(0)
  ensemble_success <- FALSE
  eval_tbl <- tibble::tibble()
  varimp_tbl <- tibble::tibble()

  tryCatch({
    biomod_data <- biomod2::BIOMOD_FormatingData(
      resp.name = paste0(config$species$target_name_en, "_", model_label),
      resp.var = model_input$resp,
      expl.var = predictor_stack[[selected_vars]],
      resp.xy = model_input$xy,
      dir.name = biomod_dir,
      filter.raster = FALSE
    )

    biomod_model <- biomod2::BIOMOD_Modeling(
      bm.format = biomod_data,
      modeling.id = paste0(model_label, "_baseline"),
      models = config$biomod2$models,
      bm.options = biomod2::BIOMOD_ModelingOptions(),
      CV.strategy = config$biomod2$cv_strategy,
      CV.nb.rep = config$biomod2$cv_nb_rep,
      CV.perc = config$biomod2$cv_perc,
      CV.do.full.models = FALSE,
      metric.eval = config$biomod2$metric_eval,
      var.import = config$biomod2$var_import,
      nb.cpu = config$biomod2$nb_cpu,
      seed.val = config$biomod2$seed,
      do.progress = FALSE
    )

    built_models <- biomod2::get_built_models(biomod_model)
    successful_algorithms <- sort(unique(vapply(strsplit(built_models, "_"), function(x) tail(x, 1), character(1))))

    eval_tbl <- tibble::as_tibble(tryCatch(biomod2::get_evaluations(biomod_model), error = function(e) tibble::tibble()))
    varimp_tbl <- tibble::as_tibble(tryCatch(biomod2::get_variables_importance(biomod_model), error = function(e) tibble::tibble()))

    biomod_em <- biomod2::BIOMOD_EnsembleModeling(
      bm.mod = biomod_model,
      em.by = "all",
      em.algo = config$biomod2$ensemble_algo,
      metric.select = config$biomod2$metric_select,
      metric.select.thresh = config$biomod2$metric_select_thresh,
      metric.eval = config$biomod2$metric_eval,
      var.import = config$biomod2$var_import,
      nb.cpu = config$biomod2$nb_cpu,
      seed.val = config$biomod2$seed,
      do.progress = FALSE
    )

    biomod_proj <- biomod2::BIOMOD_Projection(
      bm.mod = biomod_model,
      proj.name = paste0(model_label, "_projection"),
      new.env = predictor_stack[[selected_vars]],
      models.chosen = "all",
      compress = FALSE,
      build.clamping.mask = FALSE,
      nb.cpu = config$biomod2$nb_cpu,
      seed.val = config$biomod2$seed
    )

    biomod_ef <- biomod2::BIOMOD_EnsembleForecasting(
      bm.em = biomod_em,
      bm.proj = biomod_proj,
      models.chosen = "all",
      compress = FALSE,
      nb.cpu = config$biomod2$nb_cpu
    )

    ensemble_pred <- biomod2::get_predictions(biomod_ef)
    if (inherits(ensemble_pred, "SpatRaster")) {
      layer_pick <- grep(config$biomod2$ensemble_algo, names(ensemble_pred), value = TRUE)
      if (length(layer_pick) == 0) {
        layer_pick <- names(ensemble_pred)[1]
      } else {
        layer_pick <- layer_pick[1]
      }
      terra::writeRaster(ensemble_pred[[layer_pick]], ensemble_output, overwrite = TRUE)
      ensemble_success <- file.exists(ensemble_output)
    }
  }, error = function(e) {
    modeling_error <<- conditionMessage(e)
  })

  sdm_write_csv_bom(eval_tbl, eval_output)
  sdm_write_csv_bom(varimp_tbl, varimp_output)

  summary_lines <- c(
    sprintf("Model label: %s", model_label),
    sprintf("Sample size requested: %d", nrow(occ_df)),
    sprintf("Sample size used after CRS/raster intersection: %d", nrow(model_input$occ_kept)),
    sprintf("Pseudo-absence count generated: %d", model_input$pseudoabsence_n),
    sprintf("Candidate variables: %s", paste(candidate_vars, collapse = ", ")),
    sprintf("Selected variables: %s", paste(selected_vars, collapse = ", ")),
    sprintf("Successful algorithms: %s", ifelse(length(successful_algorithms) == 0, "none", paste(successful_algorithms, collapse = ", "))),
    sprintf("Ensemble generated: %s", ensemble_success),
    sprintf("Model error: %s", ifelse(is.null(modeling_error), "none", modeling_error))
  )
  writeLines(summary_lines, summary_output, useBytes = TRUE)

  list(selected_vars = selected_vars, successful_algorithms = successful_algorithms, ensemble_success = ensemble_success, error = modeling_error)
}