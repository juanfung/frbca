#!/usr/bin/env Rscript

root <- normalizePath(".", winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(root, "DESCRIPTION"))) {
  stop("Run this script from the package root (directory with DESCRIPTION).", call. = FALSE)
}

book_dir <- file.path(root, "analysis", "reports", "bookdown")
old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(book_dir)

bookdown::render_book("index.Rmd")
