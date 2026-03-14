# Smoke test

This file documents the smallest checks that confirm the project structure is usable without rerunning analysis or modeling.

## 1. Verify config loading

```r
Rscript -e "source('R/config.R'); cfg <- sdm_load_config('config/runs/humpback_cosmonaut.R'); cat(cfg$run_id, '\n')"
```

Expected output:

- `humpback_cosmonaut`

## 2. Verify `_targets.R` can be parsed

```r
Rscript -e "parse(file = '_targets.R'); cat('targets file parse ok\n')"
```

## 3. Verify formal output path construction

```r
Rscript -e "source('R/config.R'); cfg <- sdm_load_config('config/runs/humpback_cosmonaut.R'); paths <- sdm_build_run_paths(cfg); cat(paths$formal_output_root, '\n'); cat(sdm_output_path(paths, 'tables', 'demo.csv'), '\n')"
```

Expected behavior:

- the first line points to `outputs/humpback_cosmonaut`
- the second line points to `outputs/humpback_cosmonaut/tables/demo.csv`

## 4. Optional minimal test run

```r
Rscript tests/testthat.R
```

This should run only structure-level tests and should not trigger biomod2 modeling.
