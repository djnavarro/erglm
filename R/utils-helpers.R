
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

#' Logit and inverse logit functions
#'
#' @param x Numeric vector
#' @returns Numeric vector
#' @examples
#' logit((1:9)/10)
#' invlogit(-3:3)
#' logit(invlogit(-3:3))
#' @name logit
NULL

#' @export
#' @rdname logit
logit <- function(x) log(x / (1-x))

#' @export
#' @rdname logit
invlogit <- function(x) 1 / (1 + exp(-x))
