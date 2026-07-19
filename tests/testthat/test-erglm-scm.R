test_that("erglm_add_term works", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  expect_no_error(erglm_add_term(mod1, ~sex, quiet = TRUE))
  mod2 <- erglm_add_term(mod1, ~sex, quiet = TRUE)
  expect_equal(deparse(mod2$formula), "ae1 ~ aucss + sex")
  expect_equal(length(coef(mod2)), length(coef(mod1)) + 1L)
})

test_that("erglm_remove_term works", {
  mod2 <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
  expect_no_error(erglm_remove_term(mod2, ~sex, quiet = TRUE))
  mod1 <- erglm_remove_term(mod2, ~sex, quiet = TRUE)
  expect_equal(deparse(mod1$formula), "ae1 ~ aucss")
  expect_equal(length(coef(mod2)), length(coef(mod1)) + 1L)
})

test_that("erglm_add_term warns (unless quiet) when the term already exists", {
  mod1 <- erglm_model(ae1 ~ aucss + sex, erglm_data, family = binomial())
  expect_warning(erglm_add_term(mod1, ~sex), "already exists")
  expect_no_warning(mod2 <- erglm_add_term(mod1, ~sex, quiet = TRUE))
  expect_equal(deparse(mod2$formula), deparse(mod1$formula))
})

test_that("erglm_remove_term warns (unless quiet) when the term isn't in the model", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  expect_warning(erglm_remove_term(mod1, ~sex), "does not exist")
  expect_no_warning(mod2 <- erglm_remove_term(mod1, ~sex, quiet = TRUE))
  expect_equal(deparse(mod2$formula), deparse(mod1$formula))
})

test_that("erglm_scm_history works when no scm called", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  expect_no_error(erglm_scm_history(mod1))
  hh <- erglm_scm_history(mod1)
  expect_s3_class(hh, "data.frame")
  expect_equal(nrow(hh), 1L)
  expect_named(hh, c(
    "iteration", "attempt", "step", "action", "term_tested", "model_tested",
    "model_converged", "term_p_value", "model_aic", "model_bic", "model_updated"
  ))
  expect_equal(hh$iteration, 0L)
})

test_that(".erglm_once_forward works", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  expect_no_error(.erglm_once_forward(mod1, candidates = c("sex", "dose"), threshold = .01, test = "auto"))
  mod2 <- .erglm_once_forward(mod1, candidates = c("sex", "dose"), threshold = .01, test = "auto")
  hh1 <- erglm_scm_history(mod1)
  hh2 <- erglm_scm_history(mod2)
  expect_equal(nrow(hh1) + 2L, nrow(hh2))
})

test_that(".erglm_once_backward works", {
  mod1 <- erglm_model(ae1 ~ aucss + sex + dose, erglm_data, family = binomial())
  expect_no_error(.erglm_once_backward(mod1, candidates = c("sex", "dose"), threshold = .001, test = "auto"))
  mod2 <- .erglm_once_backward(mod1, candidates = c("sex", "dose"), threshold = .001, test = "auto")
  hh1 <- erglm_scm_history(mod1)
  hh2 <- erglm_scm_history(mod2)
  expect_equal(nrow(hh1) + 2L, nrow(hh2))
})

test_that("erglm_scm_forward works", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  expect_no_error(erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01))
  mod2 <- erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01)
  hh1 <- erglm_scm_history(mod1)
  hh2 <- erglm_scm_history(mod2)
  expect_equal(nrow(hh1) + 2L, nrow(hh2)) 
  expect_equal(max(hh2$iteration), 1L)
})

test_that("erglm_scm_backward works", {
  mod1 <- erglm_model(ae1 ~ aucss + sex + dose, erglm_data, family = binomial())
  expect_no_error(erglm_scm_backward(mod1, candidates = c("sex", "dose"), threshold = .001))
  mod2 <- erglm_scm_backward(mod1, candidates = c("sex", "dose"), threshold = .001)
  hh1 <- erglm_scm_history(mod1)
  hh2 <- erglm_scm_history(mod2)
  expect_equal(nrow(hh1) + 3L, nrow(hh2))
  expect_equal(max(hh2$iteration), 2L)
})

