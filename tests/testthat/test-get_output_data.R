
local_mocked_bindings(.req_perform_parallel = function(requests, ...) {
  lapply(requests, httr2::req_perform)
})

with_mocked_bindings(
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
      expect_identical(apsystem_data$output_power, set_units(c(242, 237), "W"))
      expect_identical(apsystem_data$today_energy, set_units(c(1.38517, 1.36542), "kW.h"))
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
      expect_identical(apsystem_data$output_power, set_units(c(242, 237, 42, 37), "W"))
      expect_identical(apsystem_data$today_energy, set_units(c(1.38517, 1.36542, 1.8517, 1.542), "kW.h"))
    })
  }),
  # mocking the check_device_ip to be true here on specific names
  check_device_ip = function(device_ip) {
  if (rlang::enexpr(device_ip) %in% c("apsystems_host", "apsystems_multi")) {
    return
  }
})

with_mock_dir("enphase", {
  test_that("get_output_data() works with one Enphase-Energy device", {
    skip_on_cran()
    expect_no_error(
      enphase_data <-  get_output_data(device_ip = "enphase.local", model = "Enphase-Energy")
      )
    expect_true(is.data.frame(enphase_data))
    expect_equal(
      names(enphase_data),
      c("device_id", "last_report", "name", "phase", "power", "voltage", "current")
    )
    expect_equal(nrow(enphase_data), 9L)
    expect_identical(enphase_data$power[1], set_units(12.5, "W"))
    expect_identical(enphase_data$voltage[1], set_units(230, "V"))
    expect_identical(enphase_data$current[9], set_units(2.7, "A"))
  })

  test_that("get_output_data() works with one Enphase-Envoy device", {
    skip_on_cran()
    expect_no_error(
      enphase_data <-  get_output_data(device_ip = "enphase.local", model = "Enphase-Envoy")
      )
    expect_true(is.data.frame(enphase_data))
    expect_equal(
      names(enphase_data),
      c("device_id", "last_report", "type",  "output_power", "lifetime_energy", "today_energy")
    )
    expect_equal(nrow(enphase_data), 2L)
    expect_identical(enphase_data$output_power, set_units(c(254.555, 254.555), "W"))
    expect_identical(enphase_data$today_energy, set_units(c(11887.499, 11887.499), "W.h"))
  })
})

with_mock_dir("f", {
  test_that("get_output_data() works with one Fronius device", {
    skip_on_cran()
    expect_no_error(
      get_output_data(device_ip = "f.local", model = "Fronius")
      )
    fronius_data <-  get_output_data(device_ip = "f.local", model = "Fronius")
    expect_true(is.data.frame(fronius_data))
    expect_equal(
      names(fronius_data),
      c("device_id", "last_report", "today_energy", "output_power", "lifetime_energy", "year_energy")
    )
    expect_equal(nrow(fronius_data), 1L)
    # TODO fail as mocked json do not return numeric values
    expect_identical(fronius_data$output_power, set_units(308, "W"))
    expect_identical(fronius_data$lifetime_energy, set_units(5305086, "W.h"))
    expect_identical(fronius_data$today_energy, set_units(414, "W.h"))
  })

  test_that("get_output_data() works with multiple devices from Fronius", {
    skip_on_cran()
    expect_no_error(
      get_output_data(device_ip = c("f.local","g.local"), model = "Fronius")
      )
    fronius_data <-  get_output_data(device_ip = c("f.local","g.local"), model = "Fronius")
    expect_true(is.data.frame(fronius_data))
    expect_equal(
      names(fronius_data),
      c("device_id", "last_report", "today_energy", "output_power", "lifetime_energy", "year_energy")
    )
    expect_equal(nrow(fronius_data), 2L)
    expect_identical(fronius_data$output_power, set_units(c(308, 348), "W"))
    expect_identical(fronius_data$lifetime_energy, set_units(c(5305086, 55086), "W.h"))
    expect_identical(fronius_data$today_energy, set_units(c(414, 214), "W.h"))
  })
})

test_that("get_output_data() raise an explicit message for unsupported model", {
  expect_error(
    get_output_data(apsystems_host, model = "SMA"),
    "is not supported yet")
})
