test_that("get_device_info() works with a single device from APSystems", {
  skip_if_offline(host = apsystems_host)
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

test_that("get_device_info() works with multiple devices from APSystems", {
  skip_if_offline(host = apsystems_host)
  expect_error(
    get_device_info(c(apsystems_host, apsystems_host)),
    NA)
  apsystem_info <-  get_device_info(c(apsystems_host, apsystems_host))
  expect_true(is.data.frame(apsystem_info))
  expect_equal(
    names(apsystem_info),
    c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
    )
  expect_equal(nrow(apsystem_info), 2L)
})

test_that("get_device_info() raise an explicit message for unsupported model", {
  expect_error(
    get_device_info(apsystems_host, model = "Enphase"),
    "is not supported yet")
})

