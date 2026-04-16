# Unit costs scatter
p1 <- out_frbca |>
  dplyr::bind_rows() |>
  dplyr::mutate(c_s_unit = construction/total_area) |>
  ggplot(aes(x = num_stories, y = c_s_unit)) +
  geom_point(aes(shape = design, colour = design)) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  facet_wrap(~ system, nrow = 2) +
  scale_y_continuous(labels = scales::dollar) +
  ggthemes::theme_few(base_size = 10) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12)
  ) +
  ggplot2::labs(
    shape = "",
    colour = "",
    x = "Stories",
    y = c(expression(C[C]~{"(in dollars per square foot)"})))

save_figure("fig-scatter-unit-costs.tif", p1, width = 6, height = 4)

# Cost deltas scatter
p2 <- out_frbca |>
  dplyr::bind_rows() |>
  dplyr::mutate(design = factor(design, levels = c(b_plot_designs, "full"))) |>
  ggplot(aes(x = num_stories, y = cost_delta)) +
  geom_point(aes(shape = design, colour = design)) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  facet_wrap(~ system, nrow = 2) +
  scale_y_continuous(labels = scales::percent) +
  ggthemes::theme_few(base_size = 10) +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 12),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12)
  ) +
  ggplot2::labs(
    shape = "",
    colour = "",
    x = "Stories",
    y = c(expression(Delta~C[C])))

save_figure("fig-scatter-cost-deltas.tif", p2, width = 6, height = 4)