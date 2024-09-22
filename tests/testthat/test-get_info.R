test_that("get_info works with a single device from APSystems", {
  skip_if_offline(host = apsystems_host)
  expect_error(
    get_device_info(apsystems_host),
    NA)
  apsystem_info <-  get_device_info(apsystems_host)
  expect_type(apsystem_info, data.frame)
  expect_equivalent(
    names(apsystem_info),
    c("device_id", "devVer", "ssid", "ipAddr", "minPower", "maxPower")
    )
  expect_equal(nrow(apsystem_info), 1L)
})
