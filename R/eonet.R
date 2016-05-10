#' Calls EONET webservice
#'
#' Calls NASA's Earth Observatory Natural Event Tracker (EONET) webservice and
#' returns a list containing individual events as \code{data.frame}.
#'
#' @param status Accepts 1 or 0 (open or closed). Defaults to "all", which
#'   includes both.
#' @param sources Accepts character id strings from EONET sources (see
#'   \code{eonet_sources})
#' @param category_id Accepts number id strings from EONET category tree (se
#'   \code{eonet_categories})
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
earth_event <- function(status = "all",
                        sources = "all",
                        category_id = "all",
                        limit = 10,
                        days = 20,
                        LimitType = "limit",
                        TrySimplify = TRUE)
{

  events_url <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/events?"
  # Limits
  if (LimitType == "limit") {
    limit <- paste0("limit=",limit)
  } else {
    if (LimitType == "days") {
      limit <- paste0("days=",days)
    } else {
      if (LimitType == "all") {
        limit <- paste0("limit=",limit,"&days=",days)
      } else {
        #fail
        stop("LimitType is not recognizable. Set to: limit, days or all")
      }
    }
  }

  # - Start creating series

  # status ----
  if (status == "all") {
    s <- paste0(events_url, limit)
  } else {
    if (status == 1) {
      s <- paste0(events_url, limit, "&status=open")
    } else {
      if (status == 0) {
        s <- paste0(events_url, limit, "&status=open")
      } else {
        #fail
        stop("Status is not 1 (open) or 0 (closed)")
      }
    }
  }

  # sources ----
  if (sources == "all") {
    s <- s
  } else {
    s <- paste0(s, "&source=", sources)
  }

  # categories ----
  if (category_id == "all") {
    s <- s
  } else {
    # Use Category API...
    cs <- eonet_categories()
    if (category_id %in% cs$id) {
      s <- subset(cs, id == category_id)
      s <- s$link
    }else{
      stop("Category id is not valid. Review using eonet_categories()")
    }
  }

  # download
  e <- fromJSON(s)

  # error check
  if ("error" %in% names(s)) {
    stop(cat(paste0("NASA Webservice Error \n",
                    "The following is the output: ", s$error)))
  }
  if (length(e$events) < 1) {
    stop(cat(paste0("No events found. Change parameters. \n",
                    "using: ", s)))
  }

  # event
  events <- e$events
  events <- data.frame("event_id" = as.character(events$id),
                       "event_title"  = events$title,
                       "event_description" = events$description,
                       "event_link" = events$link,
                       stringsAsFactors = FALSE)

  list_to_df <- function(l) {
    df <- as.data.frame(base::t(base::sapply(X = l, FUN = "[")))
    return(df)
  }

  # category ----
  names(e$events$categories) <- e$events$id
  categories <- list_to_df(e$events$categories)
    # Replace names and add new column...
      nn <- paste0("category_",names(categories))
      names(categories) <- nn
  categories$event_id <- as.character(row.names(categories))
  # sources ------
  sources <- e$events$sources
    names(sources) <- as.character(e$events$id)
  sources <- plyr::ldply(sources, rbind)
    names(sources) <- c("event_id", "source_id", "source_url")

  # geometry -----
  geo <- e$events$geometries
  names(geo) <- as.character(e$events$id)

  # Metadata
  meta <- data.frame("search_title" = e$title,
                     "search_url" = e$link,
                     "search_description" = e$description)

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
  categories_url <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/categories"
  e <- fromJSON(categories_url)
  as.data.frame(e$categories) # this will be returned
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
  sources_url <- "http://eonet.sci.gsfc.nasa.gov/api/v2.1/sources"
  e <- fromJSON(sources_url)
  e$sources # this will be returned
}
