---
name: write-vignettes
description: Guidance for writing and reviewing pkgdown articles (vignettes/articles/*.Rmd) in the erglm R package. Use whenever drafting a new article, restructuring an existing one, or reviewing one for stylistic consistency before it ships.
---

# Writing erglm vignettes

erglm's articles (`vignettes/articles/*.Rmd`, see the "Development workflow"
section of `AGENTS.md`) are tutorial prose for a human user deciding how to
use the package, rendered by pkgdown and never shipped inside the built
package. That audience and delivery mechanism shape everything below: write
for someone reading the rendered HTML page, not the `.Rmd` source, and never
assume they've read another article first unless you link them there
explicitly.

This skill distills conventions already established across the package's
more developed articles (`erglm.Rmd`, `scm.Rmd`, `simulate.Rmd`,
`methods.Rmd`) and adapts general prose-quality guidance from a similar
skill written for the companion `erplots` package. Follow erglm's own
existing conventions where they differ from `erplots`'s -- most notably,
erglm's articles are *about* fitting models, so the "never fit a model"
scope-fencing that shapes `erplots`'s equivalent skill doesn't apply here.

## Mechanics

- **Frontmatter is title-only**: `title: "..."`, no `author`/`date`. Match
  the article's role in `_pkgdown.yml`'s `articles:` list when choosing a
  title -- it's what readers see in the nav, not just the page `<h1>`. Any
  new or renamed article also needs a matching entry added to
  `_pkgdown.yml`'s `articles:` list by hand; `pkgdown::check_pkgdown()`
  catches drift here without needing a full site build (see `AGENTS.md`).
- **Standard setup chunk**, verbatim, immediately after the frontmatter:
  ```{r, include = FALSE}
  knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
  )
  ```
  `simulate.Rmd` additionally sets `fig.width`/`fig.height`/`fig.align`/
  `out.width` in this chunk, since it's the one article that renders plots;
  `scm.Rmd` additionally sets `options(digits = 4)` to keep printed
  p-values/AIC values from displaying long floating-point tails. Add either
  only when the article genuinely needs it (plots, or high-precision numeric
  output that would otherwise clutter the page).
- **A `setup` chunk** (`` ```{r setup} ``) loads `library(erglm)` plus
  whatever the article's examples need -- `tibble` (for constructing
  `newdata`/grids), and `ggplot2` for `simulate.Rmd`'s two demonstration
  plots (`ggplot2` is a `Suggests`-only dependency of erglm used exclusively
  for this purpose -- see `AGENTS.md`). There's no
  `requireNamespace()`/`eval = requireNamespace(...)` guard in any existing
  article; articles are pkgdown-only (excluded from the built package, see
  `.Rbuildignore`) and rendered in a controlled environment, so don't add one
  unless a dependency genuinely becomes optional for that specific article.
- **Chunk labels are short and kebab-cased** (`model`, `predict-1`,
  `forward-history`, `custom-sim`), one per logical step, not one giant
  unlabelled chunk per section. Where an article repeats a similar chunk
  later on (e.g. `simulate.Rmd`'s `predict-1`/`predict-2`/`predict-3`-style
  numbering doesn't actually occur, but `simulate-1`/`simulate-cols`/
  `simulate-many` does), suffix with a short qualifier rather than a bare
  number where the qualifier is more informative.
- **`##`/`###` headings** structure the body; a short article (`methods.Rmd`)
  uses flat `##` sections, a longer one nests `###` subsections under a `##`
  (`simulate.Rmd`'s `## The `simulate()` method`` / `### What `simulate()`
  actually does` / `### The output format` pattern). Keep heading depth to
  two levels -- no article currently goes to `####`.

## Opening paragraph

State what the article covers and, where relevant, point to the article that
covers an adjacent topic instead of re-explaining it. `erglm.Rmd` (Getting
Started) does this by naming exactly what it is -- "a quick tour of the main
pieces; the other articles go into more depth on each" -- rather than a
long scope-fence; `scm.Rmd` and `simulate.Rmd` instead open by motivating the
problem the article solves (choosing covariates; generating new data from a
fitted model) before introducing the relevant functions. Either opening
style is established practice; pick whichever fits the article's role
(overview vs. focused deep-dive).

`model.Rmd` currently opens with a placeholder sentence ("This is the
modelling article") rather than following either pattern above -- this is a
known gap, not a precedent. Any edit to `model.Rmd` should replace that
opening with a real one modelled on `scm.Rmd`/`simulate.Rmd`'s style, not
extend the placeholder.

## Cross-referencing between articles

- Links between articles are **relative, extensionless-source but
  `.html`-rendered**: `[scm.html](scm.html)`-style links appear throughout
  `erglm.Rmd` as `["Stepwise covariate modelling"](scm.html)`,
  `["Simulation"](simulate.html)`, and so on. Never link to the `.Rmd`
  source or use an absolute URL for another article in this package.
- Link text is a short descriptive phrase naming what the reader will find
  there (`"Using base R model methods"`, `"the modelling and methods
  articles"`), not a bare filename or "here".
- Function names referenced in prose are backtick-quoted
  (`` `erglm_scm_forward()` ``); pkgdown does not auto-link these the way
  `NEWS.md`/roxygen do.
- Do not bold package names (erglm, erplots, emaxnls, ertte) in prose --
  articles just use the plain word ("the companion `erplots` package", "any
  `glm()` family"). Reserve bold for genuinely new terminology being
  introduced (e.g. `scm.Rmd`'s **stepwise covariate modelling (SCM)**,
  **base model**, **candidate covariates** on first use; `simulate.Rmd`'s
  **Parameter uncertainty**/**Observation noise** as the two named sources
  of randomness).
