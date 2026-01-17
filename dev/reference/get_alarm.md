# Get inverter device alarms

Get inverter device alarms

## Usage

``` r
get_alarm(device_ip, model = "APSystems")
```

## Arguments

- device_ip:

  list or vector of devices IP address

- model:

  the inverter device model. Currently only "APSystems" is supported.

## Value

a dataframe with one row of device information per \`device_id\`
answering the query.

## Examples

``` r
if (FALSE) { # \dontrun{
get_alarm(c("192.168.0.12", "192.168.0.230"))
} # }
```
