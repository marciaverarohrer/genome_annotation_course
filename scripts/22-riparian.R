library(GENESPACE)

wd <- "/data/users/mrohrer/genome_annotation_course/output/comparisons/GENESPACE"
focal_genome <- "Kar_1"
load(file.path(wd, "results", "gsParams.rda"))   # loads gsParam
dir.create(file.path(wd, "processed_riparian"), showWarnings = FALSE)

plot_riparian(gsParam, genomeIDs = c("TAIR10", focal_genome), refGenome = "TAIR10", reorderBySynteny = TRUE, pdfFile = file.path(wd, "processed_riparian", "Kar_1_vs_TAIR10.pdf"))

plot_riparian(gsParam, refGenome = "TAIR10", reorderBySynteny = TRUE, syntenyWeight = 1, scalePlotWidth = 1.5, pdfFile = file.path(wd, "processed_riparian", "all_genomes_TAIR10.pdf"))