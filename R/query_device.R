#' AP System single device query
#'
#' @param device_ip IP address or name of the device
#' @param query the API query string
#'
#' @return a data-frame with a `device_id` column and the `$data` turned into
#'    as many columns as expected
#'
#' @family device queries
#'
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
  resp <- req |> req_perform()
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var {device_ip}} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else if (inherits(resp, "httr2_failure")) {
    cli::cli_abort(resp$message)

  } else {
    info_lst <- resp |> resp_body_json()
    cbind(device_id = info_lst$deviceId, as.data.frame(info_lst$data))
  }
}

#' AP System multi-device query
#'
#' @param device_ip list or vector of each device IP address or name
#' @inheritParams query_ap_device
#'
#' @return a data-frame with a `device_id` column and the `$Body$Data` turned into
#'    as many columns as expected
#'
#' @family device queries
#'
#' @export
#' @importFrom httr2 request response req_perform_parallel
#' @importFrom httr2 resp_body_json resp_status resp_status_desc
#' @importFrom purrr map map_lgl map_dfr walk
#'
#' @examples
#' \dontrun{
#' query_ap_devices(device_ip = c("192.168.0.234", "192.168.0.235"),
#'                  query = "getDeviceInfo"
#'                  )
#' }
query_ap_devices <- function(device_ip, query) {
  walk(device_ip, check_device_ip)
  req_url <- lapply(unique(device_ip), function(x) request(paste0("http://",x,":8050/",query)))
  resp <- req_url |> req_perform_parallel(on_error = "continue")
  response_is_error <- map_lgl(resp, inherits, "httr2_failure")

  if (all(response_is_error)) {
    cli::cli_abort("Connection to all devices raised an error.")
  }

  if (any(response_is_error)) {
    cli::cli_warn(c(
      "Connection to device {.var {device_ip[response_is_error]}} raise an error : ",
      "{map(which(response_is_error), ~resp_status(resp[[.x]]))} {map(which(response_is_error), ~resp_status_desc(resp[[.x]]))}."
      ))
  }

  info_lst <- map(resp[!response_is_error], ~.x |> resp_body_json())
  map_dfr(info_lst, ~cbind(device_id = .x$deviceId, as.data.frame(.x$data)))

}


#' Enphase Envoy single device query
#'
#' as a port of https://github.com/Matthew1471/Enphase-API/blob/main/Documentation/IQ Gateway API/IVP/Meters/Reports/Production.adoc
#'
#' @inheritParams query_ap_device
#' @param username the username needed to authenticate to the inverter.
#'  Defaults to the `ENPHASE_USERNAME` environment variable.
#' @param password the password needed to authenticate to the inverter.
#'  Defaults to the `ENPHASE_PASSWORD` environment variable.
#'
#' @return a data-frame with a `device_id` column and the `$Body$Data` turned into
#'    as many columns as expected
#'
#' @family device queries
#'
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc req_auth_basic response
#' @importFrom purrr possibly
#'
#' @examples
#' \dontrun{
#' query_enphaseenvoy_device(query = "reports/production")
#' }
query_enphaseenvoy_device <- function(device_ip = "enphase.local", query, username = Sys.getenv("ENPHASE_USERNAME"), password = Sys.getenv("ENPHASE_PASSWORD")) {
  check_device_ip(device_ip)
  url <- glue::glue("http://{device_ip}/ivp/meters/{query}")
  req <- request(url) |> req_auth_basic(username, password)
  resp <- req |> req_perform()
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var {device_ip}} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else if (inherits(resp, "httr2_failure")) {
    cli::cli_abort(resp$message)

  } else {
    info_lst <- resp |> resp_body_json()
    cbind(device_id = device_ip, as.data.frame(info_lst))
  }
}


