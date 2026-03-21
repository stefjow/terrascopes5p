#' List available Sentinel-5P collections on Terrascope
#'
#' Queries the Terrascope STAC API and returns collections matching
#' "S5P", "NO2", or "sentinel" in their ID.
#'
#' @param stac_url Character. STAC API endpoint.
#'   Default: `"https://stac.terrascope.be/"`.
#' @return A data.table with columns `id` and `title`, or `NULL` on failure.
#' @export
list_s5p_collections = function(stac_url = "https://stac.terrascope.be/") {
  stac_obj = rstac::stac(stac_url)

  cols = tryCatch({
    rstac::get_request(rstac::collections(stac_obj))
  }, error = function(e) {
    warning("Failed to fetch collections: ", e$message)
    return(NULL)
  })

  if (is.null(cols) || !"collections" %in% names(cols)) {
    return(NULL)
  }

  s5p = Filter(
    function(c) grepl("S5P|NO2|sentinel-5", c$id, ignore.case = TRUE),
    cols$collections
  )

  if (length(s5p) == 0) {
    message("No S5P collections found.")
    return(NULL)
  }

  data.table::data.table(
    id    = vapply(s5p, function(c) c$id, character(1)),
    title = vapply(s5p, function(c) c$title %||% NA_character_, character(1))
  )
}


#' Search Terrascope STAC for Sentinel-5P items
#'
#' Queries the STAC API for items matching the given collection, bounding box,
#' and date range. Returns all pages of results.
#'
#' @param bbox Numeric vector of length 4: `c(xmin, ymin, xmax, ymax)`.
#' @param start_date Date or character coercible to Date.
#' @param end_date Date or character coercible to Date.
#' @param collection Character. STAC collection ID.
#'   Default: `"terrascope-s5p-l3-no2-td-v2"`.
#' @param stac_url Character. STAC API endpoint.
#'   Default: `"https://stac.terrascope.be/"`.
#' @param limit Integer. Page size for pagination. Default: 100.
#' @return An rstac items object, or `NULL` on failure.
#' @export
search_s5p = function(bbox,
                      start_date,
                      end_date,
                      collection = "terrascope-s5p-l3-no2-td-v2",
                      stac_url = "https://stac.terrascope.be/",
                      limit = 100L) {

  start_date = as.Date(start_date)
  end_date = as.Date(end_date)

  datetime_str = paste0(
    format(start_date, "%Y-%m-%dT00:00:00Z"),
    "/",
    format(end_date, "%Y-%m-%dT00:00:00Z")
  )

  stac_obj = rstac::stac(stac_url)

  query = stac_obj |>
    rstac::stac_search(
      collections = collection,
      bbox = bbox,
      datetime = datetime_str,
      limit = limit
    )

  items = tryCatch({
    query |>
      rstac::post_request() |>
      rstac::items_fetch()
  }, error = function(e) {
    warning("STAC search failed: ", e$message)
    return(NULL)
  })

  n = if (!is.null(items) && "features" %in% names(items)) {
    length(items$features)
  } else {
    0L
  }

  message("Found ", n, " items for collection '", collection, "'")
  items
}
