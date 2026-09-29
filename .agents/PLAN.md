# erglm development plan

This document tracks scoped-out future development for erglm -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place. See `NEWS.md` for the user-facing
changelog.

## Before calling `devtools::release()` for 0.2.0

All checks are complete and clean: local `devtools::check(remote =
TRUE, manual = TRUE)`, R-hub v2 (linux, macos-arm64, windows,
nosuggests, all R-devel;
<https://github.com/djnavarro/erglm/actions/runs/36538736020>), and
both win-builder platforms (R-devel
<https://win-builder.r-project.org/z5dYitZ5Fqpp/00check.log>,
R-release
<https://win-builder.r-project.org/wY4Qc0kaXV7S/00check.log>) --
0 errors/warnings/notes everywhere. `cran-comments.md` is fully filled
in. Remaining before submitting:

- The maintainer's own read-through of `cran-comments.md`/`NEWS.md`
  before submitting.

## Companion `erplots` repo needs updating

Out of scope for this repo, but tracked here as a reminder: the
companion [erplots](https://github.com/djnavarro/erplots) repo still
references the old package/function names (`erlr::lr_model()`,
`erlr::lr_data`) in its `DESCRIPTION` `Suggests`, test helpers, and a
vignette article -- it needs a corresponding update once this rename is
published, or its `erlr`-dependent tests/vignette will break.
