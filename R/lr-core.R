

#' Fit a logistic regression function
#'
#' @param formula Model formula
#' @param data Data set
#' @param ... Other arguments passed to `glm()`
#' @returns A glm object
#' @export
#' @examples
#' mod <- lr_model(ae1 ~ aucss, lr_data)
#' mod
#' 
lr_model <- function(formula, data, ...) {
  mod <- stats::glm(formula = formula, data = data, family = stats::binomial(link = "logit"), ...)
  .as_erlr(mod)
}

# extract model predictions and confidence intervals for a new data set.
# should work for any glm, not just logistic. adapted from:
# https://fromthebottomoftheheap.net/2018/12/10/confidence-intervals-for-glms/

#' Predictions and confidence intervals for logistic regression
#'
#' @param object A logistic regression model
#' @param newdata Data frame containing cases to be predicted
#' @param conf_level Confidence level for the intervals
#' @returns A tibble
#'
#' @export
#' @examples
#' mod <- lr_model(ae1 ~ aucss, lr_data)
#' prd <- lr_predict(mod, lr_data)
#' prd
#' 
lr_predict <- function(object, newdata = NULL, conf_level = .95) {
  if (is.null(newdata)) newdata <- object$data
  inverse_link <- stats::family(object)$linkinv
  z_scale <- -stats::qnorm((1 - conf_level)/2)
  out <- newdata |> 
    dplyr::bind_cols(
      stats::setNames(
        tibble::as_tibble(stats::predict(object, newdata, se.fit = TRUE, type = "link")[1:2]),
        c('fit_link','se_link')
      )
    ) |> 
    dplyr::mutate(
      fit_resp = inverse_link(fit_link),
      ci_lower = inverse_link(fit_link - (z_scale * se_link)),
      ci_upper = inverse_link(fit_link + (z_scale * se_link)),
    )
  return(out)
}

#' Simulate from a logistic regression model
#'
#' @param object A logistic regression model
#'
#' @returns A function with arguments `param`, `data`, and `type`.
#' - The `param` argument should be a vector of coefficients
#' - The `data` argument should be a data frame or tibble
#' - The `type` argument should be a string indicating the type
#'   of prediction to generate (defaults to `"response"`)
#'
#' Takes a fitted glm object as input and returns a function
#' that will evaluate the underlying structural model with
#' user-specified parameters or data (e.g., for VPCs or
#' other counterfactual simulation scenarios). In principle
#' this should work for glms more generally, not merely 
#' logistic regressions, but has not been tested except for
#' logistic regression models
#'  
#' @examples
#' mod1 <- lr_model(ae2 ~ aucss + sex, lr_data)
#' par1 <- coef(mod1)
#' mod1_sim <- lr_simulator(mod1)
#' 
#' # no counterfactuals
#' p1 <- mod1_sim(param = par1, data = lr_data) 
#' p2 <- unname(predict(mod1, type = "response")) # same result
#' 
#' # user modifies the data set
#' lr_data2 <- lr_data[1:20, ]
#' p3 <- mod1_sim(param = par1, data = lr_data2) 
#' p4 <- unname(predict(mod1, newdata = lr_data2, type = "response")) # same result
#' 
#' # user modifies the parameters
#' par2 <- par1
#' int1 <- par1["(Intercept)"]
#' par2["(Intercept)"] <- 0
#' p5 <- mod1_sim(param = par2, data = lr_data)
#' 
#' @export
#' 
lr_simulator <- function(object) {
  ff <- stats::delete.response(stats::terms(object$formula))
  force(ff)
  function(param, data, type = "response") {
    mm <- stats::model.matrix(ff, data)
    pred <- as.vector(mm %*% param)
    if (type == "response") pred <- stats::family(object)$linkinv(pred)
    return(pred)
  }
}

# shared helper: draws `nsim` sets of coefficients from the sampling
# distribution implied by the model's variance-covariance matrix, and
# evaluates the linear predictor at each draw for the supplied `newdata`.
# Used both by `lr_vpc_sim()` and by the `er_simulate.erlr_glm()` method
# (used by erplots, if installed, for spaghetti-style uncertainty bands).
.lr_simulate_draws <- function(object, newdata, nsim = 100, seed = NULL) {
  if (is.null(seed)) {
    seed <- .pick_seed()
    rlang::inform(paste("Using seed =", seed))
  }
  fn <- lr_simulator(object)
  withr::with_seed(
    seed = seed,
    code = {
      par <- mvtnorm::rmvnorm(
        n = nsim,
        mean = stats::coef(object),
        sigma = stats::vcov(object)
      )
    }
  )
  sim <- list()
  for (ii in seq_len(nsim)) {
    dd_sim <- newdata |> dplyr::mutate(row_id = dplyr::row_number(), sim_id = ii)
    dd_sim$fit_resp <- fn(param = par[ii, ], dd_sim)
    sim[[ii]] <- dd_sim
  }
  dplyr::bind_rows(sim)
}

