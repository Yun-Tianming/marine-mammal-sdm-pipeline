# codex_sdm

English | [简体中文](README_CN.md)

## Overview

This repository is the stable v1 of a configuration-driven SDM pipeline.
The default run keeps the completed humpback whale analysis, but the project structure is now reusable for other species and regions.

## Stable v1 status

- Default run config: `config/runs/humpback_cosmonaut.R`
- Formal output root: `outputs/humpback_cosmonaut/`
- Legacy compatibility paths still exist under `outputs/`, `data_clean/`, and `env_processed/`, but they are no longer the recommended source of truth.
- `scripts/runners/` is the only recommended entry directory.
- `scripts/legacy/` is retained for traceability only.
- `renv.lock` is currently a bootstrap lock file because the local machine does not have the `renv` package installed.

## Directory layout

Top-level files and directories kept in the project root:

- `_targets.R`: targets pipeline entry
- `README.md`: project overview
- `.gitignore`: git ignore rules
- `AGENTS.md`: project-level collaboration rules
- `config/`: configuration layer
- `R/`: reusable function layer
- `scripts/`: runners, development helpers, and legacy scripts
- `docs/`: maintenance and usage notes
- `tests/`: minimal test skeleton
- `archive/`: archived development artifacts
- `data_raw/`: raw occurrence workbooks
- `data_clean/`: legacy compatibility outputs for occurrence tables
- `env_raw/`: raw environmental datasets
- `env_processed/`: processed environmental rasters and study area files
- `outputs/`: formal result directory
- `renv.lock`: environment lock file

### config/

- `config/species/`: species-level settings
- `config/regions/`: region-level settings
- `config/defaults/`: shared default parameters
- `config/runs/`: run-level assembly files
- `config/templates/`: templates for new run configs

Recommended relationship:

- `species`: what species is modeled
- `regions`: how the region is displayed or defined
- `defaults`: reusable parameter defaults
- `runs`: a concrete run assembled from species, region, defaults, input files, and output paths

### scripts/

- `scripts/runners/`: only recommended entry points
- `scripts/dev/`: debugging, inspection, and temporary helper scripts
- `scripts/legacy/`: historical scripts preserved for compatibility and traceability

### outputs/

Formal outputs should be read from:

- `outputs/<run_id>/figures/`
- `outputs/<run_id>/tables/`
- `outputs/<run_id>/rasters/`
- `outputs/<run_id>/reports/`
- `outputs/<run_id>/biomod2_full/`
- `outputs/<run_id>/biomod2_matched/`

Current default run:

- `outputs/humpback_cosmonaut/`

## Formal outputs vs legacy compatibility

Formal source of truth:

- `outputs/<run_id>/...`

Legacy compatibility only:

- historical files under `outputs/` root
- historical occurrence tables under `data_clean/`
- historical study area and raster paths under `env_processed/`

New code should use helper functions in `R/config.R` instead of hard-coded output paths.

## Quick start

Run the pipeline with the default config:

```r
Rscript scripts/runners/run_targets_pipeline.R config/runs/humpback_cosmonaut.R
```

Run the minimal tests:

```r
Rscript tests/testthat.R
```

## Environment note

`renv.lock` exists, but it was generated as a bootstrap manifest from installed packages.
For a full lock file, install `renv` locally and run `renv::snapshot()` in the project root.

## Excel note

If a CSV opens with garbled text in Excel, prefer the `.xlsx` version when available.
