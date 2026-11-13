#!/bin/bash
#SBATCH --job-name=process_pangenome
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-04
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -euo pipefail
WORKDIR=/data/users/mrohrer/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
TMPDIR="$WORKDIR/output/comparisons/Annotation_R_tmp"
mkdir -p "$TMPDIR" "$WORKDIR/plots"

apptainer exec --cleanenv --bind /data --bind "$WORKDIR" --bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" "$ANALYSIS_SIF" Rscript "$WORKDIR/scripts/20-process_pangenome.R"