# microinverterdata 0.4.0

# microinverterdata 0.3.1

* fix energy units to be kW.h (thanks to @tvroylandt)
* fix missing units for AP devices
* fix correct power unit for Enphase and Fronius
* improve error message expressivness.

# microinverterdata 0.3.0

* now perform requests to multiple devices in parallel (AP System & Fronius). #14
* device IP / name validation is now stricter.
* remove lubridate and readr dependancy.

# microinverterdata 0.2.1

* Add `Local Data Visualization` vignette. #13
* Improve device_ip check. #13

# microinverterdata 0.2.0

* Polish description and README
* Use a `switch()` based dispatch method on `model`

# microinverterdata 0.1.4

* Generalize Enphase Envoy support (`get_output_data()` only) #7

# microinverterdata 0.1.3

* Add support to Enphase Energy inverters (`get_output_data()` only) #6

# microinverterdata 0.1.2

* Add mocked http data for APSystems and Fronius #4
* Add support for 'Fronius' inverters 

# microinverterdata 0.1.1

* Add support to Enphase Envoy-S inverters (`get_output_data()` only) #1
* manage device unreachable error

# microinverterdata 0.1.0

* Initial CRAN submission.
* Support APSystems EZ1 Continuous local mode
