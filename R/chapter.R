#' Get chapter contents
#'
#' This will pull a chapter cotent
#'
#' @param bibleid Id of Bible whose Chapters to fetch
#' @param chapterid Id of the Chapter to fetch
#' @param contenttype Content type to be returned in the content property. Supported values are html (default), json (beta), and text (beta)
#' @param includenotes Include footnotes in content
#' @param includetitles Include section titles in content
#' @param includechapternumbers Include chapter numbers in content
#' @param includeversenumbers Include verse numbers in content.
#' @param includeversespans Include spans that wrap verse numbers and verse text for bible content.
#' @param parallels Comma delimited list of bibleIds to include
#' @param debug Used to help debug the query
#' @param apikey API.bible api key. Sign up here https://scripture.api.bible/signup
#'
#' @import dplyr
#' @import tibble
#' @importFrom glue glue
#' @importFrom purrr discard
#' @importFrom magrittr %>%
#' @importFrom httr RETRY
#' @importFrom httr add_headers
#' @importFrom httr verbose
#' @export
chapter <- function(bibleid = Sys.getenv('MAIN_BIBLEID'),
                    chapterid = NULL,
                    contenttype = 'json',
                    includenotes = FALSE,
                    includetitles = TRUE,
                    includechapternumbers = FALSE,
                    includeversenumbers = TRUE,
                    includeversespans = FALSE,
                    parallels = NULL,
                    debug = FALSE,
                    apikey = Sys.getenv('BIBLER_APIKEY')) {

  if(is.null(bibleid)){
    stop("Please provide a bibleid value")
  }

  #remove spaces from the list of ids items
  if(!is.na(paste(parallels,collapse=","))) {
    parallels <- paste(parallels,collapse=",")
  }

  vars <- tibble::tibble(`content-type` = contenttype,
                         `include-notes` = includenotes,
                         `include-titles` = includetitles,
                         `include-chapter-numbers` = includechapternumbers,
                         `include-verse-numbers` = includeversenumbers,
                         `include-verse-spans` = includeversespans,
                         parallels)


  #Turn the list into a string to create the query
  prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
  #remove the extra parts of the string and replace it with the query parameter breaks
  query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

  baseurl <- sprintf('https://api.scripture.api.bible/v1/bibles/%s/chapters',
                     bibleid)


  req_url <- glue::glue('{baseurl}/{chapterid}?{query_param}')

  #debug setup
  debug_call <- NULL

  if (debug) {
    debug_call <- httr::verbose(data_out = TRUE, data_in = TRUE, info = TRUE)
  }
  req <- httr::RETRY("GET",
                     url = req_url,
                     encode = "json",
                     debug_call,
                     httr::add_headers(
                       `api-key` = apikey
                     ))
  #check status
  httr::stop_for_status(req, task = httr::content(req)$message)

  return(httr::content(req)$data)

}
