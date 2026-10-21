## The module on a real BC study area.

## Run the module's init on the study area.
runModule <- function(params = list()) {
  rtm <- bcStudyArea()
  sim <- SpaDES.core::simInit(
    times = list(start = 2020, end = 2020),
    modules = moduleName,
    paths = testPaths,
    params = setNames(list(params), moduleName),
    objects = c(list(rasterToMatch = rtm), toyYieldTables(rtm)))
  SpaDES.core::spades(sim, debug = FALSE)
}

test_that("spatialConstraints has one layer per constraint on the grid, and is written to outputs", {
  skipUnlessBC()
  sim <- runModule(list(verbose = 0))
  sc <- sim$spatialConstraints
  expect_s4_class(sc, "SpatRaster")
  expect_true(terra::compareGeom(sc, sim$rasterToMatch))
  expect_identical(names(sc), c("protected", "oldGrowthMgmtArea", "wildlifeHabitatNoHarvest",
                                "ungulateWinterRange", "visualQuality", "communityWatershed"))
  vals <- terra::values(sc)
  expect_true(all(is.na(vals) | vals >= 0))  # NA = no harvest, 0 = does not apply
  expect_true(file.exists(file.path(SpaDES.core::outputPath(sim), "spatialConstraints.tif")))
})
