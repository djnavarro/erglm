
`%||%` <- function(x, y) {
  if (is.null(x)) return(y)
  x
}

.pick_seed <- function() {999 + sample.int(9000, size = 1L)}

# Renders a bad argument value for an error message without risking a
# second error from an unprintable/zero-length/weird-class input.
.fmt_bad_value <- function(x) {
  if (is.null(x)) return("NULL")
  if (length(x) == 0L) return(paste0(class(x)[1], "(0)"))
  tryCatch(
    paste(format(x), collapse = ", "),
    error = function(e) paste0("<", class(x)[1], ">")
  )
}

# `conf_level` must be a single number in [0, 1] for the `qnorm()`-based
# z-score used by `erglm_predict()`/`er_summary.erglm_model()` to be
# meaningful. 0 and 1 are legitimate (degenerate) endpoints -- a 0%
# interval collapses to the point estimate (z = 0), and a 100% interval
# is infinitely wide (z = Inf) -- but values outside [0, 1] aren't valid
# probabilities and currently produce a silently reversed or NaN interval
# rather than erroring.
.erglm_check_conf_level <- function(conf_level) {
  if (!is.numeric(conf_level) || length(conf_level) != 1L || is.na(conf_level) ||
      conf_level < 0 || conf_level > 1) {
    rlang::abort(paste0(
      "`conf_level` must be a single number between 0 and 1 (inclusive), not ",
      .fmt_bad_value(conf_level), "."
    ))
  }
}

# `nsim` must be a single positive whole number -- used by
# `simulate.erglm_model()`/`.erglm_resample()` and `.erglm_simulate_draws()`
# to size the loop of simulation replicates. Invalid values (0, negative,
# non-integer) otherwise surface as a cryptic "non-conformable arguments"
# error from downstream matrix code.
.erglm_check_nsim <- function(nsim) {
  if (!is.numeric(nsim) || length(nsim) != 1L || is.na(nsim) ||
      nsim < 1 || abs(nsim - round(nsim)) > .Machine$double.eps^0.5) {
    rlang::abort(paste0(
      "`nsim` must be a single positive whole number, not ",
      .fmt_bad_value(nsim), "."
    ))
  }
}

.as_erglm <- function(mod) {
  class(mod) <- c("erglm_model", class(mod)) # append class in case new methods are required
  mod$erglm <- list(type = stats::family(mod)$family) # internal "erglm" list to store erglm-specific info
  mod
}

# simple helpers ----------------------------------------------------------

#' Link and inverse-link functions for a fitted model
#'
#' Every `glm()` family already carries its link and inverse-link
#' functions (`stats::family(mod)$linkfun` / `stats::family(mod)$linkinv`),
#' but many users don't realise these are available for the taking.
#' `erglm_link()` and `erglm_invlink()` are thin, discoverable wrappers
#' around them: `erglm_link()` maps the response scale to the linear
#' predictor scale, and `erglm_invlink()` maps the linear predictor
#' scale back to the response scale.
#'
#' @param mod A fitted model, typically an `erglm_model`/`glm` object.
#' @returns A function of one numeric-vector argument.
#' @examples
#' mod <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
#' erglm_link(mod)(0.5)
#' erglm_invlink(mod)(0)
#' erglm_link(mod)(erglm_invlink(mod)(-2:2))
#' @name erglm_link
NULL

#' @export
#' @rdname erglm_link
erglm_link <- function(mod) stats::family(mod)$linkfun

#' @export
#' @rdname erglm_link
erglm_invlink <- function(mod) stats::family(mod)$linkinv
