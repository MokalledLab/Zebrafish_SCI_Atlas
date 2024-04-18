# System Requirements. 
You need to install R and R studio to run this script:  https://posit.co/download/rstudio-desktop/ 

Additional you need two excels files with markers list in different rows with a column title. See the demo files in the output folder. This R packages have following dependencies.

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
[1] svDialogs_1.1.0    xlsx_0.6.5         ggplot2_3.5.0      Seurat_5.0.1       SeuratObject_5.0.1 sp_2.1-2           dplyr_1.1.4       

loaded via a namespace (and not attached):
  [1] deldir_2.0-2           pbapply_1.7-2          gridExtra_2.3          rlang_1.1.3            magrittr_2.0.3        
  [6] RcppAnnoy_0.0.22       matrixStats_1.2.0      ggridges_0.5.6         compiler_4.3.1         spatstat.geom_3.2-8   
 [11] png_0.1-8              vctrs_0.6.5            reshape2_1.4.4         stringr_1.5.1          pkgconfig_2.0.3       
 [16] fastmap_1.1.1          ellipsis_0.3.2         utf8_1.2.4             promises_1.2.1         purrr_1.0.2           
 [21] jsonlite_1.8.8         goftest_1.2-3          later_1.3.2            xlsxjars_0.6.1         spatstat.utils_3.0-4  
 [26] irlba_2.3.5.1          parallel_4.3.1         cluster_2.1.4          R6_2.5.1               ica_1.0-3             
 [31] stringi_1.8.3          RColorBrewer_1.1-3     spatstat.data_3.0-4    reticulate_1.35.0      parallelly_1.37.0     
 [36] lmtest_0.9-40          scattermore_1.2        Rcpp_1.0.12            tensor_1.5             future.apply_1.11.1   
 [41] zoo_1.8-12             sctransform_0.4.1      httpuv_1.6.14          Matrix_1.6-5           splines_4.3.1         
 [46] igraph_2.0.2           tidyselect_1.2.0       rstudioapi_0.15.0      abind_1.4-5            spatstat.random_3.2-2 
 [51] codetools_0.2-19       miniUI_0.1.1.1         spatstat.explore_3.2-5 listenv_0.9.1          lattice_0.21-8        
 [56] tibble_3.2.1           plyr_1.8.9             withr_3.0.0            shiny_1.8.0            ROCR_1.0-11           
 [61] Rtsne_0.17             future_1.33.1          fastDummies_1.7.3      survival_3.5-7         rJava_1.0-11          
 [66] polyclip_1.10-6        fitdistrplus_1.1-11    pillar_1.9.0           KernSmooth_2.23-22     plotly_4.10.4         
 [71] generics_0.1.3         RcppHNSW_0.5.0         munsell_0.5.0          scales_1.3.0           svGUI_1.0.1           
 [76] globals_0.16.2         xtable_1.8-4           glue_1.7.0             lazyeval_0.2.2         tools_4.3.1           
 [81] data.table_1.15.0      RSpectra_0.16-1        RANN_2.6.1             leiden_0.4.3.1         dotCall64_1.1-1       
 [86] cowplot_1.1.3          grid_4.3.1             tidyr_1.3.1            colorspace_2.1-0       nlme_3.1-164          
 [91] patchwork_1.2.0        cli_3.6.2              spatstat.sparse_3.0-3  spam_2.10-0            fansi_1.0.6           
 [96] viridisLite_0.4.2      uwot_0.1.16            gtable_0.3.4           digest_0.6.34          progressr_0.14.0      
[101] ggrepel_0.9.5          htmlwidgets_1.6.4      htmltools_0.5.7        lifecycle_1.0.4        httr_1.4.7            
[106] mime_0.12              MASS_7.3-60  


# Instructions to run
1. Open the script in R studio and set the work directory as the folder where you saved your reference file and comparison file
2. In the case of cluster identification, I have a marker database (Supplementary table S1_Celltype marker database_full spinalcord_022624.xlsx) which is the reference file and the top DE expressed markers as comparison file (Supplementary table S4_topDEmarkers_onlypos_res0.4_fulldataset_022624.xlsx).
3. Then, I need to define the maximum number of genes expected in your comparisons (code line 65). Since, I am comparing different list of genes in the zebrafish genome, I have given total number genes present in the latest assembly as this number.
4. Click "Source" button on the top right hand side of the R-studio.
5. This should give you two excel files as output.
     - marker.scoring_ hypergeometric probability.xlsx - contain different sheets consisting of scores obtained from your comparion as well the binomial probabilities.
     - markers_identified_ hypergeometric probability.xlsx - contains markers identified for each cluster against each reference cell type.  
