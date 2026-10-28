#!/bin/bash
#SBATCH --job-name=maker_rename
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
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
OUTDIR="$WORKDIR/output/MAKER"
FINALDIR="$OUTDIR/final"
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"
prefix="Kar-1"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
mkdir -p "$FINALDIR/tmp"
cp "$OUTDIR/$gff" "$FINALDIR/${gff}.renamed.gff"
cp "$OUTDIR/$protein" "$FINALDIR/${protein}.renamed.fasta"
cp "$OUTDIR/$transcript" "$FINALDIR/${transcript}.renamed.fasta"
cd "$FINALDIR"

RUN="apptainer exec --cleanenv --env TMPDIR=/tmp --bind $FINALDIR/tmp:/tmp --bind $COURSEDIR --bind $WORKDIR --pwd $FINALDIR $MAKER_SIF"

$RUN maker_map_ids --prefix "$prefix" --justify 7 "${gff}.renamed.gff" > id.map
$RUN map_gff_ids id.map "${gff}.renamed.gff"
$RUN map_fasta_ids id.map "${protein}.renamed.fasta"
$RUN map_fasta_ids id.map "${transcript}.renamed.fasta"