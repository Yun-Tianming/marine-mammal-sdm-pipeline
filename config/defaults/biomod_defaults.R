# biomod2 默认参数 ---------------------------------------------------------------

biomod_defaults <- list(
  models = c("GLM", "GAM", "GBM", "RF", "SRE"),
  cv_strategy = "random",
  cv_nb_rep = 3L,
  cv_perc = 0.8,
  metric_eval = c("TSS", "ROC"),
  var_import = 3L,
  correlation_threshold = 0.9,
  ensemble_algo = "EMmean",
  metric_select = "ROC",
  metric_select_thresh = 0.7,
  seed = 20260314L,
  nb_cpu = 1L
)