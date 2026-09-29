# erglm development plan

This document tracks scoped-out future development for erglm -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place. See `NEWS.md` for the user-facing
changelog.

## Before calling `devtools::release()` for 0.2.0

Local `devtools::check(remote = TRUE, manual = TRUE)` and R-hub v2
(linux, macos-arm64, windows, nosuggests, all R-devel) are clean: 0
errors/warnings/notes, `Status: OK` everywhere
(<https://github.com/djnavarro/erglm/actions/runs/36538736020>).
win-builder (R-devel and R-release) was submitted 2026-09-29 via
`devtools::check_win_devel()`/`check_win_release()`; results arrive by
email (~30 min). Remaining before submitting:

- Fill in win-builder's `Status`/note count and log URLs in
  `cran-comments.md` (currently marked TODO) once the emails arrive.
- The maintainer's own read-through of `cran-comments.md`/`NEWS.md`
  before submitting.

## Companion `erplots` repo needs updating

Out of scope for this repo, but tracked here as a reminder: the
companion [erplots](https://github.com/djnavarro/erplots) repo still
references the old package/function names (`erlr::lr_model()`,
`erlr::lr_data`) in its `DESCRIPTION` `Suggests`, test helpers, and a
vignette article -- it needs a corresponding update once this rename is
published, or its `erlr`-dependent tests/vignette will break.
