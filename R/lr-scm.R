
#' Stepwise covariate modelling for exposure-response models
#'
#' @param mod An erlr model object
#' @param candidates Character vector with list of candidate terms
#' @param threshold Threshold to test against
#' @param test Which significance test to use when comparing nested
#' models. `"auto"` (the default) picks a likelihood-ratio chi-squared
#' test (`"Chisq"`) for families with known dispersion (binomial,
#' poisson) and an F-test (`"F"`) for families with an estimated
#' dispersion parameter (gaussian, Gamma, inverse.gaussian, quasi*),
#' matching `stats::anova()`'s own `test` argument. Set explicitly to
#' override.
#' @param seed Optional seed to control order of term tests
#'
#' @returns For `lr_scm_forward()` and `lr_scm_backward()`, the updated erlr model
#' is returned, with the SCM history log updated internally. For `lr_scm_history()`,
#' a data frame is returned containing the SCM history log
#'
#' @name lr_scm
#' @examples
#' mod0 <- lr_model(ae1 ~ aucss, lr_data)
#' mod1 <- lr_scm_forward(mod0, candidates = c("sex", "dose"))
#' lr_scm_history(mod1)
#' 
#' mod2 <- lr_model(ae1 ~ aucss + sex + dose, lr_data)
#' mod3 <- lr_scm_backward(mod2, candidates = c("sex", "dose"))
#' lr_scm_history(mod3)
NULL

#' @rdname lr_scm
#' @export
lr_scm_forward <- function(mod, candidates, threshold = 0.01, test = c("auto", "Chisq", "F"), seed = NULL) {
  test <- match.arg(test)
  if (is.null(seed)) {
    seed <- .pick_seed()
    rlang::inform(paste("Using seed =", seed))
  }
  withr::with_seed(
    seed = seed,
    code = {
      mod_out <- .lr_scm_forward(
        mod = mod,
        candidates = candidates,
        threshold = threshold,
        test = test
      )
    }
  )
  return(mod_out)
}

.lr_scm_forward <- function(mod, candidates, threshold, test) {
  history <- lr_scm_history(mod)
  last_iter <- max(history$iteration)
  while (TRUE) {
    mod_new <- .lr_once_forward(mod, candidates, threshold, test)
    history_new <- lr_scm_history(mod_new)
    this_iter <- max(history_new$iteration)
    if (this_iter == last_iter) return(mod)
    history <- history_new
    last_iter <- this_iter
    mod <- mod_new
    updates <- history |> 
      dplyr::filter(iteration == last_iter) |> 
      dplyr::pull(model_updated)
    if (all(updates == 0L)) return(mod)
  }
}

#' @rdname lr_scm
#' @export
lr_scm_backward <- function(mod, candidates, threshold = 0.001, test = c("auto", "Chisq", "F"), seed = NULL) {
  test <- match.arg(test)
  if (is.null(seed)) {
    seed <- .pick_seed()
    rlang::inform(paste("Using seed =", seed))
  }
  withr::with_seed(
    seed = seed,
    code = {
      mod_out <- .lr_scm_backward(
        mod = mod,
        candidates = candidates,
        threshold = threshold,
        test = test
      )
    }
  )
  return(mod_out)
}

.lr_scm_backward <- function(mod, candidates, threshold, test) {
  history <- lr_scm_history(mod)
  last_iter <- max(history$iteration)
  while (TRUE) {
    mod_new <- .lr_once_backward(mod, candidates, threshold, test)
    history_new <- lr_scm_history(mod_new)
    this_iter <- max(history_new$iteration)
    if (this_iter == last_iter) return(mod)
    history <- history_new
    last_iter <- this_iter
    mod <- mod_new
    updates <- history |> 
      dplyr::filter(iteration == last_iter) |> 
      dplyr::pull(model_updated)
    if (all(updates == 0L)) return(mod)
  }
}

#' @rdname lr_scm
#' @export
lr_scm_history <- function(mod) {
  history <- mod$erlr$history
  if (!is.null(history)) return(history)
  history_row <- tibble::tibble(
    iteration = 0L,
    attempt = 0L,
    step = "base model",
    action = NA_character_,
    term_tested = NA_character_, 
    model_tested = deparse(mod$formula),
    model_converged = mod$converged,
    term_p_value = NA_real_,
    model_aic = stats::AIC(mod),
    model_bic = stats::BIC(mod),
    model_updated = NA
  )
  return(history_row)
}

