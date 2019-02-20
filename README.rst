Summary
-----------
Effective Connectivity Scripts

Scripts used to conduct effective connectivity analyses. Comprised of:

regionCreation
	`createVMP.m` Creates VMP files for Brainvoyager using GLM. GLM must be created prior to running

	`PeakVoxelAutomation.m`8
	Imports VMP files and VOI file to select peak voxel within each region. Coordinates, t, and p value are returned in XLS format

	.. code:: m
	PeakVoxelTimeseriesExtraction.m
	Imports XLS table and creates final set of regions to be used to extract time series data from subject specific VTC files.


.. code:: sh

  TBD
