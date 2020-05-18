#' Looks up a verse and returns only the verse
#'
#' This function will enable a user to return a verse by using just a book, chapter, and verse .
#'
#' @param bk book of the bible, not case senstaive
#' @param ch the chapter of the book
#' @param vs if a specific verse or number of verses, if you want the entire chapter then leave it blank
#' @param translation choose from kjv (default) or asv
#'
#' @return verse text
#'
#' @import tidyverse
#' @export

vslkp <- function(bk = "Genesis", ch = 1, vs = NA, translation = 'kjv') {

  load("~/Documents/bibler/data/bible.rda")

  if (is.na(vs)) {
    chapter_length <- bible %>%
      filter(grepl(bk, book, ignore.case = T)) %>%
      filter(chapter == ch) %>%
      summarise(vss = n()) %>%
      pull(vss)

   txt <- bible %>%
      filter(grepl(bk, book, ignore.case = T)) %>%
      filter(chapter == ch) %>%
      filter(verse == 1:chapter_length) %>%
      mutate(ref = paste0(book, ' ', chapter, '.', verse )) %>%
      select(ref, verse = all_of(translation)) %>%
      pull(verse)

   vss <- 1:max(chapter_length)

   ref <- paste0(bk, '.', ch, ' -')
   verses <- paste(' (', vss,')', txt, sep = '', collapse = '')
   paste0(ref, verses)

  } else {

   txt <- bible %>%
      filter(grepl(bk, book, ignore.case = T)) %>%
      filter(chapter == ch) %>%
      filter(verse %in% vs) %>%
      mutate(ref = paste0(book, ' ', chapter, '.', verse )) %>%
      arrange(verse) %>%
      select(ref, verse = all_of(translation)) %>%
      pull(verse)

    vss <- min(vs):max(vs)

   ref <- paste0(toupper(bk), '.', ch, ' -')
   verses <- paste(' (', vs,')', txt, sep = '', collapse = '')
   paste0(ref, verses)
  }
}
