#!/bin/bash
#SBATCH --job-name=maker_filter
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
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

unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR
cd "$FINALDIR"

MK="apptainer exec --cleanenv --env TMPDIR=/tmp --bind $FINALDIR/tmp:/tmp --bind $COURSEDIR --bind $WORKDIR --pwd $FINALDIR $MAKER_SIF"
AN="apptainer exec --cleanenv --bind $COURSEDIR --bind $WORKDIR --pwd $FINALDIR $ANALYSIS_SIF"

# 6.3 add InterProScan results (Pfam, GO) to the GFF
$MK ipr_update_gff "${gff}.renamed.gff" output.iprscan > "${gff}.renamed.iprscan.gff"

# 6.4 AED cumulative distribution
$MK perl /usr/local/bin/AED_cdf_generator.pl -b 0.025 "${gff}.renamed.gff" > assembly.all.maker.renamed.gff.AED.txt

# 6.5 quality filter: keep transcripts with AED < 1 and/or a Pfam domain
$MK perl /usr/local/bin/quality_filter.pl -s "${gff}.renamed.iprscan.gff" > "${gff}_iprscan_quality_filtered.gff"

# 6.6 keep only gene features and their subfeatures
grep -P "\tgene\t|\tCDS\t|\texon\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t|\tmRNA\t" "${gff}_iprscan_quality_filtered.gff" > filtered.genes.renamed.gff3
sed -i '1i##gff-version 3' filtered.genes.renamed.gff3

# 6.7 keep only the filtered mRNAs in the FASTA files
grep -P "\tmRNA\t" filtered.genes.renamed.gff3 | awk '{print $9}' | cut -d ';' -f1 | sed 's/ID=//' > list.txt
$AN seqkit grep -f list.txt "${transcript}.renamed.fasta" -o "${transcript}.renamed.filtered.fasta"
$AN seqkit grep -f list.txt "${protein}.renamed.fasta" -o "${protein}.renamed.filtered.fasta"