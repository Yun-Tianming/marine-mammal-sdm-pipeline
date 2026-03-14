# AGENTS.md

## Communication

- Use Chinese when communicating with the user.
- Result reports must include explicit file paths.
- Prefer the reporting format: file name, path, purpose, generated or not.

## Analysis and modeling

- Do not rerun biomod2 unless the user explicitly asks for it.
- Do not rerun completed analysis, environmental preprocessing, or study area construction unless the user explicitly asks for it.
- When adding a new species or region, change `config/` first instead of hard-coding logic in `R/`.

## Output path policy

- Formal outputs must go to `outputs/<run_id>/`.
- Root-level `outputs/` files and other old paths are legacy compatibility only.
- New scripts should use helper functions from `R/config.R` instead of hand-written output paths.

## Plotting

- Figures should default to a white background.
- Figures should be suitable for reporting or manuscript drafts.
- Figure outputs should go to `outputs/<run_id>/figures/` by default.

## Code organization

- `scripts/runners/` stores recommended entry scripts.
- `scripts/dev/` stores debugging and temporary scripts.
- `scripts/legacy/` stores historical scripts kept for traceability.
- Do not place debugging scripts back in the project root.
