# AGENTS.md

## What this package is

erlr provides estimation tools for exposure-response models based on
logistic regression (`glm(family = binomial(link = "logit"))`): model
fitting
([`lr_model()`](https://erlr.djnavarro.net/reference/lr_model.md)),
prediction with confidence intervals
([`lr_predict()`](https://erlr.djnavarro.net/reference/lr_predict.md)),
stepwise covariate modelling
([`lr_scm_forward()`](https://erlr.djnavarro.net/reference/lr_scm.md) /
[`lr_scm_backward()`](https://erlr.djnavarro.net/reference/lr_scm.md) /
[`lr_scm_history()`](https://erlr.djnavarro.net/reference/lr_scm.md)),
and simulation
([`lr_simulator()`](https://erlr.djnavarro.net/reference/lr_simulator.md),
[`lr_vpc_sim()`](https://erlr.djnavarro.net/reference/lr_vpc_sim.md)).

It deliberately contains **no plotting code**. For a model-agnostic
mini-language to visualise exposure-response models (including those
fitted here), see the companion package
[erplots](https://github.com/djnavarro/erplots). erlr interoperates with
erplots by implementing the `er_predict()` / `er_simulate()` /
`er_summary()` generics erplots defines, registered lazily at load time
(see `R/er-methods.R`) – erlr has no hard dependency on erplots or on
plotting packages (ggplot2, patchwork).

## Planned work

See [PLAN.md](https://erlr.djnavarro.net/PLAN.md) for scoped-out future
development. The main item is generalising this package from
logistic-regression-specific to arbitrary
[`glm()`](https://rdrr.io/r/stats/glm.html) families, with an
accompanying rename to `erglm` before an initial CRAN release.

## Structure

- `R/lr-core.R` –
  [`lr_model()`](https://erlr.djnavarro.net/reference/lr_model.md),
  [`lr_predict()`](https://erlr.djnavarro.net/reference/lr_predict.md),
  the
  [`lr_simulator()`](https://erlr.djnavarro.net/reference/lr_simulator.md)
  closure factory, and the shared `.lr_simulate_draws()` helper (used by
  both
  [`lr_vpc_sim()`](https://erlr.djnavarro.net/reference/lr_vpc_sim.md)
  and, via erplots, spaghetti-style plots).
- `R/lr-scm.R` – forward/backward stepwise covariate modelling.
- `R/lr-vpc.R` –
  [`lr_vpc_sim()`](https://erlr.djnavarro.net/reference/lr_vpc_sim.md).
- `R/lr-data.R` – the synthetic `lr_data` example dataset.
- `R/er-methods.R` – erplots interoperability: S3 methods for
  `er_predict()`/`er_simulate()`/`er_summary()`, plus lazy registration
  via `.onLoad()` (vendored `s3_register()` – the standard pattern for
  optional cross-package S3 methods).
- `R/utils-helpers.R`, `R/utils-global.R` – small internal helpers and
  [`globalVariables()`](https://rdrr.io/r/utils/globalVariables.html)
  declarations for NSE.

## Development workflow

- Document with roxygen2 (`devtools::document()`); Markdown roxygen is
  enabled (`Roxygen: list(markdown = TRUE)`).
- Run tests with `devtools::test()`; full checks with
  `devtools::check()`. The package should check cleanly (0
  errors/warnings/notes).
- Tests live in `tests/testthat/`, roughly one file per `R/` source
  file. `tests/testthat/test-er-methods.R` exercises interop with
  erplots and is skipped if erplots isn’t installed.
- Vignettes/articles live in `vignettes/articles/` and are built for the
  pkgdown site, not shipped with the package (see `.Rbuildignore`).

## Conventions

- Use the base R pipe (`|>`), not the magrittr pipe.
- Follow the existing tidyverse-style conventions (dplyr/tibble/rlang)
  already used throughout.
- Public functions are prefixed `lr_`; internal helpers are prefixed
  with `.`.
- Model objects are plain `glm` objects with an extra `erlr_glm` class
  and an internal `$erlr` list for package-specific metadata (e.g. SCM
  history) – see `.as_erlr()`.
- Don’t add plotting code here – that belongs in erplots.