- The companion `erplots` package is referenced with a full Markdown link
  the first time it's mentioned in an article (`[erplots](https://github.com/djnavarro/erplots)`,
  as in `erglm.Rmd`'s "Where to next" list and `methods.Rmd`'s closing
  paragraph), and by plain name on subsequent mentions within the same
  article.

## Sentence-level style

- **Second/third person for instructions and the package's own behaviour**
  ("you can adjust the confidence level using the `conf_level` argument",
  "erglm deliberately doesn't provide its own diagnostic plotting"). A
  pedagogical first-person plural ("we can build an exposure-response curve
  with a parameter-uncertainty band...", "we'd hope to see") is established
  practice in `simulate.Rmd` for walking the reader through a worked example
  step by step -- fine to use for that purpose, not as a stand-in for "erglm"
  itself or to hedge an opinion.
- **Inline math** for statistical notation: `scm.Rmd` writes thresholds and
  p-values as `$0.01$`, `$p \approx 0.07$`, `$\text{Bernoulli}(\mu)$`, using
  single-`$` LaTeX delimiters that pkgdown/MathJax render. Use this for
  genuine mathematical notation (probabilities, distributions, symbols),
  not as a substitute for a plain code span around an R value or argument
  name.
- **British/Australian spelling**, matching `DESCRIPTION`'s `Language:
  en-GB`: modelling, summarise, colour, behaviour.
- **Conversational but not chatty.** Contractions ("it's", "doesn't") and
  short asides are fine; keep asides about the *package's* behaviour and
  design rationale, not about the writing process itself.
- **State the "why", not just the "what", for a design choice a reader might
  otherwise think is arbitrary** -- e.g. `scm.Rmd`'s "Why the thresholds
  differ" aside explaining that a looser forward threshold plus a stricter
  backward one guards against terms that only looked useful in the presence
  of others (and prevents endless add/remove cycling), not just stating
  that the two defaults differ.

## Scope discipline specific to this package

- **Every article ends by generalising to other `glm()` families, briefly.**
  `model.Rmd`, `scm.Rmd`, and `simulate.Rmd` each fit their worked examples
  on one or two families chosen to best illustrate the concept (binomial for
  SCM, gaussian for simulation) and then close with a short section (`Other
  glm() families`, `The same tools across other glm() families`) showing
  the same code generalises unchanged to the others, rather than
  re-demonstrating every concept for every one of binomial/poisson/gaussian/
  gamma from the start. Follow this shape for a new article rather than
  writing out a full worked example per family.
- **Never document plotting or VPC helpers directly -- point to `erplots`
  instead.** erglm deliberately contains no plotting code (see `AGENTS.md`).
  `simulate.Rmd`'s "Visual predictive checks" section and `methods.Rmd`'s "A
  note on diagnostic plots" section both handle this the same way: describe
  what's needed in one or two sentences, then link to the companion
  `erplots` package (e.g. `er_vpc_plot()`) for the actual visualisation,
  rather than building a bespoke VPC-style plot inline in an erglm article.
- **No agent-facing content in the rendered article body** -- no mention of
  skills, `AGENTS.md`, or `.agents/*.md`.
- **A model-fitting example is a normal, expected part of these articles**
  (unlike `erplots`, which never fits a model itself) -- no scope-fencing
  disclaimer is needed around a `erglm_model(...)` call.

## Final step: cross-article consistency check

After writing or editing one or more articles, skim the others for drift
this change should have introduced but might have missed:

- A sibling article that links to a heading slug you just renamed.
- `erglm.Rmd`'s "Where to next" list, which should stay in sync with the
  actual set of articles and their titles.
- Terminology introduced in one article (bolded on first use) that a later
  article uses without that same bolding or a different word for the same
  concept.
- Typos, doubled words, and stray double-spaces -- easy to introduce while
  editing one article and easy to miss without rereading it alongside its
  neighbours.

Re-render any touched article (pkgdown build, or
`rmarkdown::render()`/knit it directly) and read the actual rendered output,
not just the `.Rmd` source, before considering the edit done -- code chunk
output and cross-reference links are exactly the things that look fine in
source but break silently when rendered. Recall from `AGENTS.md` that a
"lazy-load database ... is corrupt" error during a pkgdown build usually
means the installed copy of erglm is stale, not a problem with the article
itself.

## Checklist before finishing an article

- [ ] Frontmatter is title-only; the article is wired into `_pkgdown.yml`'s
      `articles:` list if new or renamed.
- [ ] Standard `knitr::opts_chunk$set(collapse = TRUE, comment = "#>")`
      chunk and a labelled `setup` chunk (loading `library(erglm)` plus any
      other packages the article's code actually uses) are present.
- [ ] Opening paragraph states the article's purpose, following either the
      quick-tour style (`erglm.Rmd`) or the motivate-the-problem style
      (`scm.Rmd`/`simulate.Rmd`) -- not left as an unfinished placeholder
      like `model.Rmd`'s current text.
- [ ] Cross-article links use the relative `article-name.html` form, never
      the `.Rmd` source or an absolute URL.
- [ ] No package name is bolded in prose; genuinely new terminology is
      bolded on first introduction only.
- [ ] British/Australian spelling used consistently.
- [ ] The article generalises its worked example to other `glm()` families
      in a short closing section, rather than re-demonstrating everything
      per family from scratch.
- [ ] Any visualisation need is handled by pointing to the companion
      `erplots` package, not by building plotting code inline.
- [ ] No agent-facing material in the visible article body.
- [ ] The rendered output (not just the `.Rmd` source) was checked after
      editing, and sibling articles were skimmed for links/terminology that
      now need updating too.
