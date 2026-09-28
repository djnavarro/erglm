# Stepwise covariate modelling for exposure-response models

Automates the search for which covariates belong in an exposure-response
model: `erglm_scm_forward()` greedily adds candidate terms,
`erglm_scm_backward()` greedily removes them, and `erglm_scm_history()`
retrieves the audit log of every model considered along the way.

## Usage

``` r
erglm_scm_forward(
  mod,
  candidates,
  threshold = 0.01,
  criterion = "p-value",
  test = c("auto", "Chisq", "F"),
  seed = NULL
)

erglm_scm_backward(
  mod,
  candidates,
  threshold = 0.001,
  criterion = "p-value",
  test = c("auto", "Chisq", "F"),
  seed = NULL
)

erglm_scm_history(mod)
```

## Arguments

- mod:

  An erglm model object

- candidates:

  Character vector with list of candidate terms

- threshold:

  Threshold to test against. Used only when `criterion = "p-value"` (the
  default); ignored otherwise. Defaults to `0.01` for
  `erglm_scm_forward()` and `0.001` for `erglm_scm_backward()`.

- criterion:

  Model selection criterion. One of `"p-value"` (default), `"aic"`, or
  `"bic"`.

- test:

  Which significance test to use when comparing nested models. Only used
  when `criterion = "p-value"`. `"auto"` (the default) picks a
  likelihood-ratio chi-squared test (`"Chisq"`) for families with known
  dispersion (binomial, poisson) and an F-test (`"F"`) for families with
  an estimated dispersion parameter (gaussian, gamma, inverse.gaussian,
  quasi\*), matching
  [`stats::anova()`](https://rdrr.io/r/stats/anova.html)'s own `test`
  argument. Set explicitly to override.

- seed:

  Optional seed controlling the order candidate terms are tested in
  within a step. Defaults to `NULL`, in which case one is chosen
  automatically and used silently – unlike
  [`simulate.erglm_model()`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md)'s
  auto-picked seed, it is not reported, since (per Details below) it
  essentially never changes the result.

## Value

For `erglm_scm_forward()` and `erglm_scm_backward()`, the updated erglm
model is returned, with the SCM history log updated internally. For
`erglm_scm_history()`, a data frame is returned containing the SCM
history log

## Reproducibility and the seed argument

`seed` exists as a safety measure against two hypothetical sources of
run-to-run variation: (a) the order in which candidate terms are tested
within a step, and (b) some part of the model-fitting machinery secretly
depending on `.Random.seed`. As currently implemented, only (a) is real,
and even then its effect is usually invisible. Concretely: each step of
`erglm_scm_forward()`/ `erglm_scm_backward()` shuffles the candidate
terms ([`sample()`](https://rdrr.io/r/base/sample.html)) before testing
them one at a time, and the shuffled order is the *only* thing `seed`
(via
[`withr::with_seed()`](https://withr.r-lib.org/reference/with_seed.html))
controls. Term p-values come from
[`stats::anova()`](https://rdrr.io/r/stats/anova.html) on models fitted
with [`stats::glm()`](https://rdrr.io/r/stats/glm.html), which is a
deterministic algorithm (iteratively reweighted least squares, no random
starting values) – so which candidate is *found* to be best does not
depend on the seed. The seed can only change which candidate is
*selected* in the (rare, essentially measure-zero for continuous
predictors) case of an exact tie in p-values within a step, since ties
are broken by encounter order (`p_val < lowest_p`/ `p_val > highest_p`
are strict inequalities in the internal
`.erglm_once_forward()`/`.erglm_once_backward()` helpers). In short: for
typical data, `seed` is redundant for reproducibility of the *result*
(though it still affects the row order of the intermediate attempts
recorded in `erglm_scm_history()`) – it's retained mainly as a guard
against future refactors reintroducing genuine seed-sensitivity (e.g. if
candidate order were ever used as an early-stopping rule rather than
exhaustively tested every step).

## Aliased or collinear candidates

If a candidate term is aliased (perfectly collinear) with a term already
in the model, [`stats::anova()`](https://rdrr.io/r/stats/anova.html)
reports zero additional degrees of freedom and an `NA` p-value for it.
That candidate is skipped for the step (with a warning) rather than
being selected or crashing the search – comparisons against `NA` aren't
meaningful, and the candidate can never improve the fit anyway once it's
aliased.

## Selection criteria

Three model selection criteria are available via the `criterion`
argument:

- `"p-value"` (default): Models are compared with the significance test
  named by `test`. A term is added if its p-value falls below
  `threshold` (forward) or removed if its p-value exceeds `threshold`
  (backward). When multiple candidates satisfy the threshold within a
  step, the one with the most extreme p-value is chosen.

- `"aic"`: A term is added (forward) or removed (backward) if doing so
  strictly decreases AIC relative to the current model. When multiple
  candidates improve AIC, the one yielding the lowest AIC is chosen.

- `"bic"`: Same as `"aic"`, but using BIC as the criterion.

When `criterion` is `"aic"` or `"bic"`, the `threshold` and `test`
arguments have no effect, and `term_p_value` is left `NA` in the history
for every candidate tested that step (the significance test isn't
computed, since it plays no role in selection). The `model_aic` and
`model_bic` columns are always recorded regardless of which criterion
drove selection, and the history's `criterion` column records which one
was used for each forward/backward step.

## Candidate validation

`candidates` is validated up front: every element must be parseable as a
formula and name exactly one covariate term (e.g. `"sex"`, not
`"sex + dose"` or `"not a formula"`). This errors immediately, before
any model fitting, naming the offending element – rather than surfacing
only once the search happens to test that candidate, many steps into
what might be a long, expensive search.

## Examples

``` r
mod0 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
mod1 <- erglm_scm_forward(mod0, candidates = c("sex", "dose"))
erglm_scm_history(mod1)
#> # A tibble: 3 × 12
#>   iteration attempt step       criterion action term_tested model_tested      
#>       <int>   <int> <chr>      <chr>     <chr>  <chr>       <chr>             
#> 1         0       0 base model NA        NA     NA          ae1 ~ aucss       
#> 2         1       1 forward    p-value   add    ~sex        ae1 ~ aucss + sex 
#> 3         1       2 forward    p-value   add    ~dose       ae1 ~ aucss + dose
#> # ℹ 5 more variables: model_converged <lgl>, term_p_value <dbl>,
#> #   model_aic <dbl>, model_bic <dbl>, model_updated <int>

mod2 <- erglm_model(ae1 ~ aucss + sex + dose, erglm_data, family = binomial())
mod3 <- erglm_scm_backward(mod2, candidates = c("sex", "dose"))
erglm_scm_history(mod3)
#> # A tibble: 4 × 12
#>   iteration attempt step       criterion action term_tested model_tested        
#>       <int>   <int> <chr>      <chr>     <chr>  <chr>       <chr>               
#> 1         0       0 base model NA        NA     NA          ae1 ~ aucss + sex +…
#> 2         1       1 backward   p-value   remove ~dose       ae1 ~ aucss + sex   
#> 3         1       2 backward   p-value   remove ~sex        ae1 ~ aucss + dose  
#> 4         2       3 backward   p-value   remove ~sex        ae1 ~ aucss         
#> # ℹ 5 more variables: model_converged <lgl>, term_p_value <dbl>,
#> #   model_aic <dbl>, model_bic <dbl>, model_updated <int>

# AIC-based forward addition/backward elimination instead of p-value
mod4 <- erglm_scm_forward(mod0, candidates = c("sex", "dose"), criterion = "aic")
mod5 <- erglm_scm_backward(mod4, candidates = c("sex", "dose"), criterion = "bic")
erglm_scm_history(mod5)
#> # A tibble: 3 × 12
#>   iteration attempt step       criterion action term_tested model_tested      
#>       <int>   <int> <chr>      <chr>     <chr>  <chr>       <chr>             
#> 1         0       0 base model NA        NA     NA          ae1 ~ aucss       
#> 2         1       1 forward    aic       add    ~dose       ae1 ~ aucss + dose
#> 3         1       2 forward    aic       add    ~sex        ae1 ~ aucss + sex 
#> # ℹ 5 more variables: model_converged <lgl>, term_p_value <dbl>,
#> #   model_aic <dbl>, model_bic <dbl>, model_updated <int>
```
