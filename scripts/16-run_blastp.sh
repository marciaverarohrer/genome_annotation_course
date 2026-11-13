#!/bin/bash
#SBATCH --job-name=blastp
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=20
#SBATCH --mem=16G
#SBATCH --time=03:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-11-04
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -eo pipefail
WORKDIR=/data/users/mrohrer/genome_annotation_course
COURSEDIR=/data/courses/genome_annotation_resources/2026
FINALDIR="$WORKDIR/output/MAKER/final"
PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT="$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"
TAIR10="$COURSEDIR/data/TAIR10_pep_20110103_representative_gene_model"
OUTDIR="$WORKDIR/output/comparisons"
mkdir -p "$OUTDIR/tmp"
cd "$OUTDIR"

module load BLAST+/2.15.0-gompi-2021a

blastp -query "$PROTEINS" -db "$UNIPROT" -num_threads 10 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out "$OUTDIR/blastp_uniprot.tsv" &
uniprot_job=$!
blastp -query "$PROTEINS" -db "$TAIR10" -num_threads 10 -outfmt 6 -evalue 1e-5 -max_target_seqs 10 -out "$OUTDIR/blastp_TAIR10.tsv" &
tair_job=$!

wait "$uniprot_job"
wait "$tair_job"

# keep the best hit (highest bit score) for each query protein
for reference in uniprot TAIR10; do
  sort -k1,1 -k12,12gr -k11,11g "$OUTDIR/blastp_${reference}.tsv" | awk -F '\t' '!seen[$1]++' > "$OUTDIR/blastp_${reference}.besthits.tsv"
done