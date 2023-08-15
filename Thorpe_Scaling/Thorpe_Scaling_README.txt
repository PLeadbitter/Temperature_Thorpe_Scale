Thorpe Scaling README

Calculate_Thorpe_Length_Scale.m : This the core script that the future of any work produced with this tool box will hinge on. Firtstly the last 2 sections are image creation for sanity testing. They can be removed/ignore/commented out if you are happy with what is happening. During the cummulatve summing section of the script it is important to make sure that the profiles are being summed in the correct manner. It is worth doing a test plot of the summed data to make sure you have a number of peaks not just a single one that spans the length of the profile. The profile direction may need to be tweaked if there are any major issues with it 

Calculate_e_from_lt.m : Takes values from Calculate_e_from_lt and hydrographic data and calculates vertical dissipation rates and saves them. It also creates a multiple panel image for an intial comparison of each of the steps to check everything is working correctly. This Scirpt does not bin the data to 25m (see below).

Calculate_Krho.m : This script uses the outputs of Calculate_e_from_lt.m to calculate vertical eddy diffusivity from dissipation and then bin the results into 25m bins, this size is used as it seems to be the best compromise of smoothing out the variability in LT and still provide a good vertical resolution for comparisons across profiles. Bin size can be changed using bin_step.
