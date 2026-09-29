# AGENTS.md

## What this package is

erglm provides estimation tools for exposure-response models based on
`glm()`: model fitting (`erglm_model()`), prediction with confidence
intervals (`erglm_predict()`), stepwise covariate modelling
(`erglm_scm_forward()` / `erglm_scm_backward()` / `erglm_scm_history()`,
built on the single-term `erglm_add_term()`/`erglm_remove_term()`), and
simulation (`erglm_fun()`, `simulate.erglm_model()`).
`erglm_model()` takes a `family` argument,
defaulting to `stats::gaussian()` (matching `glm()`'s own default);
binomial, poisson, gaussian, and gamma are tested and officially
supported end to end (fitting, prediction, SCM significance testing,
and simulation). Other `glm()` families work through the same generic
mechanisms in `erglm_predict()`/`erglm_fun()` but aren't covered by
SCM's test selection or `simulate()`'s noise draws.

The package's design is deliberately harmonised with the companion
`emaxnls` package (nonlinear-least-squares Emax models, also by this
author) where the two overlap: SCM forward/backward/history functions
mirror `emax_scm_forward()`/`emax_scm_backward()`/`emax_scm_history()`
closely, `erglm_add_term()`/`erglm_remove_term()` mirror
`emax_add_term()`/`emax_remove_term()`, `erglm_fun()` mirrors
`emax_fun()` (a zero-argument-callable prediction-function factory),
and `simulate.erglm_model()` mirrors `emaxnls`'s `simulate()` output
shape (one row per observation per replicate, with sampled
coefficients and both expected/simulated response columns). Genuine
differences remain where the model classes differ -- e.g.
`erglm_fun()`'s returned function's coefficient columns are prefixed
`coef_*` in `simulate.erglm_model()`'s output to avoid colliding with
predictor columns of the same name (not an issue for `emaxnls`'s
parameter-name convention), and `erglm_add_term()`/`erglm_remove_term()`
take one-sided formula terms (e.g. `~ sex`) rather than `emaxnls`'s
two-sided, parameter-attached terms (e.g. `E0 ~ AGE`), since erglm's
`glm()`-based covariates have no structural-parameter distinction
(no E0/Emax/etc.) to attach to. See
[.agents/HISTORY.md](.agents/HISTORY.md) for how this harmonisation,
and the package's earlier `erlr` -> `erglm` rename and generalisation
from logistic-regression-only to arbitrary `glm()` families, came
about -- there are no `lr_*` deprecated aliases from that rename, since
it was a clean break predating any CRAN release or external users.

It deliberately contains **no plotting code**. For a model-agnostic
mini-language to visualise exposure-response models (including those
fitted here), see the companion package
[erplots](https://github.com/djnavarro/erplots). erglm interoperates
with erplots by implementing the `er_predict()` / `er_simulate()` /
`er_summary()` generics erplots defines, registered lazily at load time
(see `R/er-methods.R`) -- erglm has no hard dependency on erplots or on
plotting packages (ggplot2, patchwork) in package code. `ggplot2` is a
`Suggests`-only dependency used exclusively inside
`vignettes/articles/simulate.Rmd` for demonstration plots (a predictive
check and a parameter-uncertainty band); no `R/` file uses it.

## Structure

- `R/erglm-core.R` -- `erglm_model()`, `erglm_predict()`, the
  `erglm_fun()` closure factory, and the shared
  `.erglm_simulate_draws()` helper (used directly by
  `er_simulate.erglm_model()`). Its output carries both `fit_resp` (the
  expected response at a sampled parameter vector -- parameter
  uncertainty only, used by erplots' spaghetti-style plots) and
  `sim_resp` (that same `fit_resp` plus family-appropriate residual
  noise, via `.erglm_draw_response()` -- used by erplots'
  `er_vpc_add_simulated(model = ...)`), matching erplots' `er_simulate()`
  contract (see `?erplots::er_model_interface`): a method may supply
  `fit_resp` alone, or both columns from one call, and this package now
  does the latter, computing both from the same sampled coefficient
  draws for consistency. When `.erglm_simulate_draws()` auto-picks a
  seed (`seed = NULL`, via `.pick_seed()`), it reports this via
  `.cond_inform()` -- e.g. `"Using seed = 1234. Pass \`seed =
  1234\` to reproduce this result."` -- because the seed genuinely
  determines the random coefficient *and* response draws returned,
  unlike the SCM functions below.
- `R/erglm-scm.R` -- forward/backward stepwise covariate modelling
  (`erglm_scm_forward()`/`erglm_scm_backward()`/`erglm_scm_history()`),
  and the single-term `erglm_add_term()`/`erglm_remove_term()` helpers
  they're built on (also exported, matching `emaxnls`'s
  `emax_add_term()`/`emax_remove_term()`). SCM's `seed` argument only
  controls the `sample()`-shuffled order candidates are tested in
  within a step (via `.seed_with_seed()`); model fitting itself
  (`stats::glm()`) is deterministic, so `seed` is redundant for the
  *result* except in the (essentially measure-zero) case of an exact
  p-value tie between competing candidates -- documented in the
  `@details` of `erglm_scm`'s shared roxygen block, with a seed-
  invariance regression test in `tests/testthat/test-erglm-scm.R`.
  Because of that irrelevance, `erglm_scm_forward()`/
  `erglm_scm_backward()` auto-pick a seed via `.pick_seed()` silently
  when `seed = NULL` and do *not* report it via `.cond_inform()` --
  unlike the simulation functions below, where the seed does matter.
- `R/erglm-simulate.R` -- `simulate.erglm_model()`, the `stats::simulate()`
  S3 method (and its `.erglm_resample()` helper), modelled on emaxnls's
  `simulate()` output shape: one row per observation per replicate, with
  `dat_id`/`sim_id`, expected/simulated response (`mu`/`val`), sampled
  `coef_*` columns, and the model's predictor columns. Like
  `.erglm_simulate_draws()`, `.erglm_resample()` reports an auto-picked
  seed via `.cond_inform()` (with the same "pass `seed = ...`" wording)
  since it drives the actual simulated values in the output.
- `R/erglm-family.R` -- shared family-dispatch helpers used by SCM and
  simulation: `.erglm_default_test()` (picks `"Chisq"` vs `"F"` for
  `stats::anova()` based on the family's dispersion behaviour) and
  `.erglm_draw_response()` (family-specific residual noise draws used
  by both `.erglm_resample()` and `.erglm_simulate_draws()`;
  binomial/poisson/gaussian/gamma only, errors informatively
  otherwise).
- `R/erglm-data.R` -- the synthetic `erglm_data` example dataset. Has
  binary (`ae1`, `ae2`), count (`ae_count`), continuous
  (`biomarker_change`), and positive/right-skewed continuous
  (`ae_duration`) response columns, for demonstrating
  binomial/poisson/gaussian/gamma models respectively.
- `R/er-methods.R` -- erplots interoperability: S3 methods for
  `er_predict()`/`er_simulate()`/`er_summary()`, plus lazy registration
  via `.onLoad()` (vendored `s3_register()` -- the standard pattern for
  optional cross-package S3 methods). `er_summary.erglm_model()`'s
  p-value extraction is family-generic (matches `Pr(>|z|)` or
  `Pr(>|t|)` by pattern). It also returns `coefficients` (one row per
  model term, with Wald `conf_low`/`conf_high` computed the same way
  `erglm_predict()` does -- a `qnorm()` z-score times the standard
  error, not profile likelihood) and `glance` (model-level
  goodness-of-fit: `n`, `df_residual`, `logLik`, `aic`, `bic`,
  `deviance`, `r_squared`, `converged`), per erplots'
  `er_model_interface` contract. `r_squared` is only populated (as
  `1 - deviance/null.deviance`) for the classic OLS case -- gaussian
  family with an identity link -- and is `NA` otherwise, since it isn't
  a meaningful summary for other family/link combinations.
- `R/minicondition.R` -- a vendored copy of the `minicondition` mini from
  [djnavarro/minis](https://github.com/djnavarro/minis), providing
  `.cond_abort()`/`.cond_warn()`/`.cond_inform()` as dependency-free
  stand-ins for `rlang::abort()`/`warn()`/`inform()` (erglm's usage never
  needed rlang's `class`/backtrace features beyond a plain message, so
  the swap is behaviourally transparent). Copied verbatim from upstream
  aside from stripping the mini's own roxygen `@export` tags, since these
  functions stay internal to erglm; re-copy the whole file from upstream
  rather than hand-editing it if erglm's needs grow. This was the first
  of four hard dependencies (`dplyr`, `rlang`, `tibble`, `withr`)
  replaced with vendored minis ahead of 0.2.0, one at a time -- see
  `.agents/HISTORY.md` for the effort as a whole. `mvtnorm` was
  explicitly kept out of scope throughout (there's no mini for
  multivariate normal sampling, and writing one is a riskier undertaking
  than vendoring an existing mini), so it remains erglm's only runtime
  dependency besides base `stats`.
- `R/miniseed.R` -- a vendored copy of the `miniseed` mini from
  djnavarro/minis, providing `.seed_with_seed()` (plus, unused so far but
  kept for parity with upstream, `.seed_with_preserve_seed()`/
  `.seed_local_seed()`/`.seed_local_preserve_seed()`) as a dependency-free
  stand-in for `withr::with_seed()`. Part of the same hard-dependency
  reduction effort described above.
- `R/minitable.R` -- a vendored copy of the `minitable` mini from
  djnavarro/minis, but erglm only actually calls `.table_as_tibble()`
  from it (one thin wrapper around `as.data.frame(x, check.names =
  FALSE)`, used where the input is already columnar -- e.g. coercing a
  matrix of sampled coefficients in `.erglm_resample()`).
  `.table_tibble()` turned out to be unusable for erglm's actual
  `tibble::tibble()` call sites: its cross-column self-reference NSE
  trick only resolves a name against columns already built within the
  same call, not against ordinary local variables in the calling
  function (e.g. a local `mod` inside `erglm_scm_history()`) -- real
  `tibble::tibble()` has no such limitation, since it evaluates
  arguments as quosures carrying the caller's environment. None of
  erglm's call sites actually needed the self-reference feature, so
  they were rewritten as plain base `data.frame(..., check.names =
  FALSE)` calls instead of routed through the mini (see the warning in
  `R/minitable.R`'s header comment before reaching for `.table_tibble()`
  at a new call site). Filed upstream as
  [djnavarro/minis#6](https://github.com/djnavarro/minis/issues/6).
  Separately, `.table_tibble()` also doesn't tolerate a trailing comma
  after the last argument (it produces a genuine extra, unnamed
  argument that breaks its `match.call()`-based argument walking),
  filed as [djnavarro/minis#7](https://github.com/djnavarro/minis/issues/7)
  -- the same issue covers `.verb_mutate()` below, which has the same
  bug for the same reason. `erglm_scm_history()`'s row-appending (previously
  `tibble::add_row()`) uses plain `rbind()`, for the same reason
  `.table_add_row()` doesn't fit: `tibble::add_row(history,
  history_row)` relies on `add_row()`'s special-case splicing of a whole
  pre-built row passed as a single unnamed data frame argument, which
  `.table_add_row()` doesn't reproduce (its `...` only accepts
  name-value pairs) -- `rbind()` is a direct, simpler substitute since
  each `history_row` already has identical columns to `history`.
  `erglm_predict()`'s `fit_link`/`se_link` construction originally
  skipped `.table_as_tibble()`/`as.data.frame()` entirely and passed
  `stats::predict()`'s named-vector output straight to
  `dplyr::bind_cols()`, because `as.data.frame()` promotes a named
  vector's own `names()` into row names (discarding them from the
  vector itself) where `tibble::as_tibble()`/`dplyr::bind_cols()`
  preserve them as a plain vector attribute. Once dplyr was removed too
  (see `R/miniverb.R` below), this workaround stopped being available --
  plain data frame column assignment (`df$x <- named_vector`) always
  strips a vector's own `names()`, with no base-R way around it -- so
  `erglm_predict()`'s output now genuinely drops these names (a
  `predict.glm()` artifact, not a documented feature) rather than
  preserving them.
  This whole swap is a genuine, documented public-API behavior change,
  unlike the rlang/withr swaps: `erglm_predict()`, `simulate.
  erglm_model()`, and the bundled `erglm_data` dataset (regenerated via
  `.make_erglm_data()`, see below) now return/are plain data frames
  rather than `tbl_df` objects. `tibble` moved from `Imports` to
  `Suggests` (vignettes and the README still use real tibble in example
  code, e.g. to build `newdata`).
- `R/miniverb.R`, `R/minicase.R`, `R/minijoin.R` -- vendored copies of
  the `miniverb`/`minicase`/`minijoin` minis from djnavarro/minis,
  providing `.verb_mutate()`, `.case_when()`, and `.join_left_join()` as
  dependency-free stand-ins for `dplyr::mutate()`, `case_when()`, and
  `left_join()` -- the last of erglm's hard dependencies to go before
  0.2.0 (besides `mvtnorm`, out of scope, see above). Six dplyr
  functions erglm used have no mini equivalent at all and were rewritten
  as direct base-R substitutes instead of routed through any mini:
  `if_else()` -> `ifelse()`; the one grouped `n()` call (inside
  `.by = "sex"`) -> `length()` of any same-length column of the group;
  `row_number()` -> `seq_len(nrow(.))`, applied via direct column
  assignment rather than a mutate call; `pull()` (chained after
  `filter()`) -> direct base subsetting/indexing, dropping the
  `filter()` step too since there was nothing left to route through
  `.verb_filter()` for; `bind_cols()` -> direct column assignment;
  `bind_rows()` -> `do.call(rbind, ...)` (safe at every erglm call site
  since the list elements/vectors being combined always already share
  identical columns/types).
  `.by` takes a quoted character vector in `.verb_mutate()`
  (`.by = "sex"`), unlike dplyr's tidyselect-lite bare `.by = sex` --
  erglm's one grouped-mutate call site (`.make_erglm_data()`'s `weight`
  column) was rewritten accordingly. `.case_when()` has no
  data-masking, unlike `dplyr::case_when()`, but this doesn't need any
  special handling at erglm's two call sites (both already nested
  inside `.verb_mutate(...)`): verified empirically that `.case_when()`
  still resolves both `.data` columns and the enclosing function's
  ordinary local variables correctly there, since its formulas are
  constructed while `.verb_mutate()`'s own `eval()` call is still
  evaluating its expression against the data mask -- unlike the
  analogous-looking (and ultimately unusable) trick in `minitable`'s
  `.table_tibble()`. `.case_when()` *does* require every branch's value
  to have identical `typeof()` (no automatic common-type coercion like
  dplyr's) -- this caught a real, pre-existing type inconsistency in
  `erglm_scm_history()`'s `model_updated` column (seeded as a bare `NA`,
  `typeof() == "logical"`, then later set to `1L`/`0L`, `"integer"`),
  fixed by seeding it `NA_integer_` instead so the column's type is
  consistently `"integer"` throughout.
  Separately, reproducing `.make_erglm_data()`'s `weight` column exactly
  (same seed, same values) needed one more fix: base `ifelse()`
  short-circuits and skips evaluating a branch entirely when a group's
  condition is uniformly `TRUE`/`FALSE` (as it always is here, grouped
  by `.by = "sex"`) -- unlike `dplyr::if_else()`, which always evaluates
  both branches regardless. Since both branches draw random numbers,
  this desync's the RNG stream the moment it happens, corrupting every
  downstream column that depends on it (verified by comparing against
  the pre-swap `dplyr::if_else()` output bit-for-bit under the same
  seed). Fixed by forcing both branches into local variables before the
  `ifelse()` call, so both are always evaluated, in the same order,
  regardless of implementation -- keeping `erglm_data`'s values
  reproducible under `.make_erglm_data(seed = 2407L)` across the swap.
  Filed upstream as a feature request for an eager, type-strict
  `if_else()` equivalent in `minicase`:
  [djnavarro/minis#8](https://github.com/djnavarro/minis/issues/8).
  `dplyr` is dropped from `DESCRIPTION` entirely (not moved to
  `Suggests`, unlike `tibble`) since no vignette or the README ever
  used it directly.
- `R/utils-helpers.R`, `R/utils-global.R` -- small internal helpers and
  `globalVariables()` declarations for NSE. `.as_erglm()` records the
  fitted model's actual family (`stats::family(mod)$family`) in
  `mod$erglm$type`. `R/utils-helpers.R` also exports `erglm_link()` /
  `erglm_invlink()`, thin discoverable wrappers around a fitted model's
  `stats::family(mod)$linkfun` / `$linkinv` (link scale <-> response
  scale).

## Development workflow

- Document with roxygen2 (`devtools::document()`); Markdown roxygen is
  enabled (`Roxygen: list(markdown = TRUE)`).
- Run tests with `devtools::test()`; full checks with `devtools::check()`.
  The package should check cleanly (0 errors/warnings/notes).
- Tests live in `tests/testthat/`, roughly one file per `R/` source file.
  `tests/testthat/test-er-methods.R` exercises interop with erplots and is
  skipped if erplots isn't installed. Each vendored mini
  (`R/minicondition.R`, `R/miniseed.R`, `R/minitable.R`, `R/miniverb.R`,
  `R/minicase.R`, `R/minijoin.R`) has its own `test-<mini>.R`, ported
  verbatim from that mini's own test suite in djnavarro/minis (minus the
  upstream `source()` call at the top -- unnecessary here, since the
  vendored functions are already part of erglm's own namespace once the
  package is loaded, the same way any other internal, dot-prefixed
  helper is directly callable, unqualified, from erglm's other test
  files). These cover every function in each mini, including the ones
  erglm's own code doesn't call (kept "for parity with upstream", per
  each file's header comment) -- without them, those vendored-but-unused
  functions would sit at 0% coverage, which is what triggered
  `codecov`'s patch/project checks failing on the PR that introduced
  these minis; porting each mini's test suite fixed it. `withr` was
  re-added to `Suggests` (test-only, not a runtime dependency) purely
  because `test-miniseed.R` uses it to independently verify RNG-state
  save/restore.
- Vignettes/articles live in `vignettes/articles/` and are built for the
  pkgdown site, not shipped with the package (see `.Rbuildignore`):
  `erglm.Rmd` ("Getting Started" -- a short tour covering `erglm_data`,
  `erglm_model()`/`erglm_predict()`, a one-example teaser of SCM and
  simulation, the `glm`/`lm` method inheritance, and pointers to the
  other, more detailed articles), `model.Rmd` (fitting, prediction,
  other `glm()` families), `scm.Rmd` (stepwise covariate modelling,
  modelled on emaxnls's `stepwise-covariate-modelling.Rmd`),
  `methods.Rmd` (base `glm`/`lm` method inheritance), and `simulate.Rmd`
  (`simulate()` and `erglm_fun()`, modelled on emaxnls's
  `simulating-from-emax-models.Rmd`; needs `ggplot2`, see above; points
  to erplots' `er_vpc_add_simulated(model = ...)` for VPC-style plots rather
  than documenting an erglm-side VPC helper). `_pkgdown.yml`'s
  `reference:` index and `articles:` list must
  be kept in sync by hand when exports or articles are added/renamed --
  `pkgdown::check_pkgdown()` catches drift (e.g. a reference to a
  renamed/removed topic) without needing a full site build.
- If `pkgdown::build_articles()`/`build_site()` fails with "lazy-load
  database ... is corrupt" / "internal error 1 in R_decompress1", the
  installed copy of erglm is stale or was partially overwritten while a
  live session still had it loaded. Fix: unload it from the live
  session (`unloadNamespace("erglm")`), reinstall from a clean shell
  (`R CMD INSTALL .`, not `devtools::install()`, which hit the same
  issue when the package was already loaded), then retry.
- pkgdown renders every `*.md` file at the package root (and in
  `.github/`) into its own `docs/*.html` page -- hard-coded in
  `pkgdown:::package_mds()` and not configurable via `_pkgdown.yml`, so
  `.Rbuildignore`-ing `AGENTS.md`/`.agents/` (needed to keep them out of
  the built *package*) has no effect on the *pkgdown site*: unhandled,
  they'd get published as `docs/AGENTS.html` and indexed in
  `docs/search.json`/`docs/sitemap.xml`. `tools/pkgdown-postbuild.R`
  strips these pages (and their search/sitemap entries) back out;
  `.github/workflows/pkgdown.yaml` runs it right after
  `build_site_github_pages()`. Run it manually after any local
  `pkgdown::build_site()` too.
- Three skills in `.agents/skills/` (also excluded from the built package
  via `.Rbuildignore`) carry detailed, checklist-driven guidance for
  specific recurring tasks -- load the matching one before doing that task
  rather than relying on the summary here:
  - **`.agents/skills/write-roxygen-docs/`** -- what goes in a title vs.
    description vs. `@details` for erglm's two documentation shapes
    (standalone function pages vs. shared `@name`/`@rdname` topics like
    `erglm_scm`/`erglm_term`/`erglm_link`), how to calibrate documentation
    density, and how to keep roxygen comments user-facing. Use before
    adding a new exported function or editing an existing `@param`/
    `@returns`/`@details`/`@examples` block.
  - **`.agents/skills/write-news-entries/`** -- how to size and place a
    `NEWS.md` bullet under erglm's `(development version)` heading
    convention, and the same-development-cycle carve-out for bug-fix
    entries. Use whenever adding or reviewing a `NEWS.md` entry.
  - **`.agents/skills/write-vignettes/`** -- mechanics, cross-referencing,
    and prose conventions for `vignettes/articles/*.Rmd`, including the
    generalise-to-other-families closing section and pointing to `erplots`
    instead of building plotting code inline. Use before drafting a new
    article or reviewing one for consistency.

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

## Keeping this documentation current

This file (`AGENTS.md`) should stay a lean, current-state reference --
if a change makes something above inaccurate, update it in place
rather than appending a note about the change.

Two companion files in `.agents/` (also excluded from the built package
via `.Rbuildignore`) carry the parts that don't belong here:

- **[.agents/HISTORY.md](.agents/HISTORY.md)** -- a condensed record of
  completed design decisions and their rationale (what was tried,
  rejected, and why), for context in future sessions. When you finish a
  piece of nontrivial design work, add an entry here rather than
  growing this file with "used to be X, now Y" narrative.
- **[.agents/PLAN.md](.agents/PLAN.md)** -- scoped-out future work and
  deferred/open items. When you finish something listed there, move its
  write-up into `HISTORY.md` and remove it from `PLAN.md` rather than
  marking it "done" in place.
