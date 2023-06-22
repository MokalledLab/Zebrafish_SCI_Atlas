//This v3 version of the hcr program quantifies the overall HCR signal as well as the signal inside your cell type of interest. v3 doesn't need a background channel to run quantification. 
//if you have a background channel please use the v2 version
//Two caveats of this script:  you can't leave your cell specific channel empty. Make sure to threshold some pixel otherwise it will throw an error. 
//also you can only quantify  one hcr channel at a time.

//setting parameters to measure
run("Set Measurements...", "area mean min centroid integrated limit display redirect=None decimal=3");

//setting background and foreground color black
run("Color Picker...");
setForegroundColor(0, 0, 0);
setBackgroundColor(0, 0, 0);


//get the directory info and open the image and get it's info
dir = getDirectory("Select the folder containing the images you want to analyze.");
//Get a list of the images to analyze
list=newArray(0);
files = getFileList(dir);
for(i=0;i<files.length;i++){
	if(endsWith(files[i],".czi")){
		list=Array.concat(list,files[i]);
	}
}

dir2 = dir + "HCR Quantification files";
File.makeDirectory(dir2);
dir2 = dir2 + "/";

dir3 = dir2 + "Masks";
File.makeDirectory(dir3);
dir3 = dir3 + "/";

dir4 = dir2 + "Individual particle quantification";
File.makeDirectory(dir4);
dir4 = dir4 + "/";

dir5 = dir2 + "HCR overlayed images";
File.makeDirectory(dir5);
dir5 = dir5 + "/";

dir6 = dir2 + "Psuedocolored HCR images";
File.makeDirectory(dir6);
dir6 = dir6 + "/";

dir7 = dir2 + "Filtered HCR images";
File.makeDirectory(dir7);
dir7 = dir7 + "/";


