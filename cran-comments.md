## Submission

This is a new package.

## Test environments

* local Ubuntu 24.04, R 4.6.1, `devtools::check(remote = TRUE, manual = TRUE)`
* R-hub v2 (`rhub::rhub_check()`): linux, macos-arm64, windows, and
  nosuggests, all R-devel -- all `Status: OK`
* win-builder, R-devel and R-release (`devtools::check_win_devel()`/
  `check_win_release()`) -- both `Status: 1 NOTE`, re-run after the
  `Remotes` field fix to confirm it's gone: R-release
  (<https://win-builder.r-project.org/MZQKR10g1a71/00check.log>) and
  R-devel
  (<https://win-builder.r-project.org/pRgEup4LhLH8/00check.log>) both
  show the 3-item note described below with no `Remotes` mention and
  no platform-specific issues
* `devtools::check_mac_release()` was attempted but not obtained --
  mac.r-project.org returned repeated HTTP 502s at submission time.
  Not otherwise substituted, since R-hub's `macos-arm64` platform
  above already exercises macOS.

## R CMD check results

0 errors | 0 warnings | 1 note

The note bundles three sub-items from the CRAN incoming feasibility
check, addressed in turn below: expected new-submission housekeeping,
two DESCRIPTION words that are correct but not dictionary words, and
an optional Suggests dependency that isn't on CRAN.

```
New submission

Possibly misspelled words in DESCRIPTION:
  erglm (12:41)
  poisson (10:33)

Suggests or Enhances not in mainstream repositories:
  erplots
```

### "New submission"

Expected and accurate -- this is erglm's first CRAN submission.

### Possibly misspelled words: `erglm`, `poisson`

Both are correct as written: `erglm` is the package's own name, and
`poisson` is the standard (lowercase, as used generically rather than
as the proper noun `Poisson`) name of the Poisson family/distribution
supported by `erglm_model()`. This is R's own `aspell`-based scan of
the `DESCRIPTION` file's `Title`/`Description` fields as part of the
incoming-feasibility check; it has no ignore-list mechanism (unlike
`spelling::spell_check_package()`'s `inst/WORDLIST`, which covers Rd
files and vignettes and reports no errors here), so a domain-specific
term or the package's own name reliably triggers it for most new
packages. Not actionable beyond confirming both words are intentional.

### Suggests not in mainstream repositories

`erplots` (<https://github.com/djnavarro/erplots>) is a companion
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

There are no downstream dependencies for this new package.
