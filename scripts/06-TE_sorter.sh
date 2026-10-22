#!/bin/bash
#SBATCH --job-name=TEsorter_lib
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err

set -euo pipefail
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/mrohrer/genome_annotation_course
EDTA_DIR="$WORKDIR/output/EDTA"
OUTDIR="$WORKDIR/output/TEsorter_lib"
LIB="$EDTA_DIR/assembly.fasta.mod.EDTA.TElib.fa"
R_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
TE_SIF="$COURSEDIR/containers/TEsorter_1.3.0.sif"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

# Step 1: extract Copia and Gypsy library sequences
apptainer exec -C --bind "$WORKDIR" "$R_SIF" seqkit grep -r -p "Copia" "$LIB" > Copia_sequences.fa
apptainer exec -C --bind "$WORKDIR" "$R_SIF" seqkit grep -r -p "Gypsy" "$LIB" > Gypsy_sequences.fa

# Step 2: classify each set into clades
apptainer exec -C --bind "$WORKDIR" --pwd "$OUTDIR" "$TE_SIF" TEsorter Copia_sequences.fa -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"
apptainer exec -C --bind "$WORKDIR" --pwd "$OUTDIR" "$TE_SIF" TEsorter Gypsy_sequences.fa -db rexdb-plant -p "$SLURM_CPUS_PER_TASK"