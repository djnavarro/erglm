# Sample simulated data for exposure-response models with covariates

Sample simulated data for exposure-response models with covariates

## Usage

``` r
erglm_data
```

## Format

A data frame with columns:

- id:

  Identifier

- sex:

  Sex

- age:

  Age

- weight:

  Weight

- dose:

  Nominal dose, units not specified

- treatment:

  Treatment

- aucss:

  AUCss

- cmaxss:

  Cmax,ss

- ae1:

  Binary response 1 value (for binomial models)

- ae2:

  Binary response 2 value (for binomial models)

- ae_count:

  Count response (for poisson models)

- biomarker_change:

  Continuous response, can be negative (for gaussian models)

- ae_duration:

  Continuous, strictly positive, right-skewed response (for gamma
  models)

## Details

This simulated dataset is entirely synthetic You can find the data
generating code in the package source code

## Examples

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
