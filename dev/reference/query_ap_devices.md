# AP System multi-device query

AP System multi-device query

## Usage

``` r
query_ap_devices(device_ip, query)
```

## Arguments

- device_ip:

  list or vector of each device IP address or name

- query:

  the API query string

## Value

a data-frame with a \`device_id\` column and the \`\$Body\$Data\` turned
into as many columns as expected

## See also

Other device queries:
[`query_ap_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_ap_device.md),
[`query_enphaseenergy_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_enphaseenergy_device.md),
[`query_enphaseenvoy_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_enphaseenvoy_device.md),
[`query_fronius_device()`](https://camembr.github.io/microinverterdata/dev/reference/query_fronius_device.md),
[`query_fronius_devices()`](https://camembr.github.io/microinverterdata/dev/reference/query_fronius_devices.md)

## Examples

``` r
if (FALSE) { # \dontrun{
query_ap_devices(device_ip = c("192.168.0.234", "192.168.0.235"),
                 query = "getDeviceInfo"
                 )
} # }
```
