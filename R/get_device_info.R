#' Get inverter device information
#'
#' @param device_ip list or vector of devices IP address
#' @param model the inverter device model. Currently only "APSystems" is supported.
#'
#' @return a data-frame with one row of device information per `device_id` answering the query.
#' @export
#' @importFrom dplyr rename_with
#'
#' @examples
#' \dontrun{
#' get_device_info(c("192.168.0.12", "192.168.0.230"))
#' }
get_device_info <- function(device_ip, model = "APSystems") {
  if (model == "APSystems") {
    query_ap_devices(device_ip, "getDeviceInfo")[,c(1,3:7)]

  } else if (model == "Fronius") {
    query_fronius_devices(device_ip, "GetInverterInfo.cgi?Scope=System") |>
      rename_with(~gsub("X1.", "", .x, fixed = TRUE))

  } else {
    cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                   cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                   "to get support")
    )
  }
}
