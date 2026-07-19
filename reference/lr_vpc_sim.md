# VPC simulations for logistic regression models

VPC simulations for logistic regression models

## Usage

``` r
lr_vpc_sim(object, nsim = 100, seed = NULL)
```

## Arguments

- object:

  Logistic regression model

- nsim:

  Number of replicates

- seed:

  RNG state

## Value

A data frame or tibble. Contains one row per observation per simulated
replicate (identified by the `sim_id` column), with the response
variable replaced by its simulated value under parameter uncertainty.

## Details

To visualise the result (e.g. as a VPC-style plot comparing observed and
simulated response rates), see
[`erplots::er_vpc_plot()`](https://rdrr.io/pkg/erplots/man/er_vpc_plot.html).

## Examples

``` r
mod <- lr_model(ae2 ~ aucss + sex, lr_data)
sim <- lr_vpc_sim(mod)
#> Using seed = 7603
sim
#> # A tibble: 30,000 × 5
#>       ae2 aucss sex    row_id sim_id
#>     <dbl> <dbl> <fct>   <int>  <int>
#>  1 0.293   673. Male        1      1
#>  2 0.990  2806. Female      2      1
#>  3 0.124     0  Female      3      1
#>  4 0.680  1169. Female      4      1
#>  5 0.173   377. Male        5      1
#>  6 0.232   327. Female      6      1
#>  7 0.0801    0  Male        7      1
#>  8 0.700  1208. Female      8      1
#>  9 0.0801    0  Male        9      1
#> 10 0.203   254. Female     10      1
#> # ℹ 29,990 more rows
```
