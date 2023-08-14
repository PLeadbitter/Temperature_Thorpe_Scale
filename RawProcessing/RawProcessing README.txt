RawProcessing Read Me

Raw_microstructure_Processing.m : This script uses the Rockland Scientific tool box to extract the raw data from th .p files on the microstructure logger and make them matlab readable. The later half of the script simply arranges each of the profile into a data file allowing it to be saved.

Seabird_to_MSdata_Structure.m : The first section of this script simply takes the seabird temperature and salinity (from whatever platform is being used) and adds this to the raw data section of the data stucture. The second half is specifically for temperature and salinity data from a vertical profile, and bins the data to the minimum size increment that is wanted (this can be changed).