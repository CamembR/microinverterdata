% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/query_device.R
\name{query_fronius_devices}
\alias{query_fronius_devices}
\title{Fronius multi-device query}
\usage{
query_fronius_devices(
  device_ip = c("fronius.local"),
  query,
  username = Sys.getenv("FRONIUS_USERNAME"),
  password = Sys.getenv("FRONIUS_PASSWORD")
)
}
\arguments{
\item{device_ip}{list or vector of each device IP address or name}

\item{query}{the API query string}

\item{username}{the username needed to authenticate to the inverter.
Defaults to the `FRONIUS_USERNAME` environment variable.}

\item{password}{the password needed to authenticate to the inverter.
Defaults to the `FRONIUS_PASSWORD` environment variable.}
}
\value{
a data-frame with a `device_id` column and the `$Body$Data` turned into
   as many columns as expected
}
\description{
as a port of https://github.com/friissoren/pyfronius
}
\examples{
\dontrun{
query_fronius_device(query = "GetInverterRealtimeData.cgi?Scope=System")
}
}
\seealso{
Other device queries: 
\code{\link{query_ap_device}()},
\code{\link{query_ap_devices}()},
\code{\link{query_enphaseenergy_device}()},
\code{\link{query_enphaseenvoy_device}()},
\code{\link{query_fronius_device}()}
}
\concept{device queries}
