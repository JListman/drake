drake_context("future")

test_with_dir("future package functionality", {
  future::plan(future::sequential)
  scenario <- get_testing_scenario()
  e <- eval(parse(text = scenario$envir))
  load_basic_example(envir = e)
  withr::with_options(
    new = list(mc.cores = 2), code = {
      config <- make(
        e$my_plan,
        envir = e,
        parallelism = "future_lapply",
        jobs = 1,
        verbose = FALSE,
        session_info = FALSE
      )
    }
  )
  expect_equal(
    outdated(config),
    character(0)
  )
})

test_with_dir("prepare_distributed() writes cache folder if nonexistent", {
  config <- dbug()
  config$cache_path <- "nope"
  prepare_distributed(config)
  expect_true(file.exists("nope"))
})
