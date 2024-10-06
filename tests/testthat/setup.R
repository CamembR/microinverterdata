library(httptest2)
apsystems_host = Sys.getenv("APSYSTEMS_HOST1") |> gsub("^$", "192.168.0.86", x = _)
apsystems_multi = c(Sys.getenv("APSYSTEMS_HOST1") |> gsub("^$", "192.168.0.86", x = _),
                    Sys.getenv("APSYSTEMS_HOST2") |> gsub("^$", "192.168.0.175", x = _))
