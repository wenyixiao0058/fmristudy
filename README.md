# fmristudy

getfmri.m is data processing pipeline for analyzing fMRI data from the ABIDEI dataset. 
It sets up data structures, reads subject information, defines file paths, and prepares data for further analysis.
Finally, it sends the data to the setfmriAggregate.m file for further processing.

setfmriAggregate.m file is for analyzing fMRI data with multiscale entropy.
this function processes fMRI data, calculates multiscale entropy, and saves the results in various files, such as raw sample entropy map, relative sample entropy map (smmap) and standardized sample entropy map (szmap)
Therefore, it contains multiscale_entropy4fmri.m function file to perform multiscale sample entropy calculation. 
smmap.m file to generate relative sample entropy map and szmap.m file to generate standardized entropy map.

svm_fmri.py is python script for further machine learning classification.
