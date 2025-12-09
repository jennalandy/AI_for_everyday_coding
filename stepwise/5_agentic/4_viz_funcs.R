plot_county_curve <- function(county, data_filtered = NULL, deriv = TRUE, w = NULL) {
    suppressPackageStartupMessages(requireNamespace("dplyr",   quietly = TRUE))
    suppressPackageStartupMessages(requireNamespace("tidyr",   quietly = TRUE))
    suppressPackageStartupMessages(requireNamespace("ggplot2", quietly = TRUE))
    suppressPackageStartupMessages(requireNamespace("ggh4x",   quietly = TRUE))

    if (is.null(data_filtered)) {
        data_filtered <- get("data_filtered", inherits = TRUE)
    }

    curve_data <- county_curve(data_filtered, county, w = w)
    facet_order <- c("pct", "d1", "d2")
    curve_data_long <- curve_data %>%
        tidyr::pivot_longer(cols = c(pct, d1, d2)) %>%
        dplyr::mutate(name = factor(name, levels = facet_order))

    if (!deriv) {
        curve_data_long <- curve_data_long %>%
            dplyr::filter(name == "pct")
    }

    gg <- ggplot2::ggplot(curve_data_long, ggplot2::aes(x = date, y = value)) +
        ggh4x::facet_grid2(rows = ggplot2::vars(name), scales = "free_y") +
        ggplot2::geom_point() +
        ggplot2::geom_vline(
            data = curve_data %>% dplyr::filter(speed_up | slow_down),
            ggplot2::aes(xintercept = date),
            linetype = "dashed",
            color = "red"
        ) +
        ggplot2::geom_hline(
            data = curve_data %>%
                dplyr::filter(speed_up | slow_down) %>%
                dplyr::mutate(name = factor("pct", levels = facet_order)),
            ggplot2::aes(yintercept = pct),
            linetype = "dashed",
            color = "red"
        ) +
        ggplot2::theme_bw() +
        ggh4x::facetted_pos_scales(
            y = list(
                name == "pct" ~ ggplot2::scale_y_continuous(limits = c(0, 100)),
                name == "d1" ~ ggplot2::scale_y_continuous(),
                name == "d2" ~ ggplot2::scale_y_continuous()
            )
        ) +
        ggplot2::ggtitle(county)

    gg
}

save_county_curve_plot <- function(county, file_path, data_filtered = NULL, deriv = TRUE, w = NULL) {
    suppressPackageStartupMessages(requireNamespace("ggplot2", quietly = TRUE))
    p <- plot_county_curve(county, data_filtered = data_filtered, deriv = deriv, w = w)
    ggplot2::ggsave(filename = file_path, plot = p, width = 8, height = 6, dpi = 150)
    invisible(file_path)
}


