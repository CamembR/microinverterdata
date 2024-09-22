#' Get inverter output data
#'
#' @inheritParams get_device_info
#'
#' @return a dataframe with one row of device output power and energy per
#'   `device_id` / `inverter` combination.
#' @export
#'
#' @examplesIf FALSE
#' get_output_data(c("192.168.0.12", "192.168.0.230"))
#'
#' @importFrom dplyr mutate across ends_with rename
#' @importFrom tidyr pivot_longer separate pivot_wider
#' @importFrom units set_units
#' @importFrom rlang .data
#'
get_output_data <- function(device_ip, model = "APSystems") {
  if (model == "APSystems") {
    out_tbl <- query_ap_devices(device_ip, "getOutputData") |>
      rename(inverter_1_output_power = "p1", inverter_1_current_energy = "e1",
                    inverter_1_lifetime_energy = "te1", inverter_2_output_power = "p2",
                    inverter_2_current_energy = "e2", inverter_2_lifetime_energy = "te2"
      ) |>
      pivot_longer(2:7) |>
      separate(.data$name, into = c("inverter", "metric"), sep = "(?<=\\d)_") |>
      pivot_wider(names_from = .data$metric, values_from = .data$value)
    mutate(out_tbl,
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

