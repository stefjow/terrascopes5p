# Null-coalescing operator (not exported)
`%||%` = function(a, b) if (!is.null(a)) a else b


# Resolve collection: interactive picker or error
.resolve_collection = function(collection, stac_url) {
  if (!is.null(collection)) return(collection)

  cols = list_s5p_collections(stac_url = stac_url)
  if (is.null(cols) || nrow(cols) == 0) {
    stop("No collections found and no collection specified.", call. = FALSE)
  }

  if (interactive()) {
    choices = paste0(cols$id, "  (", cols$title, ")")
    selection = utils::menu(choices, title = "Select a collection:")
    if (selection == 0) stop("No collection selected.", call. = FALSE)
    return(cols$id[selection])
  }

  stop(
    "Argument 'collection' is required in non-interactive mode.\n",
    "Available collections:\n",
    paste0("  - ", cols$id, collapse = "\n"),
    call. = FALSE
  )
}
