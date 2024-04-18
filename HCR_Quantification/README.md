## System requirements

To run the Fiji Script, you need to install Fiji on your sytem from this link : https://imagej.net/software/fiji/downloads.

##Instructions to Run

#### Limitations
The script can only quantify a single plane image and not image stacks. If you have image stack, you have to make orthogonal projection to make them a single plane.
//This v3 version of the hcr program quantifies the overall HCR signal as well as the signal inside your cell type of interest. v3 doesn't need a background channel to run quantification. 
//if you have a background channel please use the v2 version
//Two caveats of this script:  you can't leave your cell specific channel empty. Make sure to threshold some pixel otherwise it will throw an error. 
//also you can only quantify  one hcr channel at a time.


1. Open Fiji and then, drag and drop this script (hcr_celltypespecific_analysis_v3.1_080222.ijm) on Fiji software. This will open the script for your
2. Hit Run button at the bottom.
3. This will ask you open the folder where the files to be quantified are located
4. Then dialogue prompt will apper asking channel numbers which contain the nuclei, the signal to be quantified and the celltype specific channel. You cannot leave the celltype channel empty here.
5. Then the macro will open the nuclei channels and asks you to draw across the region to be quantified.Then click OK
6. Now, the macro will ask to pain over any non-specific signal present in your image. Click OK
7. Now you have to set threshold for the signal that needs to be quantified. Adjust the threshold in such a way that you select lease amount of background noise. Click OK
8. Now, the macro will ask you to threshold the cell type signal that you want to quantify the amount of you HCR signal present inside. Click OK
9. Repeat the steps for all the images present in the folder. 

After finishing the quantification, a folder named HCR quantification files will be generated. Inside that files, you can find different quantification measurement in the files Quantification_summary.csv and Rawintensity_sum.txt. This marco will also pseudocolor the HCR and overlay it on the cell specific channel that you selected. 

Check out the input and output folder here to see the results. 
