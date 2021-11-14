#' Get a list of available chapters
#'
#' This will pull a list of all available chapters
#'
#' @param bibleid Id of Bible whose Chapters to fetch
#' @param bookid Id of the Book whose Chapters to fetch
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
chapters <- function(bibleid = Sys.getenv('MAIN_BIBLEID'),
                     bookid = NULL,
                     debug = FALSE,
                     apikey = Sys.getenv('BIBLER_APIKEY')) {


  baseurl <- 'https://api.scripture.api.bible/v1/bibles'

  req_url <- glue::glue('{baseurl}/{bibleid}/books/{bookid}/chapters')

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

  res1 <- httr::content(req)$data

  res2 <- tibble::as_tibble(do.call(rbind, res1))
  res2 %>%
    dplyr::mutate(across(.cols = everything(), as.character))
}
