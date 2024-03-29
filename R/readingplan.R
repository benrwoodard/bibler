#' Get today's reading plan
#'
#' This will return the passage for today's reading plan
#'
#' @param date defaults to today's date
#' @param apikey API.bible api key. Sign up here https://scripture.api.bible/signup
#'
#' @import dplyr
#' @import tidyr
#' @import lubridate
#' @import rvest
#' @importFrom janitor row_to_names
#' @importFrom janitor clean_names
#' @export
readingplan <- function(date = Sys.Date(),
                        bibleid = Sys.getenv('MAIN_BIBLEID'),
                        apikey = Sys.getenv('BIBLER_APIKEY')) {

  #read the table on the page
  url <- 'https://www.bible-reading.com/bible-plan.html'
  plans <- rvest::read_html(url) %>%
  rvest::html_table(header = TRUE)
  plan <- plans[[3]]
  vss <- plan %>%
    janitor::row_to_names(row_number = 1) %>%
    janitor::clean_names() %>%
    dplyr::filter(week == lubridate::week(date)) %>%
    tidyr::pivot_longer(cols = 2:8) %>%
    dplyr::filter(name == tolower(lubridate::wday(date,label = T, abbr = F))) %>%
    dplyr::pull(value)

    bookref <- books(bibleid = bibleid, apikey = apikey) %>%
      select(id, name)

    if(length(bookref$id[bookref$name == vss]) != 0) {
      bookid <- bookref$id[bookref$name == vss]
      ch <- chapters(bookid)
      bookchaptermax <- max(as.numeric(ch$number[ch$number != 'intro']))
      bookchaptermin <- min(as.numeric(ch$number[ch$number != 'intro']))
      passage <- glue::glue("{bookid}.{bookchaptermin}-{bookid}.{bookchaptermax}")

    } else {
    vss <- stringr::str_replace(vss,   'I ', '1') %>%
      stringr::str_replace('II ', '2') %>%
      stringr::str_replace('III ', '3') %>%
      stringr::str_split(pattern = ' ')
    vss[[1]][1] <- gsub("([1-3])([A-Z])", "\\1 \\2", vss[[1]][1])
    vss[[1]][1] <- gsub(vss[[1]][1], bookref$id[bookref$name == vss[[1]][1]], vss[[1]][1])
    vss[[1]][2] <- stringr::str_replace(vss[[1]][2], ':', '.')
    preverses <- glue::glue("{vss[[1]][1]}.{vss[[1]][2]}")
    passage <- stringr::str_replace(preverses, '-', glue::glue('-{vss[[1]][1]}.'))
    }
  passage(passage, bibleid = bibleid, apikey = apikey )
}

#' Verse of the day
#'
#' This function generates the verse of the day
#'
#' @param date the date which sets the seed for the random generator
#'
#' @param rvest
#' @importFrom stringr str_replace
#' @importFrom stringr str_split
#' @export
#'
dayverse <- function(date = Sys.Date()){

  set.seed(as.numeric(date))
  url <- 'https://www.kingjamesbibleonline.org/Popular-Bible-Verses.php'
  verses <- rvest::read_html(url) %>%
    rvest::html_elements('#top > section:nth-child(5) > div > div.dottedborder > dl > dt > p > strong > a') %>%
    rvest::html_text() %>%
    stringr::str_replace(pattern = '1 ', replacement = '1') %>%
    stringr::str_replace(pattern = '2 ', replacement = '2') %>%
    stringr::str_split(pattern = ' ')

  for(i in seq(verses)){
    verses[[i]][1] <- toupper(stringr::str_sub(verses[[i]][1], 1, 3))
    verses[[i]][2] <- stringr::str_replace(verses[[i]][2], ':', '.')
    verses[[i]] <- glue::glue("{verses[[i]][1]}.{verses[[i]][2]}")
  }
  set.seed(as.numeric(date))
  todaysverse <- sample(1:length(verses), 1)
  bibler::verse(verses[[todaysverse]])
}

