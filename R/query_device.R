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
#' @examples
#' \dontrun{
#' query_ap_device(device_ip = "192.168.0.234", query = "getDeviceInfo")
#' }
query_ap_device <- function(device_ip, query) {
  check_device_ip(device_ip)
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
#' @examples
#' \dontrun{
#' query_ap_devices(device_ip = c("192.168.0.234", "192.168.0.235"),
#'                  query = "getDeviceInfo"
#'                  )
#' }
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
#' @return a data-frame with a `device_id` column and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc
#'
#' @examples
#' \dontrun{
#' query_fronius_device(device_ip = "192.168.0.234", query = "getDeviceInfo")
#' }
query_fronius_device <- function(device_ip, query, username = Sys.getenv("FRONIUS_USERNAME"), password = Sys.getenv("FRONIUS_PASSWORD")) {
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

check_device_ip <- function(device_ip) {
  stopifnot("device_IP shall be an atomic character string" = length(device_ip) == 1)
  stopifnot("device_IP shall be of a minimal character length" = nchar(device_ip) >= 3)


}
