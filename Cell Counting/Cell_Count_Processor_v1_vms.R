##HOUSE KEEPING##
library(dplyr)
library(tidyr)
library(rstudioapi)

##PREPARE FOR ANALYSIS##
#Get a list of files to analyze
setwd(selectDirectory(caption="Select the folder containing the raw counts you want to analyze..."))
myFiles <- list.files(path=getwd(), pattern=".csv")
#Identify individual samples from this list
samples<-unique(substr(myFiles,1,as.integer(regexpr("_[^_]*$", myFiles[1])-1)))

##BEGIN ANALYSIS##
#For each sample, open the raw counts and calculate summary counts
summary<-c()
final<-c()
for (i in 1:length(samples)){
  #Open each marker count
  list<-grep(samples[i],myFiles, value = T)
  my_data <- lapply(list, read.csv)
  #Combine each separate file into a single file
  my_data <- lapply(my_data, dplyr::select, Mean)
  print(list)
  my_data <- dplyr::bind_cols(my_data)
  print("I'm fine")
  headings<-sapply(list, function(x){paste0(substr(x,as.integer(regexpr("_[^_]*$", x)+1),as.integer(regexpr("\\.[^\\.]*$", x)-1)),"_Total")})
  colnames(my_data)<-headings
  headings<-sapply(list, function(x){paste0(substr(x,as.integer(regexpr("_[^_]*$", x)+1),as.integer(regexpr("\\.[^\\.]*$", x)-1)))})
  temp<-read.csv(file=list[1])
  final<-cbind(temp$Label,temp$Position,my_data)
  colnames(final)[c(1,2)]<-c("Cell","Position")
  #Change 255 to 1
  final[final==255]<-1
  #Generate a list of possible combinations
  print("hi")
  combinations<-expand.grid(rep(list(0:1), length(list)))
  combinations<-unite(combinations,"Combinations",sep="")
  cell_combos<-unite(final[3:ncol(final)],test,sep="")
  #Make a new column for each possible combination of markers
  for (j in 1:nrow(combinations)){
    temp<-apply(cell_combos,1,function (x){if(x==combinations[j,]){as.numeric("1")}else{as.numeric("0")}})
    final<-cbind(final,temp)
    heading<-""
    for (k in 1:length(list)){
      heading<-paste0(heading,headings[k],if(substr(combinations[j,],k,k)=="1"){"+"}else{"-"})
      if (k<length(list)){heading<-paste0(heading,"/")}
    }
    colnames(final)[ncol(final)]<-heading
  }
  #Generate a summary row and add it to the overall summary
  index<-gregexpr("_",samples[i])
  temp<-as.data.frame(t(c(samples[i],substr(samples[i],index[[1]][1]+1,index[[1]][3]-1),substr(samples[i],index[[1]][3]+1,index[[1]][4]-1),"Total",nrow(final),apply(final[3:ncol(final)],2,sum))))
  colnames(temp)[1:5]<-c("Sample","ID","Level","Position","Total Nuclei")
  summary<-rbind(summary,temp)
  temp<-as.data.frame(t(c(samples[i],substr(samples[i],index[[1]][1]+1,index[[1]][3]-1),substr(samples[i],index[[1]][3]+1,index[[1]][4]-1),"Dorsal",nrow(final[which(final$Position=="Dorsal"),]),apply(final[which(final$Position=="Dorsal"),3:ncol(final)],2,sum))))
  colnames(temp)[1:5]<-c("Sample","ID","Level","Position","Total Nuclei")
  summary<-rbind(summary,temp)
  temp<-as.data.frame(t(c(samples[i],substr(samples[i],index[[1]][1]+1,index[[1]][3]-1),substr(samples[i],index[[1]][3]+1,index[[1]][4]-1),"Ventral",nrow(final[which(final$Position=="Ventral"),]),apply(final[which(final$Position=="Ventral"),3:ncol(final)],2,sum))))
  colnames(temp)[1:5]<-c("Sample","ID","Level","Position","Total Nuclei")
  summary<-rbind(summary,temp)
}

#Save the overall summary as a .csv file
write.csv(summary,file="Count_Summary.csv")
