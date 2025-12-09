w_CONST = 40

approx_derivative <- function(y, x, w) {
  n <- length(y)
  deriv <- numeric(n)
  for (i in seq_len(n)) {
    idx <- max(1, i - w):min(n, i + w)
    x_window <- x[idx]
    y_window <- y[idx]
    fit <- lm(y_window ~ x_window)
    deriv[i] <- coef(fit)[2] # slope
  }
  return(deriv)
}

county_curve <- function(county, w = w_CONST) {
    curve_data <- data_filtered %>%
        filter(recip_county == county) %>%
        # sort in date order
        arrange(date) %>%
        # add columns for the first and second derivatives
        mutate(
            d1 = approx_derivative(pct, date, w = w),
            d2 = approx_derivative(d1, date, w = w)
        ) %>%
        # identify key points: speed up and slow down
        mutate(
            speed_up = d2 == max(d2),
            slow_down = d2 == min(d2)
        ) %>%
        # only return curve data
        select(
            date, pct, d1, d2, speed_up, slow_down
        )
}

county_curve_metrics <- function(county, w = w_CONST) {
    curve_data <- county_curve(county, w)

    # duration of rapid vaccination window
    duration = curve_data$date[curve_data$slow_down] - 
               curve_data$date[curve_data$speed_up]

    # pct at start and stop of rapid vaccination window
    pct_start = curve_data$pct[curve_data$speed_up]
    pct_stop = curve_data$pct[curve_data$slow_down]

    # pct gained during rapid vaccination window
    pct_gained = pct_stop - pct_start

    # avg slope during rapid vaccination window
    slope = pct_gained / as.numeric(duration)

    # actual dates
    start = curve_data$date[curve_data$speed_up]
    stop = curve_data$date[curve_data$slow_down]

    # max at end of 2021
    pct_max = max(curve_data$pct)

    return(list(
        "county" = county,
        "start" = as.Date(start),
        "pct_start" = pct_start,
        "stop" = as.Date(stop),
        "pct_stop" = pct_stop,
        "duration" = as.numeric(duration),
        "pct_gained" = pct_gained,
        "pct_max" = pct_max,
        "slope" = slope
    ))
}

process_data <- function(data) {
    # identify counties with all zeros
    zero_counties <- data %>%
        group_by(recip_county) %>%
        summarize(
            max_pct = max(series_complete_pop_pct, na.rm = TRUE)
        ) %>%
        filter(max_pct == 0) %>%
        pull(recip_county)

    data_filtered <- data %>%
        # filter out unknown and zero counties
        filter(recip_county != "Unknown County", !(recip_county %in% zero_counties)) %>%
        # reduce only to columns we'll use
        select(
            date, fips, recip_county,
            series_complete_pop_pct,
            completeness_pct, 
            census2019
        ) %>%
        # rename series_complete_pop_pct to pct for ease of use
        rename(pct = series_complete_pop_pct)

    return(data_filtered)
}