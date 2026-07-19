# AGENTS.md

## What this package is

erglm provides estimation tools for exposure-response models based on
[`glm()`](https://rdrr.io/r/stats/glm.html): model fitting
([`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)),
prediction with confidence intervals
([`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)),
stepwise covariate modelling
([`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
/
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
/
[`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md),
built on the single-term
[`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)),
and simulation
([`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md),
[`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md),
[`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md)).
[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
takes a `family` argument, defaulting to
[`stats::gaussian()`](https://rdrr.io/r/stats/family.html) (matching
[`glm()`](https://rdrr.io/r/stats/glm.html)’s own default); binomial,
poisson, gaussian, and Gamma are tested and officially supported end to
end (fitting, prediction, SCM significance testing, and VPC simulation).
Other [`glm()`](https://rdrr.io/r/stats/glm.html) families work through
the same generic mechanisms in
[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)/[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)
but aren’t covered by SCM’s test selection or
[`simulate()`](https://rdrr.io/r/stats/simulate.html)/VPC’s noise draws.

The package’s design is deliberately harmonised with the companion
`emaxnls` package (nonlinear-least-squares Emax models, also by this
author) where the two overlap: SCM forward/backward/history functions
mirror `emax_scm_forward()`/`emax_scm_backward()`/`emax_scm_history()`
closely,
[`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
mirror `emax_add_term()`/`emax_remove_term()`,
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)
mirrors `emax_fun()` (a zero-argument-callable prediction-function
factory), and
[`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md)
mirrors `emaxnls`’s
[`simulate()`](https://rdrr.io/r/stats/simulate.html) output shape (one
row per observation per replicate, with sampled coefficients and both
expected/simulated response columns). Genuine differences remain where
the model classes differ – e.g.
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)’s
returned function’s coefficient columns are prefixed `coef_*` in
[`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md)’s
output to avoid colliding with predictor columns of the same name (not
an issue for `emaxnls`’s parameter-name convention), and
[`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
take one-sided formula terms (e.g. `~ sex`) rather than `emaxnls`’s
two-sided, parameter-attached terms (e.g. `E0 ~ AGE`), since erglm’s
[`glm()`](https://rdrr.io/r/stats/glm.html)-based covariates have no
structural-parameter distinction (no E0/Emax/etc.) to attach to.

This package was previously called `erlr` (logistic-regression-only,
`lr_*`-prefixed functions); it was renamed to `erglm` and generalised to
arbitrary [`glm()`](https://rdrr.io/r/stats/glm.html) families, per
[PLAN.md](https://erglm.djnavarro.net/PLAN.md) step 6. There are no
`lr_*` deprecated aliases – this was a clean-break rename, since the
package predates any CRAN release or external users.

It deliberately contains **no plotting code**. For a model-agnostic
mini-language to visualise exposure-response models (including those
fitted here), see the companion package
[erplots](https://github.com/djnavarro/erplots). erglm interoperates
with erplots by implementing the `er_predict()` / `er_simulate()` /
`er_summary()` generics erplots defines, registered lazily at load time
(see `R/er-methods.R`) – erglm has no hard dependency on erplots or on
plotting packages (ggplot2, patchwork) in package code. `ggplot2` is a
`Suggests`-only dependency used exclusively inside
`vignettes/articles/simulate.Rmd` for demonstration plots (a predictive
check and a parameter-uncertainty band); no `R/` file uses it.

**Known follow-up (not yet done):** the companion `erplots` repo still
references the old package/function names
([`erlr::lr_model()`](https://rdrr.io/pkg/erlr/man/lr_model.html),
[`erlr::lr_data`](https://rdrr.io/pkg/erlr/man/lr_data.html)) in its
`DESCRIPTION` `Suggests`, test helpers, and a vignette article – it
needs a corresponding update once this rename is published, or its
`erlr`-dependent tests/vignette will break.

## Planned work

See [PLAN.md](https://erglm.djnavarro.net/PLAN.md) for the history of
this generalisation/rename project. The family generalisation (steps
1-5), the `erglm` rename (step 6), its manual infrastructure follow-ups
(renaming the GitHub repo `djnavarro/erlr` -\> `djnavarro/erglm`, and
repointing the `erglm.djnavarro.net` pkgdown domain/DNS), the
emaxnls-harmonisation work
([`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md),
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md),
exporting
[`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)),
and the pkgdown site/vignette restructuring that followed it are all now
done. Two items remain: the companion `erplots` repo update noted above,
and fleshing out the `erglm.Rmd` “Getting Started” stub (see PLAN.md).

## Structure

- `R/erglm-core.R` –
  [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md),
  [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md),
  the
  [`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)
  closure factory, and the shared `.erglm_simulate_draws()` helper (used
  by both
  [`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md)
  and, via erplots, spaghetti-style plots).
- `R/erglm-scm.R` – forward/backward stepwise covariate modelling
  ([`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md)),
  and the single-term
  [`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
  helpers they’re built on (also exported, matching `emaxnls`’s
  `emax_add_term()`/`emax_remove_term()`).
- `R/erglm-simulate.R` –
  [`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md),
  the [`stats::simulate()`](https://rdrr.io/r/stats/simulate.html) S3
  method (and its `.erglm_resample()` helper), modelled on emaxnls’s
  [`simulate()`](https://rdrr.io/r/stats/simulate.html) output shape:
  one row per observation per replicate, with `dat_id`/`sim_id`,
  expected/simulated response (`mu`/`val`), sampled `coef_*` columns,
  and the model’s predictor columns.
- `R/erglm-vpc.R` –
  [`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md),
  a thin wrapper that calls
  [`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md)
  internally and reshapes its output into a VPC-ready data set (splicing
  the simulated response back into the original response column instead
  of returning sampled coefficients).
- `R/erglm-family.R` – shared family-dispatch helpers used by SCM and
  VPC: `.erglm_default_test()` (picks `"Chisq"` vs `"F"` for
  [`stats::anova()`](https://rdrr.io/r/stats/anova.html) based on the
  family’s dispersion behaviour) and `.erglm_draw_response()`
  (family-specific residual noise draws for VPC simulation;
  binomial/poisson/gaussian/Gamma only, errors informatively otherwise).
- `R/erglm-data.R` – the synthetic `erglm_data` example dataset. Has
  binary (`ae1`, `ae2`), count (`ae_count`), continuous
  (`biomarker_change`), and positive/right-skewed continuous
  (`ae_duration`) response columns, for demonstrating
  binomial/poisson/gaussian/Gamma models respectively.
- `R/er-methods.R` – erplots interoperability: S3 methods for
  `er_predict()`/`er_simulate()`/`er_summary()`, plus lazy registration
  via `.onLoad()` (vendored `s3_register()` – the standard pattern for
  optional cross-package S3 methods). `er_summary.erglm_model()`’s
  p-value extraction is family-generic (matches `Pr(>|z|)` or `Pr(>|t|)`
  by pattern).
- `R/utils-helpers.R`, `R/utils-global.R` – small internal helpers and
  [`globalVariables()`](https://rdrr.io/r/utils/globalVariables.html)
  declarations for NSE. `.as_erglm()` records the fitted model’s actual
  family (`stats::family(mod)$family`) in `mod$erglm$type`.

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
  pkgdown site, not shipped with the package (see `.Rbuildignore`):
  `erglm.Rmd` (“Getting Started”, currently a near-empty stub – see
  [PLAN.md](https://erglm.djnavarro.net/PLAN.md)), `model.Rmd` (fitting,
  prediction, other [`glm()`](https://rdrr.io/r/stats/glm.html)
  families), `scm.Rmd` (stepwise covariate modelling, modelled on
  emaxnls’s `stepwise-covariate-modelling.Rmd`), `methods.Rmd` (base
  `glm`/`lm` method inheritance), and `simulate.Rmd`
  ([`simulate()`](https://rdrr.io/r/stats/simulate.html),
  [`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md),
  and
  [`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md),
  modelled on emaxnls’s `simulating-from-emax-models.Rmd`; needs
  `ggplot2`, see above). `_pkgdown.yml`’s `reference:` index and
  `articles:` list must be kept in sync by hand when exports or articles
  are added/renamed –
  [`pkgdown::check_pkgdown()`](https://pkgdown.r-lib.org/reference/check_pkgdown.html)
  catches drift (e.g. a reference to a renamed/removed topic) without
  needing a full site build.
- If
  [`pkgdown::build_articles()`](https://pkgdown.r-lib.org/reference/build_articles.html)/`build_site()`
  fails with “lazy-load database … is corrupt” / “internal error 1 in
  R_decompress1”, the installed copy of erglm is stale or was partially
  overwritten while a live session still had it loaded. Fix: unload it
  from the live session (`unloadNamespace("erglm")`), reinstall from a
  clean shell (`R CMD INSTALL .`, not `devtools::install()`, which hit
  the same issue when the package was already loaded), then retry.

## Conventions

- Use the base R pipe (`|>`), not the magrittr pipe.
- Follow the existing tidyverse-style conventions (dplyr/tibble/rlang)
  already used throughout.
- Public functions are prefixed `erglm_`; internal helpers are prefixed
  with `.erglm_` (or, for a couple of package-wide utilities like
  `.pick_seed()`, no prefix at all).
- Model objects are plain `glm` objects with an extra `erglm_model`
  class (same name as the constructor function
  [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md),
  matching the base-R idiom of
  [`lm()`](https://rdrr.io/r/stats/lm.html)/class `"lm"`) and an
  internal `$erglm` list for package-specific metadata (e.g. SCM
  history) – see `.as_erglm()`.
- Don’t add plotting code here – that belongs in erplots.
