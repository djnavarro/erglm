# erglm development plan

This document tracks scoped-out future development for erglm. It is not
a changelog; see NEWS.md for that once one exists. Items here are
proposals to be reviewed before implementation, not committed designs.

## Done: generalise from logistic regression to arbitrary `glm()` families

Completed (see git history for the full diff; `4c663e7`, `c31a4ef`,
`90f88d1`). Summary:

- The package was originally `erlr`, a thin wrapper around
  `glm(family = binomial(link = "logit"))` with `lr_*`-prefixed
  functions. It has been generalised to support arbitrary `glm()`
  families and renamed `erglm`.
- `erglm_model()` takes a `family` argument, defaulting to
  `stats::gaussian()` (matching `glm()`'s own default). Binomial,
  poisson, gaussian, and Gamma are tested and officially supported
  end to end (fitting, prediction, SCM significance testing, VPC
  simulation); other `glm()` families work through the same generic
  mechanisms but aren't covered by SCM's test selection or VPC's noise
  draws.
- SCM (`erglm_scm_forward()`/`erglm_scm_backward()`) picks
  `anova(..., test = "Chisq")` vs. `test = "F"` automatically from the
  family's dispersion behaviour, with a `test = c("auto", "Chisq",
  "F")` override.
- VPC (`erglm_vpc_sim()`) draws family-appropriate residual noise
  (Bernoulli/`rpois()`/`rnorm()`/`rgamma()`) rather than only the
  expectation, for the four supported families; other families error
  informatively rather than silently falling back to expectation-only.
- The example dataset (`erglm_data`, formerly `lr_data`) gained count
  (`ae_count`), continuous (`biomarker_change`), and right-skewed
  continuous (`ae_duration`) response columns alongside the original
  binary ones, to exercise poisson/gaussian/Gamma.
- All exported names, the model class, internal helpers, and package
  name were renamed (`lr_*` → `erglm_*`, class `erlr_glm` →
  `erglm_model`). This was a clean break with no deprecated aliases,
  since the package predates any CRAN release or external users.
  Version is currently `0.2.0.9000`.
- Infrastructure: the GitHub repo (`djnavarro/erlr` →
  `djnavarro/erglm`) has been renamed and the `erglm.djnavarro.net`
  pkgdown domain/DNS is live.

**Still outstanding, but out of scope for this repo:** the companion
[erplots](https://github.com/djnavarro/erplots) repo still references
`erlr::lr_model()`/`erlr::lr_data` in its `DESCRIPTION` (`Suggests:
erlr`), test helpers, and a vignette article. This needs a follow-up
PR *in that repo*; it will break once `erglm` is published under its
new name, since `erlr` will no longer be findable. Tracked here only
as a reminder — no erglm-side action needed.

## Done: harmonise with emaxnls; fix stale pkgdown site; dedicated SCM/simulation vignettes

Completed across a few sessions; summary:

**API harmonisation with the companion `emaxnls` package** (see
AGENTS.md for the detailed rationale of what's genuinely shared vs.
genuinely different between the two packages):

- Added `simulate.erglm_model()` (`R/erglm-simulate.R`), a
  `stats::simulate()` S3 method modelled on emaxnls's `simulate()`
  output shape (`dat_id`/`sim_id`/`mu`/`val` plus sampled `coef_*`
  columns and the model's predictor columns).
- Renamed `erglm_simulator()` to `erglm_fun()` (clean break, no
  deprecated alias, consistent with the earlier `erlr` → `erglm`
  precedent), matching emaxnls's `emax_fun()`, and gave the returned
  function default `param`/`data` arguments
  (`coef(object)`/`object$data`) so `erglm_fun(mod)()` alone reproduces
  the fitted model, mirroring `emax_fun()`'s zero-argument ergonomics.
- Refactored `erglm_vpc_sim()` into a thin wrapper around `simulate()`,
  removing duplicated parameter-sampling/response-noise logic; the
  shared unsupported-family error message (`.erglm_draw_response()` in
  `R/erglm-family.R`) was generalised since it's now reachable from
  both callers.
- Exported the previously-internal `.erglm_add_term()`/
  `.erglm_remove_term()` as public `erglm_add_term()`/
  `erglm_remove_term()`, matching emaxnls's `emax_add_term()`/
  `emax_remove_term()` -- while keeping the genuine, documented
  structural difference (erglm's terms are one-sided formulas like
  `~ sex`; emaxnls's are two-sided and parameter-attached, like
  `E0 ~ AGE`, since only emaxnls has structural parameters to attach
  covariates to).

**pkgdown site fix + vignette restructuring**, prompted by
`pkgdown::build_site()` failing because `_pkgdown.yml` had gone stale
relative to the API changes above:

- Fixed `_pkgdown.yml`'s `reference:` index: renamed the
  `erglm_simulator` entry to `erglm_fun`, added the missing
  `erglm_term`, `simulate.erglm_model`, and `invlogit` topics, and
  restructured the sections to mirror emaxnls's own layout (`Build` /
  `Covariate selection` / `Simulate` / `Other`).
- Split stepwise covariate modelling out of `model.Rmd` into its own
  article, `vignettes/articles/scm.Rmd`, modelled on emaxnls's
  `stepwise-covariate-modelling.Rmd`: building blocks
  (`erglm_add_term()`/`erglm_remove_term()`), setting up a search,
  forward addition and backward elimination (demonstrated separately,
  since `erglm_data`'s true covariate effects turn out too weak to
  survive the default forward threshold once `aucss` is in the model --
  a saturated-model backward-elimination example was used instead to
  show the mechanics doing real, multi-iteration work), the audit log
  (`erglm_scm_history()`), and generalisation across `glm()` families.
- Expanded `vignettes/articles/simulate.Rmd` (previously a ~35-line
  stub covering only `erglm_vpc_sim()`) to also cover `simulate()` and
  `erglm_fun()`, modelled on emaxnls's
  `simulating-from-emax-models.Rmd`: output format, a predictive-check
  density plot, `erglm_fun()` as the deterministic building block
  (zero-argument default, counterfactual `param`, custom `data` grids),
  a hand-rolled parameter-uncertainty band, and generalisation across
  families. This needed adding `ggplot2` to `Suggests` (vignette-only;
  see AGENTS.md for why this doesn't contradict "no plotting code").
- `_pkgdown.yml`'s `articles:` list updated to include the new `scm`
  article.
- Verified `pkgdown::check_pkgdown()` and a full `build_site()`/
  `build_articles()` pass cleanly end to end (see AGENTS.md for a note
  on a corrupt-lazy-load-database gotcha hit and fixed along the way --
  an installed-library staleness issue, not a content bug).

## Done: generalise `logit`/`invlogit` into `erglm_link()`/`erglm_invlink()`

Completed in one session. `logit()`/`invlogit()` were leftovers from the
pre-generalisation, binomial-only `erlr` days -- hardcoded logit-scale
helpers that no longer matched a package supporting arbitrary `glm()`
families. Every `glm()` family already carries its own link/inverse-link
functions (`stats::family(mod)$linkfun`/`$linkinv`), so:

- Replaced `logit()`/`invlogit()` in `R/utils-helpers.R` with
  `erglm_link()`/`erglm_invlink()`, thin family-generic wrappers that
  take a fitted model and return `stats::family(mod)$linkfun`/
  `$linkinv` respectively -- discoverability helpers for users who
  don't realise these are available directly from the family object.
  Another clean-break rename, no deprecated aliases (same rationale as
  `erlr` → `erglm` and `erglm_simulator()` → `erglm_fun()` above).
- Updated the two internal call sites: `R/erglm-data.R`'s
  `.make_erglm_data()` generator (which used `logit()` for a
  latent-logistic Bernoulli draw) now uses base R's `stats::qlogis()`
  instead; a `test-erglm-core.R` assertion now uses `erglm_link(mod1)`.
  `erglm_data` itself (the shipped, pre-generated dataset) is
  unaffected, since it isn't rebuilt from this code at load time.
- Regenerated `NAMESPACE`/`man/` via `devtools::document()`;
  `_pkgdown.yml`'s `Other` section now lists `erglm_link`/
  `erglm_invlink` instead of `logit`/`invlogit` (superseding the
  `invlogit` topic mentioned in the harmonisation section above).
- Added a short link-scale/response-scale conversion example to
  `vignettes/articles/model.Rmd`, alongside the existing
  `erglm_predict()` discussion of `fit_link`/`fit_resp`.
- `AGENTS.md` updated to document the rename under the
  `R/utils-helpers.R` structure bullet.

## Next initiative: document `glm`/`lm` method inheritance

### Motivation

`erglm_model()` returns an object of class `c("erglm_model", "glm",
"lm")` -- it *is* a `glm` fit, not a wrapper that hides one. All of the
standard `glm`/`lm` methods (`summary()`, `coef()`, `vcov()`,
`confint()`, `predict()`, `AIC()`, `BIC()`, `logLik()`, `anova()`, even
`plot.lm()`'s diagnostic panels) already work on erglm models with no
extra code needed on erglm's part. This is currently undocumented,
which matters more than it might for a typically programmer-facing
package: the primary userbase is pharmacometricians, who are likely to
know these `glm`/`lm` methods well from other contexts but may not
think to try them on an "erglm" object, or may not realise
`erglm_predict()` is additive rather than a replacement for
`predict()`.

### Status

- Added a `@details` note to `erglm_model()`'s documentation
  (`R/erglm-core.R`) stating the class vector explicitly and listing
  the key inherited methods, with a pointer to a new vignette.
- Added `vignettes/articles/methods.Rmd`, a worked-example article
  covering `summary()`, `coef()`/`vcov()`, `confint()`, `predict()`
  (contrasted with `erglm_predict()`), `AIC()`/`BIC()`/`anova()` for
  model comparison, and a note on `plot.lm()` diagnostics (pointing to
  erplots for exposure-response-specific visualisation instead).
  Registered in `_pkgdown.yml`'s articles list, after `model.Rmd` and
  before `simulate.Rmd`.

### Still to do

- ~~Run `devtools::document()` to regenerate `man/erglm_model.Rd` from
  the updated roxygen comment, and render `methods.Rmd` end-to-end to
  confirm the code chunks all evaluate cleanly.~~ Done -- both
  `man/erglm_model.Rd` and `man/erglm_predict.Rd` are regenerated, and
  `methods.Rmd` renders cleanly with `rmarkdown::render()`.
- Consider whether the `erglm.Rmd` "Getting Started" stub (currently
  near-empty) should also mention the `glm`/`lm` inheritance up front,
  or just link to the new `methods.Rmd` article, so a first-time reader
  finds it without already knowing to look.
- ~~Cross-link from `erglm_predict()`'s own roxygen docs back to
  `predict()`/the new vignette.~~ Done -- `erglm_predict()`'s
  `@details` now notes it's an opinionated alternative to calling
  `predict()` directly, and points to `vignette("methods", package =
  "erglm")` for a side-by-side comparison.

The one remaining open item (the `erglm.Rmd` stub) is small enough that
this initiative is otherwise ready to close out once that's decided.

## Next initiative: CRAN submission prep

### Motivation

The rename/generalisation was explicitly sequenced to happen *before*
a first CRAN release (see the old rationale, preserved in git history
at `PLAN.md@c31a4ef`), to avoid a disruptive post-release rename. That
work is done, the package checks cleanly, and there are no other
planned breaking changes on the horizon — this is a reasonable point
to prepare for a first CRAN submission.

### What's already in reasonable shape

- `R-CMD-check.yaml`, `test-coverage.yaml`, and `pkgdown.yaml` GitHub
  Actions are set up and green.
- `Config/testthat/edition: 3`; tests exist per source file and cover
  all four supported families.
- MIT license with a `LICENSE`/`LICENSE.md` pair in the standard
  `usethis::use_mit_license()` format.
- `URL`/`BugReports` fields point at the renamed repo and pkgdown site.

### Gaps to close before submitting

1. **No `NEWS.md`.** CRAN doesn't require one, but reviewers and users
   benefit from a top-level entry documenting the `erlr` → `erglm`
   rename and family generalisation, since anyone who used `erlr`
   needs a migration note. Should be added regardless of submission
   timing.
2. ~~**`LICENSE.md` copyright holder doesn't match `DESCRIPTION`.**~~
   Done -- `LICENSE`/`LICENSE.md` now read "Danielle Navarro", matching
   the `cph` role in `Authors@R`.
3. **`Suggests: erplots` + `Remotes: djnavarro/erplots`.** `erplots`
   isn't on CRAN. `Remotes` is ignored by CRAN's own build (it's a
   `remotes`/`pak`-only convenience field), so it isn't itself a
   blocker, but every use of `erplots` in tests/vignettes must be
   properly gated (`requireNamespace("erplots", quietly = TRUE)` /
   `testthat::skip_if_not_installed("erplots")`) so the package builds
   and checks cleanly with `erplots` absent, which AGENTS.md says is
   already the case for tests. Worth a final `R CMD check --as-cran`
   run with `erplots` *not* installed to confirm the vignette article
   build and examples don't implicitly depend on it too (articles
   aren't shipped, so this mainly matters for `R/er-methods.R`'s
   lazy-registration path and any `\dontrun`/example code).
4. **Roxygen/Rd completeness for CRAN.** Every exported function needs
   a `@return`/`\value` tag (CRAN now enforces this) and a runnable
   `@examples` block without gratuitous `\dontrun{}`. Needs an audit
   pass across `R/erglm-core.R`, `R/erglm-scm.R`, `R/erglm-vpc.R`.
5. **Pre-submission checks.** Run and resolve findings from:
   `devtools::check(remote = TRUE, manual = TRUE)`,
   `devtools::spell_check()`, `urlchecker::url_check()`, and ideally
   `R CMD check --as-cran` on both win-builder and R-hub, since none of
   that is currently run locally or in CI (the CI workflow checks on
   its own runner matrix, but a manual as-cran pass before submission
   is still standard practice).
6. **`cran-comments.md`.** Standard practice for a first submission:
   note this is a new package, summarise `R CMD check` results (0
   errors/warnings, any NOTEs explained), and flag the `erplots`
   Suggests relationship.
7. **Version number for release.** Decide whether the first CRAN
   release ships as `0.2.0` (dropping the `.9000` dev suffix, keeping
   the version that reflects "second design," post-rename) or `1.0.0`
   (signalling API stability now that the family generalisation and
   rename are both behind it). Open question — no strong convention
   either way for a first release; flagging for a decision rather than
   picking one.

### Suggested step ordering

1. ~~Fix the `LICENSE.md` copyright holder mismatch (item 2).~~ Done.
2. Write `NEWS.md` covering the `erlr` → `erglm` history (item 1).
3. Audit roxygen `@return`/`@examples` coverage across all exported
   functions (item 4).
4. Decide the release version number (item 7) — needs user input.
5. Run the full pre-submission check suite (item 5), including a
   check with `erplots` uninstalled (item 3), and fix anything it
   surfaces.
6. Draft `cran-comments.md` (item 6) and do a final review pass before
   `devtools::release()`.

This ordering isn't committed — steps 2–3 have no open design
questions and could be done in any order or in parallel; step 4 blocks
tagging a release but not the mechanical cleanup in 2–3.
