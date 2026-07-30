## Submission

This is a resubmission (0.1.1), addressing feedback from the CRAN
reviewer on the 0.1.0 submission:

1. "Please single quote software names in both Title and Description
   fields of the DESCRIPTION file such as 'erglm'." -- The `Description`
   field's self-reference to `erglm` is now single-quoted
   (`'erglm'`); the companion package was already quoted
   (`'erplots'`). The `Title` field does not name any software (it
   reads "Exposure-Response Tools for GLM-Based Models" -- "GLM" is
   the general statistical method, not a package name), so no change
   was needed there.
2. "Suggests or Enhances not in mainstream repositories: erplots ...
   and no declaration where to get it from." -- `DESCRIPTION` now
   declares `Additional_repositories: https://djnavarro.r-universe.dev`,
   which serves `erplots` (a companion visualisation package, not yet on
   CRAN) as a source `install.packages()` can use, per the CRAN
   policy on declaring non-mainstream `Suggests`/`Enhances`
   dependencies.

No other changes since 0.1.0.

## Test environments

* local Ubuntu 24.04, R 4.6.1, `devtools::check(remote = TRUE, manual = TRUE)`
* R-hub v2 (`rhub::rhub_check()`): linux, macos-arm64, windows, and
  nosuggests, all R-devel -- all `Status: OK`
* win-builder, R-devel and R-release
  (`devtools::check_win_devel()`/`check_win_release()`)

## R CMD check results

0 errors | 0 warnings | 1 note (expected `New submission` /
possibly-misspelled-words note, as with the 0.1.0 submission; see
below).

```
New submission

Possibly misspelled words in DESCRIPTION:
  erglm (12:41)
  poisson (10:33)
```

Both are correct as written: `erglm` is the package's own name (now
single-quoted per the reviewer's request, which `aspell` still flags
since it isn't a dictionary word), and `poisson` is the standard
(lowercase, used generically rather than as the proper noun
`Poisson`) name of the Poisson family/distribution supported by
`erglm_model()`.

The `erplots`-not-in-mainstream-repositories note from the 0.1.0
submission is addressed via `Additional_repositories` (see above) and
no longer appears.

`erplots` (<https://github.com/djnavarro/erplots>) remains a companion
visualisation package that erglm optionally interoperates with via a
small set of S3 methods (`er_predict()`/`er_simulate()`/
`er_summary()`), registered lazily at load time so erglm has no hard
dependency on it. Every use is conditional:

* The one test file exercising this interop
  (`tests/testthat/test-er-methods.R`) is skipped via
  `testthat::skip_if_not_installed("erplots")` when it isn't
  installed.
* The S3 methods are registered in `.onLoad()` only if `erplots` is
  present, using a vendored `s3_register()`.
* No exported function, example, or shipped vignette requires
  `erplots`; the articles that demonstrate the interop live under
  `vignettes/articles/` and are pkgdown-only (excluded from the built
  package via `.Rbuildignore`).

This has been verified directly: the package passes `R CMD check`
cleanly (`Status: OK`) on R-hub's `nosuggests` container (R-devel on
Fedora, where `erplots` is genuinely absent), and locally against a
throwaway library with `erplots` removed. In both cases the
`test-er-methods.R` skips are reported explicitly rather than the
package silently working some other way.

## Downstream dependencies

There are no downstream dependencies for this package.
