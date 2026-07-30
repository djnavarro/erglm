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
3. "-> Poisson, Gaussian (form surnames)" -- the `Description` field's
   `poisson` and `gaussian` are now capitalised (`Poisson`, `Gaussian`),
   since they refer to the eponymous distributions/families (Poisson,
   Gauss) rather than being used as plain adjectives. `binomial` and
   `gamma` are left lowercase, as neither is an eponym.

No other changes since 0.1.0.

## Test environments

* local Ubuntu 24.04, R 4.6.1, `devtools::check(remote = TRUE, manual = TRUE)`
* R-hub v2 (`rhub::rhub_check()`): linux, macos-arm64, windows, and
  nosuggests, all R-devel -- all `Status: OK`
* win-builder, R-release (`devtools::check_win_release()`), resubmitted
  after the `Poisson`/`Gaussian` capitalisation fix above:
  `Status: 1 NOTE` (the expected new-submission/`erplots`-availability
  note; see below), 0 errors, 0 warnings
  (<https://win-builder.r-project.org/C0J7C6r2LG3N/00check.log> --
  no misspelled-words flag at all here, confirming the
  `Poisson`/`Gaussian` fix; an earlier log from the submission just
  before that fix, <https://win-builder.r-project.org/Uq48u332N0R1/00check.log>,
  still flagged `poisson`, for reference).
* win-builder, R-devel (`devtools::check_win_devel()`):
  `Status: 1 NOTE` (the same expected note), 0 errors, 0 warnings, no
  misspelled-words flag
  (<https://win-builder.r-project.org/2bNIuS069iDx/00check.log>). The
  FTP upload initially failed repeatedly with `Failed FTP upload: 550`
  across five attempts over two sessions (including a 3-minute wait
  in between), while an identical build uploaded to R-release without
  issue each time -- confirming that was a transient problem specific
  to win-builder's R-devel endpoint rather than anything in the
  package, since a later retry succeeded cleanly.

## R CMD check results

0 errors | 0 warnings | 1 note (expected `New submission` /
possibly-misspelled-words note, as with the 0.1.0 submission; see
below).

```
New submission

Possibly misspelled words in DESCRIPTION:
  erglm (12:41)
```

`erglm` is the package's own name (now single-quoted per the
reviewer's request, which `aspell` still flags since it isn't a
dictionary word). The `poisson`/`gaussian` misspelling flags from the
0.1.0 submission are gone now that both are capitalised as the
eponyms `Poisson`/`Gaussian` (see point 3 above).

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
Fedora, where `erplots` is genuinely absent) for the 0.1.0 submission,
and, for this 0.1.1 resubmission, against a local `nosuggests`-equivalent
simulation -- a throwaway library mirroring the real one but with
`erplots` removed, checked with `_R_CHECK_FORCE_SUGGESTS_=false` (`R CMD
check --as-cran` on the built tarball). The local route was used instead
of re-running R-hub's `nosuggests` container via its GitHub Actions
workflow, because that workflow's `setup-deps` step (`pak::lockfile_create()`)
doesn't consult a package's own `Additional_repositories` field when
resolving `deps::.` references -- a known upstream `pak` limitation
(<https://github.com/r-lib/pak/issues/424>), unrelated to `erglm` and
orthogonal to CRAN's own incoming-feasibility check (which does read
`Additional_repositories` correctly, as shown above). In both the
0.1.0 R-hub run and the 0.1.1 local simulation, the `test-er-methods.R`
skips are reported explicitly rather than the package silently working
some other way.

## Downstream dependencies

There are no downstream dependencies for this package.
