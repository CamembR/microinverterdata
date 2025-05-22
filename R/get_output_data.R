#' Get inverter output data
#'
#' @inheritParams get_device_info
#' @param model the inverter device model. Currently only "APSystems"
#'  "Enphase-Envoy", "Enphase-Energy" and "Fronius" are supported.
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
#' @importFrom dplyr mutate across ends_with rename select everything
#' @importFrom tidyr pivot_longer separate_wider_regex pivot_wider
#' @importFrom purrr map_dfr
#' @importFrom units set_units
#' @importFrom rlang .data
#'
get_output_data <- function(device_ip, model = "APSystems", ...) {
  switch(model,
         APSystems = get_output_data_APSystems(device_ip),
         "Enphase-Envoy" = get_output_data_Enphase_Envoy(device_ip),
         "Enphase-Energy" = get_output_data_Enphase_Energy(device_ip),
         Fronius = get_output_data_Fronius(device_ip),
         get_output_data_default(device_ip, model)
  )
}


# Method for APSystems model
get_output_data_APSystems <- function(device_ip) {
  out_tbl <- query_ap_devices(device_ip, "getOutputData") |>
    pivot_longer(!"device_id") |>
    separate_wider_regex("name", patterns = c("metric" = "\\D+","inverter" = "\\d+")) |>
    pivot_wider(names_from = "metric", values_from = "value")|>
    rename(output_power = "p", today_energy = "e", lifetime_energy = "te")

  out_tbl <- mutate(out_tbl,
         across(ends_with("_power"), \(x) set_units(x, "W")),
         across(ends_with("_energy"), \(x) set_units(x, "kW.h"))
  )

  return(out_tbl)
}

# Method for Enphase-Envoy model
get_output_data_Enphase_Envoy <- function(device_ip) {
  out_tbl <- map_dfr(device_ip, ~query_enphaseenvoy_device(.x, "reports/production") |>
                       select(-reportType) |>
                       pivot_longer(!c(device_id, createdAt)) |>
                       separate_wider_regex(name, patterns = c(type = "^\\w+", ".", metric = "\\w+$")) |>
                       pivot_wider(names_from = "metric", values_from = "value")|>
                       rename(output_power = "apprntPwr", today_energy = "whRcvdCum",
                              lifetime_energy = "whDlvdCum", last_report = "createdAt") |>
                       select(device_id, last_report, type, contains("_"))
  )
  out_tbl <- mutate(out_tbl,
                    last_report = as.POSIXct(.data$last_report),
                    # TODO BUG may fail if not parsed as number
                    across(ends_with("_power"), \(x) set_units(x, "W")),
                    across(ends_with("_energy"), \(x) set_units(x, "W.h"))
  )

  return(out_tbl)
}

# Method for Enphase-Energy model
get_output_data_Enphase_Energy <- function(device_ip) {
  out_tbl <- map_dfr(device_ip, ~query_enphaseenergy_device(.x, "stream/meter") |>
                       pivot_longer(!"device_id") |>
                       separate_wider_regex(name, patterns = c(name = ".*tion", ".", phase = "ph\\.\\w", ".", metric = "\\w$")) |>
                       pivot_wider(names_from = "metric", values_from = "value") |>
                       rename(power = "p", voltage = "v", current = "i")
  )

  out_tbl <- mutate(out_tbl,
                    last_report = Sys.time(),
                    across(ends_with("power"), \(x) set_units(x, "W")),
                    across(ends_with("voltage"), \(x) set_units(x, "V")),
                    across(ends_with("current"), \(x) set_units(x, "A"))
  ) |>
    select("device_id", "last_report", everything())

  return(out_tbl)
}

# Method for Fronius model
get_output_data_Fronius <- function(device_ip) {
  out_tbl <- query_fronius_devices(device_ip, "GetInverterRealtimeData.cgi?Scope=System") |>
    rename(output_power = "PAC.1", today_energy = "DAY_ENERGY.1",
           year_energy = "YEAR_ENERGY.1", lifetime_energy = "TOTAL_ENERGY.1"
    ) |>
    select(-ends_with(".Unit"))

  out_tbl <- mutate(out_tbl,
                    last_report = as.POSIXct(.data$last_report),
                    across(ends_with("_power"), \(x) set_units(x, "W")),
                    across(ends_with("_energy"), \(x) set_units(x, "W.h"))
  )

  return(out_tbl)
}

# Fallback method for unsupported models
get_output_data_default <- function(device_ip, model = "APSystems", ...) {
  cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                   cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                   "to get support")
  )
}

