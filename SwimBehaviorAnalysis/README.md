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
I am just copying here as well. 


3.	Capturing movies for swim behavior assay 
 
NOTE: Only up to 5 animals can be tracked at a time, if experimental groups are larger than 5 animals, multiple videos can be taken for each group, where the first video tracks 5 animals and the second video tracks the other 5 animals. For longitudinal studies that aim to track individual animals over time, fish can be individually housed and tracked across multiple time points. 

3.1.	Turn on the Infrared light panel located under the swim tunnel. Secure the camera on a ceiling mount on top of the swim tunnel. Adjust focus and aperture rings. NOTE: These settings depend on the distance between the camera and the swim tunnel on one hand and the light environment. 

3.2.	 Open camera recording software. Set the software settings as follows.
 
3.2.1.	Click 1:4 aspect display. Make sure that the field of view covers the entire swim tunnel. Turn off auto-contrast and auto-white balance to normalize background and contrast across groups.
 
3.2.2.	Open the “Camera Properties” window by clicking the wrench icon. Set parameters as follows: Pixel Clock: 344 MHz Frame Rate: 70 fps, Click the box by “Hold” to check it Exposure time: 0.290 ms Do not close this window.
 
3.2.3.	Crop the recording window to only cover the swim chamber of the tunnel, tilting/turning the camera as needed. 

3.3.	Open the recording window by clicking on the film reel icon. Set the recording settings as follows:
 
3.3.1.	Check the box for the maximum number of frames. 

3.3.2.	Manually input 63,000 for number of frames. 

3.3.3.	Check the box for “Calc. Frame rate”. This allows the program to pull the defined frame rate defined in 3.2.2 (70fps).

3.3.4.	Change the JPEG Quality to 30. 

3.4.	Record a test run. 

3.4.1.	Click “Create” and name the new file “Test” and save it on the desktop. 

3.4.2.	Go back to the recording window and click “Record”. Let the test movie run for entire duration of protocol (15 min) . 


3.4.3.	Once the test is finished, ensure there are no dropped frames and that 63000 frames are recorded. 

3.5.	Place a group of fish in the swim tunnel and close the tunnel using a fully enclosed lid. 
NOTE: Ensure all fish are in the tunnel before fully tightening the lid. Make sure there are no air bubbles under the lid. This will affect the results. 

3.6.	Open a new recording window and name the file. EX: 2_A_1_00001_WildtypeGroupA.avi NOTE: Ensure settings are according to the parameters in 3.2 and 3.3. The JPEG Quality will always go back to default and needs to be reset for each new movie. 

CAUTION: DO NOT CLICK RECORD YET
 
3.7.	Begin a new experiment using the flow velocity control software. Set the protocol at 0 cm/s for 5 min, 10 cm/s for 5 min, followed by 20 cm/s for 5 min. Save the new data output file under the same name as the movie file and in the same folder (This will save as a .csv file).
 
CAUTION: DO NOT CLICK START YET 

3.8.	Place a paper towel or piece of fabric on the side of the swim tunnel to ensure all behaviors are due to fish swimming and not a startle response caused by movement in the environment.

3.9.	In quick succession, make sure water is calm and there are no ripples moving across the frame. Click “record” in the camera software window to start recording the movie file. Click “start” in the flow velocity control software to begin the protocol. The flow velocity control protocol will continue uninterrupted. 

3.10.	Watch the movie to make sure that no frames are dropped, that there are no bubbles in the field of view, and that all fish are recorded.
 
3.11.	Once movie recording is completed, click “Emergency Stop” to end the flow velocity control protocol. The data output file saves automatically. Click “close” on the video recording window. This will save the movie file. 

3.12.	Remove the lid. Carefully retrieve the fish and return them to their tank. 

3.13.	Repeat steps 3.5 to 3.11 for all groups.
 
Once all groups are finished, movies are converted from 70 fps videos into 20 fps with the MovieProcessing_v5.bat. 

NOTE: This step is  optional. It reduces the number of frames in a 15 minute video from 63,000 to 18,000 frames, and makes the SwimBehavior.R script run more quickly.
3.14.	The tunnel must be emptied, and all equipment put away.

4.	Analyzing movies for swim behavior assessment 
NOTE: Movie recording and analysis can be completed on separate days. 

4.1.	Open the “Tracking_v2.ijm” script in “Fiji” and click “Run” to begin the program.
 
4.2.	A window will pop up. Choose the folder containing the swim behavior movies to track. Click “Open”. Frame 1 of the first movie, a dialog box, and the ROI manager will come up.
 
4.3.	Follow the directions given in the dialog box. Create an ROI of the bottom of the swim chamber. Click “OK”. NOTE: No black corners should be seen. 

