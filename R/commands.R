parsable_list <- function(x){
  lapply(x, function(y) Filter(is_parsable, y))
}

is_parsable <- Vectorize(function(x){
  tryCatch({
      parse(text = x)
      TRUE
    },
    error = error_false
  )
},
"x")

extract_filenames <- function(command){
  if (!safe_grepl("'", command)){
    return(character(0))
  }
  splits <- str_split(command, "'")[[1]]
  splits[seq(from = 2, to = length(splits), by = 2)]
}

# This is the version of the command that is
# actually run in make(), not the version
# that is cached and treated as a dependency.
# It needs to (1) wrap the command in a function
# to protect the user's environment from side effects,
# and (2) call rlang::expr() to enable tidy evaluation
# features such as quasiquotation.
get_evaluation_command <- function(target, config){
  raw_command <- config$plan$command[config$plan$target == target] %>%
    functionize
  unevaluated <- paste0("rlang::expr(", raw_command, ")")
  quasiquoted <- eval(parse(text = unevaluated), envir = config$envir)
  command <- wide_deparse(quasiquoted)
  wrap_in_try_statement(target = target, command = command)
}

# Turn a command into an anonymous function
# call to avoid side effects that could interfere
# with parallelism.
functionize <- function(command) {
  paste0("(function(){\n", command, "\n})()")
}

# If commands are text, we need to make sure
# to
wrap_in_try_statement <- function(target, command){
  paste(
    target,
    "<- evaluate::try_capture_stack(quote({\n",
    command,
    "\n}), env = config$envir)"
  )
}

# This version of the command will be hashed and cached
# as a dependency. When the command changes nontrivially,
# drake will react. Otherwise, changes to whitespace or
# comments are just standardized away, and drake
# ignores them. Thus, superfluous builds are not triggered.
get_standardized_command <- function(target, config) {
  config$plan$command[config$plan$target == target] %>%
    standardize_command
}

# The old standardization command
# that relies on formatR.
# Eventually, we may move to styler,
# since it is now the preferred option for
# text tidying.
# The important thing for drake's standardization of commands
# is to stay stable here, not to be super correct.
# If styler's behavior changes a lot, it will
# put targets out of date.
standardize_command <- function(x) {
  formatR::tidy_source(
    source = NULL,
    comment = FALSE,
    blank = FALSE,
    arrow = TRUE,
    brace.newline = FALSE,
    indent = 4,
    output = FALSE,
    text = x,
    width.cutoff = 119
  )$text.tidy %>%
    paste(collapse = "\n") %>%
    braces
}
