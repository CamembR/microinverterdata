#' Get inverter device alarms
#'
#' @inheritParams get_device_info
#'
#' @return a dataframe with one row of device information per `device_id` answering the query.
#' @export
#'
#' @examples
#' \dontrun{
#' get_alarm(c("192.168.0.12", "192.168.0.230"))
#' }
get_alarm <- function(device_ip, model = "APSystems") {
  if (model == "APSystems") {
    query_ap_devices(device_ip, "getAlarm") |>
      dplyr::mutate_at(2:5, \(x) readr::parse_integer(x)) |>
      dplyr::rename(
        off_grid = "og", dc_input_1_shot_circuit = "isce1",
        non_operating = "oe", dc_input_2_shot_circuit = "isce2",
      )
  } else {
    cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                     cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                     "to get support")
    )
  }
}