4.4.	The threshold window will open along with an edited, thresholded Frame 1. Change the color scheme from “B&W” to “Red”. Adjust the “Max value” until frame 1 shows the fish in red and nothing else. Record the threshold. Click “OK” in the dialog box. The program will automatically run. The ROI that was made for Frame 1 will be continuously selected and unselected for subsequent frames. A progress bar will monitor the process in the bottom right corner of the Fiji window. Tracking takes about 40 min per movie.
 
4.5.	When all movies are tracked the Fiji program will stop. The ROI will stop being selected. The folder containing the movies will now have a “_raw.csv” file for each movie. Fiji can be closed.
 
4.6.	Aligning, Assembling, and Acquiring Descriptive Statistics
 
4.6.1.	Open the “Swim Behavior_v7-3.R” script in “R Studio”. 

4.6.2.	Click “Source” in the top right corner of the script section. A new window will open. Choose the folder containing the “_raw.csv” files generated by Fiji. 

4.6.3.	Click “Open”. The program will run automatically. 

4.6.4.	A dialog box will come up asking to confirm the number of fish in each movie. If the numbers given are correct, if correct click “Yes”, if incorrect click “No". If “No” was clicked, a message will pop up asking that the movies be re-tracked with a new ROI and threshold. If “Yes” was clicked, the program will proceed.
 
4.6.5.	A new window will open asking if the non-swimming fish should be removed. Click “Yes” or “No”. Non-swimming fish is defined as fish with % activity less than 50% at 10cm/s.

NOTE: It is not recommended that non-swimming fish be removed. 

4.6.6.	When a response is given, that box will close and a new one will open asking if the groups are unblinded and if the user would like to combine any groups. Groups can be unblinded or combined if there is more than one control group.
 
4.6.7.	When a response is given for the last question, the program will give a message “Aligning file X of Y”, where X is the current file being aligned and Y is the total number of files to align. It takes about 30 seconds for each file to be aligned. 

4.7.	Once the files are aligned, a new csv file with the same name will be generated (“_aligned.csv”). The program will then combine the data, run statistics, and plot output graphs. The analysis files will be generated in a new folder labeled “Results” within the parent folder that contains the “_raw.csv” and “_aligned.csv” files.
 
4.8.	Within the results folder, there are two folders named “Diagnostics” and “Graphs” and four csv files named “BulkData_Avg”, “BulkData_Full”, “SummaryData_Avg”, and “SummaryData_Full”. The “Graphs” folder contains the graphs generated by the program. The csv files contain the data points for each graph that is generated.
 
4.9.	The Diagnostics folder contains a single csv file with diagnostic data for aligned files. Columns in the “Diagnostics.csv” file include the following: 

4.9.1.	The number of frames containing extra objects – Should be less than 100. Too many frames with extra objects suggests a problem with the tracking. 

4.9.2.	Number of frames with missing or merged objects – It is normal for this metric to be high. Fish that have not regenerated well will frequently be swept to the back of the tunnel and will be counted as missing. 

4.9.3.	Frames with more than 240-pixel jumps – This number increases as the number of objects (fish) in a single movie.

4.9.4.	The "SummaryData_Full.csv” contains the individual data for each fish in each group at each timepoint. This data is automatically plotted but can be extracted and plotted elsewhere. 

The behavior metrics are calculated as follows: 
	Activity – Measured as a percent of “Active” frames in the total frames of the movie. Higher percent activity usually means better functional recovery. Active frames are frames in which the distance moved was more than 5 pixels compared to the previous frame. Two plots are created for this metric, one with the flow velocity calculated into the activity, the other without the velocity.  
	Average Y position – Average Y position over the time of the movie during the different flow speeds. This is useful for injured fish because fish that are not regenerating as well will stay in the back of the tunnel, because they cannot effectively swim against the flow. 
	Direction – Titled “Time Swam Against Flow” measured in percent of “Against” frames in the total frames of the movie. “Against” is considered frames where the Y position increases by 5 pixels. If the Y position decreases by pixels, the frame is considered “With”. If the Y position changes any less than 5 pixels, the frame is labeled “Static”. “Time Swam Against Flow” is also plotted twice with flow velocity calculated and without. 
	Distance – Measured as “Distance Swam”. This is the total pixel change over all the frames of the movie. This metric is calculated with flow velocity taken into account. 
Burst – A burst is measured as a series of continuous motion (more than one frame) in the “Against” direction. Burst amplitude represents the sum of the distance traveled in all bursts divided by the total number of bursts. Burst duration measures the average number of frames per burst. Burst frequency is the number of bursts per minute.

