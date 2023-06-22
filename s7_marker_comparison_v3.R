library(dplyr)
library(Seurat)
library(ggplot2)
options(java.parameters = "-Xmx16000m")
library("xlsx")
library(svDialogs)


ref<- read.xlsx(file="Zebrafish_SC_Cell type marker_database_081022_v4.xlsx", sheetName = "zebrafish_genes")
#getting total number of markers available in the dataset for each celltype 



stat_1<- matrix(nrow = length(colnames(ref)), ncol=1, dimnames=list(colnames(ref), c("No. of markers")))
for ( k in 1:length(colnames(ref))){
  check_list<-ref[,k]
  check_list<-check_list[!is.na(check_list)]
  check_list<-unique(check_list)
  n<- length(check_list)
  #print(paste(colnames(ref)[k],n,sep = "_"))
  stat_1[k,1]<-n
}

marker<- read.xlsx(file="topDEmarkers_onlypos_RNA.xlsx", sheetName = "Organized")
marker.score<- matrix(nrow = length(colnames(ref)), ncol = length(colnames(marker)), dimnames = list(colnames(ref),colnames(marker)))
gene_id<- matrix(nrow = 1000, ncol = length(colnames(ref)), dimnames = list(NULL,colnames(ref)))
de_markers_n<- matrix(nrow = length(colnames(marker)), ncol = 1, dimnames = list(colnames(marker),"No. of genes"))


for ( k in 1:length(colnames(ref))){
  check_list<-ref[,k]
  check_list<-check_list[!is.na(check_list)]
  check_list<-unique(check_list)
  genes_identified<- matrix(nrow = 500, ncol = length(colnames(marker)), dimnames = list(NULL,colnames(marker)))
  #print(colnames(ref)[k])
  #print(check_list)
  r=1
  for (i in 1:length(colnames(marker))){
    gene_list<- marker[,i]
    gene_list<-gene_list[!is.na(gene_list)]
    gene_list<-unique(gene_list)
    gene_list_n<-length(gene_list)
    de_markers_n[i,1]<-gene_list_n
    c=0
    for( j in gene_list){
      status<- is.element(j,check_list)
      if(status==T){
        c=c+1
        gene_id[r,k]<-j
        r=r+1
        marker.score[k,i]<-c
        genes_identified[c,i]<-j
      }
    }
  }
  write.xlsx(genes_identified, file = "markers_identified_ hypergeometric probability.xlsx",append = T, sheetName = colnames(ref)[k], showNA = F,row.names = F)
}
marker.score[is.na(marker.score)]<-0
write.xlsx(marker.score, file = "marker.scoring_ hypergeometric probability.xlsx", append = T, sheetName = "Scoring")

marker.score2<- marker.score

#calculating binomial probabilities using hypergeometric distribution

z_genes_n<-26206#total number genes expected in the genome
binomial_prob<- matrix(nrow = length(row.names(marker.score2)), ncol = length(colnames(marker.score2)), dimnames = list(row.names(marker.score2), colnames(marker.score2)))
for (j in 1:length(colnames(marker.score2))){
  a<- de_markers_n[j,1]#total number of differentially expressed markers for a specific cluster
  for(k in 1:length(row.names(marker.score2))){
    b<- stat_1[k,1]#total number of genes present in the database for a specific celltype
    t<-marker.score2[k,j] #overlap between two gene list

    probability<-phyper(t-1,a,z_genes_n-a,b,lower.tail = F)
    binomial_prob[k,j]<- probability
  }
}



#normalizing the marker score to the total number of genes present in the database

for (i in 1:length(row.names(stat_1))){
  marker.score[i,]<- (marker.score[i,]/stat_1[i,1])*100
}

log_binomial<- -log10(binomial_prob)

write.xlsx(marker.score, file = "marker.scoring_ hypergeometric probability.xlsx", append = T, sheetName = "Normalized_Scoring")
write.xlsx(binomial_prob, file = "marker.scoring_ hypergeometric probability.xlsx", append = T, sheetName = "Binomial probability")
write.xlsx(log_binomial, file = "marker.scoring_ hypergeometric probability.xlsx", append = T, sheetName = "-log10P")
write.xlsx(gene_id, file = "marker.scoring_ hypergeometric probability.xlsx", append = T, sheetName = "Identified_genes", showNA = F, row.names = F)