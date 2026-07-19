# Predictions and confidence intervals for exposure-response models

Predictions and confidence intervals for exposure-response models

## Usage

``` r
lr_predict(object, newdata = NULL, conf_level = 0.95)
```

## Arguments

- object:

  An erlr model, as returned by
  [`lr_model()`](https://erlr.djnavarro.net/reference/lr_model.md)

- newdata:

  Data frame containing cases to be predicted

- conf_level:

  Confidence level for the intervals

## Value

A tibble

## Details

Computes intervals on the link scale and back-transforms with
`stats::family(object)$linkinv`, so this works for any
[`glm()`](https://rdrr.io/r/stats/glm.html) family, not just
binomial/logistic models.

## Examples

``` r
mod <- lr_model(ae1 ~ aucss, lr_data)
prd <- lr_predict(mod, lr_data)
prd
#> # A tibble: 300 × 18
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
#> # ℹ 7 more variables: biomarker_change <dbl>, ae_duration <dbl>,
#> #   fit_link <dbl>, se_link <dbl>, fit_resp <dbl>, ci_lower <dbl>,
#> #   ci_upper <dbl>

mod_gauss <- lr_model(biomarker_change ~ aucss, lr_data, family = gaussian())
lr_predict(mod_gauss, lr_data)
#> # A tibble: 300 × 18
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
#> # ℹ 7 more variables: biomarker_change <dbl>, ae_duration <dbl>,
#> #   fit_link <dbl>, se_link <dbl>, fit_resp <dbl>, ci_lower <dbl>,
#> #   ci_upper <dbl>
```
