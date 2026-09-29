---
name: write-roxygen-docs
description: Guidance for writing and reviewing roxygen2 documentation comments in the erglm R package. Use whenever adding a new exported function, editing an existing @param/@returns/@details/@examples block, or reviewing a roxygen comment before running devtools::document().
---

# Writing roxygen2 Documentation

Roxygen comments become the content of `?function` and the pkgdown reference
site — they are read by a human user deciding whether and how to call a
function, not by a future contributor or an agent. Getting the mechanics
right (tags, `@export`, blank lines) is the easy part; agents reliably get
that right already. The failure modes worth guarding against are about
*content*: putting the wrong thing in a section, writing at the wrong level
of detail, or leaking information that shouldn't be there at all.

This skill assumes familiarity with roxygen2 basics. For deeper background on
any topic below, see [R Packages (2e), ch. 16](https://r-pkgs.org/man.html).

## Two document shapes in this package

Most of erglm's exported surface is documented one of two ways, and each
shape has a different failure mode to watch for:

- **A standalone function with its own page** -- `erglm_model()`,
  `erglm_predict()`, `erglm_fun()`, `simulate.erglm_model()`, `erglm_data`.
  Here the risk is the usual one: a title/description that doesn't actually
  say what's distinctive about *this* function. `erglm_model()`,
  `erglm_predict()`, and `erglm_fun()` all revolve around "prediction" in
  some sense, but each returns a genuinely different artifact -- a fitted
  `glm` object, a tidy data frame of response-scale predictions with
  confidence intervals, and a callable prediction-function factory,
  respectively -- and the title/description should name that artifact, not
  a generic verb like "generate predictions" that could describe any of the
  three.
- **A shared `@name`/`@rdname` topic covering several functions** --
  `erglm_scm` (covers `erglm_scm_forward()`, `erglm_scm_backward()`,
  `erglm_scm_history()`), `erglm_term` (covers `erglm_add_term()`,
  `erglm_remove_term()`), `erglm_link` (covers `erglm_link()`,
  `erglm_invlink()`). Here there's only *one* title/description for the
  whole page, so the risk isn't drift between siblings' docs -- it's writing
  a description generic enough to be true of every function on the page
  without collapsing into a restatement of the title. `erglm_scm`'s
  description ("stepwise covariate modelling... forward addition...
  backward elimination... complete history") names what forward, backward,
  and the history log have in common (a shared stepwise search over `glm()`
  covariate terms) rather than pretending the three functions are
  interchangeable -- what's distinctive about *each* one (default
  `threshold`, whether it adds or removes, what it returns) belongs in
  `@param`/`@returns` instead, described per-function within the shared tag.

## What goes where

Each part of the introduction has a distinct job. Don't let content drift
into the wrong one:

- **Title** (first sentence, sentence case, no full stop): what the
  function (or, for a shared topic, the function family) does, distinguishing
  it from sibling pages -- see above.
- **Description** (next paragraph): one paragraph on the page's purpose, in
  different words than the title -- not a restatement of it. It's easy to
  skip the description paragraph entirely: roxygen2 doesn't warn you, it
  silently reuses the title as the description, which is *always* a
  restatement by construction.
- **`@details`**: everything else -- default behaviour, edge cases, how an
  argument being `NULL` is treated (e.g. `erglm_predict()`'s `newdata = NULL`
  falling back to `object$data`; `simulate.erglm_model()`'s `seed = NULL`
  being auto-picked and reported), interactions with other parts of the
  fitting/SCM/simulation pipeline. It's fine for this to be a few sentences
  to a short paragraph. Details render *after* arguments and return value on
  the help page, so don't put anything here that a reader needs before they
  can parse `@param`.
- **`@param`**: a succinct summary of what the argument controls and, if it
  has a fixed set of values (like `criterion` or `test`), what they are.
  State the default inline -- and when a shared `@rdname` page documents the
  same argument name with *different* defaults per function, say so
  explicitly. `erglm_scm`'s `threshold` is the clearest example: it defaults
  to `0.01` for `erglm_scm_forward()` but `0.001` for `erglm_scm_backward()`,
  and the `@param` prose states both, since a reader looking at only one of
  the two usage blocks would otherwise see just one number. When the default
  is a sentinel like `NULL` whose *effect* isn't obvious from the value
  itself, say what it does rather than just naming it (e.g. "If `NULL` (the
  default), one is chosen automatically and reported via a message" reads
  better than "the default is `seed = NULL`", which tells the reader nothing
  until they go read `@details` too).
