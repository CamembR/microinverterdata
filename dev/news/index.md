# Changelog

## microinverterdata (development version)

## microinverterdata 0.4.0

CRAN release: 2025-05-22

- fix energy units to be kW.h (thanks to
  [@RemiMahmoud](https://github.com/RemiMahmoud))
- fix missing units for AP devices
- fix correct power unit for Enphase and Fronius
- improve error message expressivness.

## microinverterdata 0.3.0

CRAN release: 2025-04-14

- now perform requests to multiple devices in parallel (AP System &
  Fronius).
  [\#14](https://github.com/CamembR/microinverterdata/issues/14)
- device IP / name validation is now stricter.
- remove lubridate and readr dependancy.

## microinverterdata 0.2.1

- Add `Local Data Visualization` vignette.
  [\#13](https://github.com/CamembR/microinverterdata/issues/13)
- Improve device_ip check.
  [\#13](https://github.com/CamembR/microinverterdata/issues/13)

## microinverterdata 0.2.0

CRAN release: 2024-10-24

- Polish description and README
- Use a [`switch()`](https://rdrr.io/r/base/switch.html) based dispatch
  method on `model`

## microinverterdata 0.1.4

- Generalize Enphase Envoy support
  ([`get_output_data()`](https://camembr.github.io/microinverterdata/dev/reference/get_output_data.md)
  only) [\#7](https://github.com/CamembR/microinverterdata/issues/7)

## microinverterdata 0.1.3

- Add support to Enphase Energy inverters
  ([`get_output_data()`](https://camembr.github.io/microinverterdata/dev/reference/get_output_data.md)
  only) [\#6](https://github.com/CamembR/microinverterdata/issues/6)

## microinverterdata 0.1.2

- Add mocked http data for APSystems and Fronius
  [\#4](https://github.com/CamembR/microinverterdata/issues/4)
- Add support for ‘Fronius’ inverters

## microinverterdata 0.1.1

- Add support to Enphase Envoy-S inverters
  ([`get_output_data()`](https://camembr.github.io/microinverterdata/dev/reference/get_output_data.md)
  only) [\#1](https://github.com/CamembR/microinverterdata/issues/1)
- manage device unreachable error

## microinverterdata 0.1.0

CRAN release: 2024-10-02

- Initial CRAN submission.
- Support APSystems EZ1 Continuous local mode
