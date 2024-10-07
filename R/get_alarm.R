#' Get inverter device alarms
#'
#' @inheritParams get_device_info
#'
#' @return a dataframe with one row of device information per `device_id` answering the query.
#' @export
#' @importFrom dplyr mutate across starts_with filter case_when
#' @importFrom tidyr pivot_longer separate_wider_regex pivot_wider
#' @importFrom purrr vec_depth
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

  } else if (model == "Fronius") {
    info_cols <- c("CustomName","DT","ErrorCode", "Show", "StatusCode")
    query_fronius_devices(device_ip, "GetInverterInfo.cgi?Scope=System") |>
      mutate(across(starts_with("X"), as.character)) |>
      pivot_longer(cols = starts_with("X")) |>
      separate_wider_regex("name", patterns = c(".", inverter = "\\d+",".", info = "\\D+$")) |>
      filter(info %in% info_cols) |>
      pivot_wider(names_from = "info", values_from = "value")


  } else {
    cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                     cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                     "to get support")
    )
  }
}

