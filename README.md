# harvestConstraintsBC

Spatial harvest constraints for British Columbia study areas, as simpleHarvestPlanning's `spatialConstraints`: one layer per constraint holding its rotation age (NA = no harvest, 0 = does not apply). Layers come from the BC Data Catalogue; rotations from Timber Supply Review forest-cover rules, using green-up ages read off the LandR yield curves.

A SpaDES module. The calculations are in the [timberSupply](https://github.com/PredictiveEcology/timberSupply) package. See [harvestConstraintsBC.Rmd](harvestConstraintsBC.Rmd) for the manual.
