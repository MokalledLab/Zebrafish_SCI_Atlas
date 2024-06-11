# Zebrafish_SCI_Atlas Codes
This repository contains all the codes that are used in the manuscript titled "Single-cell analysis of innate spinal cord regeneration identifies intersecting modes of neuronal repair" by Saraswathy VM et al. 2024. The instructions to run each code is provide inside the respective folders. Additionally a demo dataset in also provided inside each folder to test the respective codes. Here, I am describing the utility of each code.


## Cell Counting

Cell counting on spinal cord section is performed in two steps. The first step uses a fiji macro to count the nuclei present in the sections using the DAPI/Hoechst counterstaining. Then, the output from the Fiji Script (csv file) is processed by an R script to quantify every marker count present in the spinal cord and overlapping with the nuclear staining. 

## DE Marker Scoring

This is R script that performs quantification of overlap between two list of genes. The list of genes are read from two different excel files. Then it calculates binomial probabilities using hypergeometric distribution.

## HCR Quantification

This is a Fiji script that will take .czi files from Zen software as input and quantifies the signal of your desired channel. 

## Seurat_Species_Converter

This is an R script which convertes the gene names of count or data slot inside your seurat object to an orthologous species of your choice. The input will be a seurat object as .rds file. The script uses biomart to identify orthologous genes.

## Swim Behavior analysis

Swim behaviour analysis is performed in two steps as described in the following paper (https://app.jove.com/t/63240/assessment-of-swim-endurance-and-swim-behavior-in-adult-zebrafish). The fiji script will track the videos and then, the R script will process the output from the Fiji script to provide different swim matrics for different groups. 

Visit individual folders for more details. 

## Citation

If you find any of these codes useful for you, please cite

[![DOI](https://zenodo.org/badge/657303962.svg)](https://zenodo.org/doi/10.5281/zenodo.11585742)
