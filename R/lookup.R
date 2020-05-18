#' enables a search function
#'
#' This function will enable me to search a phrase or word and return
#' the number of verses along with a quick reference.
#'
#' @param bk book of the bible, not case senstaive
#' @param ch the chapter of the book
#' @param vs if a specific verse or number of verses, if you want the entire chapter then leave it blank
#' @param translation choose from kjv (default) or asv
#'
#' @import tidyverse
#' @export

lkp <- function(bk = "Genesis", ch = 1, vs = NA, translation = 'kjv') {

  load("~/Documents/bibler/data/bible.rda")

  if (is.na(vs)) {
    chapter_length <- bible %>%
      filter(grepl(bk, book, ignore.case = T)) %>%
      filter(chapter == ch) %>%
      summarise(vss = n()) %>%
      pull(vss)

    bible %>%
      filter(grepl(bk, book, ignore.case = T)) %>%
      filter(chapter == ch) %>%
      filter(verse == 1:chapter_length) %>%
      mutate(ref = paste0(book, ' ', chapter, '.', verse )) %>%
      select(ref, verse = all_of(translation))

  } else {

    bible %>%
      filter(grepl(bk, book, ignore.case = T)) %>%
      filter(chapter == ch) %>%
      filter(verse %in% vs) %>%
      mutate(ref = paste0(book, ' ', chapter, '.', verse )) %>%
      arrange(verse) %>%
      select(ref, verse = all_of(translation))
  }
}
