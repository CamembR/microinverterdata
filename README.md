
<!-- README.md is generated from README.Rmd. Please edit that file -->

# microinverterdata

<!-- badges: start -->

[![R-CMD-check](https://github.com/CamembR/microinverterdata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/CamembR/microinverterdata/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/microinverterdata)](https://CRAN.R-project.org/package=microinverterdata)
[![](https://cranlogs.r-pkg.org/badges/microinverterdata)](https://cran.r-project.org/package=microinverterdata)
<!-- badges: end -->

The goal of microinverterdata is to provide access to your local
micro-inverter data.

## Installation

You can install the released version from CRAN with:

``` r
install.packages("microinverterdata")
```

You can install the development version of {microinverterdata} from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("CamembR/microinverterdata")
```

## Example

This is a basic example to get inverter data for a single device:

``` r
library(microinverterdata)

## single micro-inverter device data
get_output_data(device_ip = "192.168.0.75")
#> # A tibble: 2 × 5
#>   device_id    inverter   output_power today_energy lifetime_energy
#>   <chr>        <chr>               [W]         [kW/h]          [kW/h]
#> 1 E07000017176 inverter_1          127          0.336            251.
#> 2 E07000017176 inverter_2          128          0.342            265.
```

The single device here includes 2 separated inverters. We get one row
of data per inverter, i.e. per solar panel.

You can also use a vector of IP addresses for `device_ip`. Thus the
command would run on all the inverters

``` r
## multiple inverters data
get_output_data(device_ip = c("192.168.0.75", "192.168.0.186"))
#> # A tibble: 4 × 5
#>   device_id    inverter   output_power today_energy lifetime_energy
#>   <chr>        <chr>               [W]         [kW/h]          [kW/h]
#> 1 E07000017176 inverter_1          126          0.336           251. 
#> 2 E07000017176 inverter_2          128          0.342           265. 
#> 3 E07000021746 inverter_1          125          0.334            44.0
#> 4 E07000021746 inverter_2          123          0.329            59.0
```

The packages also gives access to inverter information through `get_device_info()`
and inverter internal alarms through `get_alarm()`.

## Inverter support and configuration

The package allow querying values on diverse device models through the `model = "..."` parameter.

{microinverterdata} may require a minimal software version and configuration for the supported inverters :

| Inverter Manufacturer | Inverter Model | Firmware version | Configuration |
|------------------|------------------|------------------|------------------|
| APSystems | EZ1 | ≥ 1.7.0 | [Continuous local mode](https://camembr.github.io/microinverterdata/articles/APSystems_devices.html) (off-cloud)|
| Fronius | multiple | ≥ 1.7.2 | off-cloud (Need testers)          |
| Enphase | Envoy-S  | D5.x.x  | off-cloud (Need testers)          |
| Enphase | Energy   | < 7.x   | off-cloud (Need testers)          |
