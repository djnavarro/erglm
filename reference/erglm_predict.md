# Predictions and confidence intervals for exposure-response models

Computes model-based predictions and confidence intervals on the
response scale, returned as a tidy data frame bound to `newdata`.

## Usage

``` r
erglm_predict(object, newdata = NULL, conf_level = 0.95)
```

## Arguments

- object:

  An erglm model, as returned by
  [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)

- newdata:

  Data frame containing cases to be predicted. Defaults to `NULL`, in
  which case the data the model was originally fitted to (`object$data`)
  is used.

- conf_level:

  Confidence level for the intervals. Defaults to `0.95`.

## Value

A data frame

## Details

Computes intervals on the link scale and back-transforms with
`stats::family(object)$linkinv`, so this works for any
[`glm()`](https://rdrr.io/r/stats/glm.html) family, not just
binomial/logistic models. See also
[`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md) for
generating predictions at arbitrary (possibly counterfactual) parameters
or data. `conf_level` must be a single number between 0 and 1
(inclusive); other values error rather than silently producing a
reversed or `NaN` interval.

This is a tidy, opinionated alternative to calling base R's
[`predict()`](https://rdrr.io/r/stats/predict.html) directly on `object`
– since `object` is a genuine `glm` object,
[`predict()`](https://rdrr.io/r/stats/predict.html) (and
`predict(object, se.fit = TRUE)`, on which this function is based) work
unchanged and remain useful for quick point estimates or when a tidy
data frame isn't needed. See `vignette("methods", package = "erglm")`
for a side-by-side comparison and other inherited `glm`/`lm` methods
([`summary()`](https://rdrr.io/r/base/summary.html),
[`vcov()`](https://rdrr.io/r/stats/vcov.html),
[`AIC()`](https://rdrr.io/r/stats/AIC.html), etc.).

## Examples

``` r
mod <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
prd <- erglm_predict(mod, erglm_data)
head(prd)
#>   id    sex age weight dose treatment   aucss cmaxss ae1 ae2 ae_count
#> 1  1   Male  35     79  200      Drug  673.09  97.33   0   1        1
#> 2  2 Female  22     58  200      Drug 2806.12 300.62   1   1        6
#> 3  3 Female  28     58    0   Placebo    0.00   0.00   0   0        1
#> 4  4 Female  18     57  100      Drug 1169.04 197.78   1   1        0
#> 5  5   Male  28     77  100      Drug  377.29  51.43   0   0        0
#> 6  6 Female  19     76  200      Drug  327.08  25.37   1   0        0
#>   biomarker_change ae_duration     fit_link   se_link  fit_resp   ci_lower
#> 1             1.22       12.40  1.908813271 0.3254704 0.8708858 0.78089730
#> 2             4.87       13.70 13.634778160 1.7087135 0.9999988 0.99996589
#> 3            -1.83        5.26 -1.791383027 0.2555998 0.1429032 0.09175856
#> 4             1.90        6.70  4.635212940 0.6292355 0.9903892 0.96776492
#> 5            -1.01        6.15  0.282703739 0.1949974 0.5702090 0.47514944
#> 6            -4.97       12.83  0.006682915 0.1851779 0.5016707 0.41186543
#>    ci_upper
#> 1 0.9273531
#> 2 1.0000000
#> 3 0.2157823
#> 4 0.9971808
#> 5 0.6603584
#> 6 0.5913683

mod_gauss <- erglm_model(biomarker_change ~ aucss, erglm_data, family = gaussian())
prd_gauss <- erglm_predict(mod_gauss, erglm_data)
head(prd_gauss)
#>   id    sex age weight dose treatment   aucss cmaxss ae1 ae2 ae_count
#> 1  1   Male  35     79  200      Drug  673.09  97.33   0   1        1
#> 2  2 Female  22     58  200      Drug 2806.12 300.62   1   1        6
#> 3  3 Female  28     58    0   Placebo    0.00   0.00   0   0        1
#> 4  4 Female  18     57  100      Drug 1169.04 197.78   1   1        0
#> 5  5   Male  28     77  100      Drug  377.29  51.43   0   0        0
#> 6  6 Female  19     76  200      Drug  327.08  25.37   1   0        0
#>   biomarker_change ae_duration   fit_link    se_link   fit_resp   ci_lower
#> 1             1.22       12.40 -0.4013721 0.08690961 -0.4013721 -0.5717118
#> 2             4.87       13.70  3.5360912 0.21707171  3.5360912  3.1106385
#> 3            -1.83        5.26 -1.6438615 0.11496139 -1.6438615 -1.8691817
#> 4             1.90        6.70  0.5141260 0.09461322  0.5141260  0.3286875
#> 5            -1.01        6.15 -0.9474036 0.09470779 -0.9474036 -1.1330275
#> 6            -4.97       12.83 -1.0400887 0.09683440 -1.0400887 -1.2298806
#>     ci_upper
#> 1 -0.2310324
#> 2  3.9615440
#> 3 -1.4185413
#> 4  0.6995645
#> 5 -0.7617798
#> 6 -0.8502967
```
