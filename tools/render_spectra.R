#!/usr/bin/env Rscript

root <- normalizePath(".", winslash = "/", mustWork = TRUE)
if (!file.exists(file.path(root, "DESCRIPTION"))) {
  stop("Run this script from the package root (directory with DESCRIPTION).", call. = FALSE)
}

out_dir <- file.path(root, "analysis", "output")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

rmarkdown::render(
  input = file.path(root, "analysis", "notebooks", "spectra.Rmd"),
  output_file = "spectra.html",
  output_dir = out_dir,
  knit_root_dir = root
)
