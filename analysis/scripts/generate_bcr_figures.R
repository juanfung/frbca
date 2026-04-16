# Baseline BCRs for all systems
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_bcr(
    designs = c_plot_designs,
    systems = c_plot_systems,
    stories = c_plot_stories)

save_figure("fig-frbca-bcrs.tif", p)

# Sensitivity analysis for multiple systems (4-story)
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_bcr_sensitivity(
    systems = c_plot_systems,
    designs = b_plot_designs,
    stories = 4)

save_figure("fig-sensitivity-all-4.tif", p)

# Sensitivity analysis for multiple systems (12-story)
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_bcr_sensitivity(
    systems = c_plot_systems,
    designs = b_plot_designs,
    stories = 12)

save_figure("fig-sensitivity-all-12.tif", p)

# Full intervention sensitivity (4-story)
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_bcr_sensitivity(
    systems = c_plot_systems,
    designs = c("full"),
    stories = 4)

save_figure("fig-sensitivity-full-4.tif", p)

# Full intervention sensitivity (12-story)
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_bcr_sensitivity(
    systems = c_plot_systems,
    designs = c("full"),
    stories = 12)

save_figure("fig-sensitivity-full-12.tif", p)

# Single system BCR sensitivity for RCMF (4 stories) - for backward compatibility
p_single <- out_frbca[["RCMF"]] |>
  dplyr::bind_rows() |>
  frbca::plot_bcr_sensitivity(
           systems = "RCMF",
           designs = b_plot_designs,
           stories = 4)

save_figure("fig-sensitivity-rcmf-4.tif", p_single)