setBatchMode(false);
//collect channel information of the images
		names=newArray(3);
		Dialog.create("");
		Dialog.addMessage("Enter the channel number for each staining in your images:");
		Dialog.addString("Nuclei chanel #", "");
		Dialog.addString("HCR chanel #", "");
		//Dialog.addString("Background chanel #", "");
		Dialog.addString("celltype specific chanel #", "");
		Dialog.show();
		for (i=0;i<3;i++){
			names[i]=Dialog.getString();
		}
		
		//assigning channel information
		nuclei_channel= "C"+names[0]+"-";
		hcr_channel= "C"+names[1]+"-";
		overlay_channel="C"+names[2]+"-";
		
		//start analysis
		for(i=0;i<list.length;i++){
			//Open next image in series
				roiManager("reset");
				filename=dir+list[i];
				open(filename);
				//run("Bio-Formats", "open=filename autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
				title=getTitle();
				nuclei = nuclei_channel+title;
				hcr= hcr_channel+title;
				overlay =overlay_channel+title;
				split_title=split(title, ".");
				run("Split Channels");
				selectWindow(nuclei);
				setTool("polygon");
				waitForUser("Draw a polygon around the area you want to analyze and press OK.\n(Note: The ROI can be drawn on any channel)");
				selectWindow(hcr);
				run("Restore Selection");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
				run("Select None");
				selectWindow(overlay);
				run("Restore Selection");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
				run("Select None");
				run("Duplicate...", " ");
				overlay2=getTitle();
				selectWindow(hcr);
				setTool("Paintbrush Tool");
				run("Paintbrush Tool Options...", "brush=25");
				waitForUser("Click or paint over the background signal to mask them and then press OK.");
				run("Threshold...");
				setAutoThreshold("Default dark");
				waitForUser("Set the desired threshold for you hcr signal and press OK.");
				min=0;
				max=0;
				getThreshold(min, max);
				run("Create Mask");
				run("Invert");
				mask1=getTitle();
				saveAs("Tiff", dir3+mask1);
				mask1=getTitle();
				selectWindow(hcr);
				resetThreshold();
				imageCalculator("Subtract create", hcr,mask1);
				final_hcr=getTitle();
				run("Duplicate...", " ");
				final_hcr2=getTitle();
				selectWindow(final_hcr);
				final_hcr_name=split_title[0]+"_Total HCR Signal";
				saveAs("Tiff", dir7+final_hcr_name);
				final_hcr=getTitle();
				run("Threshold...");
				setThreshold(min, max);
				//setAutoThreshold("Default dark");
				//waitForUser("Set the desired threshold to count particle and intensity of the hcr signals and press OK.");
				run("Analyze Particles...", "  show=Outlines summarize display");
				selectWindow("Results");
				result_name=split_title[0]+"_individual particle data.csv";
				saveAs("Results", dir4+result_name);
				selectWindow("Results");
				rawintensity_full=Table.getColumn("RawIntDen");
				Array.getStatistics(rawintensity_full, min, max, mean, stdDev);
				numberofelements_full=lengthOf(rawintensity_full);
				sum_full=mean*numberofelements_full;
				data1=newArray(final_hcr_name,sum_full);
				Array.print(data1);
				selectWindow("Results");
				run("Close");
				selectWindow(final_hcr);
				run("Threshold...");
				run("16 colors");
				hcr_lut=getTitle();
				setThreshold(1, 255);
				run("Create Selection");
				selectWindow(overlay);
				run("Select None");
				run("RGB Color");
				run("Restore Selection");
				selectWindow(hcr_lut);
				resetThreshold();
				run("Copy");
				selectWindow(overlay);
				run("Paste");
				overlay_name="HCR overlayed image_"+split_title[0];
				saveAs("Tiff", dir5+overlay_name);
				selectWindow(hcr_lut);
				run("Calibration Bar...", "location=[Upper Right] fill=White label=Black number=5 decimal=0 font=12 zoom=2 overlay");
				run("Flatten");
				hcr_lut2=getTitle();
				lut_name="Psuedocolored HCR image_16color_"+split_title[0];
				saveAs("Tiff", dir6+lut_name);
				selectWindow(overlay2);
				run("Select None");
				run("Threshold...");
				setAutoThreshold("Default dark");
				waitForUser("Set the desired threshold for your cell specific marker and press OK.");
				run("Create Mask");
				run("Invert");
				mask4="inverted mask of celltype marker_"+split_title[0];
				saveAs("Tiff", dir3+mask4);
				mask4=getTitle();
				selectWindow(final_hcr2);
				run("Select None");
				imageCalculator("Subtract create", final_hcr2,mask4);
				celltype_hcr=getTitle();
				hcr_celltype_mask=celltype_hcr+"_HCR inside celltype";
				saveAs("Tiff", dir7+hcr_celltype_mask);
				celltype_hcr=getTitle();
				selectWindow(celltype_hcr);
				run("Threshold...");
				setThreshold(min, max);
				//setAutoThreshold("Default dark");
				//waitForUser("Set the desired threshold to count particle and intensity of the hcr signals inside your celltype marker and press OK.");
				run("Analyze Particles...", "  show=Outlines summarize display");
				selectWindow("Results");
				result_name2=split_title[0]+"_celltype specific individual particle data.csv";
				saveAs("Results", dir4+result_name2);
				selectWindow("Results");
				rawintensity_celltype=Table.getColumn("RawIntDen");
				Array.getStatistics(rawintensity_celltype, min, max, mean, stdDev);
				numberofelements_celltype=lengthOf(rawintensity_celltype);
				sum_celltype=mean*numberofelements_celltype;
				data2=newArray(hcr_celltype_mask,sum_celltype);
				Array.print(data2);
				selectWindow("Results");
				run("Close");
				run("Close All");		
		}
selectWindow("Summary"); 
saveAs("Results", dir2+"Quantification_summary.csv");
Table.deleteRows(0, (list.length*2), "Quantification_summary.csv");
selectWindow("Log");
log_name="Rawintensity_sum.txt";
saveAs("Text", dir2+log_name);
print("\\Clear");