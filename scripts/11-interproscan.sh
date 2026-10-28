#!/bin/bash
#SBATCH --job-name=interproscan
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=02:00:00
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
MAKER_SIF="$COURSEDIR/containers/MAKER_3.01.03.sif"
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"

IPS_SIF="$COURSEDIR/containers/InterProScan_5.70.sif"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
mkdir -p "$FINALDIR/tmp"
cd "$FINALDIR"

apptainer exec --cleanenv --pwd "$FINALDIR" --bind "$COURSEDIR/data/interproscan-5.70-102.0/data":/opt/interproscan/data \
    --bind "$COURSEDIR" --bind "$WORKDIR" --bind "$FINALDIR/tmp":/temp "$IPS_SIF" /opt/interproscan/interproscan.sh \
    -appl pfam --disable-precalc -f TSV --goterms --iprlookup --seqtype p -i "${protein}.renamed.fasta" -o output.iprscan