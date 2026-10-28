#!/bin/bash
#SBATCH --job-name=merge_maker_gff
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -euo pipefail

WORKDIR=/data/users/mrohrer/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
OUTDIR="$WORKDIR/output/MAKER"
mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

shopt -s nullglob
INDEXES=(*.maker.output/*_master_datastore_index.log)
test "${#INDEXES[@]}" -eq 1
INDEX="${INDEXES[0]}"


apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp \
    --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$OUTDIR" "$MAKER_SIF" \
    gff3_merge -d "$INDEX" -o assembly.all.maker.gff


apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp \
    --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$OUTDIR" "$MAKER_SIF" \
    gff3_merge -n -d "$INDEX" -o assembly.all.maker.noseq.gff


apptainer exec --cleanenv --env TMPDIR=/tmp --bind "$OUTDIR/tmp":/tmp \
    --bind "$COURSEDIR" --bind "$WORKDIR" --pwd "$OUTDIR" "$MAKER_SIF" \
    fasta_merge -d "$INDEX" -o assembly