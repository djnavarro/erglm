# Modelling

``` r

library(erglm)
```

Fitting a model and turning it into predictions are the two most basic
tasks in erglm – every other tool in the package (stepwise covariate
selection, simulation) builds on
[`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
and
[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md).
The [“Getting Started”](https://erglm.djnavarro.net/articles/erglm.md)
article gives a quick tour of both; this article goes into more depth,
including how each one generalises unchanged across the other
[`glm()`](https://rdrr.io/r/stats/glm.html) families erglm supports.

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
  erglm_predict(newdata = data.frame(
    aucss = seq(from = 0, to = 1500, by = 100)
  ))
pred
#>    aucss   fit_link   se_link  fit_resp   ci_lower  ci_upper
#> 1      0 -1.7913830 0.2555998 0.1429032 0.09175856 0.2157823
#> 2    100 -1.2416503 0.2136687 0.2241489 0.15970386 0.3051553
#> 3    200 -0.6919175 0.1869474 0.3336067 0.25762916 0.4193342
#> 4    300 -0.1421847 0.1822536 0.4645136 0.37768282 0.5535503
#> 5    400  0.4075481 0.2011352 0.6004998 0.50333251 0.6903521
#> 6    500  0.9572808 0.2380470 0.7225770 0.62027537 0.8059404
#> 7    600  1.5070136 0.2860933 0.8186182 0.72036663 0.8877285
#> 8    700  2.0567464 0.3405942 0.8866275 0.80046354 0.9384453
#> 9    800  2.6064791 0.3989127 0.9312774 0.86112011 0.9673379
#> 10   900  3.1562119 0.4595980 0.9591528 0.90511671 0.9829935
#> 11  1000  3.7059447 0.5218250 0.9760125 0.93602720 0.9912395
#> 12  1100  4.2556774 0.5851019 0.9860149 0.95725832 0.9955147
#> 13  1200  4.8054102 0.6491219 0.9918811 0.97161654 0.9977117
#> 14  1300  5.3551430 0.7136849 0.9952984 0.98122630 0.9988351
#> 15  1400  5.9048757 0.7786560 0.9972813 0.98761416 0.9994078
#> 16  1500  6.4546085 0.8439408 0.9984292 0.99184160 0.9996992
```

`pred` reports both the link-scale (`fit_link`) and response-scale
(`fit_resp`) predictions. If you need to move between these two scales
yourself – e.g. to transform a raw response-scale value onto the link
scale –
[`erglm_link()`](https://erglm.djnavarro.net/reference/erglm_link.md)
and
[`erglm_invlink()`](https://erglm.djnavarro.net/reference/erglm_link.md)
extract the relevant functions straight from the model’s
[`glm()`](https://rdrr.io/r/stats/glm.html) family:

``` r

erglm_link(mod)(0.5)    # response scale -> link scale
#> [1] 0
erglm_invlink(mod)(0)   # link scale -> response scale
#> [1] 0.5
```

The confidence level can be adjusted using the `conf_level` argument

``` r

pred <- mod |> 
  erglm_predict(
    newdata = data.frame(aucss = seq(from = 0, to = 1500, by = 100)), 
    conf_level = 0.8 
  )
pred
#>    aucss   fit_link   se_link  fit_resp  ci_lower  ci_upper
#> 1      0 -1.7913830 0.2555998 0.1429032 0.1072688 0.1878840
#> 2    100 -1.2416503 0.2136687 0.2241489 0.1801284 0.2753147
#> 3    200 -0.6919175 0.1869474 0.3336067 0.2826204 0.3888058
#> 4    300 -0.1421847 0.1822536 0.4645136 0.4071519 0.5228298
#> 5    400  0.4075481 0.2011352 0.6004998 0.5373759 0.6604529
#> 6    500  0.9572808 0.2380470 0.7225770 0.6575086 0.7794304
#> 7    600  1.5070136 0.2860933 0.8186182 0.7577476 0.8668809
#> 8    700  2.0567464 0.3405942 0.8866275 0.8348306 0.9236662
#> 9    800  2.6064791 0.3989127 0.9312774 0.8904408 0.9576172
#> 10   900  3.1562119 0.4595980 0.9591528 0.9287214 0.9769149
#> 11  1000  3.7059447 0.5218250 0.9760125 0.9542266 0.9875645
#> 12  1100  4.2556774 0.5851019 0.9860149 0.9708535 0.9933437
#> 13  1200  4.8054102 0.6491219 0.9918811 0.9815402 0.9964501
#> 14  1300  5.3551430 0.7136849 0.9952984 0.9883476 0.9981109
#> 15  1400  5.9048757 0.7786560 0.9972813 0.9926596 0.9989960
#> 16  1500  6.4546085 0.8439408 0.9984292 0.9953815 0.9994668
```

Choosing which covariates belong in the model – stepwise covariate
modelling with
[`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)/[`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
– is covered in its own article, “Stepwise covariate modelling”.

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
#>   -0.930026     0.001053    -0.172637  
#> 
#> Degrees of Freedom: 299 Total (i.e. Null);  297 Residual
#> Null Deviance:       868.8 
#> Residual Deviance: 272.4     AIC: 712.6
```

[`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
and [`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md)
work unchanged, since both operate on the link scale generically via
`stats::family(object)$linkinv`:

``` r

mod_pois |> 
  erglm_predict(newdata = data.frame(aucss = seq(0, 3000, by = 500), sex = "Female"))
#>   aucss    sex   fit_link    se_link  fit_resp  ci_lower   ci_upper
#> 1     0 Female -0.9300263 0.10377160 0.3945433 0.3219320  0.4835321
#> 2   500 Female -0.4035030 0.08880099 0.6679760 0.5612719  0.7949657
#> 3  1000 Female  0.1230202 0.07687139 1.1309072 0.9727336  1.3148010
#> 4  1500 Female  0.6495434 0.06956528 1.9146664 1.6706252  2.1943565
#> 5  2000 Female  1.1760666 0.06838105 3.2415986 2.8350008  3.7065110
#> 6  2500 Female  1.7025898 0.07361474 5.4881424 4.7507742  6.3399576
#> 7  3000 Female  2.2291131 0.08407625 9.2916213 7.8799901 10.9561338
```

Stepwise covariate modelling also generalises across families – see the
“Stepwise covariate modelling” article for details.
