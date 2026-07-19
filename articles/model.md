# Modelling

This is the modelling article

``` r

library(erglm)
library(tibble)
```

The core function is
[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md),
a very thin wrapper around [`glm()`](https://rdrr.io/r/stats/glm.html).
By default it fits a gaussian model (`family = gaussian()`, matching
[`glm()`](https://rdrr.io/r/stats/glm.html)’s own default), but any
[`glm()`](https://rdrr.io/r/stats/glm.html) family can be supplied
explicitly – `binomial`, `poisson`, and `Gamma` are also tested and
supported. The package comes with a synthetic data set called
`erglm_data` that we can use:

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

## Fitting models

Creating a model:

``` r

mod <- erglm_model(formula = ae1 ~ aucss, data = erglm_data, family = binomial())
mod
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss  
#>   -1.791383     0.005497  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  298 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 193.4     AIC: 197.4
```

## Prediction

The
[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
function produces model predictions:

``` r

pred <- mod |> 
  erglm_predict(newdata = tibble(
    aucss = seq(from = 0, to = 1500, by = 100)
  ))
pred
#> # A tibble: 16 × 6
#>    aucss fit_link se_link fit_resp ci_lower ci_upper
#>    <dbl>    <dbl>   <dbl>    <dbl>    <dbl>    <dbl>
#>  1     0   -1.79    0.256    0.143   0.0918    0.216
#>  2   100   -1.24    0.214    0.224   0.160     0.305
#>  3   200   -0.692   0.187    0.334   0.258     0.419
#>  4   300   -0.142   0.182    0.465   0.378     0.554
#>  5   400    0.408   0.201    0.600   0.503     0.690
#>  6   500    0.957   0.238    0.723   0.620     0.806
#>  7   600    1.51    0.286    0.819   0.720     0.888
#>  8   700    2.06    0.341    0.887   0.800     0.938
#>  9   800    2.61    0.399    0.931   0.861     0.967
#> 10   900    3.16    0.460    0.959   0.905     0.983
#> 11  1000    3.71    0.522    0.976   0.936     0.991
#> 12  1100    4.26    0.585    0.986   0.957     0.996
#> 13  1200    4.81    0.649    0.992   0.972     0.998
#> 14  1300    5.36    0.714    0.995   0.981     0.999
#> 15  1400    5.90    0.779    0.997   0.988     0.999
#> 16  1500    6.45    0.844    0.998   0.992     1.000
```

The confidence level can be adjusted using the `conf_level` argument

``` r

pred <- mod |> 
  erglm_predict(
    newdata = tibble(aucss = seq(from = 0, to = 1500, by = 100)), 
    conf_level = 0.8 
  )
pred
#> # A tibble: 16 × 6
#>    aucss fit_link se_link fit_resp ci_lower ci_upper
#>    <dbl>    <dbl>   <dbl>    <dbl>    <dbl>    <dbl>
#>  1     0   -1.79    0.256    0.143    0.107    0.188
#>  2   100   -1.24    0.214    0.224    0.180    0.275
#>  3   200   -0.692   0.187    0.334    0.283    0.389
#>  4   300   -0.142   0.182    0.465    0.407    0.523
#>  5   400    0.408   0.201    0.600    0.537    0.660
#>  6   500    0.957   0.238    0.723    0.658    0.779
#>  7   600    1.51    0.286    0.819    0.758    0.867
#>  8   700    2.06    0.341    0.887    0.835    0.924
#>  9   800    2.61    0.399    0.931    0.890    0.958
#> 10   900    3.16    0.460    0.959    0.929    0.977
#> 11  1000    3.71    0.522    0.976    0.954    0.988
#> 12  1100    4.26    0.585    0.986    0.971    0.993
#> 13  1200    4.81    0.649    0.992    0.982    0.996
#> 14  1300    5.36    0.714    0.995    0.988    0.998
#> 15  1400    5.90    0.779    0.997    0.993    0.999
#> 16  1500    6.45    0.844    0.998    0.995    0.999
```

## Stepwise covariate modelling

There are two functions that control SCM regression,
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
and
[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md):

``` r

base_mod <- erglm_model(formula = ae1 ~ aucss, data = erglm_data, family = binomial())
candidates <- c("sex", "dose", "weight", "age")

final_mod <- base_mod |> 
  erglm_scm_forward(candidates, threshold = 0.01, seed = 3425) |> 
  erglm_scm_backward(candidates, threshold = 0.001, seed = 9821)

final_mod
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss  
#>   -1.791383     0.005497  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  298 Residual
#> Null Deviance:       402.1 
#> Residual Deviance: 193.4     AIC: 197.4
```

To extract the log, use
[`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md):

``` r

erglm_scm_history(final_mod)
#> # A tibble: 5 × 11
#>   iteration attempt step       action term_tested model_tested   model_converged
#>       <int>   <int> <chr>      <chr>  <chr>       <chr>          <lgl>          
#> 1         0       0 base model NA     NA          ae1 ~ aucss    TRUE           
#> 2         1       1 forward    add    ~sex        ae1 ~ aucss +… TRUE           
#> 3         1       2 forward    add    ~weight     ae1 ~ aucss +… TRUE           
#> 4         1       3 forward    add    ~age        ae1 ~ aucss +… TRUE           
#> 5         1       4 forward    add    ~dose       ae1 ~ aucss +… TRUE           
#> # ℹ 4 more variables: term_p_value <dbl>, model_aic <dbl>, model_bic <dbl>,
#> #   model_updated <int>
```

## Other `glm()` families

`erglm_data` also includes a count response (`ae_count`), a continuous
response (`biomarker_change`), and a right-skewed positive continuous
response (`ae_duration`), for demonstrating `poisson`, `gaussian`, and
`Gamma` models respectively:

``` r

mod_pois <- erglm_model(ae_count ~ aucss + sex, erglm_data, family = poisson())
mod_pois
#> 
#> Call:  stats::glm(formula = formula, family = family, data = data)
#> 
#> Coefficients:
#> (Intercept)        aucss      sexMale  
#>   -0.930026     0.001053    -0.172638  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       868.8 
#> Residual Deviance: 272.4     AIC: 712.6
```

[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
and
[`erglm_simulator()`](https://erglm.djnavarro.net/reference/erglm_simulator.md)
work unchanged, since both operate on the link scale generically via
`stats::family(object)$linkinv`:

``` r

mod_pois |> 
  erglm_predict(newdata = tibble(aucss = seq(0, 3000, by = 500), sex = "Female"))
#> # A tibble: 7 × 7
#>   aucss sex    fit_link se_link fit_resp ci_lower ci_upper
#>   <dbl> <chr>     <dbl>   <dbl>    <dbl>    <dbl>    <dbl>
#> 1     0 Female   -0.930  0.104     0.395    0.322    0.484
#> 2   500 Female   -0.404  0.0888    0.668    0.561    0.795
#> 3  1000 Female    0.123  0.0769    1.13     0.973    1.31 
#> 4  1500 Female    0.650  0.0696    1.91     1.67     2.19 
#> 5  2000 Female    1.18   0.0684    3.24     2.84     3.71 
#> 6  2500 Female    1.70   0.0736    5.49     4.75     6.34 
#> 7  3000 Female    2.23   0.0841    9.29     7.88    11.0
```

Stepwise covariate modelling also generalises: by default
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
pick a likelihood-ratio chi-squared test for `poisson` (as here) and
`binomial` models, and an F-test for `gaussian`/`Gamma` models, matching
[`stats::anova()`](https://rdrr.io/r/stats/anova.html)’s own `test`
argument. This can be overridden with the `test` argument if needed.
