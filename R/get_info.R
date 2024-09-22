#' Get inverter device information
#'
#' @inheritParams query_ap_devices
#' @param model the inverter device model. Currrently only "APSystems" is supported.
#'
#' @return a dataframe with one row of device information per `device_id` answering the query.
#' @export
#'
#' @examples
#' get_device_info(c("192.168.0.12", "192.168.0.230"))
get_device_info <- function(device_ip, model = "APSystems") {
  if (model == "APSystems") {
    query_ap_devices(device_ip, "getDeviceInfo")[,c(1,3:7)]
  } else {
    cli::cli_abort(c("Your device model {.var model} is not supported yet. Please raise an ",
                   cli::style_hyperlink("issue", "https://github.com/CamembR/microinverterdata/issues/new/choose"),
                   "to get support")
    )
  }
}
