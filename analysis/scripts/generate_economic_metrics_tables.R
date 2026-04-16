# Economic metrics table for multiple systems
# Returns a flextable and saves as .docx in analysis/output/tables directory

# Assume out_frbca is available in the environment
p <- out_frbca |>
  dplyr::bind_rows() |>
  dplyr::filter(label=='base' & design %in% c_plot_designs_tables) |>
  dplyr::filter(num_stories %in% c_plot_stories_tables) |>
  dplyr::select(system, num_stories, design, total_area,
                bcr, npv, aroi, irr) |>
  dplyr::mutate(
           bcr=scales::number(bcr, accuracy=0.1),
           npv=scales::dollar(npv, accuracy=1000),
           aroi=scales::percent(aroi, accuracy=0.1),
           irr=scales::percent(irr, accuracy=0.1)) |>
  dplyr::select(!total_area) |>
  flextable::flextable() |>
  flextable::align(align = "right", part = "all")

ft_metrics = flextable::set_table_properties(p,
                                             width=1,
                                             layout="autofit")

# Save the table
save_table(ft_metrics, "table-economic-metrics.docx")

# Return the flextable for use in the document
ft_metrics
