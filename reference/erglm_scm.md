# Stepwise covariate modelling for exposure-response models

Stepwise covariate modelling for exposure-response models

## Usage

``` r
erglm_scm_forward(
  mod,
  candidates,
  threshold = 0.01,
  test = c("auto", "Chisq", "F"),
  seed = NULL
)

erglm_scm_backward(
  mod,
  candidates,
  threshold = 0.001,
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

  Threshold to test against

- test:

  Which significance test to use when comparing nested models. `"auto"`
  (the default) picks a likelihood-ratio chi-squared test (`"Chisq"`)
  for families with known dispersion (binomial, poisson) and an F-test
  (`"F"`) for families with an estimated dispersion parameter (gaussian,
  Gamma, inverse.gaussian, quasi\*), matching
  [`stats::anova()`](https://rdrr.io/r/stats/anova.html)'s own `test`
  argument. Set explicitly to override.

- seed:

  Optional seed to control order of term tests

## Value

For `erglm_scm_forward()` and `erglm_scm_backward()`, the updated erglm
model is returned, with the SCM history log updated internally. For
`erglm_scm_history()`, a data frame is returned containing the SCM
history log

## Details

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

## Examples

``` r
mod0 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
mod1 <- erglm_scm_forward(mod0, candidates = c("sex", "dose"))
erglm_scm_history(mod1)
#> # A tibble: 3 × 11
#>   iteration attempt step       action term_tested model_tested   model_converged
#>       <int>   <int> <chr>      <chr>  <chr>       <chr>          <lgl>          
#> 1         0       0 base model NA     NA          ae1 ~ aucss    TRUE           
#> 2         1       1 forward    add    ~sex        ae1 ~ aucss +… TRUE           
#> 3         1       2 forward    add    ~dose       ae1 ~ aucss +… TRUE           
#> # ℹ 4 more variables: term_p_value <dbl>, model_aic <dbl>, model_bic <dbl>,
#> #   model_updated <int>

mod2 <- erglm_model(ae1 ~ aucss + sex + dose, erglm_data, family = binomial())
mod3 <- erglm_scm_backward(mod2, candidates = c("sex", "dose"))
erglm_scm_history(mod3)
#> # A tibble: 4 × 11
#>   iteration attempt step       action term_tested model_tested   model_converged
#>       <int>   <int> <chr>      <chr>  <chr>       <chr>          <lgl>          
#> 1         0       0 base model NA     NA          ae1 ~ aucss +… TRUE           
#> 2         1       1 backward   remove ~dose       ae1 ~ aucss +… TRUE           
#> 3         1       2 backward   remove ~sex        ae1 ~ aucss +… TRUE           
#> 4         2       3 backward   remove ~sex        ae1 ~ aucss    TRUE           
#> # ℹ 4 more variables: term_p_value <dbl>, model_aic <dbl>, model_bic <dbl>,
#> #   model_updated <int>
```
