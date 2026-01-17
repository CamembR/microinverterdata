# Get inverter device information

Get inverter device information

## Usage

``` r
get_device_info(device_ip, model = "APSystems")
```

## Arguments

- device_ip:

  list or vector of devices IP address

- model:

  the inverter device model. Currently only "APSystems" is supported.

## Value

a data-frame with one row of device information per \`device_id\`
answering the query.

## Examples

``` r
if (FALSE) { # \dontrun{
get_device_info(c("192.168.0.12", "192.168.0.230"))
} # }
```
