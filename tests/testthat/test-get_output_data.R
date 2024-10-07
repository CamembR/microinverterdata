with_mock_dir("apsystems", {
  test_that("get_output_data() works with one APSystems device", {
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

with_mock_dir("enphase", {
  test_that("get_output_data() works with one Enphase-Energy device", {
    skip_on_cran()
    expect_error(
      enphase_data <-  get_output_data(device_ip = "enphase.local", model = "Enphase-Energy"),
      NA)
    expect_true(is.data.frame(enphase_data))
    expect_equal(
      names(enphase_data),
      c("device_id", "last_report", "today_energy", "output_power", "lifetime_energy", "year_energy")
    )
    expect_equal(nrow(enphase_data), 1L)
  })
})

with_mock_dir("fronius", {
  test_that("get_output_data() works with one Fronius device", {
    skip_on_cran()
    expect_error(
      get_output_data(device_ip = "fronius.local", model = "Fronius"),
      NA)
    fronius_data <-  get_output_data(device_ip = "fronius.local", model = "Fronius")
    expect_true(is.data.frame(fronius_data))
    expect_equal(
      names(fronius_data),
      c("device_id", "last_report", "today_energy", "output_power", "lifetime_energy", "year_energy")
    )
    expect_equal(nrow(fronius_data), 1L)
  })

  test_that("get_output_data() works with multiple devices from Fronius", {
    skip_on_cran()
    expect_error(
      get_output_data(device_ip = c("fronius.local","fronius2.local"), model = "Fronius"),
      NA)
    fronius_data <-  get_output_data(device_ip = c("fronius.local","fronius2.local"), model = "Fronius")
    expect_true(is.data.frame(fronius_data))
    expect_equal(
      names(fronius_data),
      c("device_id", "last_report", "today_energy", "output_power", "lifetime_energy", "year_energy")
    )
    expect_equal(nrow(fronius_data), 2L)
  })
})


test_that("get_output_data() raise an explicit message for unsupported model", {
  expect_error(
    get_output_data(apsystems_host, model = "SMA"),
    "is not supported yet")
})