.lr_once_forward <- function(mod, candidates, threshold, test) {
  candidates <- sample(candidates)
  history <- lr_scm_history(mod)
  iter <- max(history$iteration) + 1L
  attm <- max(history$attempt)
  lowest_p <- threshold
  update_ind <- NA_integer_
  best_mod <- mod
  for (cc in candidates) {    
    add <- stats::as.formula(paste("~", cc))
    attm <- attm + 1L
    if (!.term_in_model(mod, add)) {
      mod_new <- .lr_add_term(mod, add, quiet = TRUE)
      p_val <- .lr_anova_p(mod, mod_new, test)
      history_row <- tibble::tibble(
        iteration = iter,
        attempt = attm,
        step = "forward",
        action = "add",
        term_tested = deparse(add), 
        model_tested = deparse(mod_new$formula),
        model_converged = mod_new$converged,
        term_p_value = p_val,
        model_aic = stats::AIC(mod_new),
        model_bic = stats::BIC(mod_new),
        model_updated = NA
      )
      history <- tibble::add_row(history, history_row)
      if (p_val < lowest_p) {
        update_ind <- attm
        lowest_p <- p_val
        best_mod <- mod_new
      }
    }
  }
  history <- history |> 
    dplyr::mutate(
      model_updated = dplyr::case_when(
        iteration != iter ~ model_updated,
        attempt == update_ind ~ 1L,
        TRUE ~ 0L
      )
    )
  best_mod$erlr$history <- history
  return(best_mod)
}

.lr_once_backward <- function(mod, candidates, threshold, test) {
  trm_mod <- stats::terms(mod)
  trm_lab <- attr(trm_mod, "term.labels")
  candidates <- intersect(trm_lab, candidates)
  if (length(candidates) == 0L) return(mod)
  candidates <- sample(candidates)
  history <- lr_scm_history(mod)
  iter <- max(history$iteration) + 1L
  attm <- max(history$attempt)
  highest_p <- threshold
  update_ind <- NA_integer_
  best_mod <- mod
  for (cc in candidates) {    
    del <- stats::as.formula(paste("~", cc))
    attm <- attm + 1L
    if (.term_in_model(mod, del)) {
      mod_new <- .lr_remove_term(mod, del, quiet = TRUE)
      p_val <- .lr_anova_p(mod, mod_new, test)
      history_row <- tibble::tibble(
        iteration = iter,
        attempt = attm,
        step = "backward",
        action = "remove",
        term_tested = deparse(del), 
        model_tested = deparse(mod_new$formula),
        model_converged = mod_new$converged,
        term_p_value = p_val,
        model_aic = stats::AIC(mod_new),
        model_bic = stats::BIC(mod_new),
        model_updated = NA
      )
      history <- tibble::add_row(history, history_row)
      if (p_val > highest_p) {
        update_ind <- attm
        highest_p <- p_val
        best_mod <- mod_new
      }
    }
  }
  history <- history |> 
    dplyr::mutate(
      model_updated = dplyr::case_when(
        iteration != iter ~ model_updated,
        attempt == update_ind ~ 1L,
        TRUE ~ 0L
      )
    )
  best_mod$erlr$history <- history
  return(best_mod)
}

.lr_anova_p <- function(mod1, mod2, test) {
  family_name <- stats::family(mod1)$family
  test <- .lr_resolve_test(test, family_name)
  smm <- stats::anova(mod1, mod2, test = test)
  p_col <- grep("^Pr\\(", colnames(smm))[1]
  return(smm[[p_col]][2])
}

.term_in_model <- function(mod, term) {
  trm_mod <- stats::terms(mod)
  trm_tst <- stats::terms(term)
  trm_mod_lab <- attr(trm_mod, "term.labels")
  trm_tst_lab <- attr(trm_tst, "term.labels")
  ind <- which(trm_mod_lab == trm_tst_lab)
  return(length(ind) != 0)
}

.lr_add_term <- function(mod, add, quiet = FALSE) {
  trm_mod <- stats::terms(mod)
  trm_add <- stats::terms(add)
  trm_mod_lab <- attr(trm_mod, "term.labels")
  trm_add_lab <- attr(trm_add, "term.labels")
  ind <- which(trm_mod_lab == trm_add_lab)
  if (length(ind) != 0L) {
    if (!quiet) rlang::warn("cannot add a term that already exists in the model")
    return(mod)
  }
  trm_add_var <- all.vars(attr(trm_add, "variables"))
  dat <- mod$data
  vars_ok <- trm_add_var %in% names(dat)
  if (!all(vars_ok)) {
    if (!quiet) rlang::warn("cannot add a term that uses variables not in the data")
    return(mod)
  }
  fml <- stats::as.formula(
    paste(deparse(mod$formula), deparse(add[[2]]), sep = " + ")
  )
  lr_model(formula = fml, data = dat, family = stats::family(mod))
}

.lr_remove_term <- function(mod, remove, quiet = FALSE) {
  trm_mod <- stats::terms(mod)
  trm_del <- stats::terms(remove)
  trm_mod_lab <- attr(trm_mod, "term.labels")
  trm_del_lab <- attr(trm_del, "term.labels")
  ind <- which(trm_mod_lab == trm_del_lab)
  if (length(ind) == 0L) {
    if (!quiet) rlang::warn("cannot remove a term that does not exist in the model")
    return(mod)
  }
  dat <- mod$data
  trm_new <- stats::drop.terms(trm_mod, ind, keep.response = TRUE)
  lr_model(formula = trm_new, data = dat, family = stats::family(mod))
}


