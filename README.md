# Iowa-Corn-Nitrate-Transport
The following files allow for an example run of the nitrate transport model using one Iowa soil SSURGO map unit, precipitation from 2020, and an application timing of 14 days after seed germination and fertilizer application of 2.3 mg/cm2. Run this simulation by running the Model_Run script.


**Code Description:**
With all files in the same folder, navigate to the Model_Run.m script. This file loads the necessary precipitation data, soil database, and farm variables needed to begin the simulation. This script has the capability of iterating through every Iowa soil map unit and each map units components (see https://data.nal.usda.gov/dataset/soil-survey-geographic-database-ssurgo for description of map units and components). For this example only one map unit and one component of the map unit has been chosen. The soil data from this map unit component is compiled. This scrip will also iterate through all precipitation datasets from weather stations associated with a soil map unit. For this example, only a single weather station is used. With this data the function syssetup.m is called and the 3d soil space used in the simulation is generated. 

With the 3d soil space generated denoted as the variable "system", and the precipitation and farm variables included, the script then calls the function SIMfunc.m to run the simulation. This function loads pertinent files needed to generate the 3d corn root system and iterates through time and space to map nitrate fate and transport. This simulation should take about 90 seconds to run. Following the simulation a results file is generated and saved into the folder as "DATA.mat".

**Output Description**
The DATA.mat file is a database meant to organize the saved data when iterating through many soil map units, soil components, precipitation data sets, and on-farm variables. The first layer displayes the soil map unit, then soil component, then weather station. The results are presented in a 3x2 matrix. Columns represent the mass and mass ratio respectively. Rows represent partitioning between the plant, conserved in the soil system, and leached from the system respectively. 
