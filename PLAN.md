# erglm development plan

This document tracks scoped-out future development for erglm (formerly
`erlr`, renamed per step 6 below). It is not a changelog; see NEWS.md
for that once one exists. Items here are proposals to be reviewed before
implementation, not committed designs; the sections below are kept as a
historical record of the generalisation/rename project even though the
package has since moved on from the `erlr`/`lr_*` names they describe.

## Generalise from logistic regression to arbitrary `glm()` families (→ `erglm`)

### Motivation

Since the plotting mini-language moved out to
[erplots](https://github.com/djnavarro/erplots), erlr is a fairly thin
wrapper around `glm(family = binomial(link = "logit"))`. Most of the
underlying machinery (prediction with CIs, parameter-uncertainty
simulation, stepwise covariate modelling) is not actually specific to
logistic regression – it would work, with minor changes, for any
[`glm()`](https://rdrr.io/r/stats/glm.html) family. Generalising is a
natural next step, and should happen *before* an initial CRAN release
(to avoid a disruptive rename afterwards). The package would be renamed
`erglm` at that point.

### What already generalises for free

- `lr_predict()` already computes CIs on the link scale using
  `stats::family(object)$linkinv`, not a hardcoded logit/inverse-logit.
  It should work unchanged for any `glm` family.
- `lr_simulator()` builds a model matrix from the (response-stripped)
  formula and applies `stats::family(object)$linkinv` – also already
  family-agnostic.

### What needs to change

- **`lr_model()`**: currently hardcodes
  `family = stats::binomial(link = "logit")`. Needs a `family` argument;
  see decision (2) below on what it should default to once renamed.
- **`.as_erlr()`**: hardcodes `mod$erlr$type <- "logistic"`. Should
  record the actual family (`stats::family(mod)$family`) instead.
- **`er_summary.erlr_glm()`** (in `R/er-methods.R`): extracts a p-value
  from column `"Pr(>|z|)"` of `summary(model)$coefficients`. That column
  is `"Pr(>|t|)"` for families with an estimated dispersion parameter
  (gaussian, Gamma, inverse.gaussian, quasi\*). Needs to match the
  `"Pr("` column by pattern rather than by exact name.
- **`.lr_anova_p()`** (stepwise covariate modelling): uses
  `stats::anova(mod1, mod2)` and reads off `Pr(>Chi)`. A
  likelihood-ratio chi-squared test is appropriate for families with
  known dispersion (binomial, Poisson) but not for families with an
  estimated dispersion parameter (gaussian, Gamma), where an F-test is
  the standard choice (`stats::anova(mod1, mod2, test = "F")`). SCM
  needs to pick the test based on family, or expose it as an argument,
  and read the resulting column name generically (`"Pr(>Chi)"` vs
  `"Pr(>F)"`).
- **`lr_vpc_sim()` / `.lr_simulate_draws()`**: currently returns the
  *expected* response under sampled parameters (`fit_resp`) as the
  “simulated” value – a reasonable shortcut for a 0/1 response (it’s the
  simulated probability), but for a continuous or count response a
  proper VPC typically needs a full draw including residual/dispersion
  noise (e.g. `rnorm(n, mean = fit, sd = sigma)` for gaussian,
  `rpois(n, lambda = fit)` for Poisson), not just the conditional mean.
  This needs a family-dispatched noise-generation step, most likely via
  an internal generic keyed on `family(model)$family`.
- **Naming**: functions are all prefixed `lr_` (logistic regression
  specific). Proposed rename scheme (open for discussion): `lr_model()`
  → `glm_model()`, `lr_predict()` → `glm_predict()`, `lr_simulator()` →
  `glm_simulator()`, `lr_scm_*()` → `glm_scm_*()`, `lr_vpc_sim()` →
  `glm_vpc_sim()`. Class `erlr_glm` → `erglm_model` (or similar).
  Because erplots dispatches purely on the generic name plus whatever
  class erlr/erglm chooses to register, this rename is entirely internal
  to this package – no coordination needed with erplots beyond updating
  the [`registerS3method()`](https://rdrr.io/r/base/ns-internal.html)
  calls in `R/er-methods.R`.
- **Example data**: `lr_data` only has binary (`ae1`/`ae2`) responses.
  Demonstrating gaussian/Poisson families well would benefit from adding
  a continuous and/or count response column (also useful for erplots’
  continuous-response work, see its PLAN.md).

### Design decisions (reviewed)

The questions below were originally left open; each now has a working
recommendation so implementation isn’t blocked, but all are still up for
debate if new information changes the calculus.

1.  **Rename timing.** Do the family generalisation and the `erglm`
    rename as two separate steps, not one PR: generalise behaviour first
    (under the existing `erlr` name), get it reviewed and tested, then
    do the rename as a final, purely mechanical pass right before CRAN
    submission. Rationale: this keeps behavioural review separate from a
    large, low-risk find-and-replace diff, and means a generalisation
    decision can be revisited without re-doing a rename. (This matches
    the existing step ordering below, where the rename is last.)

2.  **Default `family`.** Once renamed, `glm_model()` should default to
    `family = stats::gaussian()` – i.e. match
    [`stats::glm()`](https://rdrr.io/r/stats/glm.html)’s own default –
    rather than keeping the binomial-logit default. A package that’s no
    longer logistic-regression-specific shouldn’t quietly special-case
    binary responses; users fitting logistic models pass
    `family = binomial()` explicitly, same as they would with base
    [`glm()`](https://rdrr.io/r/stats/glm.html). This is the more
    predictable choice for anyone coming from base R, at the cost of a
    breaking change for existing `lr_model()` callers – acceptable given
    the rename already breaks call sites.

3.  **v1 family scope.** Explicitly support and test four families that
    cover the common exposure-response use cases: `binomial` (binary
    AE), `poisson` (count AE), `gaussian` (continuous biomarker), and
    `Gamma` (skewed continuous/time-based endpoints). Other families
    (inverse.gaussian, quasi-families, etc.) should work through the
    same generic mechanisms but are “untested, not officially supported”
    until someone actually needs one – don’t build a speculative test
    matrix for families with no current use case.

4.  **SCM test selection.** Automatic by default, with an escape hatch:
    pick the test from the family’s dispersion behaviour (`"Chisq"` for
    binomial/poisson, which have known dispersion; `"F"` for
    gaussian/Gamma/inverse.gaussian/quasi\*, which have estimated
    dispersion), but expose `test = c("auto", "Chisq", "F")` on the
    forward/backward SCM functions so users can override it. This
    follows the same convention `car::Anova()` and similar tools use,
    and avoids silently giving wrong-flavoured p-values for less common
    families.

5.  **VPC noise-model dispatch.** Implement it, rather than punting to a
    documented limitation – VPCs are a core diagnostic in this domain,
    and an “expectation only” VPC is materially weaker for
    continuous/count responses (it understates predictive uncertainty by
    ignoring residual noise entirely). Scope the initial implementation
    to the same four families as (3): Bernoulli/probability draws for
    binomial, [`rpois()`](https://rdrr.io/r/stats/Poisson.html) for
    poisson, [`rnorm()`](https://rdrr.io/r/stats/Normal.html) (using the
    estimated residual SD) for gaussian,
    [`rgamma()`](https://rdrr.io/r/stats/GammaDist.html) (using the
    estimated shape/dispersion) for Gamma. Families outside that set
    should raise an informative error rather than silently falling back
    to the expectation-only shortcut.

### Suggested step ordering

1.  ~~Add `family` argument to `lr_model()`; generalise `.as_erlr()`.~~
    Done. `lr_model()` gained a `family` argument (still defaulting to
    `binomial(link = "logit")` for backward compatibility, per decision
    2 – the switch to a
    [`gaussian()`](https://rdrr.io/r/stats/family.html) default happens
    at rename time). `.as_erlr()` now records
    `stats::family(mod)$family` instead of a hardcoded `"logistic"`.

2.  ~~Generalise `er_summary.erlr_glm()`’s p-value column lookup.~~
    Done, now matches `^Pr\(` in the coefficient table’s column names.

3.  ~~Generalise SCM’s test statistic selection.~~ Done.
    `lr_scm_forward()` / `lr_scm_backward()` gained a
    `test = c("auto", "Chisq", "F")` argument (see decision 4);
    `.lr_anova_p()` picks the test automatically from the family’s
    dispersion behaviour (`R/lr-family.R::.lr_default_test()`) and reads
    the p-value column generically. Also fixed a latent bug in
    `.lr_add_term()`/ `.lr_remove_term()`, which previously refit via
    `lr_model()` without passing through the original model’s `family`
    (so SCM on a non-default family would silently refit as
    binomial-logit).

4.  ~~Design and implement family-dispatched VPC noise generation.~~
    Done, per decision 5, scoped to binomial/poisson/gaussian/Gamma
    (`R/lr-family.R::.lr_draw_response()`); other families raise an
    informative error from `lr_vpc_sim()` rather than silently falling
    back to expectation-only draws. `.lr_simulate_draws()` itself is
    unchanged (still expectation-only, since it’s shared with
    `er_simulate.erlr_glm()`/spaghetti plots, which want smooth
    expectation curves) – the noise draw is applied only in
    `lr_vpc_sim()`, on top of `.lr_simulate_draws()`’s output.

5.  ~~Expand `lr_data` (or add a second example dataset) with
    continuous/count responses; expand tests across families.~~ Done.
    Added `ae_count` (poisson), `biomarker_change` (gaussian), and
    `ae_duration` (Gamma) columns to `lr_data`, generated by appending
    new draws after the existing generator code so `id`/`sex`/…/`ae1`/
    `ae2` are unchanged bit-for-bit under the same seed. Tests extended
    across all four families in `test-lr-core.R`, `test-lr-scm.R`,
    `test-lr-vpc.R`, `test-er-methods.R`; vignette articles `model.Rmd`
    and `simulate.Rmd` gained non-binomial worked examples.

6.  ~~Execute the `erglm` rename (package name, exported function names,
    class names, DESCRIPTION/NAMESPACE/pkgdown/README/vignettes, GitHub
    repo).~~ Done (in-repo changes). Final naming scheme used: package
    `erlr` → `erglm`; `lr_model()` →
    [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
    (default `family` now
    [`stats::gaussian()`](https://rdrr.io/r/stats/family.html), per
    decision 2); `lr_predict()` →
    [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md);
    `lr_simulator()` →
    [`erglm_simulator()`](https://erglm.djnavarro.net/reference/erglm_simulator.md);
    `lr_scm_forward()`/`lr_scm_backward()`/`lr_scm_history()` →
    [`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md);
    `lr_vpc_sim()` →
    [`erglm_vpc_sim()`](https://erglm.djnavarro.net/reference/erglm_vpc_sim.md);
    dataset `lr_data` → `erglm_data`; class `erlr_glm` → `erglm_model`
    (same name as the constructor function, matching the
    [`lm()`](https://rdrr.io/r/stats/lm.html)/`"lm"` base-R idiom);
    internal `.lr_*` helpers → `.erglm_*`. Clean break, no deprecated
    `lr_*` aliases. Version bumped to `0.2.0.9000`.

    **Not done as part of this pass** (tracked separately, per the
    erlr→erglm rename plan’s stated scope):

    - Actually renaming the GitHub repo (`djnavarro/erlr` →
      `djnavarro/erglm`) and repointing the `erglm.djnavarro.net`
      pkgdown custom domain – manual/infrastructure steps, not a file
      change in this repo. `DESCRIPTION`/`README.Rmd`/`_pkgdown.yml`
      already reference the new URLs, so they won’t resolve until this
      happens.
    - Updating the companion `erplots` repo, which still references
      [`erlr::lr_model()`](https://erlr.djnavarro.net/reference/lr_model.html)/[`erlr::lr_data`](https://erlr.djnavarro.net/reference/lr_data.html)
      in its `DESCRIPTION` (`Suggests: erlr`),
      `tests/testthat/helper-data.R`, and `vignettes/articles/plot.Rmd`.
      This will break once erglm is published under the new name; needs
      a follow-up PR against that repo.
