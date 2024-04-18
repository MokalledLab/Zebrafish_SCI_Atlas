Swim behaviour analysis is performed in two steps as described in the following paper (https://app.jove.com/t/63240/assessment-of-swim-endurance-and-swim-behavior-in-adult-zebrafish).

# System requirements.
To avi file, you need a windows system. 

To run the Fiji Script, you need to install Fiji on your sytem from this link : https://imagej.net/software/fiji/downloads. 
To Run the R script:

You need to have R and R studio installed : https://posit.co/download/rstudio-desktop/
The R script will use of following packages and corresponding versions

R version 4.3.1 (2023-06-16 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default


locale:
[1] LC_COLLATE=English_United States.utf8  LC_CTYPE=English_United States.utf8   
[3] LC_MONETARY=English_United States.utf8 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.utf8    

time zone: America/Chicago
tzcode source: internal

attached base packages:
[1] tcltk     stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] RcppHungarian_0.2  scales_1.2.1       data.table_1.14.8  combinat_0.0-8    
 [5] stringi_1.7.12     tidyr_1.3.0        ggplot2_3.4.2      rowr_1.1.3        
 [9] dplyr_1.1.2        RColorBrewer_1.1-3 MASS_7.3-60        svDialogs_1.1.0   

loaded via a namespace (and not attached):
 [1] vctrs_0.6.3       cli_3.6.1         rlang_1.1.1       purrr_1.0.2       generics_0.1.3   
 [6] glue_1.6.2        colorspace_2.1-0  fansi_1.0.4       grid_4.3.1        munsell_0.5.0    
[11] tibble_3.2.1      lifecycle_1.0.3   compiler_4.3.1    sessioninfo_1.2.2 Rcpp_1.0.11      
[16] pkgconfig_2.0.3   rstudioapi_0.15.0 R6_2.5.1          tidyselect_1.2.0  utf8_1.2.3       
[21] pillar_1.9.0      magrittr_2.0.3    withr_2.5.0       tools_4.3.1       gtable_0.3.4     
[26] svGUI_1.0.1      


# Instructions to Run
Following instructions are already published here : https://app.jove.com/t/63240/assessment-of-swim-endurance-and-swim-behavior-in-adult-zebrafish
I am just copy here as well. 

3. Capturing videos for swim behavior assay

NOTE: Only up to five animals can be tracked at a time. If experimental groups are larger than five animals, multiple videos can be taken for each group, where the first video tracks five or fewer animals and the second video tracks the other five or fewer animals. For longitudinal studies that aim to track individual animals over time, fish can be individually housed and tracked across multiple time points. 
Open the camera recording software (see Table of Materials). Set the software settings as follows.
Click the 1:4 aspect display. Make sure that the field of view covers the entire swim tunnel. Turn off auto-contrast and auto-white balance to normalize the background and contrast across groups.
Open the Camera Properties window by clicking on the wrench icon. Set the parameters as follows: Pixel Clock: 344 MHz, Frame Rate: 70 fps, click on the box next to Hold to check it, Exposure Time: 0.290 ms. Do not close this window.
Crop the Recording Window to cover only the swim chamber of the tunnel by tilting/turning the camera as needed.
Open the Recording Window by clicking on the film reel icon. Set the recording settings as follows:
Check the box for the maximum number of frames.
Manually input 63,000 for the number of frames.
Check the box for Calc. Frame Rate. This allows the program to pull the frame rate defined in step 3.2.2 (70 fps).
Change the JPEG Quality to 30.
Record a test run.
Click on Create and name the new file Test and save it on the desktop.
Go back to the recording window and click Record. Let the test movie run for the entire duration of the protocol (15 min).
Once the test is finished, ensure that there are no dropped frames and that 63,000 frames are recorded.
Place a group of fish in the swim tunnel and close the tunnel using a standard fully enclosed lid.
NOTE: Ensure all the fish are in the tunnel before fully tightening the lid. Make sure there are no air bubbles under the lid. This will otherwise affect the results.
Open a new recording window and name the file. Example: 2_A_1_00001_WildtypeGroupA.avi
NOTE: Ensure that the settings are according to the parameters in steps 3.2 and 3.3. The JPEG Quality will always go back to default and needs to be reset for each new movie.
CAUTION: Do not click record yet.
Begin a new experiment using the flow velocity control software.
NOTE: To begin an automated protocol, click the Start Logging box. In the dialog window that opens, choose Automated from the dropdown list. To choose a previously saved protocol file, click on the file icon next to Protocol File to open the desired protocol.
To begin a manual protocol, set the flow speed to 0 cm/s for 5 min, 10 cm/s for 5 min, followed by 20 cm/s for 5 min using the Uwater [cm/s] box in the flow velocity control software.
Save the new data output file (will be saved as a .csv file) under the same name as the movie file and in the same folder.
CAUTION: Do not click start yet.
Place a paper towel or piece of fabric on the side of the swim tunnel to ensure all behaviors are due to fish swimming and not due to a startle response caused by movement in the environment.
In quick succession, make sure water is calm and no ripples are moving across the frame. Click Record in the camera software window to start recording the movie file. Click Start in the flow velocity control software to begin the protocol, which will continue uninterrupted.
Watch the movie to make sure that no frames are dropped, that there are no bubbles in the field of view, and that all fish are recorded.
Once the movie recording is completed, click on Emergency Stop to end the flow velocity control protocol. Check for the data output file that is saved automatically. Click Close on the Recording Window to save the movie file.
Remove the lid. Carefully retrieve the fish and return them to their tank.
Repeat steps 3.5 to 3.12 for all groups of fish.
Once the movie recording is finished for all the groups, convert movies from 70 fps videos to 20 fps videos with the MovieProcessing_v5.bat script. To do this, move the script file to the folder containing the raw videos. Right-click on the file and choose Run.
NOTE: The script runs automatically. A command prompt window will come up showing the progress of the script. The above step is optional. It reduces the number of frames in a 15 min video from 63,000 to 18,000 frames and makes the SwimBehavior_v7.R script run more quickly.
Empty the tunnel and put away all the equipment.
4. Analyzing movies for swim behavior assessment

NOTE: Movie recording and analysis can be completed on separate days.

Open the Tracking_v2.ijm script in Fiji and click Run to begin the program. In the window that pops up, choose the folder containing the swim behavior movies to track and click Open. Look for frame 1 of the first movie, a dialog box, and the region of interest (ROI) manager that will come up.
Follow the directions given in the dialog box. Create an ROI of the bottom of the swim tunnel chamber and click OK. Ensure that no black corners are seen.
NOTE: The threshold window will open along with an edited, thresholded Frame 1.
Change the color scheme from B&W to Red. Adjust the Max Value until frame 1 shows the fish in red and nothing else. Record the threshold. Click OK in the dialog box.
NOTE: The program will automatically run. The ROI that was made for Frame 1 will be continuously selected and unselected for subsequent frames. A progress bar will monitor the process in the bottom-right corner of the Fiji window. Tracking takes about 40 min per movie. When all the movies are tracked, the Fiji program will stop. The ROI will stop being selected. The folder containing the movies will now have a _raw.csv file for each movie. Fiji can be closed at this point.
Aligning, assembling, and acquiring descriptive statistics
Open the Swim Behavior_v7.R script in R Studio.
Click on Source in the top-right corner of the script section. In a new window that opens, choose the folder containing the _raw.csv files generated by Fiji. Click Open.
NOTE: The program will run automatically.
In a dialog box that pops up asking to confirm the number of fish in each movie, click Yes if the numbers given are correct, or click No if the numbers are incorrect.
NOTE: If No was clicked, a message will pop up asking that the movies be re-tracked with a new ROI and threshold. If Yes was clicked, the program will proceed.
In the new window that opens asking whether the non-swimming fish should be removed, click Yes or No.
NOTE: Non-swimming fish is defined as fish with less than 50% activity at 10 cm/s. It is not recommended that non-swimming fish be removed.
In a new pop-up window that asks whether the groups are unblinded and whether the user would like to combine any groups, unblind or combine groups if there is more than one control group.
After a response is given for the previous question, ensure that the program gives a message Aligning file X of Y, where X is the current file being aligned and Y is the total number of files to align. It takes about 30 s for each file to be aligned.
Once the files are aligned, check for a new .csv file generated with the same name (_aligned.csv). Ensure that the program combines the data, runs statistics, and plots output graphs. Check for the analysis files generated in a new folder labeled Results within the parent folder that contains the _raw.csv and _aligned.csv files.
Within the Results folder, check for two folders named Diagnostics and Graphs and four .csv files named BulkData_Avg, BulkData_Full, SummaryData_Avg, and SummaryData_Full.
NOTE: The SummaryData_Full.csv contains the individual data for each fish in each group at each time point. This data is automatically plotted but can be extracted and plotted elsewhere.
Ensure that the Graphs folder contains the graphs generated by the program and .csv files containing the data points for each graph.
Ensure that the Diagnostics folder contains a single .csv file with diagnostic data for aligned files.
NOTE: Columns in the Diagnostics.csv file include the following: a) The number of frames containing extra objects, which should be less than 100. Too many frames with extra objects suggest a problem with the tracking. b)The number of frames with missing or merged objects. It is normal for this metric to be high. Fish that have not regenerated well will frequently be swept to the back of the tunnel and will be counted as missing. c) Frames with more than 240-pixel jumps. This number increases with the number of objects (fish) in a single movie. A detailed explanation of how the behavior metrics were calculated is provided in Supplementary File 1.
