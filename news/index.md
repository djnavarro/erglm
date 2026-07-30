# Changelog

## erglm 0.1.1

CRAN resubmission, addressing reviewer feedback on the 0.1.0 submission:

- Self-references to ‘erglm’ in the `DESCRIPTION` `Description` field
  are now single-quoted, per CRAN’s software-name convention.
- `DESCRIPTION` now declares
  `Additional_repositories: https://djnavarro.r-universe.dev`, the
  repository from which the optional `Suggests` dependency ‘erplots’
  (not on CRAN) can be installed, per CRAN policy on declaring where to
  obtain such packages.

## erglm 0.1.0

Initial CRAN release.

- Model fitting and prediction for exposure-response models based on
  [`glm()`](https://rdrr.io/r/stats/glm.html)
  ([`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md),
  [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)),
  supporting arbitrary [`glm()`](https://rdrr.io/r/stats/glm.html)
  families; binomial, poisson, gaussian, and gamma are tested and
  officially supported end to end (fitting, prediction, SCM significance
  testing, and simulation).
- Stepwise covariate modelling
  ([`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md),
  [`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md),
  [`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md)),
  built on the single-term
  [`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)/[`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
  helpers.
- Simulation support
  ([`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md),
  [`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md))
  for drawing replicate responses from a fitted model, with sampled
  coefficients and both expected and simulated response columns.
- Interoperability with the companion
  [erplots](https://github.com/djnavarro/erplots) package via
  `er_predict()`/`er_simulate()`/`er_summary()` methods, registered
  lazily so erglm has no hard dependency on erplots or on any plotting
  package.
- [`erglm_link()`](https://erglm.djnavarro.net/reference/erglm_link.md)/[`erglm_invlink()`](https://erglm.djnavarro.net/reference/erglm_link.md),
  discoverable wrappers around a fitted model’s link and inverse-link
  functions.
- An example dataset, `erglm_data`, with binary, count, and
  continuous/right-skewed continuous response columns for demonstrating
  each supported family.
