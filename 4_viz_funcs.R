my_theme <- function(title_bold = FALSE) {
  theme_bw() +
  theme(
    strip.placement = "outside",
    strip.text.y.left = element_text(angle = 0),
    text = element_text(size = 14),
    plot.title = element_text(size = 16, face = ifelse(title_bold, "bold", "plain"))
  )
}

plot_county_curve <- function(county, w = 30, derivs = TRUE) {
  facet_labels <- c(
    'Pct Fully\nVaccinated',
    'First\nDerivative',
    'Second\nDerivative'
  )
  curve_data <- county_curve(county, w)
  curve_data_long <- curve_data %>%
  pivot_longer(
    cols = c(pct, d1, d2)
  ) %>%
  mutate(
    name = factor(
      name,
      levels = c('pct','d1','d2'),
      labels = facet_labels
    )
  ) 
  if (!derivs) {
  curve_data_long <- curve_data_long %>%
    filter(name == 'Pct Fully\nVaccinated')
  }
  curve_data_long %>%
  ggplot(aes(x = date, y = value)) +
  ggh4x::facet_grid2(
    rows = vars(name), switch = "y",
    scales = "free"
  ) +
  geom_point() +
  ggtitle(county) +
  # vertical red dashed lines at speed_up and slow_down
  geom_vline(
    data = curve_data %>% filter(speed_up | slow_down),
    aes(xintercept = date),
    color = 'red',
    linetype = 'dashed'
  ) +
  # horizontal red dashed lines at pct for speed_up and slow_down
  geom_hline(
    data = curve_data %>% 
      filter(speed_up | slow_down) %>%
      # only include it for the pct facet
      mutate(
        name = factor(
          "pct", 
          levels = c('pct','d1','d2'), 
          labels = facet_labels
        )
      ),
    aes(yintercept = pct),
    color = 'red',
    linetype = 'dashed'
  ) +
  my_theme() +
  labs(
    x = "",
    y = "",
    title = paste("Vaccination Curve for", county, "\nRed dashed lines indicate boarders of rapid vaccination phase")
  ) +
  # rescale pct facet to 0-100 with ggh4x facetted_pos_scales
  ggh4x::facetted_pos_scales(
    y = list(
      name = scale_y_continuous(limits = c(0, 100))
    )
  )
}