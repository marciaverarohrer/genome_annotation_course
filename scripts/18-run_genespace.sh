#!/bin/bash
#SBATCH --job-name=genespace
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=64G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-04
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -euo pipefail
WORKDIR=/data/users/mrohrer/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
GENESPACE_DIR="$WORKDIR/output/comparisons/GENESPACE"
GENESPACE_SIF="$COURSEDIR/containers/genespace_latest.sif"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
TMPDIR="$WORKDIR/output/comparisons/GENESPACE_R_tmp"
mkdir -p "$TMPDIR"
cd "$WORKDIR"

apptainer exec --cleanenv --bind /data --bind "$WORKDIR" --bind "$TMPDIR":/temp --env TMPDIR=/temp --pwd "$WORKDIR" "$GENESPACE_SIF" Rscript "$WORKDIR/scripts/17-genespace.R" "$GENESPACE_DIR"