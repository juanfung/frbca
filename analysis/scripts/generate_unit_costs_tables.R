# Unit costs table for multiple systems
# Returns a flextable and saves as .docx in analysis/output/tables directory

# Assume out_frbca is available in the environment
p <- out_frbca |>
  dplyr::bind_rows() |>
  dplyr::filter(label == 'base' & design %in% c_plot_designs_unit_costs) |>
  dplyr::filter(num_stories %in% c_plot_stories_tables) |>
  dplyr::mutate(
           c_s=scales::number(c_s/total_area, accuracy=0.01),
           c_ns=scales::number(c_ns/total_area, accuracy=0.01),
           c_c=scales::number(construction/total_area, accuracy=0.01),
           c_p=scales::number(project/total_area, accuracy=0.01)) |>
  dplyr::select(system, num_stories, design, c_s, c_ns, c_c, c_p) |>
  flextable::flextable() |>
  flextable::align(align = "right", part = "all")

ft_unit_c = flextable::set_table_properties(p,
                                             width=1,
                                             layout="autofit")

# Save the table
save_table(ft_unit_c, "table-unit-costs.docx")

# Return the flextable for use in the document
ft_unit_c
