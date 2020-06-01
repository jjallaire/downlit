find_reexport_source <- function(obj, ns, topic) {
  if (is.function(obj)) {
    ## For functions, we can just take their environment.
    ns_env_name(get_env(obj))
  } else {
    ## For other objects, we need to check the import env of the package,
    ## to see where 'topic' is coming from. The import env has redundant
    ## information. It seems that we just need to find a named list
    ## entry that contains `topic`. We take the last match, in case imports
    ## have name clashes.
    imp <- getNamespaceImports(ns)
    imp <- imp[names(imp) != ""]
    wpkgs <- vapply(imp, `%in%`, x = topic, FUN.VALUE = logical(1))
    if (!any(wpkgs)) stop("Cannot find reexport source for `", topic, "`")
    pkgs <- names(wpkgs)[wpkgs]
    pkgs[[length(pkgs)]]
  }
}

a <- function(text, href) {
  ifelse(is.na(href), text, paste0("<a href='", href, "'>", text, "</a>"))
}

up_path <- function(depth) {
  paste(rep.int("../", depth), collapse = "")
}

is_infix <- function(x) {
  ops <- c(
    "::", ":::", "$", "@", "[", "[[", "^", "-", "+", ":", "*", "/",
    "<", ">", "<=", ">=", "==", "!=", "!", "&", "&&", "|", "||", "~",
    "->", "->>", "<-", "<<-", "=", "?"
  )

  grepl("^%.*%$", x) || x %in% ops
}

is_prefix <- function(x) {
  if (is_infix(x)) {
    return(FALSE)
  }

  special <- c(
    "(", "{", "if", "for", "while", "repeat", "next", "break", "function"
  )
  if (x %in% special) {
    return(FALSE)
  }

  TRUE
}

devtools_loaded <- function(x) {
  if (!x %in% loadedNamespaces()) {
    return(FALSE)
  }
  ns <- .getNamespace(x)
  env_has(ns, ".__DEVTOOLS__")
}

invert_index <- function(x) {
  stopifnot(is.list(x))

  if (length(x) == 0)
    return(list())

  key <- rep(names(x), lengths(x))
  val <- unlist(x, use.names = FALSE)

  split(key, val)
}

safe_parse <- function(text) {
  text <- gsub("\r", "", text)
  tryCatch(
    parse(text = text, keep.source = TRUE),
    error = function(e) NULL
  )
}