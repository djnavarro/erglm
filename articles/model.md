# Modelling

This is the modelling article

``` r

library(erlr)
library(tibble)
```

The core function is
[`lr_model()`](https://erlr.djnavarro.net/reference/lr_model.md), a very
thin wrapper around [`glm()`](https://rdrr.io/r/stats/glm.html) that
specifies the family and link function to create a logistic regression.
The package comes with a synthetic data set called `lr_data` that we can
use:

``` r

lr_data
#> # A tibble: 300 × 10
#>       id sex      age weight  dose treatment aucss cmaxss   ae1   ae2
#>    <int> <fct>  <int>  <dbl> <dbl> <fct>     <dbl>  <dbl> <dbl> <dbl>
#>  1     1 Male      35     79   200 Drug       673.   97.3     0     1
#>  2     2 Female    22     58   200 Drug      2806.  301.      1     1
#>  3     3 Female    28     58     0 Placebo      0     0       0     0
#>  4     4 Female    18     57   100 Drug      1169.  198.      1     1
#>  5     5 Male      28     77   100 Drug       377.   51.4     0     0
#>  6     6 Female    19     76   200 Drug       327.   25.4     1     0
#>  7     7 Male      30     70     0 Placebo      0     0       0     0
#>  8     8 Female    34     60   100 Drug      1208.  133.      1     1
#>  9     9 Male      21     89     0 Placebo      0     0       0     0
#> 10    10 Female    34     56   200 Drug       254.   31.0     0     0
#> # ℹ 290 more rows
```

## Fitting models

Creating a model:

``` r

mod <- lr_model(formula = ae1 ~ aucss, data = lr_data)
mod
#> 
#> Call:  stats::glm(formula = formula, family = stats::binomial(link = "logit"), 
#>     data = data)
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

The [`lr_predict()`](https://erlr.djnavarro.net/reference/lr_predict.md)
function produces model predictions:

``` r

pred <- mod |> 
  lr_predict(newdata = tibble(
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
  lr_predict(
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
[`lr_scm_forward()`](https://erlr.djnavarro.net/reference/lr_scm.md) and
[`lr_scm_backward()`](https://erlr.djnavarro.net/reference/lr_scm.md):

``` r

base_mod <- lr_model(formula = ae1 ~ aucss, data = lr_data)
candidates <- c("sex", "dose", "weight", "age")

final_mod <- base_mod |> 
  lr_scm_forward(candidates, threshold = 0.01, seed = 3425) |> 
  lr_scm_backward(candidates, threshold = 0.001, seed = 9821)

final_mod
#> 
#> Call:  stats::glm(formula = formula, family = stats::binomial(link = "logit"), 
#>     data = data)
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
[`lr_scm_history()`](https://erlr.djnavarro.net/reference/lr_scm.md):

``` r

lr_scm_history(final_mod)
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
