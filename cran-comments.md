## Submission

This is a resubmission (0.1.1), addressing three points of feedback on
the 0.1.0 submission:

1. Software names should be single-quoted in `Title`/`Description`.
   `erglm`'s self-reference in `Description` is now `'erglm'` (the
   companion package `'erplots'` was already quoted).
2. `erplots` (a `Suggests` dependency, not on CRAN) needs a declared
   source. `DESCRIPTION` now includes `Additional_repositories:
   https://djnavarro.r-universe.dev`, from which it installs.
3. `poisson` and `gaussian` in `Description` should be capitalised, as
   they name the eponymous distributions (Poisson, Gauss). `binomial`
   and `gamma` are left lowercase, as neither is an eponym.

No other changes since 0.1.0.

## Test environments

* local Ubuntu 24.04, R 4.6.1, `devtools::check(remote = TRUE, manual = TRUE)`
* R-hub v2 (`rhub::rhub_check()`): linux, macos-arm64, windows, and
  nosuggests, all R-devel -- all `Status: OK`
* win-builder, R-devel and R-release -- both `Status: 1 NOTE` (below),
  0 errors, 0 warnings
  (<https://win-builder.r-project.org/2bNIuS069iDx/00check.log>,
  <https://win-builder.r-project.org/C0J7C6r2LG3N/00check.log>)

## R CMD check results

0 errors | 0 warnings | 1 note

```
New submission

Suggests or Enhances not in mainstream repositories:
  erplots
Availability using Additional_repositories specification:
  erplots   yes   https://djnavarro.r-universe.dev
```

`erplots` (<https://github.com/djnavarro/erplots>) is a companion
visualisation package erglm optionally interoperates with via three S3
methods, registered lazily at load time. Every use is conditional: the
one test file exercising it is skipped via
`testthat::skip_if_not_installed("erplots")`, the S3 methods are only
registered if `erplots` is present, and no exported function, example,
or shipped vignette requires it. Verified directly: the package passes
`R CMD check` cleanly with `erplots` genuinely absent (`Status: OK` on
R-hub's `nosuggests` container, and locally against a throwaway
library with `erplots` removed), with the skip reported explicitly.

## Downstream dependencies

There are no downstream dependencies for this package.
