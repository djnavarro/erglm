# Sample simulated data for exposure-response models with covariates

A synthetic dataset bundled with the package and used throughout its
documentation and examples, with response columns illustrating each of
erglm's supported [`glm()`](https://rdrr.io/r/stats/glm.html) families.

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

This simulated dataset is entirely synthetic. See the package source for
the data-generating code.

## Examples

``` r
head(erglm_data)
#>   id    sex age weight dose treatment   aucss cmaxss ae1 ae2 ae_count
#> 1  1   Male  35     79  200      Drug  673.09  97.33   0   1        1
#> 2  2 Female  22     58  200      Drug 2806.12 300.62   1   1        6
#> 3  3 Female  28     58    0   Placebo    0.00   0.00   0   0        1
#> 4  4 Female  18     57  100      Drug 1169.04 197.78   1   1        0
#> 5  5   Male  28     77  100      Drug  377.29  51.43   0   0        0
#> 6  6 Female  19     76  200      Drug  327.08  25.37   1   0        0
#>   biomarker_change ae_duration
#> 1             1.22       12.40
#> 2             4.87       13.70
#> 3            -1.83        5.26
#> 4             1.90        6.70
#> 5            -1.01        6.15
#> 6            -4.97       12.83
```
