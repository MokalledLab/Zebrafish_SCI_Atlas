# System Requirements

You need to install R and R studio to run this script:  https://posit.co/download/rstudio-desktop/ 

## Session info

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
[1] progress_1.2.3     Matrix_1.6-5       biomaRt_2.56.1     xlsx_0.6.5         ggplot2_3.5.0      Seurat_5.0.1       SeuratObject_5.0.1
[8] sp_2.1-2           dplyr_1.1.4       

loaded via a namespace (and not attached):
  [1] RColorBrewer_1.1-3      rstudioapi_0.15.0       jsonlite_1.8.8          magrittr_2.0.3          spatstat.utils_3.0-4   
  [6] zlibbioc_1.46.0         vctrs_0.6.5             ROCR_1.0-11             memoise_2.0.1           spatstat.explore_3.2-5 
 [11] RCurl_1.98-1.14         htmltools_0.5.7         curl_5.2.0              sctransform_0.4.1       parallelly_1.37.0      
 [16] KernSmooth_2.23-22      htmlwidgets_1.6.4       ica_1.0-3               plyr_1.8.9              plotly_4.10.4          
 [21] zoo_1.8-12              cachem_1.0.8            igraph_2.0.2            mime_0.12               lifecycle_1.0.4        
 [26] pkgconfig_2.0.3         R6_2.5.1                fastmap_1.1.1           GenomeInfoDbData_1.2.10 fitdistrplus_1.1-11    
 [31] future_1.33.1           shiny_1.8.0             digest_0.6.34           colorspace_2.1-0        S4Vectors_0.38.2       
 [36] patchwork_1.2.0         AnnotationDbi_1.62.2    tensor_1.5              RSpectra_0.16-1         irlba_2.3.5.1          
 [41] RSQLite_2.3.5           filelock_1.0.3          progressr_0.14.0        fansi_1.0.6             spatstat.sparse_3.0-3  
 [46] httr_1.4.7              polyclip_1.10-6         abind_1.4-5             compiler_4.3.1          bit64_4.0.5            
 [51] withr_3.0.0             DBI_1.2.2               fastDummies_1.7.3       MASS_7.3-60             rappdirs_0.3.3         
 [56] tools_4.3.1             lmtest_0.9-40           httpuv_1.6.14           future.apply_1.11.1     goftest_1.2-3          
 [61] glue_1.7.0              nlme_3.1-164            promises_1.2.1          grid_4.3.1              Rtsne_0.17             
 [66] cluster_2.1.4           reshape2_1.4.4          generics_0.1.3          gtable_0.3.4            spatstat.data_3.0-4    
 [71] tidyr_1.3.1             hms_1.1.3               data.table_1.15.0       xml2_1.3.6              XVector_0.40.0         
 [76] utf8_1.2.4              BiocGenerics_0.46.0     spatstat.geom_3.2-8     RcppAnnoy_0.0.22        ggrepel_0.9.5          
 [81] RANN_2.6.1              pillar_1.9.0            stringr_1.5.1           spam_2.10-0             RcppHNSW_0.5.0         
 [86] later_1.3.2             rJava_1.0-11            splines_4.3.1           BiocFileCache_2.8.0     lattice_0.21-8         
 [91] survival_3.5-7          bit_4.0.5               deldir_2.0-2            tidyselect_1.2.0        Biostrings_2.68.1      
 [96] miniUI_0.1.1.1          pbapply_1.7-2           gridExtra_2.3           IRanges_2.34.1          scattermore_1.2        
[101] stats4_4.3.1            Biobase_2.60.0          matrixStats_1.2.0       stringi_1.8.3           lazyeval_0.2.2         
[106] codetools_0.2-19        xlsxjars_0.6.1          tibble_3.2.1            cli_3.6.2               uwot_0.1.16            
[111] xtable_1.8-4            reticulate_1.35.0       munsell_0.5.0           GenomeInfoDb_1.36.4     Rcpp_1.0.12            
[116] globals_0.16.2          spatstat.random_3.2-2   dbplyr_2.4.0            png_0.1-8               XML_3.99-0.16.1        
[121] parallel_4.3.1          ellipsis_0.3.2          blob_1.2.4              prettyunits_1.2.0       dotCall64_1.1-1        
[126] bitops_1.0-7            listenv_0.9.1           viridisLite_0.4.2       scales_1.3.0            ggridges_0.5.6         
[131] crayon_1.5.2            leiden_0.4.3.1          purrr_1.0.2             rlang_1.1.3             KEGGREST_1.40.1        
[136] cowplot_1.1.3    

# Instructions to Run

Open the R script in R studio. Set the directory as the folder where you saved all the .rds files that need conversion

By default, this R script will convert the data slot of your seurat object in the RNA assay ( Defined in line 113:  zebra.data<- zebra@assays$RNA@data). You can easily convert any slot by changing
the slot name instead of "data" in line 113. But give the same slot name in line 123 as well:  CreateAssayObject(data = convert.data). For e.g., if I want to convert the counts slot, following will be my codes
 113:  zebra.data<- zebra@assays$RNA@counts
 123:  zebra[["RNA"]]<- CreateAssayObject(counts = convert.data)

 Now you have to edit the user input sections: line 13 and line 15. By default this script convert from zebrafish data to any species of your selection from the ensemble genome database. You can provide a list of all the 
 seurat objects (.rds files) separated by comma in line 13 and give the species to convert name in line 15. Save the R script and hit source button. 


 ## Expected output

 A new RDS file with convert seurat object will be created. And this new RDS will be over writing the existing RNA data with new converted data and then saving the rds file with a new name.

 ## Run time 
 This will vary depending on the size of the dataset. A dataset with 20k cells will take around 2 hrs to finish converting.


 ## Defined set of rules to convert zebrafish dataset to species of choice. 

The following rules were applied while converting the data matrix from zebrafish to human: 1) one-to-one orthologue mapping was performed whenever possible, 2) For genes with one to several human orthologues, the corresponding zebrafish RNA data value was copied to every mapped gene in humans, 3) RNA data values were eliminated for zebrafish genes that did not have any human orthologue, 4) RNA data values of paralogous zebrafish genes were added and the cumulative data value was assigned to the human orthologue 
 
