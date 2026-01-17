# Fronius single device query

as a port of https://github.com/friissoren/pyfronius

## Usage

``` r
query_fronius_device(
  device_ip = "fronius.local",
  query,
  username = Sys.getenv("FRONIUS_USERNAME"),
  password = Sys.getenv("FRONIUS_PASSWORD")
)
```

## Arguments

- device_ip:

  IP address or name of the device

- query:

  the API query string

- username:

  the username needed to authenticate to the inverter. Defaults to the
  \`FRONIUS_USERNAME\` environment variable.

- password:

  the password needed to authenticate to the inverter. Defaults to the
  \`FRONIUS_PASSWORD\` environment variable.

## Value

a data-frame with a \`device_id\` column and the \`\$Body\$Data\` turned
into as many columns as expected

## See also

Other device queries:
[`query_ap_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_ap_device.md),
[`query_ap_devices()`](https://camembr.github.io/microinverterdata/dev/reference/query_ap_devices.md),
[`query_enphaseenergy_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_enphaseenergy_device.md),
[`query_enphaseenvoy_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_enphaseenvoy_device.md),
[`query_fronius_devices()`](https://camembr.github.io/microinverterdata/dev/reference/query_fronius_devices.md)

## Examples

``` r
if (FALSE) { # \dontrun{
query_fronius_device(query = "GetInverterRealtimeData.cgi?Scope=System")
} # }
```
