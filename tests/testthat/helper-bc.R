## Study area and yield curves for running the module on real BC data (as in timberSupply's tests).

## Tests that query the BC Data Catalogue skip unless online, and never run on CRAN.
skipUnlessBC <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_offline("openmaps.gov.bc.ca")
  testthat::skip_if_not_installed("bcdata")
  testthat::skip_if_not_installed("sf")
}

## A 4 km x 4 km study area near 100 Mile House, BC (TSA 23, no Tree Farm Licence), in
## Canada Albers so that results have to be projected back to it.
bcStudyArea <- function() {
  p <- terra::project(terra::vect(cbind(-121.3, 51.64), crs = "EPSG:4326"), "EPSG:3978")
  xy <- terra::geom(p)[1, c("x", "y")]
  terra::rast(xmin = xy[["x"]] - 2000, xmax = xy[["x"]] + 2000,
              ymin = xy[["y"]] - 2000, ymax = xy[["y"]] + 2000,
              res = 250, crs = "EPSG:3978", vals = 1)
}

## One yield curve for every pixel: two species growing to 10000 g/m2 in total by age 100.
toyYieldTables <- function(rasterToMatch) {
  ages <- seq(0L, 200L, by = 10L)
  grow <- pmin(ages, 100) / 100
  list(
    yieldTablesCumulative = data.table::data.table(
      yieldTableIndex = 1L,
      speciesCode = rep(c("Pice_mar", "Popu_tre"), each = length(ages)),
      age = rep(ages, 2),
      biomass = c(6000 * grow, 4000 * grow)),
    yieldTablesId = data.table::data.table(pixelIndex = seq_len(terra::ncell(rasterToMatch)),
                                           yieldTableIndex = 1L))
}
