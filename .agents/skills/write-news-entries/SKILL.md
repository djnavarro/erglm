---
name: write-news-entries
description: Guidance for writing entries in NEWS.md for the erglm R package. Use whenever adding, updating, or reviewing a NEWS.md entry, e.g. after implementing a new feature, fixing a bug, or making an API change.
---

# Writing NEWS.md Entries

`NEWS.md` is a user-facing changelog, not a commit log or a design document.
Unreleased changes accumulate under the top heading of the file, which --
unlike some sibling packages -- is written as the literal
`# erglm (development version)` rather than a version number carrying a
`.9000` suffix. When a release is cut, that heading is replaced by the
concrete version being released (e.g. `# erglm 0.1.2`), and a fresh
`# erglm (development version)` heading is added above it for the next
cycle. `NEWS.md` currently uses a flat bullet list under each heading, with
no `## New features`/`## Improvements`/`## Bug fixes` subsections -- match
that (see "Rules" below); only introduce subsections if a release genuinely
grows large enough to need them.

erglm has already shipped two CRAN releases -- `# erglm 0.1.0` ("Initial
CRAN release.") and `# erglm 0.1.1` (a CRAN resubmission addressing reviewer
feedback) are both real, released versions, not drafts. That makes the
distinction in rule 3 below live: a bug introduced since `0.1.1` (i.e. only
present in code under the current `(development version)` heading) is a
same-cycle fix, but a regression in code that shipped in `0.1.1` or `0.1.0`
is a genuine, user-visible `## Bug fixes` (or, given the current flat-list
convention, just a plainly-worded) entry.

Two failure modes recur when writing entries here: restating information
that already lives elsewhere (function documentation, a linked GitHub
issue), and describing a bug fix for code that was only ever broken within
the current, unreleased development cycle. The rules below exist to avoid
both.

## Rules

1. **Keep it short.** One sentence is usually enough; two only if the
   change genuinely needs it. A bare function name like
   `` erglm_scm_forward() `` is auto-linked by pkgdown straight to its help
   page, so do not restate parameter names, defaults, algorithmic detail, or
   examples that are already covered in that function's `@details`/
   `@examples`. The existing dev-heading entry is a good model:

   > `erglm_scm_forward()`/`erglm_scm_backward()` gain a `criterion`
   > argument, supporting `"aic"`/`"bic"`-based term selection in addition
   > to the existing `"p-value"` default. The SCM history
   > (`erglm_scm_history()`) gains a `criterion` column recording which
   > selection rule was applied in each forward/backward step (#7).

   It names what changed and points at the functions/history column
   involved, without re-explaining how `criterion = "aic"` is scored --
   that belongs in `erglm_scm`'s own `@details`.

2. **NEWS.md is strictly user-facing.** Never reference or link to
   agent-facing or contributor-facing material: skills, `AGENTS.md`,
   `.agents/HISTORY.md`/`.agents/PLAN.md`, internal dot-prefixed helper
   functions (e.g. `.erglm_once_forward()`, `.erglm_draw_response()`,
   `.pick_seed()`), CI configuration, or "how we implemented this"
   narrative. If a change has no visible effect on the public API,
   documented behavior, or output (e.g. an internal helper was refactored,
   `.erglm_check_criterion()` gained a case nothing exported surfaces
   differently), it does not belong in NEWS.md at all -- skip it rather than
   finding a way to phrase it.

3. **Only describe what changed since the last CRAN release.** Check the
   heading at the top of the file: everything under
   `# erglm (development version)` is unreleased. If a bug being fixed was
   introduced by a feature added earlier in the *same* development cycle
   (i.e. that feature has never shipped to CRAN), it is not a user-visible
   "bug fix" -- it's the feature working correctly. Don't add a bug-fix entry
   for it; either revise the original feature's own bullet if it needs
   correcting, or just fix the code silently. Only regressions in code that
   already shipped in `0.1.1` or `0.1.0` deserve their own entry, worded as
   a fix.

4. **Point to the issue/PR instead of re-explaining it.** Append `(#N)` to
   the end of the bullet when a GitHub issue or PR number exists -- as the
   current dev-heading entry does with `(#7)`. Don't restate the issue's
   background, discussion, or design rationale -- that history is already
   written down in the issue itself, one click away.

5. **Match the existing flat-list structure and voice.** `NEWS.md` doesn't
   currently use `##` subsections at all -- each heading (`0.1.0`, `0.1.1`,
   the dev heading) is just a bullet list, occasionally preceded by a short
   scene-setting sentence (`0.1.0`'s "Initial CRAN release.", `0.1.1`'s
   "CRAN resubmission, addressing reviewer feedback on the 0.1.0
   submission:"). Keep new entries as bullets in that same flat list; only
   introduce `## New features`/`## Bug fixes`-style subsections if a
   release grows large and varied enough that the flat list becomes hard to
   scan. Start each bullet with a past-tense verb ("Added", "Fixed",
   "Changed", "Removed", "Deprecated") or, for a package/API-focused
   sentence like the existing dev entry, a present-tense verb describing
   what the function now does ("gains a `criterion` argument").

6. **A compliance-only entry can be narrowly scoped, not padded to sound
   substantial.** `0.1.1`'s three bullets (single-quoting 'erglm' in
   `DESCRIPTION`, adding `Additional_repositories:`, capitalising `Poisson`/
   `Gaussian`) are each one sentence describing a specific, narrow
   documentation/metadata fix requested by a CRAN reviewer. Follow that
   model for similar housekeeping changes -- state exactly what changed and
   why (if a reviewer or policy prompted it), and stop there.

## Example

Too long -- restates documentation detail and mentions an internal helper:

```md
- Added a `criterion` argument to `erglm_scm_forward()` and
  `erglm_scm_backward()` that selects the significance test used at each
  step: `"p-value"` (the existing threshold-based test), `"aic"`, or
  `"bic"`. Internally, `.erglm_once_forward()`/`.erglm_once_backward()`
  compare each candidate's AIC/BIC against `best_metric`, updated as better
  candidates are found within the step, rather than against `threshold`,
  which only applies in `"p-value"` mode. `erglm_scm_history()`'s returned
  tibble now also records which criterion drove each step, in a new
  `criterion` column (#7).

- `.erglm_check_criterion()` now validates the new argument too (#7).
```

Right level of detail -- says what changed, links to the function for the
rest, skips the internal-only change entirely:

```md
- `erglm_scm_forward()`/`erglm_scm_backward()` gain a `criterion`
  argument, supporting `"aic"`/`"bic"`-based term selection in addition to
  the existing `"p-value"` default. The SCM history
  (`erglm_scm_history()`) gains a `criterion` column recording which
  selection rule was applied in each forward/backward step (#7).
```

## Checklist before adding an entry

- [ ] Is this visible to a user of the package, not just to future
      contributors? If not, skip NEWS.md entirely.
- [ ] If this is a bug fix, did the bug exist in a previously released
      version (`0.1.1` or `0.1.0`), rather than being a same-cycle
      regression in code only ever under the current
      `(development version)` heading?
- [ ] Is the bullet one or two sentences, with parameter/implementation
      detail left to the function's own documentation?
- [ ] Does it rely on pkgdown's auto-linking of bare function names rather
      than re-describing what that link leads to?
- [ ] Does it append `(#N)` instead of re-explaining the linked issue/PR?
- [ ] Does it stay a flat bullet, matching the file's existing convention,
      rather than introducing `##` subsections for a small change?
- [ ] Does it avoid mentioning skills, `AGENTS.md`, `.agents/*.md`, internal
      dot-prefixed helpers, or other agent/contributor-facing material?
