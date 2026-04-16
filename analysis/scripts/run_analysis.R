# Run FR-BCA analysis and generate all figures and tables
# This script is sourced by analysis notebooks and bookdown reports

## Load the frbca package from the package root.
path_frbca <- here::here()
devtools::load_all(path_frbca)
library(frbca)

## Helper function to format names
my_name_repair <- function(name) {
  return(gsub('__days', '',
              tolower(gsub('(\\s+|\\(|\\?|-|/)', '_', gsub('\\)', '', name)))))
}

## Load EAL and cost data
## FROM SHARED DRIVE:
## UPDATED 2025-02-13 with 20-story and 18-stor costs
path_inputs = "~/gdrive-shared/nist-umd-fy23/functional-recovery/model-inputs"
path_eal = 'input-eal-all.csv' ## input-eal-rcmf.csv
path_cost = 'input-cost-all.csv' ## input-cost-rcmf.csv

input_eal = readr::read_csv(file.path(path_inputs, path_eal),
                            name_repair=my_name_repair) |>
  dplyr::rename_with(~stringr::str_remove(., '__days')) |>
  dplyr::select(!construction_type)

input_cost = readr::read_csv(file.path(path_inputs, path_cost),
                             name_repair=my_name_repair) |>
  dplyr::rename(c_s = structural, c_ns = nonstructural) |>
  ## drop pre-computed deltas etc
  dplyr::select(!c(construction_type, starts_with("delta_"), starts_with("unit_")))

## Load parameters from package (instead of hardcoded)
bca_inputs <- frbca::input_param

## Activate the frbca project (must be set by the calling script)
# usethis::proj_activate(path_frbca)

## full analysis
out_frbca <- frbca::frbca(input_eal, input_cost, bca_inputs)

## Variables for figure generation
c_plot_systems <- c("RCMF", "RCSW")
b_plot_designs <- c("baseline", "structural", "nonstructural")
c_plot_designs <- c("baseline", "structural", "nonstructural")
c_plot_stories <- c(4, 12)
f_plot_designs <- c("baseline", "structural", "nonstructural")

## Variables for table generation (note: some tables use different systems/stories)
c_plot_systems_tables <- c("RCMF", "RCSW", "SMF", "BRBF")
c_plot_stories_tables <- c(4, 12)
c_plot_designs_tables <- c("structural", "nonstructural", "full")
fr_plot_designs <- c("baseline", "structural", "nonstructural")
fr_full_designs <- c("baseline", "structural", "nonstructural", "full")
tn_plot_stories <- c(4, 8, 12, 18, 20)

## Source configuration for figure/table saving functions
source(here::here("analysis/scripts/generate_figures_tables.R"))

## Generate all figures using the unified system
## This ensures figures are saved to analysis/output/figs directory when sourced.
source(here::here("analysis/scripts/generate_scatter_figures.R"))
source(here::here("analysis/scripts/generate_eal_figures.R"))
source(here::here("analysis/scripts/generate_bcr_figures.R"))
source(here::here("analysis/scripts/generate_bcr_figures_single.R"))
source(here::here("analysis/scripts/generate_cost_figures.R"))

## Generate all tables using the unified system
## This ensures tables are saved as .docx in analysis/output/tables when sourced.
source(here::here("analysis/scripts/generate_tables.R"))

## Return the output for potential use in the calling document
invisible(out_frbca)
