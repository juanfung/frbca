# Configuration
output_figures_dir <- here::here("analysis", "output", "figs")
output_tables_dir <- here::here("analysis", "output", "tables")
# Ensure directories exist
dir.create(output_figures_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(output_tables_dir, showWarnings = FALSE, recursive = TRUE)

# Load required packages
library(officedown)
library(flextable)

# Define standard figure saving function
save_figure <- function(filename, plot, width = 7, height = 5, dpi = 600) {
  ggsave(
    filename = file.path(output_figures_dir, filename),
    plot = plot,
    device = "tiff",
    width = width,
    height = height,
    dpi = dpi,
    units = "in",
    compression = "lzw"
  )
}

# Define standard table saving function
save_table <- function(ft, filename) {
  save_as_docx(ft, path = file.path(output_tables_dir, filename))
}