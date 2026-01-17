# Get inverter output data

Get inverter output data

## Usage

``` r
get_output_data(device_ip, model = "APSystems", ...)
```

## Arguments

- device_ip:

  list or vector of devices IP address

- model:

  the inverter device model. Currently only "APSystems" "Enphase-Envoy",
  "Enphase-Energy" and "Fronius" are supported.

- ...:

  additional parameters passed to the inverter if needed.

## Value

a dataframe with one row of device output power and energy per
\`device_id\` / \`inverter\` combination.

## Examples

``` r
if (FALSE) { # \dontrun{
get_output_data(c("192.168.0.12", "192.168.0.230"))
} # }
```
