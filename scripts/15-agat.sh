#!/bin/bash
#SBATCH --job-name=agat_stats
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -euo pipefail
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/mrohrer/genome_annotation_course
FINALDIR="$WORKDIR/output/MAKER/final"
AGAT_SIF="$COURSEDIR/containers/AGAT_v1.4.1.sif"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
cd "$FINALDIR"
apptainer exec --cleanenv --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$FINALDIR" "$AGAT_SIF" agat_sp_statistics.pl --gff filtered.genes.renamed.gff3 --output annotation.stat