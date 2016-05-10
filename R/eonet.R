#' Calls EONET webservice
#'
#' Calls NASA's Earth Observatory Natural Event Tracker (EONET) webservice and
#' returns a list containing individual events as \code{data.frame}.
#'
#' @param status Accepts "open" or "closed".
#'               Defaults to "all", which includes both.
#' @param sources Accepts character id strings from EONET sources
#'   (see \code{eonet_sources})
#' @param category_id Accepts number id strings from EONET category tree
#'   (see \code{eonet_categories})
#' @param limit Limit of events to download. If \code{LimitType = "days"} this
#'   is not considered. Defaults to 10.
#' @param days Limit of days (less than today) to download events from.
#'   If \code{LimitType = "limit"} this is not considered. Defaults to 20.
#' @param LimitType Type of limit to consider: "limit" (count of events), "days"
#'   (days less than today) or "all" (both limits).
#' @param TrySimplify If TRUE tries to coerce category and event data.frames
#'   into one (successful if there is one category per event).
#'
#' @return Returns a \code{list} with individual events:
#' \item{Events}{\code{data.frame} - TODO description}
#' \item{Sources}{\code{data.frame} - TODO description}
#' \item{Categories}{\code{data.frame} - TODO description}
#' \item{Geography}{\code{list} of \code{data.frame} - TODO description}
#' \item{Meta}{\code{data.frame} - TODO description}
#'
#' @examples
#'\dontrun{
#' event <- earth_event(limit = 1)
#'}
#'
#' @importFrom dplyr inner_join
#' @importFrom plyr ldply
#' @importFrom jsonlite fromJSON
#' @export
earth_event <- function(status = c("all", "open", "closed"),
                        sources = "all",
                        category_id = "all",
                        limit = 10,
                        days = 20,
                        LimitType = c("limit", "days", "all"),
                        TrySimplify = TRUE)
{

  events_url <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?"

  # checking unsupported values
  status <- match.arg(status)
  LimitType <- match.arg(LimitType)

  # Limits
  limit <- switch(LimitType,
    limit = sprintf("limit=%s", limit),
    days = sprintf("days=%s", days),
    all = sprintf("limit=%s&days=%s", limit, days),
    stop("programming error. should not reach this code")
  )

  # status ----
  # TODO: the query construction should be implemented better
  query <- switch(as.character(status),
    all = paste0(events_url, limit),
    open = paste0(events_url, limit, "&status=open"),
    closed = paste0(events_url, limit, "&status=closed"),
    stop("programming error. should not reach this code")
  )

  # sources ----
  if (sources != "all") {
    query <- paste0(query, "&source=", sources)
  }

  # categories ----
  if (category_id != "all") {
    # TODO: Previously constructed "s" gets replaced within this branch !!!!
    # Use Category API...
    cs <- eonet_categories()
    query <- cs[cs$id == category_id,]$link
    if (length(query) == 0) {
      stop("Category id is not valid. Review using eonet_categories()")
    }
  }

  # download
  reply <- fromJSON(query)

  # error check
  if ("error" %in% names(reply)) {
    stop(paste0("NASA Webservice Error\n",
                "The following is the output: ", reply$error))
  }
  if (length(reply$events) < 1) {
    stop(paste0("No events found. Change parameters.\n",
                "using: ", reply))
  }

  # event
  events <- data.frame("event_id" = reply$events$id,
                       "event_title"  = reply$events$title,
                       "event_description" = reply$events$description,
                       "event_link" = reply$events$link,
                       stringsAsFactors = FALSE)

  # --------------------------------
  # TODO: needs refactoring
  # --------------------------------
  list_to_df <- function(l) as.data.frame(t(sapply(X = l, FUN = "[")))

  # category ----
  names(reply$events$categories) <- reply$events$id
  categories <- list_to_df(reply$events$categories)
    # Replace names and add new column...
      nn <- paste0("category_", names(categories))
      names(categories) <- nn
  categories$event_id <- as.character(row.names(categories))

  # sources ------
  sources <- reply$events$sources
    names(sources) <- as.character(reply$events$id)
  sources <- plyr::ldply(sources, rbind)
    names(sources) <- c("event_id", "source_id", "source_url")

  # geometry -----
  geo <- reply$events$geometries
  names(geo) <- as.character(reply$events$id)
  # --------------------------------
  # TODO: end of "needs refactoring"
  # --------------------------------

  # Metadata
  meta <- data.frame("search_title" = reply$title,
                     "search_url" = reply$link,
                     "search_description" = reply$description)

  # unite and final parse ----
  list("Events" = events,
       "Sources" = sources,
       "Categories" = categories,
       "Geography" = geo,
       "Meta" = meta) # this will be returned
}

#' Calls EONET category webservice.
#'
#' Calls NASA's EONET Webservice and returns all categories available.
#'
#' @return Returns \code{data.frame} with 5 columns:
#' \item{id}{Unique id (can be used to filter \code{earth_event})}
#' \item{title}{Title of category}
#' \item{link}{Direct json link (the result is equal to filtering all
#'             \code{earth_event} with category)}
#' \item{description}{Description of category}
#' \item{layers}{Layers of category (see oficial documentation)}
#'
#' @examples
#'\dontrun{
#' categories <- eonet_categories()
#'}
#'
#' @importFrom jsonlite fromJSON
#' @export
eonet_categories <- function() {
  reply <- fromJSON("http://eonet.sci.gsfc.nasa.gov/api/v2.1/categories")
  as.data.frame(reply$categories)
}

#' Calls EONET sources webservice
#'
#' Calls NASA's EONET Webservice and returns all sources available.
#'
#' @return Returns \code{data.frame} with 4 columns:
#' \item{id}{Unique id (can be used to filter \code{earth_event})}
#' \item{title}{Title of source}
#' \item{source}{Official source URL}
#' \item{link}{Direct json link (the result is equal to filtering all
#'             \code{earth_event} with source)}
#'
#' @examples
#'\dontrun{
#' sources <- eonet_sources()
#'}
#' @importFrom jsonlite fromJSON
#' @export
eonet_sources <- function() {
  reply <- fromJSON("http://eonet.sci.gsfc.nasa.gov/api/v2.1/sources")
  as.data.frame(reply$sources)
}
