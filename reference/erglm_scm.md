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

## Examples

``` r
mod0 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
mod1 <- erglm_scm_forward(mod0, candidates = c("sex", "dose"))
#> Using seed = 6292
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
#> Using seed = 6526
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
