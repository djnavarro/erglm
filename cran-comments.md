## Submission

This is a routine feature release (0.2.0), following on from 0.1.1's
CRAN resubmission. Highlights (see `NEWS.md` for the complete list):

* `erglm_scm_forward()`/`erglm_scm_backward()` gain a `criterion`
  argument, supporting `"aic"`/`"bic"`-based term selection in addition
  to the existing `"p-value"` default.
* erglm no longer depends on rlang, withr, tibble, or dplyr -- `mvtnorm`
  remains its only runtime dependency besides base `stats`. As a
  consequence, several functions now return plain data frames rather
  than tibbles (a documented, intentional public-API change; see
  `NEWS.md`).
* Various documentation fixes.

No changes to `DESCRIPTION`'s dependency declarations require reviewer
attention this time. `erplots`, erglm's `Suggests`-only, optional
interoperability dependency, is itself now on CRAN (0.1.2, published
2026-09-09), so the `Additional_repositories`/not-on-CRAN caveats from
the 0.1.0/0.1.1 submissions no longer apply; erglm's use of it remains
conditional regardless (registered lazily at load time, with the one
test file exercising it skipped via
`testthat::skip_if_not_installed("erplots")`).

## Test environments

* local Ubuntu 24.04, R 4.6.1, `devtools::check(remote = TRUE, manual = TRUE)`
* R-hub v2 (GitHub Actions workflow): linux, macos-arm64, windows, and
  nosuggests, all R-devel -- all `Status: OK`
  (<https://github.com/djnavarro/erglm/actions/runs/36538736020>)
* win-builder, R-release -- `Status: OK`, 0 notes
  (<https://win-builder.r-project.org/wY4Qc0kaXV7S/00check.log>)
* win-builder, R-devel -- `Status: OK`, 0 notes
  (<https://win-builder.r-project.org/z5dYitZ5Fqpp/00check.log>)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Downstream dependencies

There are no downstream dependencies for this package.
