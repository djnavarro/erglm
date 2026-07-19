
# Interoperability with erplots ------------------------------------------
#
# erlr has no hard dependency on erplots (a modeling package shouldn't need
# to pull in ggplot2/patchwork). But if erplots *is* installed and loaded,
# erlr's model objects should work seamlessly with erplots' model-agnostic
# plotting API (`er_plot_show_model()`, `er_vpc_plot()`, etc.), which relies
# on the `er_predict()`/`er_simulate()`/`er_summary()` generics defined in
# erplots (see `erplots::er_model_interface`).
#
# These methods are registered lazily at load time (via `.onLoad()` below),
# so that neither erplots nor its dependencies need to be installed for
# erlr's modeling functions to work standalone.

er_predict.erlr_glm <- function(model, newdata, conf_level = 0.95, ...) {
  lr_predict(object = model, newdata = newdata, conf_level = conf_level)
}

er_simulate.erlr_glm <- function(model, newdata, nsim = 100, seed = NULL, ...) {
  .lr_simulate_draws(object = model, newdata = newdata, nsim = nsim, seed = seed)
}

er_summary.erlr_glm <- function(model, ...) {
  coefs <- summary(model)$coefficients
  if (nrow(coefs) < 2) return(NULL)
  list(p_value = unname(coefs[2, "Pr(>|z|)"]))
}

.onLoad <- function(libname, pkgname) {
  .s3_register("erplots::er_predict", "erlr_glm", er_predict.erlr_glm)
  .s3_register("erplots::er_simulate", "erlr_glm", er_simulate.erlr_glm)
  .s3_register("erplots::er_summary", "erlr_glm", er_summary.erlr_glm)
}

# Registers `method` as an S3 method for `generic` (given as
# "package::generic") and `class`, without requiring `package` to be
# installed or loaded. If `package` isn't loaded yet, registration is
# deferred until it is (via a load hook). This is the standard pattern used
# across the tidyverse for optional cross-package S3 methods (e.g. as
# implemented in `vctrs::s3_register()`); vendored here to avoid adding a
# dependency for a single small helper.
.s3_register <- function(generic, class, method) {
  pieces <- strsplit(generic, "::")[[1]]
  package <- pieces[[1]]
  generic <- pieces[[2]]

  register <- function(...) {
    envir <- asNamespace(package)
    registerS3method(generic, class, method, envir = envir)
  }

  if (isNamespaceLoaded(package)) {
    register()
  }
  setHook(packageEvent(package, "onLoad"), function(...) register())

  invisible()
}
