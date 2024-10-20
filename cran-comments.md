## R CMD check results

0 errors | 0 warnings | 2 notes

* Two non-portable file paths are present in tests/testthat/fronius/. Those are needed to
mock API endpoints. The file paths are as long as the REST API path of the real use-case.
