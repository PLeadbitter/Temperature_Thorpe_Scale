Data_Cleaning README

To make best use of the scripts in this directory please run the scripts in blocks of ii and iii that can be found in 2021_Flow_Chart_Method.pdf. The files below are ordered in such a way to make this easier but may not be ordered in the same way in the directory itself. 

Part ii
Converting_pressure_depth.m : This is a simple script that turns the pressure from the raw data into depth. As Thorpe scaling is calculated over a distance we need to have the depth of the instrument and not the pressure. 



Convert_temp_cons_temp.mat : This is a stand alone script that needs to be done before doing part iii but is seperate from part ii. This is another simple script that loads in the temperature data and converts it to conservative temperature. This isn't necessary for the Thorpe scaling but useful if you want to use the high resolution temperature for other analysis. 

Part iii
Filtering_to_100hz.m : Due to the response time of the FP07 fast thermistor there is a chance that not all measuresments will be independent of each other. To remove as many spurious overturns as possible the data is filtered to remove any variation below 100hz, whih is the reponse time of this particular sensor.

Binning_temperature_seaglider.m : As with the filtering above we want to try and minimise the number of overturns picked up that aren't real. In addition to filtering we aim to minimise these buy removing points that would not be independent of each other based on the fall rate and angle of the platform through the water. This script is written to take into account the seaglider path through the water. In the section following the data load in there is a section of the code commented out. To use profiler data un-comment this and comment the trigonometry based pitch calculations.



Rapid_Temperature_Binning.m : This is a script to quickly bin the fast temperature data without taking into account vehicle speed or angle if a rapid temperature time series is required from the high resolution temperature
