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
attention this time: `erplots` remains a `Suggests`-only, optional
interoperability dependency (not on CRAN), used conditionally and with
its absence verified harmless (see below), and the `Additional_repositories`
field has been removed now that no vignette/example needs `erplots`
installed to build.

## Test environments

* local Ubuntu 24.04, R 4.6.1, `devtools::check(remote = TRUE, manual = TRUE)`
* R-hub v2 (GitHub Actions workflow): linux, macos-arm64, windows, and
  nosuggests, all R-devel -- all `Status: OK`
  (<https://github.com/djnavarro/erglm/actions/runs/36538736020>)
* win-builder, R-devel and R-release -- TODO: fill in `Status`/note
  count and log URLs once the win-builder emails arrive
  (submitted 2026-09-29, results expected ~30 min later)

## R CMD check results

0 errors | 0 warnings | 0 notes

## Downstream dependencies

There are no downstream dependencies for this package.
