# Performance metrics table for multiple systems
# Returns a flextable and saves as .docx in analysis/output/tables directory

# Assume out_frbca is available in the environment
p <- out_frbca |>
  dplyr::bind_rows() |>
  dplyr::select(system, design, num_stories, eal_diff, bcr) |>
  dplyr::arrange(system, design, num_stories) |>
  flextable::flextable() |>
  flextable::theme_vanilla() |>
  flextable::align(align = "center", part = "all") |>
  flextable::set_header_labels(
    system = "System",
    design = "Design",
    num_stories = "Stories",
    eal_diff = "EAL",
    bcr = "BCR"
  ) |>
  flextable::colformat_num(
    j = c("eal_diff", "bcr"),
    digits = 2,
    suffix = "",
    big.mark = ","
  ) |>
  flextable::autofit()

# Save the table
save_table(p, "table-performance-metrics.docx")

# Return the flextable for use in the document
p