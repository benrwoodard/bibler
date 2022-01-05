#' Get a list of available Bible versions
#'
#' This will pull a list of all available bible versions
#'
#' @param language ISO 639-3 three digit language code used to filter results
#' @param abbreviation Bible abbreviation to search for
#' @param name Bible name to search for
#' @param ids Comma separated list of Bible ids to return
#' @param details Boolean to include full Bible details (e.g. copyright and promo info)
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
bibles <- function(language = 'eng',
                   abbreviation = NA,
                   name = NA,
                   ids = NA,
                   details = FALSE,
                   debug = FALSE,
                   apikey = Sys.getenv('BIBLER_APIKEY')) {

  #remove spaces from the list of ids items
  if(!is.na(paste(ids,collapse=","))) {
    ids <- paste(ids,collapse=",")
  }
  name = URLencode(name)

  vars <- tibble::tibble(`language` = language,
                         `abbreviation` = abbreviation,
                         `name` = name,
                         `ids` = ids,
                        `include-full-details` = details)


  #Turn the list into a string to create the query
  prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
  #remove the extra parts of the string and replace it with the query parameter breaks
  query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

  baseurl <- 'https://api.scripture.api.bible/v1/bibles'

  req_url <- glue::glue('{baseurl}?{query_param}')

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