test_that(".erglm_default_test picks Chisq for known-dispersion families and F otherwise", {
  expect_equal(.erglm_default_test("binomial"), "Chisq")
  expect_equal(.erglm_default_test("poisson"), "Chisq")
  expect_equal(.erglm_default_test("gaussian"), "F")
  expect_equal(.erglm_default_test("Gamma"), "F")
  expect_equal(.erglm_default_test("inverse.gaussian"), "F")
})

test_that(".erglm_anova_p auto-selects the test based on family and reads the p-value generically", {
  mod1 <- erglm_model(ae_count ~ aucss, erglm_data, family = poisson())
  mod2 <- erglm_model(ae_count ~ aucss + sex, erglm_data, family = poisson())
  p_auto <- .erglm_anova_p(mod1, mod2, test = "auto")
  p_chisq <- .erglm_anova_p(mod1, mod2, test = "Chisq")
  expect_equal(p_auto, p_chisq)

  mod3 <- erglm_model(biomarker_change ~ aucss, erglm_data, family = gaussian())
  mod4 <- erglm_model(biomarker_change ~ aucss + sex, erglm_data, family = gaussian())
  p_auto_gauss <- .erglm_anova_p(mod3, mod4, test = "auto")
  p_f_gauss <- .erglm_anova_p(mod3, mod4, test = "F")
  expect_equal(p_auto_gauss, p_f_gauss)
  expect_false(isTRUE(all.equal(p_auto_gauss, .erglm_anova_p(mod3, mod4, test = "Chisq"))))
})

test_that("erglm_scm_forward works for a gaussian model with the default auto test", {
  mod1 <- erglm_model(biomarker_change ~ aucss, erglm_data, family = gaussian())
  expect_no_error(erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01))
  mod2 <- erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01)
  hh2 <- erglm_scm_history(mod2)
  expect_true(all(family(mod2)$family == "gaussian"))
  expect_true(nrow(hh2) > 1L)
})

test_that("erglm_scm_forward respects an explicit test override", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  mod_auto <- erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01, seed = 5544, test = "auto")
  mod_chisq <- erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01, seed = 5544, test = "Chisq")
  expect_equal(deparse(mod_auto$formula), deparse(mod_chisq$formula))
})

test_that("erglm_scm_forward is seed-invariant on non-tied data", {
  mod1 <- erglm_model(ae1 ~ aucss, erglm_data, family = binomial())
  seeds <- c(101L, 2202L, 33033L, 4004L, 55055L)
  mods <- lapply(seeds, function(s) {
    erglm_scm_forward(mod1, candidates = c("sex", "dose"), threshold = .01, seed = s)
  })
  formulas <- vapply(mods, function(m) deparse(m$formula), character(1))
  expect_length(unique(formulas), 1L)
  aics <- vapply(mods, stats::AIC, numeric(1))
  expect_equal(aics, rep(aics[1], length(aics)))
})

test_that("erglm_scm_backward is seed-invariant on non-tied data", {
  mod1 <- erglm_model(ae1 ~ aucss + sex + dose, erglm_data, family = binomial())
  seeds <- c(101L, 2202L, 33033L, 4004L, 55055L)
  mods <- lapply(seeds, function(s) {
    erglm_scm_backward(mod1, candidates = c("sex", "dose"), threshold = .001, seed = s)
  })
  formulas <- vapply(mods, function(m) deparse(m$formula), character(1))
  expect_length(unique(formulas), 1L)
  aics <- vapply(mods, stats::AIC, numeric(1))
  expect_equal(aics, rep(aics[1], length(aics)))
})

test_that("erglm_add_term and erglm_remove_term preserve the model's family", {
  mod1 <- erglm_model(ae_count ~ aucss, erglm_data, family = poisson())
  mod2 <- erglm_add_term(mod1, ~sex, quiet = TRUE)
  expect_equal(family(mod2)$family, "poisson")

  mod3 <- erglm_model(ae_count ~ aucss + sex, erglm_data, family = poisson())
  mod4 <- erglm_remove_term(mod3, ~sex, quiet = TRUE)
  expect_equal(family(mod4)$family, "poisson")
})
