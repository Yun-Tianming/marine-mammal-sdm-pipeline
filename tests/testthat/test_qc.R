sample_occurrence <- data.frame(
  source_file = c("a.xlsx", "a.xlsx", "b.xlsx"),
  source_sheet = c("Sheet1", "Sheet1", "Sheet2"),
  survey_date_utc = c("2023-01-01", "2023-01-01", "2023-01-02"),
  survey_time_utc = c("10:00:00", "10:00:00", "11:00:00"),
  species_cn = c("座头鲸", "座头鲸", "座头鲸"),
  region = c(NA, NA, "A"),
  lon = c(60.1, 60.1, NA),
  lat = c(-65.1, -65.1, -66.2),
  count = c(2, 2, 1),
  distance_m_raw = c("100", "100", "200"),
  distance_m = c(100, 100, 200),
  stringsAsFactors = FALSE
)

testthat::test_that("qc identifies duplicate records", {
  qc <- sdm_qc_occurrence(sample_occurrence)
  testthat::expect_true(any(qc$qc_report$duplicate_exact))
})

testthat::test_that("qc identifies missing coordinates", {
  qc <- sdm_qc_occurrence(sample_occurrence)
  testthat::expect_true(any(qc$qc_report$missing_coord))
  testthat::expect_true(any(qc$qc_report$drop_reason == "missing_coord"))
})