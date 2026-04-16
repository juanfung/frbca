# Single system BCR sensitivity for RCMF (4 stories)
p <- out_frbca[["RCMF"]] |>
  dplyr::bind_rows() |>
  frbca::plot_bcr_sensitivity(
           systems = "RCMF",
           designs = b_plot_designs,
           stories = 4)

save_figure("fig-sensitivity-rcmf-4.tif", p)