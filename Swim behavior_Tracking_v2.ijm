//Get a list of the videos you would like to track
dir = getDirectory("Select the folder containing the videos you want to track.");
list = getFileList(dir);
files=newArray(0);
done_files=newArray(0);
do_files=newArray(0);
roiManager("reset");
setBackgroundColor(255, 255, 255);
run("Set Measurements...", "area centroid display redirect=None decimal=3");
//Create a list of all .avi files which have not been tracked already
for(i=0;i<list.length;i++){
	if(endsWith(list[i],".avi")){
        files=Array.concat(files,list[i]);
	}
	if(endsWith(list[i],"_raw.csv")){
        done_files=Array.concat(done_files,list[i]);
	}
}
for(i=0;i<done_files.length;i++){
	done_files[i]=substring(done_files[i], 0,6);
}
for(i=0;i<files.length;i++){
	match=0;
	for(j=0;j<done_files.length;j++){
		if(startsWith(files[i],done_files[j])){
			match=match+1;
		} 
	}	
	if(match==0){do_files=Array.concat(do_files,files[i]);
	}
}

//Identify objects in each frame and save the coordinates for each of these objects in a .csv file.
setBatchMode(false);
for(j=0;j<do_files.length;j++){
	movie=j+1;
	showStatus("Processing movie "+movie+" of "+do_files.length);
	run("Clear Results");
	filename=dir+do_files[j];
	run("AVI...", "open=&filename use");
	Stack.getDimensions(width, height, channels, slices, frames);
	//Open the first movie to set the ROI and threshold used for tracking all of the movies.
	if(j==0){
		waitForUser("Draw a rectagle or polygon around the ROI in which to track and press OK"); 	
		roiManager("Add");	
		
		Stack.setSlice(1);
		run("Duplicate...", "title=1");
		roiManager("Select", 0);	
		run("Clear Outside");
		run("8-bit");
		run("Threshold...");
		waitForUser("Set the desired threshold and press OK"); 
		getThreshold(lower,upper);
		close();
		close();
		setBatchMode(true);
		run("AVI...", "open=&filename use");
	}
	//Using the ROI and threshold set above, record the XY coordinates of each object in each frame
	for (i=1; i<=slices; i++){
		showProgress(i, slices);
		roiManager("select", 0);
		Stack.setSlice(i);
		run("Duplicate...", "title=&i");
		roiManager("Select", 0);
		run("Clear Outside");
		run("8-bit");
		setThreshold(lower, upper);
		run("Convert to Mask", "method=Default background=Light");				
		run("Analyze Particles...", "size=1500-Infinity");
		close();
	}
	dotIndex = indexOf(do_files[j], ".avi");
	new_filename=dir+substring(do_files[j], 0, dotIndex)+"_raw.csv";
	saveAs("Results", new_filename);
	close();
}