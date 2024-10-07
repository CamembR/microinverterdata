#' Get inverter output data
#'
#' @inheritParams get_device_info
#' @param model the inverter device model. Currently only "APSystems"
#'  "Enphase-Envoy-S" and "Fronius" are supported.
#' @param ... additional parameters passed to the inverter if needed.
#'
#' @return a dataframe with one row of device output power and energy per
#'   `device_id` / `inverter` combination.
#' @export
#'
#' @examples
#' \dontrun{
#' get_output_data(c("192.168.0.12", "192.168.0.230"))
#' }
#'
#' @importFrom dplyr mutate across ends_with rename select ends_with
#' @importFrom tidyr pivot_longer separate_wider_regex pivot_wider
#' @importFrom purrr map_dfr
#' @importFrom units set_units
#' @importFrom rlang .data
#'
get_output_data <- function(device_ip, model = "APSystems", ...) {

  if (model == "APSystems") {
    out_tbl <- query_ap_devices(device_ip, "getOutputData") |>
      pivot_longer(!device_id) |>
      separate_wider_regex("name", patterns = c("metric" = "\\D+","inverter" = "\\d+")) |>
      pivot_wider(names_from = "metric", values_from = "value")|>
      rename(output_power = "p", today_energy = "e", lifetime_energy = "te")
    mutate(out_tbl,
           across(ends_with("_power"), \(x) set_units(x, "W")),
           across(ends_with("_energy"), \(x) set_units(x, "kW/h"))
    )

  } else if (model == "Enphase-Envoy-S") {
    out_tbl <- map_dfr(device_ip, ~query_enphaseenvoy_device(.x, "production/inverters/") |>
      rename(output_power = "lastReportWatts", output_max_power = "maxReportWatts",
             last_report = "lastReportDate"
      ))
    mutate(out_tbl,
           last_report = as.POSIXct(last_report),
           # TODO BUG may fail if not parsed as number
           across(ends_with("_power"), \(x) set_units(x, "W"))
    )

  } else if (model == "Enphase-Energy") {
    out_tbl <- map_dfr(device_ip, ~query_enphaseenergy_device(.x, "stream/meter") |>
      rename(output_power = "lastReportWatts", output_max_power = "maxReportWatts",
             last_report = "lastReportDate"
      ))
    mutate(out_tbl,
           last_report = as.POSIXct(last_report),
           # TODO BUG may fail if not parsed as number
           across(ends_with("_power"), \(x) set_units(x, "W"))
    )

  } else if (model == "Fronius") {
    out_tbl <- query_fronius_devices(device_ip, "GetInverterRealtimeData.cgi?Scope=System") |>
      rename(output_power = "PAC.1", today_energy = "DAY_ENERGY.1",
             year_energy = "YEAR_ENERGY.1",  lifetime_energy = "TOTAL_ENERGY.1"
      ) |>
      select(-ends_with(".Unit"))
    mutate(out_tbl,
           last_report = as.POSIXct(last_report),
           across(ends_with("_power"), \(x) set_units(x, "W")),
           across(ends_with("_energy"), \(x) set_units(x, "kW/h"))
    )

  } else {
    cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                     cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                     "to get support")
    )
  }
}

