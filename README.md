# Project description
This project contains scripts to make annotation of a eukaryotic genome after a successful assembly.

In this case the used assembly is flye, outputting a .fasta file used as input for the EDTA annotation.

Arabidopsis Thaliana is the organism used in this project, the assembled sequences stem from PacBio HiFi reads.

EDTA (Extensive de novo TE Annotator), a pipeline designed for the annotation of both structurally intact and fragmented TEs, is applied to the flye .fasta output. It generates a non-redundant TE library, classifies the elements into superfamilies, and outputs annotations in GFF3 format.

The following steps can be done using the scripts:
- EDTA annotation, script 01-
- Transposable Element (TE) sorting, script 02-
- 

# How to use this repository

