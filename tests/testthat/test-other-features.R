drake_context("other features")

test_with_dir("build_target() does not need to access cache", {
  config <- drake_config(drake_plan(x = 1))
  config$cache <- NULL
  expect_equal(1, build_target(target = "x", config = config))
  expect_error(
    drake_build(target = "x", config = config),
    regexp = "cannot find drake cache"
  )
})

test_with_dir("cache log files and make()", {
  x <- drake_plan(a = 1)
  make(x, session_info = FALSE)
  expect_false(file.exists("drake_cache.log"))
  make(x, session_info = FALSE)
  expect_false(file.exists("drake_cache.log"))
  make(x, session_info = FALSE, cache_log_file = TRUE)
  expect_true(file.exists("drake_cache.log"))
  make(x, session_info = FALSE, cache_log_file = "my.log")
  expect_true(file.exists("my.log"))
})

test_with_dir("drake_build works as expected", {
  scenario <- get_testing_scenario()
  e <- eval(parse(text = scenario$envir))
  pl <- drake_plan(a = 1, b = a)
  con <- drake_config(plan = pl, session_info = FALSE, envir = e)

  # can run before any make()
  o <- drake_build(
    target = "a", character_only = TRUE, config = con, envir = e)
  x <- cached()
  expect_equal(x, "a")
  o <- make(pl, envir = e)
  expect_true("a" %in% ls(envir = e))
  expect_equal(justbuilt(o), "b")
  remove(list = "a", envir = e)
  expect_false("a" %in% ls(envir = e))

  # Can run without config
  o <- drake_build(b, envir = e)
  expect_equal(o, e$b)
  expect_equal(o, readd(b))
  expect_true("a" %in% ls(envir = e))

  # Replacing deps in environment
  expect_equal(e$a, 1)
  e$a <- 2
  o <- drake_build(b, envir = e)
  expect_equal(e$a, 2)
  expect_equal(readd(a), 1)
  o <- drake_build(b, envir = e, replace = FALSE)
  expect_equal(e$a, 2)
  expect_equal(readd(a), 1)
  e$a <- 3
  o <- drake_build(b, envir = e, replace = TRUE)
  expect_equal(e$a, 1)

  # `replace` in loadd()
  expect_equal(e$b, 1)
  e$b <- 5
  loadd(b, envir = e, replace = FALSE)
  expect_equal(e$b, 5)
  loadd(b, envir = e, replace = TRUE)
  expect_equal(e$b, 1)
  e$b <- 5
  loadd(b, envir = e)
  expect_equal(e$b, 1)
})

test_with_dir("colors and shapes", {
  expect_message(drake_palette())
  expect_is(color_of("target"), "character")
  expect_is(color_of("import"), "character")
  expect_is(color_of("not found"), "character")
  expect_is(color_of("not found"), "character")
  expect_equal(color_of("bluhlaksjdf"), color_of("other"))
  expect_is(shape_of("object"), "character")
  expect_is(shape_of("file"), "character")
  expect_is(shape_of("not found"), "character")
  expect_equal(shape_of("bluhlaksjdf"), shape_of("other"))
})

test_with_dir("shapes", {
  expect_is(shape_of("target"), "character")
  expect_is(shape_of("import"), "character")
  expect_is(shape_of("not found"), "character")
  expect_is(shape_of("object"), "character")
  expect_is(color_of("file"), "character")
  expect_is(color_of("not found"), "character")
  expect_equal(color_of("bluhlaksjdf"), color_of("other"))
})

test_with_dir("make() with imports_only", {
  expect_silent(make(drake_plan(x = 1), imports_only = TRUE,
    verbose = FALSE, session_info = FALSE))
  expect_false(cached(x))
})

test_with_dir("in_progress() works and errors are handled correctly", {
  expect_equal(in_progress(), character(0))
  bad_plan <- drake_plan(x = function_doesnt_exist())
  expect_error(tmp <- capture.output({
      make(bad_plan, verbose = FALSE, session_info = FALSE)
    },
    type = "message")
  )
  expect_equal(failed(), "x")
  expect_equal(in_progress(), character(0))
  expect_is(e <- diagnose(x), "error")
  expect_true(grepl(pattern = "function_doesnt_exist", x = e$message))
  expect_error(diagnose("notfound"))
  expect_true(inherits(diagnose(x), "error"))
  y <- "x"
  expect_true(inherits(diagnose(y, character_only = TRUE), "error"))
})

test_with_dir("missed() works", {
  # May have been loaded in a globalenv() testing scenario
  remove_these <- intersect(ls(envir = globalenv()), c("f", "g"))
  rm(list = remove_these, envir = globalenv())
  o <- dbug()
  expect_equal(character(0), missed(o))
  rm(list = c("f", "g"), envir = o$envir)
  expect_equal(sort(c("f", "g")), sort(missed(o)))
})

test_with_dir(".onLoad() warns correctly and .onAttach() works", {
  f <- ".RData"
  expect_false(file.exists(f))
  expect_silent(drake:::.onLoad())
  save.image()
  expect_true(file.exists(f))
  expect_warning(drake:::.onLoad())
  unlink(f, force = TRUE)
  set.seed(0)
  expect_true(is.character(drake_tip()))
  expect_silent(suppressPackageStartupMessages(drake:::.onAttach()))
})

test_with_dir("check_drake_config() via check_plan() and make()", {
  config <- dbug()
  y <- data.frame(x = 1, y = 2)
  expect_error(check_plan(y, envir = config$envir))
  expect_error(make(y, envir = config$envir, session_info = FALSE))
  y <- data.frame(target = character(0), command = character(0))
  expect_error(check_plan(y, envir = config$envir))
  expect_error(make(y, envir = config$envir, session_info = FALSE))
  expect_error(
    check_plan(config$plan, targets = character(0), envir = config$envir))
  expect_error(
    make(
      config$plan,
      targets = character(0),
      envir = config$envir,
      session_info = FALSE
    )
  )
  y <- drake_plan(x = 1, y = 2)
  y$bla <- "bluh"
  expect_warning(make(y, session_info = FALSE))
})

test_with_dir("targets can be partially specified", {
  config <- dbug()
  config$targets <- "'intermediatefile.rds'"
  testrun(config)
  expect_true(file.exists("intermediatefile.rds"))
  expect_error(readd(final, search = FALSE))
  config$targets <- "final"
  testrun(config)
  expect_true(is.numeric(readd(final, search = FALSE)))
  pl <- drake_plan(x = 1, y = 2)
  expect_error(check_plan(pl, "lskjdf", verbose = FALSE))
  expect_warning(check_plan(pl, c("lskdjf", "x"), verbose = FALSE))
  expect_silent(check_plan(pl, verbose = FALSE))
})

test_with_dir("as_drake_filename quotes properly", {
  expect_equal(as_drake_filename("x"), "'x'")
})

test_with_dir("unique_random_string() works", {
  set.seed(2017)
  x <- unique_random_string(n = 15)
  y <- unique_random_string(exclude = "a", n = 10)
  expect_equal(nchar(x), 15)
  expect_equal(nchar(y), 10)
  exclude <- c(letters, LETTERS, 1:9)
  for (i in 1:10){
    expect_equal(
      unique_random_string(exclude = exclude, n = 1),
      "0"
    )
  }
})
