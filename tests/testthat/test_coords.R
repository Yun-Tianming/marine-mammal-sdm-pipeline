testthat::test_that("coordinate parser handles degree decimal minutes", {
  value <- sdm_parse_coord_value("78°16.109‘E", default_hemisphere = "E")
  testthat::expect_equal(round(value, 6), round(78 + 16.109 / 60, 6))
})

testthat::test_that("coordinate parser handles degrees minutes seconds and south latitude", {
  value <- sdm_parse_coord_value("29°59'15\"S", default_hemisphere = "S")
  expected <- -(29 + 59 / 60 + 15 / 3600)
  testthat::expect_equal(round(value, 6), round(expected, 6))
})