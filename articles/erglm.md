# Getting Started

erglm provides estimation tools for exposure-response models based on
[`glm()`](https://rdrr.io/r/stats/glm.html). It’s mostly a convenience
package: the core tools are thin wrappers around
[`glm()`](https://rdrr.io/r/stats/glm.html) and its usual machinery,
tested and supported for binomial, poisson, gaussian, and gamma
families. This article is a quick tour of the main pieces; the other
articles go into more depth on each.

``` r

library(erglm)
library(tibble)
```

## Example data

The package ships with a synthetic dataset, `erglm_data`, used
throughout the documentation. It has an exposure metric (`aucss`),
several covariates (`sex`, `age`, `weight`, `dose`, …), and response
columns for each supported family: binary (`ae1`, `ae2`), count
(`ae_count`), continuous (`biomarker_change`), and positive right-skewed
continuous (`ae_duration`):

``` r

erglm_data
#> # A tibble: 300 × 13
#>       id sex      age weight  dose treatment aucss cmaxss   ae1   ae2 ae_count
#>    <int> <fct>  <int>  <dbl> <dbl> <fct>     <dbl>  <dbl> <dbl> <dbl>    <int>
#>  1     1 Male      35     79   200 Drug       673.   97.3     0     1        1
#>  2     2 Female    22     58   200 Drug      2806.  301.      1     1        6
#>  3     3 Female    28     58     0 Placebo      0     0       0     0        1
#>  4     4 Female    18     57   100 Drug      1169.  198.      1     1        0
#>  5     5 Male      28     77   100 Drug       377.   51.4     0     0        0
#>  6     6 Female    19     76   200 Drug       327.   25.4     1     0        0
#>  7     7 Male      30     70     0 Placebo      0     0       0     0        0
#>  8     8 Female    34     60   100 Drug      1208.  133.      1     1        1
#>  9     9 Male      21     89     0 Placebo      0     0       0     0        0
#> 10    10 Female    34     56   200 Drug       254.   31.0     0     0        1
#> # ℹ 290 more rows
#> # ℹ 2 more variables: biomarker_change <dbl>, ae_duration <dbl>
```

## Fitting a model

[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
fits the model – it takes the same `formula`/`data` arguments as
[`glm()`](https://rdrr.io/r/stats/glm.html), plus a `family` argument
(defaulting to [`gaussian()`](https://rdrr.io/r/stats/family.html),
matching [`glm()`](https://rdrr.io/r/stats/glm.html)’s own default):

``` r

mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
mod
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss      sexMale  
#>   -1.648112     0.005508    -0.312232  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 192.7     AIC: 198.7
```

## Prediction

[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
produces predictions with confidence intervals, on both the link and
response scales, as a tidy data frame:

``` r

mod |>
  erglm_predict(newdata = tibble(aucss = seq(0, 3000, by = 500), sex = "Female"))
#> # A tibble: 7 × 7
#>   aucss sex    fit_link se_link fit_resp ci_lower ci_upper
#>   <dbl> <chr>     <dbl>   <dbl>    <dbl>    <dbl>    <dbl>
#> 1     0 Female    -1.65   0.301    0.161   0.0964    0.258
#> 2   500 Female     1.11   0.297    0.751   0.628     0.844
#> 3  1000 Female     3.86   0.558    0.979   0.941     0.993
#> 4  1500 Female     6.61   0.871    0.999   0.993     1.000
#> 5  2000 Female     9.37   1.20     1.000   0.999     1.000
#> 6  2500 Female    12.1    1.53     1.000   1.000     1.000
#> 7  3000 Female    14.9    1.86     1.000   1.000     1.000
```

## Choosing covariates

When there are several candidate covariates,
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
and
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
automate the process of deciding which belong in the model, via stepwise
addition/elimination based on significance testing:

``` r

erglm_scm_forward(mod, candidates = c("dose", "weight", "age"), seed = 1024)
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss      sexMale  
#>   -1.648112     0.005508    -0.312232  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 192.7     AIC: 198.7
```

See the [“Stepwise covariate
modelling”](https://erglm.djnavarro.net/articles/scm.md) article for a
full treatment, including the forward/backward workflow and the audit
log
([`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md)).

## Simulation

[`simulate()`](https://rdrr.io/r/stats/simulate.html) generates
replicate datasets from a fitted model, capturing both parameter
uncertainty and observation-level noise:

``` r

simulate(mod, nsim = 5, seed = 2048)
#> # A tibble: 1,500 × 9
#>    dat_id sim_id     mu   val `coef_(Intercept)` coef_aucss coef_sexMale aucss
#>     <int>  <int>  <dbl> <int>              <dbl>      <dbl>        <dbl> <dbl>
#>  1      1      1 0.841      0              -1.86    0.00577       -0.361  673.
#>  2      2      1 1.000      1              -1.86    0.00577       -0.361 2806.
#>  3      3      1 0.135      0              -1.86    0.00577       -0.361    0 
#>  4      4      1 0.993      1              -1.86    0.00577       -0.361 1169.
#>  5      5      1 0.489      1              -1.86    0.00577       -0.361  377.
#>  6      6      1 0.507      1              -1.86    0.00577       -0.361  327.
#>  7      7      1 0.0980     0              -1.86    0.00577       -0.361    0 
#>  8      8      1 0.994      1              -1.86    0.00577       -0.361 1208.
#>  9      9      1 0.0980     0              -1.86    0.00577       -0.361    0 
#> 10     10      1 0.402      1              -1.86    0.00577       -0.361  254.
#> # ℹ 1,490 more rows
#> # ℹ 1 more variable: sex <fct>
```

See the [“Simulation”](https://erglm.djnavarro.net/articles/simulate.md)
article for details, including the lower-level
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)
building block.

## Working with fitted models

An object returned by
[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
is a genuine `glm` object – it has class `c("erglm_model", "glm", "lm")`
– so all of the standard `glm`/`lm` methods
([`summary()`](https://rdrr.io/r/base/summary.html),
[`predict()`](https://rdrr.io/r/stats/predict.html),
[`confint()`](https://rdrr.io/r/stats/confint.html),
[`AIC()`](https://rdrr.io/r/stats/AIC.html),
[`anova()`](https://rdrr.io/r/stats/anova.html), and so on) work on it
directly, with no erglm-specific replacement needed. See the [“Using
base R model methods”](https://erglm.djnavarro.net/articles/methods.md)
article for a worked-through tour of these.

## Where to next

- [“Modelling”](https://erglm.djnavarro.net/articles/model.md) – more on
  fitting and prediction, including the other
  [`glm()`](https://rdrr.io/r/stats/glm.html) families erglm supports.
- [“Stepwise covariate
  modelling”](https://erglm.djnavarro.net/articles/scm.md) – the
  forward/backward SCM workflow in full.
- [“Using base R model
  methods”](https://erglm.djnavarro.net/articles/methods.md) – the
  `glm`/`lm` methods that come for free.
- [“Simulation”](https://erglm.djnavarro.net/articles/simulate.md) –
  [`simulate()`](https://rdrr.io/r/stats/simulate.html) and
  [`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md).
- the companion [erplots](https://github.com/djnavarro/erplots) package,
  for visualising exposure-response models fitted with erglm.
