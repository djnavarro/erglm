# erglm development plan

This document tracks scoped-out future development for erglm. It is not
a changelog; see NEWS.md for that once one exists. Items here are
proposals to be reviewed before implementation, not committed designs.

## Done: generalise from logistic regression to arbitrary `glm()` families

Completed (see git history for the full diff; `4c663e7`, `c31a4ef`,
`90f88d1`). Summary:

- The package was originally `erlr`, a thin wrapper around
  `glm(family = binomial(link = "logit"))` with `lr_*`-prefixed
  functions. It has been generalised to support arbitrary
  [`glm()`](https://rdrr.io/r/stats/glm.html) families and renamed
  `erglm`.
- [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
  takes a `family` argument, defaulting to
  [`stats::gaussian()`](https://rdrr.io/r/stats/family.html) (matching
  [`glm()`](https://rdrr.io/r/stats/glm.html)’s own default). Binomial,
  poisson, gaussian, and Gamma are tested and officially supported end
  to end (fitting, prediction, SCM significance testing, VPC
  simulation); other [`glm()`](https://rdrr.io/r/stats/glm.html)
  families work through the same generic mechanisms but aren’t covered
  by SCM’s test selection or VPC’s noise draws.
- SCM
  ([`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md))
  picks `anova(..., test = "Chisq")` vs. `test = "F"` automatically from
  the family’s dispersion behaviour, with a
  `test = c("auto", "Chisq", "F")` override.
- VPC
  ([`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md))
  draws family-appropriate residual noise
  (Bernoulli/[`rpois()`](https://rdrr.io/r/stats/Poisson.html)/[`rnorm()`](https://rdrr.io/r/stats/Normal.html)/[`rgamma()`](https://rdrr.io/r/stats/GammaDist.html))
  rather than only the expectation, for the four supported families;
  other families error informatively rather than silently falling back
  to expectation-only.
- The example dataset (`erglm_data`, formerly `lr_data`) gained count
  (`ae_count`), continuous (`biomarker_change`), and right-skewed
  continuous (`ae_duration`) response columns alongside the original
  binary ones, to exercise poisson/gaussian/Gamma.
- All exported names, the model class, internal helpers, and package
  name were renamed (`lr_*` → `erglm_*`, class `erlr_glm` →
  `erglm_model`). This was a clean break with no deprecated aliases,
  since the package predates any CRAN release or external users. Version
  is currently `0.2.0.9000`.
- Infrastructure: the GitHub repo (`djnavarro/erlr` → `djnavarro/erglm`)
  has been renamed and the `erglm.djnavarro.net` pkgdown domain/DNS is
  live.

**Still outstanding, but out of scope for this repo:** the companion
[erplots](https://github.com/djnavarro/erplots) repo still references
[`erlr::lr_model()`](https://rdrr.io/pkg/erlr/man/lr_model.html)/[`erlr::lr_data`](https://rdrr.io/pkg/erlr/man/lr_data.html)
in its `DESCRIPTION` (`Suggests: erlr`), test helpers, and a vignette
article. This needs a follow-up PR *in that repo*; it will break once
`erglm` is published under its new name, since `erlr` will no longer be
findable. Tracked here only as a reminder — no erglm-side action needed.

## Next initiative: document `glm`/`lm` method inheritance

### Motivation

[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
returns an object of class `c("erglm_model", "glm", "lm")` – it *is* a
`glm` fit, not a wrapper that hides one. All of the standard `glm`/`lm`
methods ([`summary()`](https://rdrr.io/r/base/summary.html),
[`coef()`](https://rdrr.io/r/stats/coef.html),
[`vcov()`](https://rdrr.io/r/stats/vcov.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`predict()`](https://rdrr.io/r/stats/predict.html),
[`AIC()`](https://rdrr.io/r/stats/AIC.html),
[`BIC()`](https://rdrr.io/r/stats/AIC.html),
[`logLik()`](https://rdrr.io/r/stats/logLik.html),
[`anova()`](https://rdrr.io/r/stats/anova.html), even `plot.lm()`’s
diagnostic panels) already work on erglm models with no extra code
needed on erglm’s part. This is currently undocumented, which matters
more than it might for a typically programmer-facing package: the
primary userbase is pharmacometricians, who are likely to know these
`glm`/`lm` methods well from other contexts but may not think to try
them on an “erglm” object, or may not realise
[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
is additive rather than a replacement for
[`predict()`](https://rdrr.io/r/stats/predict.html).

### Status

- Added a `@details` note to
  [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)’s
  documentation (`R/erglm-core.R`) stating the class vector explicitly
  and listing the key inherited methods, with a pointer to a new
  vignette.
- Added `vignettes/articles/methods.Rmd`, a worked-example article
  covering [`summary()`](https://rdrr.io/r/base/summary.html),
  [`coef()`](https://rdrr.io/r/stats/coef.html)/[`vcov()`](https://rdrr.io/r/stats/vcov.html),
  [`confint()`](https://rdrr.io/r/stats/confint.html),
  [`predict()`](https://rdrr.io/r/stats/predict.html) (contrasted with
  [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)),
  [`AIC()`](https://rdrr.io/r/stats/AIC.html)/[`BIC()`](https://rdrr.io/r/stats/AIC.html)/[`anova()`](https://rdrr.io/r/stats/anova.html)
  for model comparison, and a note on `plot.lm()` diagnostics (pointing
  to erplots for exposure-response-specific visualisation instead).
  Registered in `_pkgdown.yml`’s articles list, after `model.Rmd` and
  before `simulate.Rmd`.

### Still to do

- ~~Run `devtools::document()` to regenerate `man/erglm_model.Rd` from
  the updated roxygen comment, and render `methods.Rmd` end-to-end to
  confirm the code chunks all evaluate cleanly.~~ Done – both
  `man/erglm_model.Rd` and `man/erglm_predict.Rd` are regenerated, and
  `methods.Rmd` renders cleanly with
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).
- Consider whether the `erglm.Rmd` “Getting Started” stub (currently
  near-empty) should also mention the `glm`/`lm` inheritance up front,
  or just link to the new `methods.Rmd` article, so a first-time reader
  finds it without already knowing to look.
- ~~Cross-link from
  [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)’s
  own roxygen docs back to
  [`predict()`](https://rdrr.io/r/stats/predict.html)/the new
  vignette.~~ Done –
  [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)’s
  `@details` now notes it’s an opinionated alternative to calling
  [`predict()`](https://rdrr.io/r/stats/predict.html) directly, and
  points to `vignette("methods", package = "erglm")` for a side-by-side
  comparison.

The one remaining open item (the `erglm.Rmd` stub) is small enough that
this initiative is otherwise ready to close out once that’s decided.

## Next initiative: CRAN submission prep

### Motivation

The rename/generalisation was explicitly sequenced to happen *before* a
first CRAN release (see the old rationale, preserved in git history at
`PLAN.md@c31a4ef`), to avoid a disruptive post-release rename. That work
is done, the package checks cleanly, and there are no other planned
breaking changes on the horizon — this is a reasonable point to prepare
for a first CRAN submission.

### What’s already in reasonable shape

- `R-CMD-check.yaml`, `test-coverage.yaml`, and `pkgdown.yaml` GitHub
  Actions are set up and green.
- `Config/testthat/edition: 3`; tests exist per source file and cover
  all four supported families.
- MIT license with a `LICENSE`/`LICENSE.md` pair in the standard
  `usethis::use_mit_license()` format.
- `URL`/`BugReports` fields point at the renamed repo and pkgdown site.

### Gaps to close before submitting

1.  **No `NEWS.md`.** CRAN doesn’t require one, but reviewers and users
    benefit from a top-level entry documenting the `erlr` → `erglm`
    rename and family generalisation, since anyone who used `erlr` needs
    a migration note. Should be added regardless of submission timing.
2.  ~~**`LICENSE.md` copyright holder doesn’t match `DESCRIPTION`.**~~
    Done – `LICENSE`/`LICENSE.md` now read “Danielle Navarro”, matching
    the `cph` role in `Authors@R`.
3.  **`Suggests: erplots` + `Remotes: djnavarro/erplots`.** `erplots`
    isn’t on CRAN. `Remotes` is ignored by CRAN’s own build (it’s a
    `remotes`/`pak`-only convenience field), so it isn’t itself a
    blocker, but every use of `erplots` in tests/vignettes must be
    properly gated
    ([`requireNamespace("erplots", quietly = TRUE)`](https://rdrr.io/r/base/ns-load.html)
    / `testthat::skip_if_not_installed("erplots")`) so the package
    builds and checks cleanly with `erplots` absent, which AGENTS.md
    says is already the case for tests. Worth a final
    `R CMD check --as-cran` run with `erplots` *not* installed to
    confirm the vignette article build and examples don’t implicitly
    depend on it too (articles aren’t shipped, so this mainly matters
    for `R/er-methods.R`’s lazy-registration path and any
    `\dontrun`/example code).
4.  **Roxygen/Rd completeness for CRAN.** Every exported function needs
    a `@return`/`\value` tag (CRAN now enforces this) and a runnable
    `@examples` block without gratuitous `\dontrun{}`. Needs an audit
    pass across `R/erglm-core.R`, `R/erglm-scm.R`, `R/erglm-vpc.R`.
5.  **Pre-submission checks.** Run and resolve findings from:
    `devtools::check(remote = TRUE, manual = TRUE)`,
    `devtools::spell_check()`, `urlchecker::url_check()`, and ideally
    `R CMD check --as-cran` on both win-builder and R-hub, since none of
    that is currently run locally or in CI (the CI workflow checks on
    its own runner matrix, but a manual as-cran pass before submission
    is still standard practice).
6.  **`cran-comments.md`.** Standard practice for a first submission:
    note this is a new package, summarise `R CMD check` results (0
    errors/warnings, any NOTEs explained), and flag the `erplots`
    Suggests relationship.
7.  **Version number for release.** Decide whether the first CRAN
    release ships as `0.2.0` (dropping the `.9000` dev suffix, keeping
    the version that reflects “second design,” post-rename) or `1.0.0`
    (signalling API stability now that the family generalisation and
    rename are both behind it). Open question — no strong convention
    either way for a first release; flagging for a decision rather than
    picking one.

### Suggested step ordering

1.  ~~Fix the `LICENSE.md` copyright holder mismatch (item 2).~~ Done.
2.  Write `NEWS.md` covering the `erlr` → `erglm` history (item 1).
3.  Audit roxygen `@return`/`@examples` coverage across all exported
    functions (item 4).
4.  Decide the release version number (item 7) — needs user input.
5.  Run the full pre-submission check suite (item 5), including a check
    with `erplots` uninstalled (item 3), and fix anything it surfaces.
6.  Draft `cran-comments.md` (item 6) and do a final review pass before
    `devtools::release()`.

This ordering isn’t committed — steps 2–3 have no open design questions
and could be done in any order or in parallel; step 4 blocks tagging a
release but not the mechanical cleanup in 2–3.
