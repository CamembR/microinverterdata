with_mock_dir("apsystems", {
  test_that("get_device_info() works with a single device from APSystems", {
    skip_on_cran()
    expect_error(
      get_device_info(apsystems_host),
      NA)
    apsystem_info <-  get_device_info(apsystems_host)
    expect_true(is.data.frame(apsystem_info))
    expect_equal(
      names(apsystem_info),
      c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
      )
    expect_equal(nrow(apsystem_info), 1L)
  })
})

with_mock_dir("fronius", {
  test_that("get_device_info() works with a single device from Fronius", {
    skip_on_cran()
    expect_error(
      get_device_info(device_ip = "fronius.local", model = "Fronius"),
      NA)
    fronius_info <-  get_device_info(device_ip = "fronius.local", model = "Fronius")
    expect_true(is.data.frame(fronius_info))
    expect_equal(
      names(fronius_info),
      c("device_id", "last_report", "inverter", "CustomName", "DT", "PVPower", "Show", "UniqueID")
      )
    expect_equal(nrow(fronius_info), 1L)
  })
})

with_mock_dir("apsystems", {
  test_that("get_device_info() works with multiple devices from APSystems", {
    skip_on_cran()
    expect_error(
      get_device_info(apsystems_multi),
      NA)
    apsystem_info <-  get_device_info(apsystems_multi)
    expect_true(is.data.frame(apsystem_info))
    expect_equal(
      names(apsystem_info),
      c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
      )
    expect_equal(nrow(apsystem_info), 2L)
  })
})

with_mock_dir("fronius", {
  test_that("get_device_info() works with multiple devices from Fronius", {
    skip_on_cran()
    expect_error(
      get_device_info(device_ip = c("fronius.local", "fronius2.local"), model = "Fronius"),
      NA)
    fronius_info <-  get_device_info(device_ip = c("fronius.local", "fronius2.local"), model = "Fronius")
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
      fronius_info <- get_device_info(device_ip = c("fronius.local", "fronius3.local"), model = "Fronius"),
      "Connection to device")
    expect_equal(nrow(fronius_info), 1L)
  })
})

test_that("get_device_info() raise an explicit message for unsupported model", {
  expect_error(
    get_device_info(apsystems_host, model = "SMA"),
    "is not supported yet")
})

