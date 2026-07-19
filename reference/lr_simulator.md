# Simulate from an exposure-response model

Simulate from an exposure-response model

## Usage

``` r
lr_simulator(object)
```

## Arguments

- object:

  An erlr model, as returned by
  [`lr_model()`](https://erlr.djnavarro.net/reference/lr_model.md)

## Value

A function with arguments `param`, `data`, and `type`.

- The `param` argument should be a vector of coefficients

- The `data` argument should be a data frame or tibble

- The `type` argument should be a string indicating the type of
  prediction to generate (defaults to `"response"`)

Takes a fitted glm object as input and returns a function that will
evaluate the underlying structural model with user-specified parameters
or data (e.g., for VPCs or other counterfactual simulation scenarios).
Uses `stats::family(object)$linkinv`, so this works for any
[`glm()`](https://rdrr.io/r/stats/glm.html) family, not just
binomial/logistic models; tested for binomial, poisson, gaussian, and
Gamma families.

## Examples

``` r
mod1 <- lr_model(ae2 ~ aucss + sex, lr_data)
par1 <- coef(mod1)
mod1_sim <- lr_simulator(mod1)

# no counterfactuals
p1 <- mod1_sim(param = par1, data = lr_data) 
p2 <- unname(predict(mod1, type = "response")) # same result

# user modifies the data set
lr_data2 <- lr_data[1:20, ]
p3 <- mod1_sim(param = par1, data = lr_data2) 
p4 <- unname(predict(mod1, newdata = lr_data2, type = "response")) # same result

# user modifies the parameters
par2 <- par1
int1 <- par1["(Intercept)"]
par2["(Intercept)"] <- 0
p5 <- mod1_sim(param = par2, data = lr_data)
```
