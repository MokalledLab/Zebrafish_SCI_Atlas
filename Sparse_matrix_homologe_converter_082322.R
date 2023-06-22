library(dplyr)
library(Seurat)
library(ggplot2)
library(xlsx)
library(biomaRt)
library(Matrix)
library(progress)
future::plan("multicore", workers = 4)


##########################################USER INPUT##################################################################
#this can convert multiple rds file into respective species orthologues. So give the list of rds file names here.
file.list<- c("ekab_uninj136_complete_control.rds", "ekab_uninj136_complete_1 wpi.rds","ekab_uninj136_complete_3 wpi.rds","ekab_uninj136_complete_6 wpi.rds")
#give the species name that you want to convert here. Its normally first letter of the genus name with species name -all small letters and no spaces. 
species.name.to.convert<-"hsapiens" #must be compatible with biomaRT package ensemble species name eg. hsapiens for humans
##########################################################################################################################


#following is the function to convert sparse matrix from zebrafish to the given species orthologues
count_matrix_converter<- function(data.input,species){
  genes<- row.names(data.input)
  #genes<- genes[1:100]
  pb <- progress_bar$new(
    format = " Converting matrix [:bar] :percent eta: :eta",
    total = length(genes), clear = FALSE, width= 60)
  gene_name<- paste0(species,"_homolog_associated_gene_name")
  gene_id<-  paste0(species,"_homolog_ensembl_gene")
  ortho<- getBM(attributes = c("ensembl_gene_id","external_gene_name"  ,gene_name, gene_id), 
                filters ="external_gene_name",
                values = genes,
                mart = ensembl.zebra, uniqueRows = T)
  c=2
  mat1 <- Matrix(0, nrow = 1, 
                 ncol = length(colnames(data.input)), 
                 sparse = TRUE)
  c2=2
  mat2 <- Matrix(0, nrow = 1, 
                 ncol = length(colnames(data.input)), 
                 sparse = TRUE)
  
  for (i in 1:length(genes)){
    pb$tick()
    check1<- which(genes[i]== ortho[,2])
    #print(paste(genes[i],check1,length(check1), sep = "_"))
    if (length(check1)==1){
      check2<- nchar(ortho[,3][check1])
      check3<- is.na(ortho[,3][check1])
      if(check2>0 && check3==F){
        mat1<-rbind(mat1, data.input[i,])
        row.names(mat1)[c]<-ortho[,3][check1]
        c=c+1
      }
    }else if (length(check1)>1){
      for (j in check1){
        check4<-nchar(ortho[,3][j])
        check5<-is.na(ortho[,3][j])
        if(check4>0 && check5==F){
          mat2<-rbind(mat2,data.input[i,])
          row.names(mat2)[c2]<-ortho[,3][j]
          c2=c2+1
        }
      }
    }
  }
  
  mat1<-mat1[-1,]
  mat2<-mat2[-1,]
  comb.mat<- rbind(mat1, mat2)
  colnames(comb.mat)<- colnames(data.input)
  
  urname.comb<- unique(row.names(comb.mat))
  pb2 <- progress_bar$new(
    format = " Adding data of duplicate genes [:bar] :percent eta: :eta",
    total = length(urname.comb), clear = FALSE, width= 60)
  
  pb3 <- progress_bar$new(
    format = " Purging duplicate genes [:bar] :percent eta: :eta",
    total = length(urname.comb), clear = FALSE, width= 60)
  for ( d in urname.comb){
    pb2$tick()
    dup.pos<- which(d==row.names(comb.mat))
    n<- length(dup.pos)
    if(n>1){
      #print(dup.pos)
      for (p in 2:n){
        comb.mat[dup.pos[1],]<-comb.mat[dup.pos[1],]+comb.mat[dup.pos[p],]
      }
    }
  }
  
  for ( d in urname.comb){
    pb3$tick()
    dup.pos<- which(d==row.names(comb.mat))
    n<- length(dup.pos)
    if(n>1){
      for (p in 2:n){
        comb.mat<-comb.mat[-(dup.pos[p]),]
      }
    }
  }
  return(comb.mat)
}



for ( filen in file.list ){
    status<- paste0("Converting ", filen, " to ",species.name.to.convert," orthologues....")
    print(status)
    
    filename<-filen
    zebra<- readRDS(file = filename)
    
    zebra.data<- zebra@assays$RNA@data #if you want to convert data slot, put data instead of count - usually done for CellChat CCI
    
    
    #ideally, you can convert from any species to any. Here it is from zebrafish to your species of choice.
    ensembl <- useMart("ensembl")
    ensembl.zebra <- useMart("ensembl", dataset = "drerio_gene_ensembl")
    species<- species.name.to.convert
    convert.data<-  count_matrix_converter(zebra.data,species)
    
    #over writing the existing RNA data with new converted data and then saving the rds file with a new name
    zebra[["RNA"]]<- CreateAssayObject(data = convert.data)
    new.filename<-paste0("Converted_",species,"_",filename)
    saveRDS(zebra, file = new.filename)
    
}