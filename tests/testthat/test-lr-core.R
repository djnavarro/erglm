test_that("lr_model works", {
  expect_no_error(lr_model(ae1 ~ aucss + sex, lr_data))
  mod1 <- lr_model(ae1 ~ aucss + sex, lr_data)
  expect_s3_class(mod1, "glm")
})

test_that("lr_simulator returns a function", {
  mod1 <- lr_model(ae1 ~ aucss + sex, lr_data)
  expect_no_error(lr_simulator(mod1))
  mod1_sim <- lr_simulator(mod1)
  expect_type(mod1_sim, "closure")
})

test_that("lr_simulator works", {

  # simulator setup
  mod1 <- lr_model(ae1 ~ aucss + sex, lr_data)
  par1 <- coef(mod1)
  mod1_sim <- lr_simulator(mod1)

  # no counterfactuals
  p1 <- mod1_sim(param = par1, data = lr_data) 
  p2 <- unname(predict(mod1, type = "response")) # same result
  expect_equal(p1, p2)

  # user modifies the data set
  lr_data2 <- lr_data[1:20, ]
  p3 <- mod1_sim(param = par1, data = lr_data2) 
  p4 <- unname(predict(mod1, newdata = lr_data2, type = "response")) # same result
  expect_equal(p3, p4)

  # user modifies the parameters
  par2 <- par1
  int1 <- par1["(Intercept)"]
  par2["(Intercept)"] <- 0
  p5 <- mod1_sim(param = par2, data = lr_data)
  expect_equal(logit(p1), logit(p5) + int1)
  
})

test_that("lr_predict works with default data", {
  mod <- lr_model(ae1 ~ aucss + sex, lr_data)
  expect_no_error(lr_predict(mod))
  prd <- lr_predict(mod)
  pr_resp <- predict(mod, type = "response", se.fit = TRUE)
  pr_link <- predict(mod, type = "link", se.fit = TRUE)
  expect_equal(prd$fit_resp, pr_resp$fit)
  expect_equal(prd$fit_link, pr_link$fit)
  expect_equal(prd$se_link, pr_link$se.fit)
})

test_that("lr_predict works with modified data", {
  mod <- lr_model(ae1 ~ aucss + sex, lr_data)
  dat_1 <- lr_data[1:20,]
  expect_no_error(lr_predict(mod, newdata = dat_1))
  prd <- lr_predict(mod, newdata = dat_1)
  pr_resp <- predict(mod, newdata = dat_1, type = "response", se.fit = TRUE)
  pr_link <- predict(mod, newdata = dat_1, type = "link", se.fit = TRUE)
  expect_equal(prd$fit_resp, pr_resp$fit)
  expect_equal(prd$fit_link, pr_link$fit)
  expect_equal(prd$se_link, pr_link$se.fit)
})

test_that("lr_predict can adjust confidence level", {
  mod <- lr_model(ae1 ~ aucss + sex, lr_data)
  expect_no_error(lr_predict(mod, conf_level = 0))
  prd0 <- lr_predict(mod, conf_level = 0)
  expect_equal(prd0$ci_lower, prd0$fit_resp)
  expect_equal(prd0$ci_upper, prd0$fit_resp)
})

test_that("lr_model supports non-binomial glm families", {
  mod_pois <- lr_model(ae_count ~ aucss + sex, lr_data, family = poisson())
  expect_s3_class(mod_pois, "glm")
  expect_equal(family(mod_pois)$family, "poisson")

  mod_gauss <- lr_model(biomarker_change ~ aucss, lr_data, family = gaussian())
  expect_equal(family(mod_gauss)$family, "gaussian")

  mod_gamma <- lr_model(ae_duration ~ aucss + dose, lr_data, family = Gamma(link = "log"))
  expect_equal(family(mod_gamma)$family, "Gamma")
})

test_that("lr_predict is family-generic", {
  mod_pois <- lr_model(ae_count ~ aucss + sex, lr_data, family = poisson())
  prd <- lr_predict(mod_pois)
  pr_resp <- predict(mod_pois, type = "response", se.fit = TRUE)
  expect_equal(prd$fit_resp, pr_resp$fit)

  mod_gauss <- lr_model(biomarker_change ~ aucss, lr_data, family = gaussian())
  prd_gauss <- lr_predict(mod_gauss)
  pr_resp_gauss <- predict(mod_gauss, type = "response", se.fit = TRUE)
  expect_equal(prd_gauss$fit_resp, pr_resp_gauss$fit)
})

test_that("lr_simulator is family-generic", {
  mod_pois <- lr_model(ae_count ~ aucss + sex, lr_data, family = poisson())
  par1 <- coef(mod_pois)
  sim_fn <- lr_simulator(mod_pois)
  p1 <- sim_fn(param = par1, data = lr_data)
  p2 <- unname(predict(mod_pois, type = "response"))
  expect_equal(p1, p2)
})

