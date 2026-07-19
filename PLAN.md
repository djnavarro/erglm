# erlr development plan

This document tracks scoped-out future development for erlr. It is not a
changelog; see NEWS.md for that once one exists. Items here are proposals
to be reviewed before implementation, not committed designs.

## Generalise from logistic regression to arbitrary `glm()` families (→ `erglm`)

### Motivation

Since the plotting mini-language moved out to
[erplots](https://github.com/djnavarro/erplots), erlr is a fairly thin
wrapper around `glm(family = binomial(link = "logit"))`. Most of the
underlying machinery (prediction with CIs, parameter-uncertainty
simulation, stepwise covariate modelling) is not actually specific to
logistic regression -- it would work, with minor changes, for any `glm()`
family. Generalising is a natural next step, and should happen *before* an
initial CRAN release (to avoid a disruptive rename afterwards). The
package would be renamed `erglm` at that point.

### What already generalises for free

- `lr_predict()` already computes CIs on the link scale using
  `stats::family(object)$linkinv`, not a hardcoded logit/inverse-logit.
  It should work unchanged for any `glm` family.
- `lr_simulator()` builds a model matrix from the (response-stripped)
  formula and applies `stats::family(object)$linkinv` -- also already
  family-agnostic.

### What needs to change

- **`lr_model()`**: currently hardcodes
  `family = stats::binomial(link = "logit")`. Needs a `family` argument
  (defaulting to `binomial(link = "logit")` for backward compatibility,
  or with no default once renamed).
- **`.as_erlr()`**: hardcodes `mod$erlr$type <- "logistic"`. Should record
  the actual family (`stats::family(mod)$family`) instead.
- **`er_summary.erlr_glm()`** (in `R/er-methods.R`): extracts a p-value
  from column `"Pr(>|z|)"` of `summary(model)$coefficients`. That column
  is `"Pr(>|t|)"` for families with an estimated dispersion parameter
  (gaussian, Gamma, inverse.gaussian, quasi*). Needs to match the `"Pr("`
  column by pattern rather than by exact name.
- **`.lr_anova_p()`** (stepwise covariate modelling): uses
  `stats::anova(mod1, mod2)` and reads off `Pr(>Chi)`. A likelihood-ratio
  chi-squared test is appropriate for families with known dispersion
  (binomial, Poisson) but not for families with an estimated dispersion
  parameter (gaussian, Gamma), where an F-test is the standard choice
  (`stats::anova(mod1, mod2, test = "F")`). SCM needs to pick the test
  based on family, or expose it as an argument, and read the resulting
  column name generically (`"Pr(>Chi)"` vs `"Pr(>F)"`).
- **`lr_vpc_sim()` / `.lr_simulate_draws()`**: currently returns the
  *expected* response under sampled parameters (`fit_resp`) as the
  "simulated" value -- a reasonable shortcut for a 0/1 response (it's the
  simulated probability), but for a continuous or count response a proper
  VPC typically needs a full draw including residual/dispersion noise
  (e.g. `rnorm(n, mean = fit, sd = sigma)` for gaussian,
  `rpois(n, lambda = fit)` for Poisson), not just the conditional mean.
  This needs a family-dispatched noise-generation step, most likely via an
  internal generic keyed on `family(model)$family`.
- **Naming**: functions are all prefixed `lr_` (logistic regression
  specific). Proposed rename scheme (open for discussion):
  `lr_model()` → `glm_model()`, `lr_predict()` → `glm_predict()`,
  `lr_simulator()` → `glm_simulator()`, `lr_scm_*()` → `glm_scm_*()`,
  `lr_vpc_sim()` → `glm_vpc_sim()`. Class `erlr_glm` → `erglm_model` (or
  similar). Because erplots dispatches purely on the generic name plus
  whatever class erlr/erglm chooses to register, this rename is entirely
  internal to this package -- no coordination needed with erplots beyond
  updating the `registerS3method()` calls in `R/er-methods.R`.
- **Example data**: `lr_data` only has binary (`ae1`/`ae2`) responses.
  Demonstrating gaussian/Poisson families well would benefit from adding
  a continuous and/or count response column (also useful for erplots'
  continuous-response work, see its PLAN.md).

### Open questions to resolve before implementation

1. Should the rename to `erglm` happen in the same PR as the family
   generalisation, or as a separate, purely mechanical rename afterwards?
2. Default `family` for `glm_model()` once renamed -- require it
   explicitly, or keep binomial-logit as a default for continuity?
3. Scope of family support for v1: full generality (any `family` object,
   including quasi-families), or an initially-supported subset
   (binomial, poisson, gaussian, Gamma) with others left as "should work,
   untested"?
4. Whether SCM's test-selection-by-family should be automatic or a
   user-facing argument (e.g. `test = c("auto", "Chisq", "F")`).
5. How much of the VPC noise-model dispatch belongs in this package vs.
   left as a documented limitation (e.g. only supporting the
   "expectation only" shortcut, at least for v1).

### Suggested step ordering

1. Add `family` argument to `lr_model()`; generalise `.as_erlr()`.
2. Generalise `er_summary.erlr_glm()`'s p-value column lookup.
3. Generalise SCM's test statistic selection.
4. Design and implement family-dispatched VPC noise generation.
5. Expand `lr_data` (or add a second example dataset) with
   continuous/count responses; expand tests across families.
6. Execute the `erglm` rename (package name, exported function names,
   class names, DESCRIPTION/NAMESPACE/pkgdown/README/vignettes, GitHub
   repo).
