# Cost delta figure for multiple systems
c_plot_systems <- c("RCMF", "RCSW", "SMF", "BRBF")
c_plot_stories <- c(4, 12)
c_plot_designs <- c("structural", "nonstructural", "full")

p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_cost_delta(systems = c_plot_systems,
                         designs = c_plot_designs,
                         stories = c_plot_stories)

save_figure("fig-frbca-cost-delta.tif", p)