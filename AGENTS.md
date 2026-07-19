# AGENTS.md

## What this package is

erglm provides estimation tools for exposure-response models based on
`glm()`: model fitting (`erglm_model()`), prediction with confidence
intervals (`erglm_predict()`), stepwise covariate modelling
(`erglm_scm_forward()` / `erglm_scm_backward()` / `erglm_scm_history()`),
and simulation (`erglm_simulator()`, `erglm_vpc_sim()`).
`erglm_model()` takes a `family` argument, defaulting to
`stats::gaussian()` (matching `glm()`'s own default); binomial, poisson,
gaussian, and Gamma are tested and officially supported end to end
(fitting, prediction, SCM significance testing, and VPC simulation).
Other `glm()` families work through the same generic mechanisms in
`erglm_predict()`/`erglm_simulator()` but aren't covered by SCM's test
selection or VPC's noise draws.

This package was previously called `erlr` (logistic-regression-only,
`lr_*`-prefixed functions); it was renamed to `erglm` and generalised to
arbitrary `glm()` families, per [PLAN.md](PLAN.md) step 6. There are no
`lr_*` deprecated aliases -- this was a clean-break rename, since the
package predates any CRAN release or external users.

It deliberately contains **no plotting code**. For a model-agnostic
mini-language to visualise exposure-response models (including those
fitted here), see the companion package
[erplots](https://github.com/djnavarro/erplots). erglm interoperates
with erplots by implementing the `er_predict()` / `er_simulate()` /
`er_summary()` generics erplots defines, registered lazily at load time
(see `R/er-methods.R`) -- erglm has no hard dependency on erplots or on
plotting packages (ggplot2, patchwork).

**Known follow-up (not yet done):** the companion `erplots` repo still
references the old package/function names (`erlr::lr_model()`,
`erlr::lr_data`) in its `DESCRIPTION` `Suggests`, test helpers, and a
vignette article -- it needs a corresponding update once this rename is
published, or its `erlr`-dependent tests/vignette will break.

## Planned work

See [PLAN.md](PLAN.md) for the history of this generalisation/rename
project. The family generalisation (steps 1-5), the `erglm` rename
(step 6), and its manual infrastructure follow-ups (renaming the
GitHub repo `djnavarro/erlr` -> `djnavarro/erglm`, and repointing the
`erglm.djnavarro.net` pkgdown domain/DNS) are all now done. The only
remaining item is the companion `erplots` repo update noted above.

## Structure

- `R/erglm-core.R` -- `erglm_model()`, `erglm_predict()`, the
  `erglm_simulator()` closure factory, and the shared
  `.erglm_simulate_draws()` helper (used by both `erglm_vpc_sim()` and,
  via erplots, spaghetti-style plots).
- `R/erglm-scm.R` -- forward/backward stepwise covariate modelling.
- `R/erglm-vpc.R` -- `erglm_vpc_sim()`.
- `R/erglm-family.R` -- shared family-dispatch helpers used by SCM and
  VPC: `.erglm_default_test()` (picks `"Chisq"` vs `"F"` for
  `stats::anova()` based on the family's dispersion behaviour) and
  `.erglm_draw_response()` (family-specific residual noise draws for
  VPC simulation; binomial/poisson/gaussian/Gamma only, errors
  informatively otherwise).
- `R/erglm-data.R` -- the synthetic `erglm_data` example dataset. Has
  binary (`ae1`, `ae2`), count (`ae_count`), continuous
  (`biomarker_change`), and positive/right-skewed continuous
  (`ae_duration`) response columns, for demonstrating
  binomial/poisson/gaussian/Gamma models respectively.
- `R/er-methods.R` -- erplots interoperability: S3 methods for
  `er_predict()`/`er_simulate()`/`er_summary()`, plus lazy registration
  via `.onLoad()` (vendored `s3_register()` -- the standard pattern for
  optional cross-package S3 methods). `er_summary.erglm_model()`'s
  p-value extraction is family-generic (matches `Pr(>|z|)` or
  `Pr(>|t|)` by pattern).
- `R/utils-helpers.R`, `R/utils-global.R` -- small internal helpers and
  `globalVariables()` declarations for NSE. `.as_erglm()` records the
  fitted model's actual family (`stats::family(mod)$family`) in
  `mod$erglm$type`.

## Development workflow

- Document with roxygen2 (`devtools::document()`); Markdown roxygen is
  enabled (`Roxygen: list(markdown = TRUE)`).
- Run tests with `devtools::test()`; full checks with `devtools::check()`.
  The package should check cleanly (0 errors/warnings/notes).
- Tests live in `tests/testthat/`, roughly one file per `R/` source file.
  `tests/testthat/test-er-methods.R` exercises interop with erplots and is
  skipped if erplots isn't installed.
- Vignettes/articles live in `vignettes/articles/` and are built for the
  pkgdown site, not shipped with the package (see `.Rbuildignore`).

## Conventions

- Use the base R pipe (`|>`), not the magrittr pipe.
- Follow the existing tidyverse-style conventions (dplyr/tibble/rlang)
  already used throughout.
- Public functions are prefixed `erglm_`; internal helpers are prefixed
  with `.erglm_` (or, for a couple of package-wide utilities like
  `.pick_seed()`, no prefix at all).
- Model objects are plain `glm` objects with an extra `erglm_model`
  class (same name as the constructor function `erglm_model()`,
  matching the base-R idiom of `lm()`/class `"lm"`) and an internal
  `$erglm` list for package-specific metadata (e.g. SCM history) -- see
  `.as_erglm()`.
- Don't add plotting code here -- that belongs in erplots.
