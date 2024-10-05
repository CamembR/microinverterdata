#' AP System single device query
#'
#' @param device_ip IP address of the APSystem device
#' @param query the API query string
#'
#' @return a data-frame with a `device_id` column and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request response req_perform resp_is_error
#' @importFrom httr2 resp_body_json resp_status resp_status_desc
#' @importFrom purrr possibly
#'
#' @examples
#' \dontrun{
#' query_ap_device(device_ip = "192.168.0.234", query = "getDeviceInfo")
#' }
query_ap_device <- function(device_ip, query) {
  check_device_ip(device_ip)
  url <- glue::glue("http://{device_ip}:8050/{query}")
  req <- request(url)
  resp <- possibly(req |> req_perform(), otherwise = response(504))
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var device_ip} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))
  } else {
    info_lst <- resp |> resp_body_json()
    cbind(device_id = info_lst$deviceId, as.data.frame(info_lst$data))
  }
}

#' AP System multi-device query
#'
#' @param device_ip list or vector of each APSystem device IP address
#' @param query the API query string
#'
#' @return a data-frame with a row for each `device_id`, and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request response req_perform resp_is_error
#' @importFrom httr2 resp_body_json resp_status resp_status_desc
#' @importFrom purrr map map_lgl map_dfr possibly
#'
#' @examples
#' \dontrun{
#' query_ap_devices(device_ip = c("192.168.0.234", "192.168.0.235"),
#'                  query = "getDeviceInfo"
#'                  )
#' }
query_ap_devices <- function(device_ip, query) {
  url <- glue::glue("http://{unique(device_ip)}:8050/{query}")
  resp <- map(url, possibly(~.x |> request() |> req_perform(error_call = rlang::caller_env()),
                            otherwise = response(504))
  )
  response_is_error <- map_lgl(resp, resp_is_error)
  if (any(response_is_error)) {
    cli::cli_warn(c("Connection to device {.var device_ip[response_is_error]} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else {
    info_lst <- map(resp[!response_is_error], ~.x |> resp_body_json())
    map_dfr(info_lst, ~cbind(device_id = .x$deviceId, as.data.frame(.x$data))
    )
  }
}


#' Enphase single device query
#'
#' as a port of https://github.com/mr-manuel/venus-os_dbus-enphase-envoy/tree/master#json-structure
#'
#' @param device_ip IP address of the Enphase device
#' @param query the API query string
#' @param username the username needed to authenticate to the inverter.
#'  Defaults to the `ENPHASE_USERNAME` environment variable.
#' @param password the password needed to authenticate to the inverter.
#'  Defaults to the `ENPHASE_PASSWORD` environment variable.
#'
#' @return a data-frame with a `device_id` column and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc req_auth_basic response
#' @importFrom purrr possibly
#'
#' @examples
#' \dontrun{
#' query_enphase_device(device_ip = "192.168.0.234", query = "production/inverters/")
#' }
query_enphase_device <- function(device_ip = "enphase.local", query, username = Sys.getenv("ENPHASE_USERNAME"), password = Sys.getenv("ENPHASE_PASSWORD")) {
  check_device_ip(device_ip)
  url <- glue::glue("http://{device_ip}/api/v1/{query}")
  req <- request(url) |> req_auth_basic(username, password)
  resp <- req |> req_perform()
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var device_ip} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else {
    info_lst <- resp |> resp_body_json()

    if (info_lst[["production"]][[1]][["activeCount"]] > 0) {
      cbind(device_id = info_lst$serialNumber, as.data.frame(info_lst))
    } else {
      cli::cli_abort(c("the Enphase device {.var device_ip} does not have the correct Metering setup"))
    }
  }
}


#' Fronius single device query
#'
#' as a port of https://github.com/friissoren/pyfronius
#'
#' @param device_ip IP address of the Fronius device
#' @param query the API query string
#' @param username the username needed to authenticate to the inverter.
#'  Defaults to the `FRONIUS_USERNAME` environment variable.
#' @param password the password needed to authenticate to the inverter.
#'  Defaults to the `FRONIUS_PASSWORD` environment variable.
#'
#' @return a data-frame with a `device_id` column and the `$Body$Data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc req_auth_basic response
#' @importFrom purrr possibly
#'
#' @examples
#' \dontrun{
#' query_fronius_device(query = "GetInverterRealtimeData.cgi?Scope=System")
#' }
query_fronius_device <- function(device_ip = "fronius.local", query, username = Sys.getenv("FRONIUS_USERNAME"), password = Sys.getenv("FRONIUS_PASSWORD")) {
  check_device_ip(device_ip)
  url <- glue::glue("http://{device_ip}/solar_api/v1/{query}")
  req <- request(url) |> req_auth_basic(username, password)
  resp <- req |> req_perform()
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var device_ip} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else {
    info_lst <- resp |> resp_body_json()

    if (info_lst[["Head"]][["Status"]][["Code"]] == 0) {
      cbind(device_id = device_ip, last_report = info_lst$Head$Timestamp, as.data.frame(info_lst$Body$Data))
    } else {
      cli::cli_abort(c("the Fronius device {.var device_ip} does not have the correct Metering setup"))
    }
  }
}

check_device_ip <- function(device_ip) {
  stopifnot("device_IP shall be an atomic character string" = length(device_ip) == 1)
  stopifnot("device_IP shall be of a minimal character length" = nchar(device_ip) >= 3)
  # TODO minimal IP validation device_IP shall contain at least a  \. or at least two \:
  # TODO use a proper IP address validation function
}
