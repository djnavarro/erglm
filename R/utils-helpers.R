
`%||%` <- function(x, y) {
  if (is.null(x)) return(y)
  x
}

.pick_seed <- function() {999 + sample.int(9000, size = 1L)}

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
