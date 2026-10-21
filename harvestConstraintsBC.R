defineModule(sim, list(
  name = "harvestConstraintsBC",
  description = paste("Spatial harvest constraints for British Columbia study areas, as simpleHarvestPlanning's",
                      "`spatialConstraints`: one layer per constraint holding its rotation age (NA = no",
                      "harvest, 0 = does not apply). Layers come from the BC Data Catalogue; rotations from Timber Supply Review",
                      "forest-cover rules, using green-up ages read off the LandR yield curves."),
  keywords = c("harvest", "constraints", "protected areas", "visual quality", "British Columbia"),
  authors = c(person("Eliot", "McIntire", email = "eliotmcintire@gmail.com", role = c("aut", "cre"))),
  childModules = character(0),
  version = list(harvestConstraintsBC = "0.0.1"),
  timeframe = as.POSIXlt(c(NA, NA)),
  timeunit = "year",
  citation = list(),
  documentation = list(),
  reqdPkgs = list("SpaDES.core", "bcdata", "data.table", "sf", "terra",
                  "PredictiveEcology/reproducible@development (>= 3.2.1.9061)", # postProcessTo(rasterize = ), #628
                  "PredictiveEcology/timberSupply@main"),
  parameters = bindrows(
    defineParameter("greenupShare", "numeric", c(`3` = 0.026, `5` = 0.063, `6` = 0.085, `8.5` = 0.140), 0, 1,
                    paste("Share of a yield curve's maximum B at which a stand is taken to reach green-up",
                          "height, named by height (m); interpolated between heights. Calibrated on the",
                          "Southern Interior test-area curves of 2026-10-04 (balanceGrowth, initialB = 10; curves",
                          "with max B >= minMaxB) so the median green-up age is the",
                          "growth-intercept midpoint: 14, 21, 23.5 and 30 yr (Nigh 1999).")),
    defineParameter("minMaxB", "numeric", 6000, 0, NA,
                    paste("Curves whose maximum B (g/m2) is below this have no green-up age and are left",
                          "out of the class medians (the derived-THLB productivity rule).")),
    defineParameter("vegHeight", "numeric", 5, 3, 8.5,
                    paste("Visually effective green-up height (m) for visual quality objectives.",
                          "TSRs use 3-8.5 m by slope; one value here.")),
    defineParameter("vqoMaxDisturbed", "numeric", c(R = 0.03, PR = 0.10, M = 0.20), 0, 1,
                    paste("Maximum share of a visual quality class below `vegHeight`, by",
                          "REC_EVQO_CODE (midpoints in the 100 Mile House, Kamloops and Okanagan TSRs).",
                          "Rotation = median green-up age / share. Preservation (P) is no harvest.")),
    defineParameter("cwHeight", "numeric", 6, 0, NA,
                    "Hydrological green-up height (m) in community watersheds."),
    defineParameter("cwMaxDisturbed", "numeric", 0.25, 0, 1,
                    paste("Maximum share of a community watershed below `cwHeight` (Kamloops 2015:",
                          "25.2% < 6.6 m; Okanagan 2017: 30% < 6 m).")),
    defineParameter("uwrConditionalRotation", "numeric",
                    c(`M-ODHE` = 160, `M-ORAM` = 150, `M-ALAM` = 120, `M-RATA-01` = 150), 1, NA,
                    paste("Rotation in conditional-harvest ungulate winter range, by SPECIES_1. Mule deer:",
                          "the 100 Mile House TSR's 120/160/200 by habitat class (middle). Goat: min 33%",
                          "> 100 yr gives 100 / 0.67. Moose and caribou: from the TSR cover rules.",
                          "No-harvest zones are always no harvest (NA).")),
    defineParameter("includeDeferrals", "logical", FALSE, NA, NA,
                    paste("Scenario: old-growth priority deferral areas as no harvest. Not in the base case",
                          "(100 Mile House TSR 2024).")),
    defineParameter("verbose", "numeric", 1, 0, NA, "Print the rotation of each class.")
  ),
  inputObjects = bindrows(
    expectsInput("rasterToMatch", "SpatRaster", "Template raster."),
    expectsInput("yieldTablesCumulative", "data.table",
                 "Yield curves: yieldTableIndex, age, speciesCode, biomass (g/m2). From Biomass_yieldTables."),
    expectsInput("yieldTablesId", "data.table", "pixelIndex to yieldTableIndex. From Biomass_yieldTables.")
  ),
  outputObjects = bindrows(
    createsOutput("spatialConstraints", "SpatRaster",
                  "One layer per constraint: rotation age, NA = no harvest, 0 = does not apply.")
  )
))

doEvent.harvestConstraintsBC <- function(sim, eventTime, eventType) {
  switch(
    eventType,
    init = {
      sim$spatialConstraints <- timberSupply::harvestConstraintsBC(
        sim$rasterToMatch, sim$yieldTablesCumulative, sim$yieldTablesId,
        greenupShare = P(sim)$greenupShare, minMaxB = P(sim)$minMaxB, vqoMaxDisturbed = P(sim)$vqoMaxDisturbed,
        vegHeight = P(sim)$vegHeight, cwMaxDisturbed = P(sim)$cwMaxDisturbed,
        cwHeight = P(sim)$cwHeight, uwrConditionalRotation = P(sim)$uwrConditionalRotation,
        includeDeferrals = P(sim)$includeDeferrals, verbose = P(sim)$verbose)
      terra::writeRaster(sim$spatialConstraints, file.path(outputPath(sim), "spatialConstraints.tif"),
                         overwrite = TRUE)
    },
    warning(noEventWarning(sim))
  )
  invisible(sim)
}
