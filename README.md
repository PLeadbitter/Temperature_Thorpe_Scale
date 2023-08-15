# Temperature_Thorpe_Scale
Selection of MatLab Scripts for Thorpe Scale high resolution temperature data 
Produced on MatLab version R2017b

These scripts were produced as part of my Ph.D work and will require modification if another user wishes to make them compatible with their setup. The main changes will be creating the correct pathing for the files and making sure that all the scripts can "see" each other within the matlab working directory.

A break down of the methodology used in my thesis can be seen here: https://ueaeprints.uea.ac.uk/id/eprint/89987/1/PL%20Final%20PhD%20thesis.pdf. A key image, found on page 28 shows the process that the scripts in this repositary need to be run in. The image is also included as a pdf in this level of the directory under Flow_chart_method.pdf

A modified version of these methods can be found here: https://os.copernicus.org/articles/19/77/2023/

The collection consists of 4 different directories each that has a different purpose. Please see the README's in each directory for an indepth explination of each file. A brief overview is given below.

RawProcessing : The Scripts in this directory are the least vital to the process, although using them will aid any user in having the correct data structure for the following scripts. The scripts in this directory allow you convert raw microstructure files, .p, to .mat files allowing them to be read in MatLab

Data_cleaning : This directory contains scripts that clean the raw data through filtering and binning, as well as conerting a number of variables into more standard forms to allow the Thorpe Scaling methodolgy to be applied.

Thorpe_Scaling : Tales the data structures created in the above directories and calculates a number of scientificly useful variables for the ocean mixing communities that need them

Functions : This directory contains a number of small functions that are called throughout the other scripts here. They are in a seperate folder to keep things tidy. 
Also required is the Gibbs Seawater Tool box (GSW, https://www.teos-10.org/software.htm). The version used for this project was 3.0 (current version 3.06)

The scripts here need to be run as seperate scripts in certain orders, work is being done (when I have the time to slim the front end down so that some of these scripts can be run in batches to improve the user experience.
