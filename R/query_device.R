#' AP System single device query
#'
#' @param device_ip IP address of the APSystem device
#' @param query the API query string
#'
#' @return a data-frame with a `device_id` column and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json
#'
#' @examples
#' query_ap_device(device_ip = "192.168.0.234", query = "getDeviceInfo")
query_ap_device <- function(device_ip, query) {
  url <- glue::glue("http://{device_ip}:8050/{query}")
  req <- request(url)
  resp <- req |> req_perform()
  if (!resp_is_error(resp)) {
    info_lst <- resp |> resp_body_json()
    cbind(device_id = info_lst$deviceId, as.data.frame(info_lst$data))
  }
  # TODO proper error management
}

#' AP System multi-device query
#'
#' @param device_ip list or vector of each APSystem device IP address
#' @param query the API query string
#'
#' @return a data-frame with a row for each `device_id`, and the `$data` turned into
#'    as many columns as expected
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json
#' @importFrom purrr map map_lgl map_dfr
#'
#' @examples
#' query_ap_devices(device_ip = c("192.168.0.234", "192.168.0.234"),
#'                  query = "getDeviceInfo"
#'                  )
query_ap_devices <- function(device_ip, query) {
  url <- glue::glue("http://{device_ip}:8050/{query}")
  resp <- map(url, ~.x |> request() |> req_perform())
  if (!any(map_lgl(resp, resp_is_error))) {
    info_lst <- map(resp, ~.x |> resp_body_json())
    map_dfr(info_lst, ~cbind(device_id = .x$deviceId, as.data.frame(.x$data))
    )
  }
  # TODO proper error management
}

