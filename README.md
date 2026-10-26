# Genome annotation of *Arabidopsis thaliana*

Annotation of a previously assembled *A. thaliana* genome (PacBio HiFi reads, assembled with Flye). The project covers transposable element (TE) annotation and analysis, and gene annotation with MAKER. It was done on the university cluster (SLURM + Apptainer containers) as part of a genome annotation course.

last updated: 26.10.

## Pipeline overview

| Step | What it does | Tool | Script |
|---|---|---|---|
| 1 | TE annotation: builds a non-redundant TE library, classifies TEs, writes GFF3 | EDTA | `scripts/01-run_EDTA.sh` |
| 2 | Classifies intact LTR retrotransposons into clades | TEsorter | `scripts/02-run_TEsorter_full_length_LTRs.sh` |
| 3 | Plots LTR identity per clade (young vs. old insertions) | R | `scripts/03-full_length_LTRs_identity_copy.R` |
| 4 | Circos plot of TE density along the largest contigs | R (circlize) | `scripts/04-annotation_circlize.R` |
| 5 | Gene annotation | MAKER | `scripts/05-run_maker.sh` |
| 6 | Classifies Copia/Gypsy sequences of the TE library into clades | TEsorter | `scripts/06-TEsorter_lib.sh` |
| 7 | Parses Repeat Masker outputs | parseRM.pl | `scripts/07-parseRM.pl` 
| 8 | TE landscape and insertion age plots | RepeatMasker output, parseRM.pl, R | `scripts/08-plot_div.R` |
| 8a | Converts x-axis of landscape plot into Myr | RepeatMasker output, parseRM.pl, R | `scripts/08a-plot_div.R`


## Repository layout

```
scripts/     SLURM and R scripts (tracked)
plots/       final figures (tracked)
results/     small result tables (tracked)
data/        assembly and inputs (not tracked)
output/      raw tool output (not tracked)
logs/        SLURM logs (not tracked)
```

Large files (assembly, EDTA, MAKER output, containers) are excluded with `.gitignore`.

## How to use

Requirements: a SLURM cluster with Apptainer and the course containers (EDTA, TEsorter, MAKER, and the R analysis image `Annotation_analysis_R4.4.sif`).

1. Clone the repository and create the folders that are not tracked:
   ```bash
   git clone git@github.com:marciaverarohrer/genome_annotation_course.git
   cd genome_annotation_course
   mkdir -p logs data/assemblies/flye output plots
   ```
2. Put the Flye assembly at `data/assemblies/flye/assembly.fasta`.
3. Edit `WORKDIR` (and `COURSEDIR` if needed) at the top of each script.
4. Submit the SLURM scripts from the project root, in order:
   ```bash
   sbatch scripts/01-run_EDTA.sh
   ```
   Step 2 needs the EDTA intact LTR files, so start it once EDTA has written them. Steps 3, 4 and 6 are R scripts, run on an interactive node:
   ```bash
   apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla scripts/04-annotation_circlize.R
   ```
   Step 6 first needs `parseRM.pl` run on the EDTA RepeatMasker output (`*.RM.out`).

## Main results

- Genome: 134.3 Mb in 155 sequences; 14.09% annotated as interspersed TEs.
- Gypsy is the most abundant superfamily (4.35% of the genome, 5.8 Mb), followed by helitrons (2.94%), Mutator (2.61%) and Copia (1.46%).
- Of 290 intact LTR retrotransposons, Ale (Copia) and Athila (Gypsy) are the most abundant clades.
- The TE landscape shows a recent peak at about 1 Myr (mostly MITE/DTM) and an older Gypsy-dominated peak at about 3-8 Myr. Ages use T = K / 2r with r = 8.22 × 10⁻⁹ (Kagale et al., 2014), without CpG correction, so they are approximate.

## Tools

EDTA v2.3.0, TEsorter 1.3.0 (rexdb-plant), RepeatMasker (via EDTA), parseRM.pl, R 4.4 (circlize, tidyverse, ComplexHeatmap), MAKER 3.01.03, SeqKit, samtools.

## Notes

README.md organization, debugging and step_by_step.md organization and questions were edited with help of claude.ai
