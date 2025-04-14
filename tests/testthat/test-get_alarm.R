local_mocked_bindings(check_device_ip = function(device_ip) {
  if (rlang::enexpr(device_ip) %in% c("apsystems_host", "apsystems_multi", "f", "g")) {
    return
  }
})


with_mock_dir("apsystems", {
  test_that("get_alarm() works with a single device from APSystems", {
    skip_on_cran()
    expect_no_error(
      get_alarm(apsystems_host)
      )
    apsystem_alarm <-  get_alarm(apsystems_host)
    expect_true(is.data.frame(apsystem_alarm))
    expect_equal(
      names(apsystem_alarm),
      c("device_id", "off_grid", "dc_input_1_shot_circuit", "dc_input_2_shot_circuit", "non_operating")
    )
    expect_equal(nrow(apsystem_alarm), 1L)
  })

  test_that("get_alarm() works with multiple devices from APSystems", {
    skip_on_cran()
    expect_no_error(
      get_alarm(apsystems_multi)
      )
    apsystem_alarm <-  get_alarm(apsystems_multi)
    expect_true(is.data.frame(apsystem_alarm))
    expect_equal(
      names(apsystem_alarm),
      c("device_id", "off_grid", "dc_input_1_shot_circuit", "dc_input_2_shot_circuit", "non_operating")
    )
    expect_equal(nrow(apsystem_alarm), 2L)
  })
})

test_that("get_alarm() raise an explicit message for unsupported model", {
  expect_error(
    get_alarm(apsystems_host, model = "SMA"),
    "is not supported yet")
})