- **`@returns`**: the shape of the return value. For a standalone page, one
  sentence naming the concrete type (e.g. "A data frame" for `erglm_predict()`).
  For a shared `@rdname` page where the functions return genuinely different
  things, disambiguate explicitly within the one `@returns` tag rather than
  writing something vague enough to cover all of them -- `erglm_scm`'s
  `@returns` does this correctly: "For `erglm_scm_forward()` and
  `erglm_scm_backward()`, the updated erglm model is returned... For
  `erglm_scm_history()`, a data frame is returned...". Every exported
  function must have this tag (inherited from its `@rdname` page if shared).
- **`@examples`**: runnable code showing typical usage. Not a place to
  re-explain arguments already covered in `@param`. Fitting via
  `erglm_model()` is a single IRLS call and always fast, so (unlike a package
  fitting via iterative nonlinear optimisation) there's no options object or
  time limit to pass just to keep examples from hanging -- a plain
  `erglm_model(ae1 ~ aucss, erglm_data, family = binomial())` against the
  bundled `erglm_data` is a complete, fast example.

## Calibrating detail

Match documentation density to how novel the content actually is:

- `erglm_scm`'s real `@details` is a useful reference point for *when* to
  reach for structure: it currently covers four distinct sub-topics in a row
  (why `seed` is mostly redundant, what happens when a candidate term is
  aliased/collinear, the three `criterion` values as a bullet list, and how
  `candidates` is validated up front) as one long unbroken block. Once
  `@details` grows to that many sub-topics, break it into markdown headings
  or `@section` blocks instead -- a reader looking for just the aliasing
  behaviour shouldn't have to read past the seed rationale to find it.
