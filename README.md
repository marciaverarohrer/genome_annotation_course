# Genome annotation of *Arabidopsis thaliana*

Annotation of a previously assembled *A. thaliana* genome (PacBio HiFi reads, assembled with Flye). The project covers transposable element (TE) annotation and analysis, and gene annotation with MAKER. It was done on the university cluster (SLURM + Apptainer containers) as part of a genome annotation course.

last updated: 29.10.

## Pipeline overview

### Weeks 1-2: transposable elements
 
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

### Week 3: gene annotation
 
| Step | What it does | Tool | Script |
|---|---|---|---|
| MAKER | Gene prediction from Trinity RNA-seq, protein evidence and Augustus (*arabidopsis* model), using the EDTA TE library for masking | MAKER (MPI) | `scripts/XX-run_maker.sh` |
| 9 | Merges the per-contig MAKER output into single GFF and FASTA files | gff3_merge, fasta_merge | `scripts/09-merge_maker.sh` |
| 10 | Renames genes, transcripts and proteins with the accession prefix (`Kar-1`) | maker_map_ids | `scripts/10-rename_ids.sh` |
| 11 | Pfam domain search on the proteins | InterProScan 5.70 | `scripts/11-interproscan.sh` |
| 12 | Adds Pfam/GO to the GFF, computes AED, filters models, subsets FASTA files | MAKER utilities, seqkit | `scripts/12-filter_gff.sh` |
| 13 | Cumulative AED plot | R | `scripts/13-plot_AED.R` |
| 14 | Longest isoform per gene, then BUSCO (`brassicales_odb10`) | seqkit, BUSCO | `scripts/14-busco.sh` |
| 15 | Annotation statistics (gene length, exons, single-exon genes, ...) | AGAT | `scripts/15-agat.sh` |

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

Requirements: a SLURM cluster with Apptainer and the course containers (EDTA, TEsorter, MAKER, InterProScan, AGAT and the R analysis image `Annotation_analysis_R4.4.sif`).
 
1. Clone the repository and create the folders that are not tracked:
```bash
   git clone git@github.com:marciaverarohrer/genome_annotation_course.git
   cd genome_annotation_course
   mkdir -p logs data/assemblies/flye output plots
```
2. Put the Flye assembly at `data/assemblies/flye/assembly.fasta` and the Trinity transcriptome at `data/assemblies/Trinity/trinity_out.Trinity.fasta`.
3. Edit `WORKDIR` (and `COURSEDIR` if needed) at the top of each script.
4. Submit the scripts from the project root, in numerical order, each one after the previous one has finished:
```bash
   sbatch scripts/01-run_EDTA.sh
```
   - Step 2 needs the EDTA intact LTR files, and step 6 needs `parseRM.pl` run on the EDTA `*.RM.out` file first.
   - MAKER needs the four control files (`maker_*.ctl`) in the project root, with `genome=`, `est=` and `rmlib=` edited to absolute paths.
   - Scripts 10 and 11 need the merged files from 09, and script 12 needs the InterProScan output from 11.
   - R scripts (3, 4, 6, 13) are run on an interactive node:
```bash
     apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla scripts/13-plot_AED.R
```


## Main results

**Transposable elements**
- Genome: 134.3 Mb in 155 sequences; 14.09% annotated as interspersed TEs.
- Gypsy is the most abundant superfamily (4.35% of the genome, 5.8 Mb), followed by helitrons (2.94%), Mutator (2.61%) and Copia (1.46%).
- Of 290 intact LTR retrotransposons, Ale (Copia) and Athila (Gypsy) are the most abundant clades.
- The TE landscape shows a recent peak at about 1 Myr (mostly MITE/DTM) and an older Gypsy-dominated peak at about 3-8 Myr. Ages use T = K / 2r with r = 8.22 × 10⁻⁹ (Kagale et al., 2014), without CpG correction, so they are approximate.

**Genes (MAKER)**
- 27,854 gene models and 30,957 mRNAs (30,930 after filtering; only mRNAs were removed, no genes).
- 97.6% of the models have an AED ≤ 0.5.
- 77.9% of the proteins have a Pfam domain: 79.0% of models with AED ≤ 0.5 and 33.4% of models with AED > 0.5.
- BUSCO (brassicales_odb10, n = 4,596), proteins: 96.9% complete (95.3% single-copy, 1.6% duplicated), 0.5% fragmented, 2.6% missing.
- Mean gene length 2,372 bp, 6.4 exons per mRNA, 6,736 single-exon genes (24%).

## Tools

EDTA v2.3.0, TEsorter 1.3.0 (rexdb-plant), RepeatMasker (via EDTA), parseRM.pl, MAKER 3.01.03, Augustus, InterProScan 5.70, BUSCO 5.4.2, AGAT 1.4.1, SeqKit, samtools, R 4.4 (circlize, tidyverse, ComplexHeatmap).

## Notes

README.md organization, debugging and step_by_step.md organization and questions were edited with help of claude.ai
The step_by_step.md is merely a more detailed documentation of the steps for future usage and to prepare for the presentation, exam and final report. 