#' Enphase Energy single device query
#'
#' as a port of https://github.com/sarnau/EnphaseEnergy/blob/main/enphaseStreamMeter.py
#'
#' @inheritParams query_enphaseenvoy_device
#'
#' @return a data-frame with a `device_id` column and the `$Body$Data` turned into
#'    as many columns as expected
#'
#' @family device queries
#'
#' @export
#' @importFrom httr2 request req_perform resp_is_error resp_body_json resp_status resp_status_desc req_auth_basic response
#' @importFrom purrr possibly
#'
#' @examples
#' \dontrun{
#' query_enphaseenergy_device(query = "stream/meter")
#' }
query_enphaseenergy_device <- function(device_ip = "enphase.local", query, username = Sys.getenv("ENPHASE_USERNAME"), password = Sys.getenv("ENPHASE_PASSWORD")) {
  check_device_ip(device_ip)
  url <- glue::glue("http://{device_ip}/{query}")
  req <- request(url) |> req_auth_basic(username, password)
  resp <- req |> req_perform()
  if (resp_is_error(resp)) {
    cli::cli_abort(c("Connection to device {.var {device_ip}} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else {
    info_lst <- resp |> resp_body_json()

    if (length(info_lst[["data"]]) >= 3) {
      cbind(device_id = device_ip, as.data.frame(info_lst[["data"]]))
    } else {
      cli::cli_abort(c("the Enphase device {.var {device_ip}} is not supported"))
    }
  }
}


#' Fronius single device query
#'
#' as a port of https://github.com/friissoren/pyfronius
#'
#' @inheritParams query_ap_device
#' @param username the username needed to authenticate to the inverter.
#'  Defaults to the `FRONIUS_USERNAME` environment variable.
#' @param password the password needed to authenticate to the inverter.
#'  Defaults to the `FRONIUS_PASSWORD` environment variable.
#'
#' @return a data-frame with a `device_id` column and the `$Body$Data` turned into
#'    as many columns as expected
#'
#' @family device queries
#'
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
    cli::cli_abort(c("Connection to device {.var {device_ip}} raise an error : ",
                     "{resp_status(resp)} {resp_status_desc(resp)}."))

  } else if (inherits(resp, "httr2_failure")) {
    cli::cli_abort(resp$message)

  } else {
    info_lst <- resp |> resp_body_json()

    if (info_lst[["Head"]][["Status"]][["Code"]] == 0) {
      cbind(device_id = device_ip, last_report = info_lst$Head$Timestamp, as.data.frame(info_lst$Body$Data))
    } else {
      cli::cli_abort(c("the Fronius device {.var {device_ip}} does not have the correct Metering setup"))
    }
  }
}


#' Fronius multi-device query
#'
#' as a port of https://github.com/friissoren/pyfronius
#'
#' @inheritParams query_ap_devices
#' @inheritParams query_fronius_device
#'
#' @return a data-frame with a `device_id` column and the `$Body$Data` turned into
#'    as many columns as expected
#'
#' @family device queries
#'
#' @export
#' @importFrom httr2 request response req_perform_parallel
#' @importFrom httr2 resp_body_json resp_status resp_status_desc
#' @importFrom purrr map map_lgl map_dfr map2_dfr walk
#'
#'
#' @examples
#' \dontrun{
#' query_fronius_device(query = "GetInverterRealtimeData.cgi?Scope=System")
#' }
query_fronius_devices <- function(device_ip = c("fronius.local"), query, username = Sys.getenv("FRONIUS_USERNAME"), password = Sys.getenv("FRONIUS_PASSWORD")) {
  walk(device_ip, check_device_ip)
  req_url <- lapply(unique(device_ip), function(x) paste0("http://",x,"/solar_api/v1/",query) |> request() |> req_auth_basic(username, password))
  resp <- req_url |> req_perform_parallel(on_error = "continue")

  response_is_error <- map_lgl(resp, inherits, "httr2_failure")
  if (all(response_is_error)) {
    cli::cli_abort("Connection to all devices raised an error.")
  }

  if (any(response_is_error)) {
    cli::cli_warn(c(
      "Connection to device {.var {device_ip[response_is_error]}} raise an error : ",
      "{map(which(response_is_error), ~resp_status(resp[[.x]]))} {map(which(response_is_error), ~resp_status_desc(resp[[.x]]))}."
    ))
  }

  info_lst <- map(resp[!response_is_error], ~.x |> resp_body_json())
  incorrect_status_code <- map_lgl(info_lst, ~.x[["Head"]][["Status"]][["Code"]] != 0)

  if (any(incorrect_status_code)) {
    cli::cli_warn("the Fronius device {.var {device_ip[incorrect_status_code]}} does not have the correct Metering setup")
  }

  map2_dfr(device_ip[!response_is_error][!incorrect_status_code], info_lst[!incorrect_status_code],
    ~cbind(device_id = .x, last_report = .y$Head$Timestamp, as.data.frame(.y$Body$Data))
  )

}

check_device_ip <- function(device_ip) {
  stopifnot("device_ip shall be an atomic character string" = length(device_ip) == 1)
  stopifnot("device_ip shall be of a minimal character length" = nchar(device_ip) >= 3)

  # Regular expression to match a valid IPv4 address
  ipv4_regex <- "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
  # Regular expression to match a valid IPv6 address
  ipv6_regex <- "^[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){7}$"
  # Regular expression to match a .local domain resolution
  local_regex <- "\\.local$"

  stopifnot("device_ip shall be a valid .local, IPv4 or IPv6 address" = grepl(ipv4_regex, device_ip) || grepl(ipv6_regex, device_ip) || grepl(local_regex, device_ip))
}

