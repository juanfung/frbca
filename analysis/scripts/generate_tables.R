# Source all table generation scripts
source(here::here("analysis/scripts/generate_performance_metrics_tables.R"))
source(here::here("analysis/scripts/generate_avoided_losses_tables.R"))
source(here::here("analysis/scripts/generate_economic_metrics_tables.R"))
source(here::here("analysis/scripts/generate_unit_costs_tables.R"))
source(here::here("analysis/scripts/generate_cost_deltas_tables.R"))

message("All tables generated and saved to analysis/output/tables/ directory")