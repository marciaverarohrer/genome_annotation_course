#!/bin/bash
#SBATCH --job-name=busco_maker
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=03:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-28
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-user=marcia.rohrer@students.unibe.ch
#SBATCH --mail-type=end

set -eo pipefail   # no -u: the module system can trip on unset variables
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/mrohrer/genome_annotation_course
FINALDIR="$WORKDIR/output/MAKER/final"
ANALYSIS_SIF="$COURSEDIR/containers/Annotation_analysis_R4.4.sif"
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
cd "$FINALDIR"
AN="apptainer exec --cleanenv --bind $COURSEDIR --bind $WORKDIR --pwd $FINALDIR $ANALYSIS_SIF"

# keep the longest record per gene (gene = ID before "-R")
longest() {
  local in="$1" out="$2"
  $AN seqkit fx2tab -n -l -i "$in" \
    | awk -F'\t' '{g=$1; sub(/-R.*$/,"",g); if(!(g in len) || $2>len[g]){len[g]=$2; best[g]=$1}} END{for(g in best) print best[g]}' \
    > "${out}.ids"
  $AN seqkit grep -f "${out}.ids" "$in" -o "$out"
}

longest "${protein}.renamed.filtered.fasta"    "${protein}.renamed.longest.fasta"
longest "${transcript}.renamed.filtered.fasta" "${transcript}.renamed.longest.fasta"

# BUSCO
module load BUSCO/5.4.2-foss-2021a
export PYTHONNOUSERSITE=1
busco -f -i "${protein}.renamed.longest.fasta"    -l brassicales_odb10 -o busco_proteins    -m proteins      -c 4
busco -f -i "${transcript}.renamed.longest.fasta" -l brassicales_odb10 -o busco_transcripts -m transcriptome -c 4