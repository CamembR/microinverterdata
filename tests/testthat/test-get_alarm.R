test_that("get_alarm() works with a single device from APSystems", {
  skip_if_offline(host = apsystems_host)
  expect_error(
    get_alarm(apsystems_host),
    NA)
  apsystem_alarm <-  get_alarm(apsystems_host)
  expect_true(is.data.frame(apsystem_alarm))
  expect_equal(
    names(apsystem_alarm),
    c("device_id", "off_grid", "dc_input_1_shot_circuit", "dc_input_2_shot_circuit", "non_operating")
  )
  expect_equal(nrow(apsystem_alarm), 1L)
})

test_that("get_alarm() raise an explicit message for unsupported model", {
  expect_error(
    get_alarm(apsystems_host, model = "Enphase"),
    "is not supported yet")
})
