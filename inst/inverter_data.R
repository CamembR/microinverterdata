## code to update {pins} local board `inverter_data` dataset
## this requires the setup of the environment variables
## `APSYSTEMS_HOST1` and `APSYSTEMS_HOST2`with the IP address of your inverter(s)
board <- pins::board_local()

history <- board |> pins::pin_read("inverter_data")
print(glue::glue("history size : {nrow(history)}"))
device_ip = c(Sys.getenv("APSYSTEMS_HOST1"), Sys.getenv("APSYSTEMS_HOST2"))
new_data <- tibble::tibble(
  date = lubridate::now(),
  microinverterdata::get_output_data(device_ip = device_ip)
)
board |> pins::pin_write(
  rbind(history, new_data),
  name = "inverter_data",
  versioned = TRUE
)
print(glue::glue("updated size : {nrow(rbind(history, new_data))}"))
