# erglm design history

This file is a condensed historical record of completed design
decisions: what was tried, what was rejected, and why. It exists for
context in future sessions, not as a changelog or PR log -- step-by-step
implementation narrative (file-by-file diffs, exact test-pass counts,
staged PR sequencing) has generally been trimmed in favor of the
decisions themselves; see git history for that level of detail if it's
ever needed. Entries are in roughly chronological order. Current-state
facts that came out of this history (what the API looks like today)
live in `AGENTS.md`, not here.

## The `erlr` -> `erglm` rename and family generalisation

The package was originally `erlr`, a thin wrapper around `glm(family =
binomial(link = "logit"))` with `lr_*`-prefixed functions. It was
generalised to support arbitrary `glm()` families and renamed `erglm`:
`erglm_model()` gained a `family` argument (default `stats::gaussian()`,
matching `glm()`'s own default), with binomial/poisson/gaussian/gamma
tested and officially supported end to end (fitting, prediction, SCM
significance testing, VPC simulation) and other families working
through the same generic mechanisms but uncovered by SCM's test
selection or the noise draws. SCM's `anova()` test selection
(`"Chisq"` vs `"F"`) became automatic, driven by the family's
dispersion behaviour, with a `test = c("auto", "Chisq", "F")` override.
The (since-removed, see below) VPC helper `erglm_vpc_sim()` drew
family-appropriate residual noise (Bernoulli/`rpois()`/`rnorm()`/
`rgamma()`) rather than only the expectation. The example dataset
(`erglm_data`, formerly `lr_data`) gained count (`ae_count`), continuous
(`biomarker_change`), and right-skewed continuous (`ae_duration`)
response columns alongside the original binary ones, to exercise
poisson/gaussian/gamma.

All exported names, the model class, internal helpers, and the package
name were renamed (`lr_*` -> `erglm_*`, class `erlr_glm` ->
`erglm_model`). This was a clean break with no deprecated aliases,
since the package predated any CRAN release or external users --
Infrastructure followed suit: the GitHub repo (`djnavarro/erlr` ->
`djnavarro/erglm`) was renamed and the `erglm.djnavarro.net` pkgdown
domain/DNS repointed.

**Left as a tracked reminder, out of scope for this repo:** the
companion [erplots](https://github.com/djnavarro/erplots) repo still
referenced `erlr::lr_model()`/`erlr::lr_data` in its `DESCRIPTION`
(`Suggests: erlr`), test helpers, and a vignette article at the time of
this rename -- see `.agents/PLAN.md`.

## Harmonising with `emaxnls`; pkgdown site fix; dedicated SCM/simulation vignettes

**API harmonisation with the companion `emaxnls` package** (see
`AGENTS.md` for the detailed rationale of what's genuinely shared vs.
genuinely different between the two packages):

- Added `simulate.erglm_model()` (`R/erglm-simulate.R`), a
  `stats::simulate()` S3 method modelled on emaxnls's `simulate()`
  output shape (`dat_id`/`sim_id`/`mu`/`val` plus sampled `coef_*`
  columns and the model's predictor columns).
- Renamed `erglm_simulator()` to `erglm_fun()` (clean break, no
  deprecated alias, consistent with the `erlr` -> `erglm` precedent),
  matching emaxnls's `emax_fun()`, and gave the returned function
  default `param`/`data` arguments (`coef(object)`/`object$data`) so
  `erglm_fun(mod)()` alone reproduces the fitted model, mirroring
  `emax_fun()`'s zero-argument ergonomics.
- Refactored `erglm_vpc_sim()` into a thin wrapper around `simulate()`,
  removing duplicated parameter-sampling/response-noise logic; the
  shared unsupported-family error message (`.erglm_draw_response()` in
  `R/erglm-family.R`) was generalised since it became reachable from
  both callers.
- Exported the previously-internal `.erglm_add_term()`/
  `.erglm_remove_term()` as public `erglm_add_term()`/
  `erglm_remove_term()`, matching emaxnls's `emax_add_term()`/
  `emax_remove_term()` -- while keeping the genuine, documented
  structural difference (erglm's terms are one-sided formulas like
  `~ sex`; emaxnls's are two-sided and parameter-attached, like `E0 ~
  AGE`, since only emaxnls has structural parameters to attach
  covariates to).

**pkgdown site fix + vignette restructuring**, prompted by
`pkgdown::build_site()` failing because `_pkgdown.yml` had gone stale
relative to the API changes above: fixed the `reference:` index
(renamed the `erglm_simulator` entry to `erglm_fun`, added the missing
`erglm_term`, `simulate.erglm_model`, and `invlogit` topics, and
restructured the sections to mirror emaxnls's own layout); split
stepwise covariate modelling out of `model.Rmd` into its own article,
`vignettes/articles/scm.Rmd`, modelled on emaxnls's
`stepwise-covariate-modelling.Rmd` (forward addition and backward
elimination are demonstrated separately, since `erglm_data`'s true
covariate effects turn out too weak to survive the default forward
threshold once `aucss` is in the model -- a saturated-model
backward-elimination example was used instead to show the mechanics
doing real, multi-iteration work); and expanded
`vignettes/articles/simulate.Rmd` (previously a ~35-line stub covering
only `erglm_vpc_sim()`) to also cover `simulate()` and `erglm_fun()`,
modelled on emaxnls's `simulating-from-emax-models.Rmd`. This needed
adding `ggplot2` to `Suggests` (vignette-only). A corrupt-lazy-load-
database / "internal error 1 in R_decompress1" error was hit and traced
to a stale installed copy of erglm overwritten while a live session
still had it loaded -- documented as a workflow gotcha in `AGENTS.md`
rather than a content bug.

## `logit()`/`invlogit()` generalised into `erglm_link()`/`erglm_invlink()`

`logit()`/`invlogit()` were leftovers from the pre-generalisation,
binomial-only `erlr` days -- hardcoded logit-scale helpers that no
longer matched a package supporting arbitrary `glm()` families. Every
`glm()` family already carries its own link/inverse-link functions
(`stats::family(mod)$linkfun`/`$linkinv`), so they were replaced with
`erglm_link()`/`erglm_invlink()`, thin family-generic wrappers that
take a fitted model and return those functions directly --
discoverability helpers for users who don't realise these are
available straight from the family object. Another clean-break rename,
no deprecated aliases. The two internal call sites were updated
(`R/erglm-data.R`'s dataset generator now uses `stats::qlogis()`
directly; the shipped, pre-generated `erglm_data` itself was
unaffected, since it isn't rebuilt from this code at load time).

## Auditing SCM's `seed` argument for genuine RNG-dependence

Prompted by a request to check whether `erglm_scm_forward()`/
`erglm_scm_backward()`'s `seed` argument (added as a safety measure
against candidate-testing order mattering, or model fitting secretly
depending on `.Random.seed`) is actually load-bearing. Traced the
seed's only consumer: `withr::with_seed()` wraps a `sample(candidates)`
shuffle in `.erglm_once_forward()`/`.erglm_once_backward()`. Everything
downstream -- `erglm_model()`/`stats::glm()` (IRLS, no random starting
values) and `stats::anova()` for p-values -- is deterministic, so the
RNG-dependence concern doesn't currently hold; the candidate-order
concern is real in principle but only changes the *selected* candidate
in the case of an exact p-value tie within a step, since ties are
broken by strict `<`/`>` comparisons against encounter order.
Documented in a new `@details` section of `erglm_scm`'s shared roxygen
block, with a regression test (`tests/testthat/test-erglm-scm.R`)
asserting both SCM functions select the same formula/AIC across five
distinct seeds on `erglm_data` (non-tied data). `seed` itself was left
in place -- a guard against future refactors reintroducing genuine
seed-sensitivity.

## Documenting `glm`/`lm` method inheritance

`erglm_model()` returns an object of class `c("erglm_model", "glm",
"lm")` -- it *is* a `glm` fit, not a wrapper that hides one, so all
standard `glm`/`lm` methods (`summary()`, `coef()`, `vcov()`,
`confint()`, `predict()`, `AIC()`, `BIC()`, `logLik()`, `anova()`, even
`plot.lm()`'s diagnostic panels) already work with no extra erglm code.
This mattered more than it might for a typically programmer-facing
package because the primary userbase is pharmacometricians, who are
likely to know these `glm`/`lm` methods well from other contexts but
may not think to try them on an "erglm" object, or may not realise
`erglm_predict()` is additive rather than a replacement for
`predict()`. Closed by adding a `@details` note to `erglm_model()`'s
documentation stating the class vector explicitly and listing the key
inherited methods, adding `vignettes/articles/methods.Rmd` (a
worked-example article), and cross-linking from `erglm_predict()`'s own
roxygen docs back to `predict()`/the vignette.

## Fleshing out the `erglm.Rmd` "Getting Started" stub

`erglm.Rmd` was a ~15-line placeholder; it became a short tour of the
package intended as the first thing a new user reads, linking out to
the other, more detailed articles rather than duplicating them: a
package description, a look at `erglm_data`, fitting with
`erglm_model()`, prediction with `erglm_predict()`, one-example teasers
of SCM and simulation, the `glm`/`lm` method-inheritance note, and a
closing "Where to next" list linking every other article plus erplots.
Registered at the top of `_pkgdown.yml`'s `articles:` list (it had been
omitted entirely, even as a stub).

## Enriching `er_summary.erglm_model()` with `coefficients`/`glance`

Prompted by erplots' `er_summary()` generic contract
(`erplots::er_model_interface`) being fleshed out on the erplots side
to specify `coefficients`/`glance` list elements alongside the existing
`p_value`; erglm's method only ever returned `p_value`. Added
`coefficients` (one row per model term: `term`, `estimate`,
`std_error`, `statistic`, `p_value`, `conf_low`, `conf_high` --
confidence intervals are Wald, a `qnorm()` z-score times the standard
error, matching `erglm_predict()`'s existing approach rather than
introducing profile-likelihood machinery) and `glance` (a single-row
goodness-of-fit tibble: `n`, `df_residual`, `logLik`, `aic`, `bic`,
`deviance`, `r_squared`, `converged`; `r_squared` only populated for
the classic OLS case -- gaussian family, identity link -- `NA`
otherwise). Added a `conf_level` argument (default `0.95`). Considered
and declined adding a `label` column to `coefficients` (erplots'
contract allows one): erglm's terms are already plain design-matrix
column names (e.g. `aucss`, `sexMale`), unlike emaxnls's opaque
structural parameter codes that genuinely benefit from a translated
label, and prettifying factor-dummy terms would need fragile heuristics
that could misfire on interactions.

## Removing `erglm_vpc_sim()`, superseded by `er_vpc_plot(model = ...)`

Prompted by reconsidering whether `erglm_vpc_sim()` still earned its
place once erplots' own `er_simulate()` generic (and
`.erglm_simulate_draws()` on the erglm side) gained a `sim_resp` column
and erplots added `er_vpc_plot(model = ...)` as its preferred VPC entry
point. Confirmed the wrapper was genuinely orphaned: `er_vpc_plot(model
= mod)` calls `er_simulate(model, ...)` internally and reads
`sim_resp` straight off `.erglm_simulate_draws()`'s output, so the
`sim`-shaped data frame `erglm_vpc_sim()` used to produce was no longer
needed for erglm models specifically. Removed `R/erglm-vpc.R`, its
tests, docs, and `NAMESPACE` export, and updated every reference
(`README.Rmd`, `vignettes/articles/simulate.Rmd` and `erglm.Rmd`,
`_pkgdown.yml`, and roxygen `@details`/inline comments in
`R/erglm-core.R`/`R/erglm-simulate.R`/`R/erglm-family.R`). Clean break,
no deprecated alias, per the package's established convention.
Verified `devtools::test()` (119 passing), `devtools::document()`, and
`pkgdown::check_pkgdown()` all pass cleanly after the removal.

## CRAN submission prep

The rename/generalisation was explicitly sequenced to happen *before* a
first CRAN release, to avoid a disruptive post-release rename. Once
that work was done and the package checked cleanly with no other
planned breaking changes, CRAN submission prep began.

**Framing decision: erglm is a new package, not a renamed `erlr`.**
Since `erlr` was never released on CRAN and was only briefly public on
GitHub, and erglm's functionality (arbitrary `glm()` families, SCM,
simulation, erplots interop) differs substantially from `erlr`'s
binomial-only scope, CRAN-facing artefacts (`NEWS.md`, the release
version number) treat erglm as an entirely new package with no
migration story to tell. `NEWS.md` describes erglm 0.1.0 as an initial
release with no mention of `erlr`; the dev version was reset from
`0.2.0.9000` to `0.0.0.9000` before being bumped to `0.1.0` for
submission. This is a framing decision only -- it doesn't undo any of
the rename work recorded elsewhere in this file.

**Gaps closed before submitting:**

- `LICENSE.md`'s copyright holder was corrected to match
  `DESCRIPTION`'s `cph` role.
- `Suggests: erplots` was added, gated everywhere in tests/vignettes
  (`requireNamespace()`/`skip_if_not_installed()`) so the package
  builds and checks cleanly with `erplots` absent -- verified locally
  and via R-hub's `nosuggests` container. A `Remotes: djnavarro/erplots`
  field was initially kept (harmless for CRAN's own build, useful for
  CI dependency resolution) but ultimately removed, since
  `devtools::release()`'s checklist explicitly warns against it before
  submission; CI's `setup-r-dependencies` steps list
  `github::djnavarro/erplots` in `extra-packages` directly instead, so
  no `DESCRIPTION` field is needed for that.
- Every exported function was audited for CRAN's `@return`/`\value`
  and runnable `@examples` (no `\dontrun{}`) requirements; all topics
  already complied by the time `erglm_vpc_sim()` was removed.
- Ran the full pre-submission check suite: `devtools::check(remote =
  TRUE, manual = TRUE)` (0 errors/warnings, 1 explained NOTE covering
  "new submission", possibly-misspelled `erglm`/`poisson` -- a
  CRAN-incoming-feasibility false positive with no suppression
  mechanism, documented in `cran-comments.md` rather than claimed
  fixed -- and `erplots` not being in a mainstream repository);
  `urlchecker::url_check()` (clean); a from-tarball `R CMD check
  --as-cran` against a library with `erplots` genuinely absent (0
  errors/warnings, `erplots`'s unavailability downgraded to `INFO`);
  R-hub v2 checks across linux/macos-arm64/windows/nosuggests, all
  `Status: OK`; and CRAN's win-builder devel/release services, both
  `Status: 1 NOTE` (the same note as above). `check_mac_release()` was
  attempted three times and abandoned after repeated HTTP 502s from
  `mac.r-project.org`, since R-hub's `macos-arm64` run already covered
  macOS.
- Drafted `cran-comments.md` explaining the NOTE, backed by the
  `erplots`-free verification above.
- Version bumped from `0.0.0.9000` to `0.1.0` for the release.

Remaining before actually calling `devtools::release()` is tracked in
`.agents/PLAN.md`.
