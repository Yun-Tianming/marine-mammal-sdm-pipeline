# Project structure notes

## Current recommendation

- `scripts/runners/` is the only recommended entry directory.
- `scripts/legacy/` is for historical scripts kept for compatibility and traceability.
- `scripts/dev/` is for debugging, inspection, experiments, and temporary helpers.

## Formal outputs

The formal source of truth is:

- `outputs/<run_id>/figures/`
- `outputs/<run_id>/tables/`
- `outputs/<run_id>/rasters/`
- `outputs/<run_id>/reports/`

For the current stable run, the formal output root is:

- `outputs/humpback_cosmonaut/`

## Legacy compatibility

The following paths still exist only for backward compatibility:

- `outputs/` root-level historical files
- `data_clean/` historical occurrence outputs
- `env_processed/` historical study area and predictor paths

These locations are not the recommended read paths for new work.

## Config relationship

- `config/species/`: species settings
- `config/regions/`: region settings
- `config/defaults/`: shared defaults
- `config/runs/`: run assembly files
- `config/templates/`: templates for new runs

## Tests and environment

- `tests/testthat/` contains the minimal test skeleton for config loading, coordinate parsing, and QC behavior.
- `renv.lock` currently acts as a bootstrap lock file. Replace it with a formal `renv::snapshot()` output when `renv` is available locally.
