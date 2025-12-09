approx_derivative <- function(y, x, w = NULL) {
    if (is.null(w)) {
        w <- tryCatch({
            if (exists("params", inherits = TRUE) && !is.null(params$window_w)) {
                as.integer(params$window_w)
            } else {
                40L
            }
        }, error = function(e) 40L)
    }
    n <- length(x)
    dy_dx <- rep(NA_real_, n)
    for (i in seq_len(n)) {
        lower <- max(1L, i - w)
        upper <- min(n, i + w)
        x_window <- x[lower:upper]
        y_window <- y[lower:upper]
        if (length(x_window) >= 2 && any(is.finite(x_window)) && any(is.finite(y_window))) {
            fit <- stats::lm(y_window ~ x_window)
            dy_dx[i] <- stats::coef(fit)[2]
        } else {
            dy_dx[i] <- NA_real_
        }
    }
    dy_dx
}

process_data <- function(data) {
    suppressPackageStartupMessages(requireNamespace("dplyr", quietly = TRUE))
    suppressPackageStartupMessages(requireNamespace("tidyr", quietly = TRUE))

    data %>%
        dplyr::mutate(date = as.Date(date)) %>%
        dplyr::group_by(recip_county) %>%
        dplyr::mutate(series_complete_pop_pct = as.numeric(series_complete_pop_pct)) %>%
        dplyr::ungroup() %>%
        dplyr::group_by(recip_county) %>%
        dplyr::summarize(
            max_pct = max(tidyr::replace_na(series_complete_pop_pct, 0), na.rm = TRUE),
            .groups = "drop"
        ) %>%
        dplyr::filter(max_pct == 0) %>%
        dplyr::pull(recip_county) -> zero_counties

    data %>%
        dplyr::mutate(date = as.Date(date)) %>%
        dplyr::filter(
            recip_county != "Unknown County",
            !recip_county %in% zero_counties
        ) %>%
        dplyr::select(date, fips, recip_county, series_complete_pop_pct) %>%
        dplyr::rename(pct = series_complete_pop_pct) %>%
        dplyr::mutate(pct = as.numeric(pct)) %>%
        dplyr::arrange(recip_county, date)
}

county_curve <- function(data_filtered, county, w = NULL) {
    suppressPackageStartupMessages(requireNamespace("dplyr", quietly = TRUE))

    df <- data_filtered %>%
        dplyr::filter(recip_county == county) %>%
        dplyr::arrange(date)

    if (nrow(df) == 0) {
        stop(paste0("No data available for county: ", county))
    }

    d1 <- approx_derivative(df$pct, as.numeric(df$date), w = w)
    d2 <- approx_derivative(d1,       as.numeric(df$date), w = w)

    # Find unique indices for speed-up and slow-down
    idx_max <- which.max(d2)
    idx_min <- which.min(d2)

    df %>%
        dplyr::mutate(
            d1 = d1,
            d2 = d2,
            speed_up = dplyr::row_number() == idx_max,
            slow_down = dplyr::row_number() == idx_min
        )
}

county_curve_metrics <- function(data_filtered, county, w = NULL) {
    suppressPackageStartupMessages(requireNamespace("dplyr", quietly = TRUE))
    cd <- county_curve(data_filtered, county, w = w)

    idx_max <- which.max(cd$d2)
    idx_min <- which.min(cd$d2)

    start_date <- cd$date[idx_max]
    stop_date  <- cd$date[idx_min]
    duration   <- as.numeric(stop_date - start_date)
    start_pct  <- cd$pct[idx_max]
    stop_pct   <- cd$pct[idx_min]
    pct_increase <- stop_pct - start_pct
    avg_slope    <- if (is.finite(duration) && duration != 0) pct_increase / duration else NA_real_
    max_pct      <- max(cd$pct, na.rm = TRUE)

    data.frame(
        county = as.character(county),
        start = as.Date(start_date),
        stop = as.Date(stop_date),
        duration = as.numeric(duration),
        start_pct = as.numeric(start_pct),
        stop_pct = as.numeric(stop_pct),
        pct_increase = as.numeric(pct_increase),
        avg_slope = as.numeric(avg_slope),
        max_pct = as.numeric(max_pct),
        stringsAsFactors = FALSE
    )
}


