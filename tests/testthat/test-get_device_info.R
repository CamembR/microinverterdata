
local_mocked_bindings(.req_perform_parallel = function(requests, ...) {
  lapply(requests, httr2::req_perform)
})

local_mocked_bindings(check_device_ip = function(device_ip) {
  if (rlang::enexpr(device_ip) %in% c("apsystems_host", "apsystems_multi", "fronius", "fronius2", "fronius3")) {
    return
  } else {
    stopifnot("**device_ip** shall be an atomic character string" = is.atomic(device_ip))
    stopifnot("**device_ip** shall be of a minimal character length" = nchar(device_ip) >= 3)

    # Regular expression to match a valid IPv4 address
    ipv4_regex <- "^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    # Regular expression to match a valid IPv6 address
    ipv6_regex <- "^[0-9a-fA-F]{1,4}(:[0-9a-fA-F]{1,4}){7}$"
    # Regular expression to match a .local domain resolution
    local_regex <- "\\.local$"

    stopifnot("**device_ip** shall be a valid .local, IPv4 or IPv6 address" = grepl(ipv4_regex, device_ip) || grepl(ipv6_regex, device_ip) || grepl(local_regex, device_ip))

  }
})


with_mock_dir("apsystems", {

    test_that("get_device_info() works with a single device from APSystems", {
    skip_on_cran()
    expect_no_error(
      apsystem_info <- get_device_info(apsystems_host)
      )
    expect_true(is.data.frame(apsystem_info))
    expect_equal(
      names(apsystem_info),
      c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
      )
    expect_equal(nrow(apsystem_info), 1L)
  })

  test_that("get_device_info() works with multiple devices from APSystems", {
    skip_on_cran()
    expect_no_error(
      apsystem_info <-  get_device_info(apsystems_multi)
      )
    expect_true(is.data.frame(apsystem_info))
    expect_equal(
      names(apsystem_info),
      c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
      )
    expect_equal(nrow(apsystem_info), 2L)
  })
})


with_mock_dir("f", {

  test_that("get_device_info() works with a single device from Fronius", {
    skip_on_cran()
    expect_error(
      fronius_info <-  get_device_info(device_ip = "fronius", model = "Fronius"),
      NA)
    expect_true(is.data.frame(fronius_info))
    expect_equal(
      names(fronius_info),
      c("device_id", "last_report", "inverter", "CustomName", "DT", "PVPower", "Show", "UniqueID")
      )
    expect_equal(nrow(fronius_info), 1L)
  })

  test_that("get_device_info() works with multiple devices from Fronius", {
    skip_on_cran()
    expect_error(
      fronius_info <-  get_device_info(device_ip = c("fronius", "fronius2"), model = "Fronius"),
      NA)
    expect_true(is.data.frame(fronius_info))
    expect_equal(
      names(fronius_info),
      c("device_id", "last_report", "inverter", "CustomName", "DT", "PVPower", "Show", "UniqueID")
      )
    expect_equal(nrow(fronius_info), 4L)
  })

  test_that("get_device_info() can raise a warning of one failing out of multiple Fronius", {
    skip_on_cran()
    expect_warning(
      fronius_info <- get_device_info(device_ip = c("fronius", "fronius3"), model = "Fronius"),
      "Connection to device")
    expect_equal(nrow(fronius_info), 1L)
  })
})

test_that("get_device_info() raise an explicit message for unsupported model", {
  expect_error(
    get_device_info(apsystems_host, model = "SMA"),
    "is not supported yet")
})