- A dense wall of text is harder to scan than the same information broken
  into a sentence or two per idea, or a short bullet list (roxygen2 markdown
  supports `* item` lists in any prose section). Prefer that when an
  argument has more than two or three possible values (e.g. `criterion`'s
  three values, or `test`'s three).
- Don't pad a short, genuinely simple function's documentation just to make
  it look thorough. `erglm_link()`/`erglm_invlink()` are compact by design
  (each is a one-line wrapper around a piece of `stats::family()` that
  already exists); if the description already says everything, an empty or
  one-line `@details` -- or omitting the tag -- is correct.
- `@section` titles must be capitalized (R Core's own
  [Rd file guidelines](https://developer.r-project.org/Rds.html) state this
  explicitly for both `\title` and `\section` titles). Don't just reuse a
  lowercase identifier verbatim as a heading -- prefer a short, readable
  capitalized phrase, and refer to the actual identifier in the body text
  instead, in backticks.

## Keep it user-facing

Roxygen documentation ships to end users via `?function` and pkgdown. It is
governed by the same boundary as `NEWS.md` (see the `write-news-entries`
skill):

- **Never reference agent- or contributor-facing material.** No mentions of
  skills, `AGENTS.md`, `.agents/HISTORY.md`/`.agents/PLAN.md`, or CI
  configuration.
- **Don't name internal `.erglm_*`-prefixed helper functions or otherwise
  describe implementation details that could change.** Explain behaviour in
  terms of what the function does and what the user observes (inputs
  accepted, outputs produced, what the fitted object contains), not the
  private helper functions or code paths used to get there. Naming a
  dot-prefixed internal function in documentation also invites users to
  reach for it with `:::`, which is best avoided.

  Note: two roxygen blocks in this package currently *do* name internal
  helpers -- `erglm_scm`'s `@details` names `.erglm_once_forward()`/
  `.erglm_once_backward()`, and `simulate.erglm_model()`'s `@details` names
  `.erglm_draw_response()`. That predates this rule and is tracked as
  cleanup, not a pattern to extend -- don't use existing docs as a precedent
  when writing new ones. If you find yourself writing "internally, this
  calls..." or naming a `.erglm_*()` function, cut it and keep only the
  behavioural consequence (e.g. "family-appropriate residual noise" instead
  of naming `.erglm_draw_response()`).
- **Write for a reader who has never seen the source.** Avoid phrasing that
  only makes sense with the R script open (e.g. "as shown above" referring
  to code, not prose already in the same doc).
- **Cross-reference with square brackets, not just backticks.** Writing
  `` `erglm_fun()` `` renders as code but produces no link;
  `[erglm_fun()]` (or `[erplots::er_vpc_add_simulated()]` for another package) is
  what roxygen2/pkgdown turn into an actual hyperlink. `erglm_predict()`'s
  own docs already do this correctly (`See also [erglm_fun()]`) -- match
  that pattern for any new cross-reference, whether in `@details`,
  `@seealso`, or prose.
- **Check the compiled `.Rd` for stray aliases, not just the prose.**
  erglm's shared-topic pages (`erglm_scm`, `erglm_term`, `erglm_link`) all
  use the standard `@name X ... NULL` idiom: the roxygen block is followed
  immediately by a bare `NULL`, which is the object the `@name` block
  actually attaches to, before the real `@rdname`-tagged functions follow.
  If some other object -- an internal helper, a stray constant -- ends up
  sitting between the roxygen block and that `NULL`, roxygen2 silently
  attaches the block to that object instead and gives it a public `\alias`,
  which can surface as nonsense in the rendered `\usage{}`. Reading the
  roxygen comments won't reveal this; open the generated `man/*.Rd` and
  check that every `\alias{}` is something the topic is actually meant to
  document.

## Checklist before finishing a roxygen block

- [ ] For a standalone function, the title/description names the specific
      artifact it returns, not a generic verb shared with sibling functions
      (e.g. `erglm_model()`/`erglm_predict()`/`erglm_fun()` all differ here).
- [ ] For a shared `@name`/`@rdname` page, the title/description names what
      the documented functions have in common, and per-function
      distinctions (different defaults, different return shapes) are
      pushed down into `@param`/`@returns` instead.
- [ ] An explicit `@description` paragraph was actually written, distinct
      from the title -- not left to roxygen2's default of silently reusing
      the title verbatim.
- [ ] Everything in `@details` is genuinely additional to the description,
      not filler to make the section non-empty.
- [ ] If `@details` covers more than three or four sub-topics (as
      `erglm_scm`'s currently does), it's broken into headings/`@section`s
      rather than left as one long block.
- [ ] Every `@section` title is capitalized, and reads as a short phrase
      rather than a bare lowercase identifier copied from the code.
- [ ] Every `@param` states the default where one exists -- including both
      defaults, if a shared `@rdname` page's argument default differs by
      function (e.g. `threshold`) -- and enumerates fixed value sets (e.g.
      `criterion`, `test`).
- [ ] `@returns` is present and names the concrete class/shape returned,
      disambiguated per function on a shared `@rdname` page where the
      return values genuinely differ.
- [ ] Every reference to another function (in `@details`, `@seealso`, or
      prose) uses square brackets so it actually renders as a link, not
      backticks alone.
- [ ] No mention of skills, `AGENTS.md`, `.agents/*.md`, CI, or other
      agent/contributor-facing material.
- [ ] No newly-introduced description of implementation details a user
      would need `:::` to verify, and no newly-named internal `.erglm_*()`
      helper -- only observable inputs/outputs/behavior (unless it's one of
      the two pre-existing exceptions noted above, tracked as cleanup).
- [ ] For `@name`/`@rdname` topics, every `\alias{}` in the compiled
      `man/*.Rd` is something the topic is actually meant to document -- no
      internal object picked up by accident ahead of the `NULL` placeholder.
- [ ] Ran `devtools::document()` and skimmed the rendered `man/*.Rd` (or
      `?function` output) rather than just the roxygen comment source. If
      the fix touched code (not just comments) -- e.g. reordering
      definitions to fix an alias leak -- also ran `devtools::test()`.
