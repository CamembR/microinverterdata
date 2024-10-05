with_mock_dir("apsystems", {
  test_that("get_output_data() works with a single device from APSystems", {
    skip_on_cran()
    expect_error(
      get_output_data(apsystems_host),
      NA)
    apsystem_data <-  get_output_data(apsystems_host)
    expect_true(is.data.frame(apsystem_data))
    expect_equal(
      names(apsystem_data),
      c("device_id", "inverter", "output_power", "today_energy", "lifetime_energy")
    )
    expect_equal(nrow(apsystem_data), 2L)
  })
})

with_mock_dir("fronius", {
  test_that("get_output_data() works with a single device from Fronius", {
    skip_on_cran()
    expect_error(
      get_output_data(device_ip = "fronius.local", model = "Fronius"),
      NA)
    fronius_data <-  get_output_data(device_ip = "fronius.local", model = "Fronius")
    expect_true(is.data.frame(fronius_data))
    expect_equal(
      names(fronius_data),
      c("device_id", "inverter", "output_power", "today_energy", "lifetime_energy")
    )
    expect_equal(nrow(fronius_data), 1L)
  })
})

with_mock_dir("apsystems", {
  test_that("get_output_data() works with multiple devices from APSystems", {
    skip_on_cran()
    expect_error(
      get_output_data(apsystems_multi),
      NA)
    apsystem_data <-  get_output_data(apsystems_multi)
    expect_true(is.data.frame(apsystem_data))
    expect_equal(
      names(apsystem_data),
      c("device_id", "inverter", "output_power", "today_energy", "lifetime_energy")
    )
    expect_equal(nrow(apsystem_data), 4L)
  })
})


test_that("get_output_data() raise an explicit message for unsupported model", {
  expect_error(
    get_output_data(apsystems_host, model = "SMA"),
    "is not supported yet")
})
