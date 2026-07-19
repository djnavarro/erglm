
# vpc helpers -------------------------------------------------------------

#' VPC simulations for logistic regression models
#'
#' @param object Logistic regression model
#' @param nsim Number of replicates
#' @param seed RNG state
#'
#' @returns A data frame or tibble. Contains one row per observation per
#' simulated replicate (identified by the `sim_id` column), with the
#' response variable replaced by its simulated value under parameter
#' uncertainty.
#'
#' @details To visualise the result (e.g. as a VPC-style plot comparing
#' observed and simulated response rates), see `erplots::er_vpc_plot()`.
#'
#' @export
#' @examples
#' mod <- lr_model(ae2 ~ aucss + sex, lr_data)
#' sim <- lr_vpc_sim(mod)
#' sim
#' 
lr_vpc_sim <- function(object, nsim = 100, seed = NULL) {
  ff <- object$formula
  vv <- all.vars(ff)
  rsp_var <- vv[1]
  dd <- object$data[, vv]
  sim <- .lr_simulate_draws(object, newdata = dd, nsim = nsim, seed = seed)
  sim[[rsp_var]] <- sim$fit_resp
  sim$fit_resp <- NULL
  return(sim)
}
