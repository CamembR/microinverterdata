with_mock_dir("apsystems", {

    test_that("get_device_info() works with a single device from APSystems", {
    skip_on_cran()
    expect_error(
      apsystem_info <- get_device_info(apsystems_host),
      NA)
    expect_true(is.data.frame(apsystem_info))
    expect_equal(
      names(apsystem_info),
      c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
      )
    expect_equal(nrow(apsystem_info), 1L)
  })

  test_that("get_device_info() works with multiple devices from APSystems", {
    skip_on_cran()
    expect_error(
      apsystem_info <-  get_device_info(apsystems_multi),
      NA)
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

