# Total EALs for multiple systems
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_eal(systems = c_plot_systems, designs = f_plot_designs, stories = c_plot_stories)

save_figure("fig-frbca-eal-all.tif", p)

# Total EALs weighted by project cost
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_eal_weighted(systems = c_plot_systems, designs = f_plot_designs, stories = c_plot_stories, w = "project")

save_figure("fig-frbca-eal-weighted-project.tif", p)

# Total EALs weighted by total area
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_eal_weighted(systems = c_plot_systems, designs = f_plot_designs, stories = c_plot_stories, w = "total_area")

save_figure("fig-frbca-eal-weighted-total-area.tif", p)

# Total EALs weighted by number of stories
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_eal_weighted(systems = c_plot_systems, designs = f_plot_designs, stories = c_plot_stories, w = "num_stories")

save_figure("fig-frbca-eal-weighted-num-stories.tif", p)

# By loss for 4-story
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_eal_by_loss(
    systems = c_plot_systems,
    designs = f_plot_designs,
    stories = 4)

save_figure("fig-frbca-eals-by-loss-4.tif", p)

# By loss for 12-story
p <- out_frbca |>
  dplyr::bind_rows() |>
  frbca::plot_eal_by_loss(
    systems = c_plot_systems,
    designs = f_plot_designs,
    stories = 12)

save_figure("fig-frbca-eals-by-loss-12.tif", p)