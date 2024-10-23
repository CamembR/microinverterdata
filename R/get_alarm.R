#' Get inverter device alarms
#'
#' @inheritParams get_device_info
#'
#' @return a dataframe with one row of device information per `device_id` answering the query.
#' @export
#' @importFrom dplyr mutate across starts_with filter case_when
#' @importFrom tidyr pivot_longer separate_wider_regex pivot_wider
#' @importFrom purrr vec_depth
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_alarm(c("192.168.0.12", "192.168.0.230"))
#' }
get_alarm <- function(device_ip, model = "APSystems") {
  switch(model,
         APSystems = get_alarm_APSystems(device_ip),
         Fronius = get_alarm_Fronius(device_ip),
         get_alarm_default(model)
  )
}


# Method for APSystems model
get_alarm_APSystems <- function(device_ip) {
  query_ap_devices(device_ip, "getAlarm") |>
    dplyr::mutate_at(2:5, \(x) readr::parse_integer(x)) |>
    dplyr::rename(
      off_grid = "og", dc_input_1_shot_circuit = "isce1",
      non_operating = "oe", dc_input_2_shot_circuit = "isce2",
    )
}

# Method for Fronius model
get_alarm_Fronius <- function(device_ip) {
  info_cols <- c("CustomName","DT","ErrorCode", "Show", "StatusCode")
  query_fronius_devices(device_ip, "GetInverterInfo.cgi?Scope=System") |>
    mutate(across(starts_with("X"), as.character)) |>
    pivot_longer(cols = starts_with("X")) |>
    separate_wider_regex("name", patterns = c(".", inverter = "\\d+",".", info = "\\D+$")) |>
    filter(.data$info %in% info_cols) |>
    pivot_wider(names_from = "info", values_from = "value")
}

# Default method if the model is not supported
get_alarm_default <- function(model) {
  cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                   cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                   "to get support")
  )
}
