#' Get inverter device information
#'
#' @param device_ip list or vector of devices IP address
#' @param model the inverter device model. Currently only "APSystems" is supported.
#'
#' @return a data-frame with one row of device information per `device_id` answering the query.
#' @export
#' @importFrom dplyr mutate across starts_with filter
#' @importFrom tidyr pivot_longer separate_wider_regex pivot_wider
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_device_info(c("192.168.0.12", "192.168.0.230"))
#' }
get_device_info <- function(device_ip, model = "APSystems") {
  if (model == "APSystems") {
    query_ap_devices(device_ip, "getDeviceInfo")[,c(1,3:7)]

  } else if (model == "Fronius") {
    info_cols <- c("CustomName","DT","PVPower", "Show", "UniqueID")
    query_fronius_devices(device_ip, "GetInverterInfo.cgi?Scope=System") |>
      mutate(across(starts_with("X"), as.character)) |>
      pivot_longer(cols = starts_with("X")) |>
      separate_wider_regex("name", patterns = c(".", inverter = "\\d+",".", info = "\\D+$")) |>
      filter(.data$info %in% info_cols) |>
      pivot_wider(names_from = "info", values_from = "value") # |>
      # TODO need to filter out all empty rows
      # filter(across(info_cols), ~!is.na(.))

  } else {
    cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                   cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                   "to get support")
    )
  }
}
