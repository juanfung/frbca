# Cost deltas table for multiple systems
# Returns a flextable and saves as .docx in analysis/output/tables directory

# Assume out_frbca is available in the environment
p <- out_frbca |>
  dplyr::bind_rows() |>
  dplyr::filter(label == 'base' & design %in% c_plot_designs_tables) |>
  dplyr::filter(num_stories %in% c_plot_stories_tables) |>
  dplyr::select(system, num_stories, design, cost_delta) |>
  dplyr::arrange(system, design, num_stories) |>
  flextable::flextable() |>
  flextable::theme_vanilla() |>
  flextable::align(align = "center", part = "all") |>
  flextable::set_header_labels(
    system = "System",
    design = "Design",
    num_stories = "Stories",
    cost_delta = "Cost Delta"
  ) |>
  flextable::colformat_num(
    j = "cost_delta",
    digits = 1,
    suffix = "%",
    big.mark = ","
  ) |>
  flextable::autofit()

# Save the table
save_table(p, "table-cost-deltas.docx")

# Return the flextable for use in the document
p