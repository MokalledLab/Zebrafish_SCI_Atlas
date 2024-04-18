## System requirement

To run the Fiji Script, you need to install Fiji on your sytem from this link : https://imagej.net/software/fiji/downloads. The plugin ICTN_.jar (provided here) need to be installed in your fiji. 

To Run the R script:

You need to have R and R studio installed : https://posit.co/download/rstudio-desktop/
The R script make use of following packages and corresponding versions

R version 4.3.1 (2023-06-16 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 11 x64 (build 22631)

Matrix products: default


locale:
[1] LC_COLLATE=English_United States.utf8  LC_CTYPE=English_United States.utf8    LC_MONETARY=English_United States.utf8
[4] LC_NUMERIC=C                           LC_TIME=English_United States.utf8    

time zone: America/Chicago
tzcode source: internal

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] rstudioapi_0.15.0 tidyr_1.3.1       dplyr_1.1.4      

loaded via a namespace (and not attached):
 [1] utf8_1.2.4       R6_2.5.1         tidyselect_1.2.0 magrittr_2.0.3   glue_1.7.0       tibble_3.2.1     pkgconfig_2.0.3  generics_0.1.3  
 [9] lifecycle_1.0.4  cli_3.6.2        fansi_1.0.6      vctrs_0.6.5      compiler_4.3.1   purrr_1.0.2      tools_4.3.1      pillar_1.9.0    
[17] rlang_1.1.3     


## Instruction to run

This protocol is intended for counting cells in spinal cord sections which contain cell-type-specific markers. The approach identifies all nuclei in a specified region (e.g. the spinal cord) and then asks whether those nuclei overlap with markers in other channels. This method works with cell-type-specific markers that label either the nucleus (e.g. Sox2) or the whole cell (e.g. HuC). 
Workflow:

![image](https://github.com/MokalledLab/Zebrafish_SCI_Atlas/assets/81267539/87bd5159-511f-4ce4-9fd8-2619b3b2eaa8)

 
Acquiring Images
This protocol is not intended to cover the usage of the confocal microscope. Rather, here are some important things to consider during image acquisition:
•	IMPORTANT: Use the following standardized naming format for the raw images.
o	Experiment_Block_Fish_Level_AnythingElse.czi
o	Example: mm11_2a_F1_Lm1_AnythingElse.czi
(Note: For L+ level, use Lp and L- level: Lm. Example: L+3 : Lp3 and L-3 :Lm3)
•	Visually distinct nuclei are important for the analysis. Nuclei can be touching, but you must be able to tell them apart by eye. For instance, over saturating an image will cause adjacent nuclei to merge into a single blob…THAT’S BAD. This is especially problematic in the ependymal cells where nuclei are closely grouped.
•	Cell counting will be faster and more consistent if the images have similar signal intensities. In this case, it is acceptable to adjust the gain to make individual images comparable.
•	The cell counter requires a single image (not a z-stack). Z-stacks should be converted to maximum intensity projections with the suffix “_3D.czi” before proceeding with the analysis.
Cell Counting
Note: Before you start this analysis you will need to know which marker is present in which channel. If you are unsure, you can check by opening one of the .czi files in ImageJ.
Get raw counts with ImageJ: 
1.	Open Fiji
2.	Click “Plugins” > “Macros” > “Run”
3.	Select the latest version of “Cell_Counter.ijm” in LAB MEMBERS/SHARED/Code for Custom Analyses/
4.	Follow the on-screen instructions:
a.	Select the folder containing the “.czi” files you would like to count. If the folder contains a mixture of “_3D.czi” and “.czi” files, then only those files with “3D” in their name will be used. If the folder contains no files with “3D” in their name, then all single plane “.czi” files will be used.
b.	Identify the marker in each channel.
c.	Select the channel containing all nuclei (i.e. DAPI, Hoechst).
d.	Select the cell-type specific markers you want to count.
e.	As each image is opened, specify the following:
i.	Mark the middle of the central canal (everything above this point will be called dorsal and everything below this point will be called ventral).
IMPORTANT: This program expects the images to be oriented such that the spinal cord is “straight” with dorsal on top and ventral on the bottom.
ii.	Trace the outline of the spinal cord. Only cells within your outline will be counted. Sometimes it is easier to identify the spinal cord in a channel other than the nuclei channel. You can outline the spinal cord in any channel you want and the program will interpret it properly.
iii.	Optimize the settings in the ITCN counter. Start with the following values:
1.	Width: 15
2.	Min Distance: 7.5
3.	Threshold: 0.4
4.	Click “Count”
5.	A window with pink spots marking nuclei will open. If you are satisfied with these marker placement, then click OK in the message box. If you are not satisfied with the marker placement then close the window and try some new settings. 
Note: ITCN performs well at counting nuclei, but it is not perfect especially when there are nuclei of varying intensity and size (as in the spinal cord). At some point you have to leave good enough alone. Usually it is fine to use the same parameters for all images in a batch.
iv.	Adjust the threshold for each marker. If you selected “Same threshold” above, then you will only need to set the threshold for the first image. 
5.	The output from “Cell_Counter.ijm” is a “Results” folder containing:
a.	Individual images for each channel showing the overlap of nuclei and the marker. (Note: For some odd reason, the output images do not all have the same color scheme…I don’t know why. It doesn’t affect the results). 
b.	A “.csv” file containing the raw counts for each channel.
Process raw counts with R: 
Now that we have the raw counts, we can use R to reorganize the data and provide us with a final count for all possible combinations of markers.
1.	Open RStudio
2.	Click “File” > “Open File…” > select the latest version of the “Cell_Count_Processor.R” file in LAB MEMBERS/SHARED/Code for Custom Analysis/
3.	Click “Source”:
•	Select the folder containing the raw counts (“.csv” files) from ImageJ. 
•	Note: The result is nearly instant.
4.	The output of “Cell_Count_Processor” is a “Count_Summary.csv” containing the final counts in the format below. Most of the data is self-explanatory with the following exceptions.
•	The “_Total” columns contain the raw count for each marker. These columns will not add up to the “Total Nuclei” column since some of the nuclei will not have any marker and some will have more than one marker.
•	The sum of the columns containing all possible combinations of markers (e.g. EdU-/HuC-/Sox2-) will add up to the “Total Nuclei”.
•	With regard to “Position”, the sum of “Dorsal” and “Ventral” rows will always equal the “Total” row.
 

   
