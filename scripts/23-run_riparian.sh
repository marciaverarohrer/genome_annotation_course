#!/bin/bash
#SBATCH --job-name=riparian
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=00:30:00
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -euo pipefail
WORKDIR=/data/users/mrohrer/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
GENESPACE_SIF="$COURSEDIR/containers/genespace_latest.sif"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
cd "$WORKDIR"
apptainer exec --cleanenv --bind /data --bind "$WORKDIR" --pwd "$WORKDIR" "$GENESPACE_SIF" Rscript "$WORKDIR/scripts/22-riparian.R"