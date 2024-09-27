#' AP System single device query
#'
#' @param device_ip IP address of the APSystem device
#' @param query the API query string
#'
#' @return a data-frame with a `device_id` column and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc
#'
#' @examplesIf FALSE
#' query_ap_device(device_ip = "192.168.0.234", query = "getDeviceInfo")
query_ap_device <- function(device_ip, query) {
  stopifnot("device_IP shall be an atomic character string" = length(device_ip) == 1)
  url <- glue::glue("http://{device_ip}:8050/{query}")
  req <- request(url)
  resp <- req |> req_perform()
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
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc
#' @importFrom purrr map map_lgl map_dfr
#'
#' @examplesIf FALSE
#' query_ap_devices(device_ip = c("192.168.0.234", "192.168.0.235"),
#'                  query = "getDeviceInfo"
#'                  )
query_ap_devices <- function(device_ip, query) {
  url <- glue::glue("http://{unique(device_ip)}:8050/{query}")
  resp <- map(url, ~.x |> request() |> req_perform(error_call = rlang::caller_env()))
  response_is_error <- map_lgl(resp, resp_is_error)
  if (any(response_is_error)) {
    cli::cli_abort(c("Connection to device {.var device_ip[response_is_error]} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else {
    info_lst <- map(resp, ~.x |> resp_body_json())
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
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc
#'
#' @examplesIf FALSE
#' query_enphase_device(device_ip = "192.168.0.234", query = "getDeviceInfo")
query_enphase_device <- function(device_ip, query, username = Sys.getenv("ENPHASE_USERNAME"), password = Sys.getenv("ENPHASE_PASSWORD")) {
  stopifnot("device_IP shall be an atomic character string" = length(device_ip) == 1)
  url <- glue::glue("http://{device_ip}/api/v1/{query}")
  req <- request(url) |> req_auth_basic(username, password)
  resp <- req |> req_perform()
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var device_ip} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))
  } else {
    info_lst <- resp |> resp_body_json()
    cbind(device_id = info_lst$serialNumber, as.data.frame(info_lst))
  }
}

