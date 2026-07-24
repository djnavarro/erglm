# Package index

## Build

Build exposure-response models based on glm()

- [`erglm_model()`](https://erglm.djnavarro.net/reference/erglm_model.md)
  :

  Fit an exposure-response model based on
  [`glm()`](https://rdrr.io/r/stats/glm.html)

- [`erglm_predict()`](https://erglm.djnavarro.net/reference/erglm_predict.md)
  : Predictions and confidence intervals for exposure-response models

## Covariate selection

Stepwise covariate modelling for exposure-response models

- [`erglm_scm_forward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
  [`erglm_scm_backward()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
  [`erglm_scm_history()`](https://erglm.djnavarro.net/reference/erglm_scm.md)
  : Stepwise covariate modelling for exposure-response models
- [`erglm_add_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
  [`erglm_remove_term()`](https://erglm.djnavarro.net/reference/erglm_term.md)
  : Add or remove a covariate term from an exposure-response model

## Simulate

Simulation tools for exposure-response glm() models

- [`erglm_fun()`](https://erglm.djnavarro.net/reference/erglm_fun.md) :
  Prediction function for an exposure-response model
- [`simulate(`*`<erglm_model>`*`)`](https://erglm.djnavarro.net/reference/simulate.erglm_model.md)
  : Simulate responses from an exposure-response model

## Other

Other functions and objects

- [`erglm_data`](https://erglm.djnavarro.net/reference/erglm_data.md) :
  Sample simulated data for exposure-response models with covariates
- [`erglm_link()`](https://erglm.djnavarro.net/reference/erglm_link.md)
  [`erglm_invlink()`](https://erglm.djnavarro.net/reference/erglm_link.md)
  : Link and inverse-link functions for a fitted model
