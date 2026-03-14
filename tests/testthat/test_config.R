testthat::test_that("run config can be loaded", {
  cfg <- sdm_load_config(file.path(project_root, "config", "runs", "humpback_cosmonaut.R"))
  testthat::expect_type(cfg, "list")
  testthat::expect_equal(cfg$run_id, "humpback_cosmonaut")
  testthat::expect_true(file.exists(cfg$config_path))
  testthat::expect_equal(cfg$species$target_name_cn, "座头鲸")
})

testthat::test_that("run paths point to formal outputs directory", {
  cfg <- sdm_load_config(file.path(project_root, "config", "runs", "humpback_cosmonaut.R"))
  paths <- sdm_build_run_paths(cfg)
  formal_root <- gsub("\\\\", "/", paths$formal_output_root)
  testthat::expect_match(formal_root, "outputs/humpback_cosmonaut$")
  testthat::expect_match(sdm_output_path(paths, "tables", "demo.csv"), "outputs/.*/tables/demo\\.csv$")
})