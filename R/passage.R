#' Get passage contents
#'
#' This will pull a range of versions in a passage format
#'
#' @param bibleid Id of Bible whose Chapters to fetch
#' @param passageid Id of the Chapter to fetch
#' @param contenttype Content type to be returned in the content property. Supported values are html (default), json (beta), and text (beta)
#' @param includenotes Include footnotes in content
#' @param includetitles Include section titles in content
#' @param includechapternumbers Include chapter numbers in content
#' @param includeversenumbers Include verse numbers in content.
#' @param includeversespans Include spans that wrap verse numbers and verse text for bible content.
#' @param parallels Comma delimited list of bibleIds to include
#' @param useorgid Use the supplied id(s) to match the verseOrgId instead of the verseId
#' @param returnstring Do you want a table or a string to be returned
#' @param debug Used to help debug the query
#' @param apikey API.bible api key. Sign up here https://scripture.api.bible/signup
#'
#' @import dplyr
#' @import tibble
#' @importFrom glue glue
#' @importFrom purrr discard
#' @importFrom purrr map_df
#' @importFrom purrr map
#' @importFrom magrittr %>%
#' @importFrom httr RETRY
#' @importFrom httr add_headers
#' @importFrom httr verbose
#' @importFrom rlang :=
#' @export
passage <- function(passageid = "mrk.1",
                    contenttype = 'text',
                    includenotes = FALSE,
                    includetitles = TRUE,
                    includechapternumbers = FALSE,
                    includeversenumbers = TRUE,
                    includeversespans = FALSE,
                    parallels = NULL,
                    useorgid = FALSE,
                    returnstring = TRUE,
                    bibleid = Sys.getenv('MAIN_BIBLEID'),
                    debug = FALSE,
                    apikey = Sys.getenv('BIBLER_APIKEY')) {

  if(is.null(bibleid)){
    stop("Please provide a bibleid value")
  }
  #define the Bibles being requested
  main_pars <- c(bibleid, parallels)
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
                         parallels,
                         `use-org-id` = useorgid)


  #Turn the list into a string to create the query
  prequery <- vars %>% purrr::discard(~all(is.na(.) | . ==""))
  #remove the extra parts of the string and replace it with the query parameter breaks
  query_param <-  paste(names(prequery), prequery, sep = '=', collapse = '&')

  baseurl <- sprintf('https://api.scripture.api.bible/v1/bibles/%s/passages',
                     bibleid)


  req_url <- glue::glue('{baseurl}/{passageid}?{query_param}')

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
  httr::stop_for_status(req, task = glue::glue("{httr::content(req)$message} - {passageid}"))

  res <- httr::content(req)$data

  if(!is.null(res$parallels)) {
    mainbible <- data.frame(bibleid = res$bibleId,
                            ref = res$reference,
                            content = trimws(res$content))
    p_bibles <- purrr::map_df(seq(res$parallels), function(x) {
      data.frame(bibleid = res$parallels[[x]]$bibleId,
                 ref = res$parallels[[x]]$reference,
                 content = trimws(res$parallels[[x]]$content))
    })

    allpars <- rbind(mainbible, p_bibles)

    #reference BibleIds to pull in the name of the bible
    par.bibleids <- bibles(ids = paste(main_pars, collapse = ','))
    par.bible <- select(par.bibleids, id, abbreviation)
    final <- allpars %>%
      left_join(select(par.bible, id, abbreviation), by = c('bibleid' = 'id'),
                keep = F) %>%
      select(-bibleid) %>%
      relocate(abbreviation, .before = 1) %>%
      rename(bible = 1, passage = content)
    final
  } else {
    if(returnstring){
      glue::glue('{res$id} {trimws(res$content)}')
    } else {
      tibble::tibble(reference = res$reference, verse = trimws(res$content))
    }
  }
}
