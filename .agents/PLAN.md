# erglm development plan

This document tracks scoped-out future development for erglm -- work
that's been thought about but not done, or deliberately deferred. It is
not a changelog: once an item here is completed, its write-up should
move to [.agents/HISTORY.md](HISTORY.md) and be removed from this file
rather than marked "done" in place. See `NEWS.md` for the user-facing
changelog.

## Before calling `devtools::release()`

CRAN submission prep (see `.agents/HISTORY.md`) is otherwise complete:
the package checks cleanly (0 errors/warnings, one explained NOTE) on
R-hub and both win-builder platforms, with `erplots`'s absence
confirmed harmless. Remaining:

- A final `devtools::check()` at the `0.1.0` version to confirm nothing
  regressed since the last full check.
- The maintainer's own read-through of `cran-comments.md`/`NEWS.md`
  before submitting.

## Companion `erplots` repo needs updating

Out of scope for this repo, but tracked here as a reminder: the
companion [erplots](https://github.com/djnavarro/erplots) repo still
references the old package/function names (`erlr::lr_model()`,
`erlr::lr_data`) in its `DESCRIPTION` `Suggests`, test helpers, and a
vignette article -- it needs a corresponding update once this rename is
published, or its `erlr`-dependent tests/vignette will break.
