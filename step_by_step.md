# Documentation of the practical part in step-by-step manner
This documentation is detailed in what steps were done,
what commands were run to obtain answers to the guiding questions,
or how specific information was extracted from the results.
It relies heavily on the exercise scripts obtained in the lecture. 
It should help prepare for the exam, presentation and results report.

# Week 1 & Week 2: Transposable Element Annotation and Classification

## 1. TE Annotation using EDTA

### 1.1 create wd and run EDTA

flye assembly was copied from the other class (assembly) into the data/assembly/flye/assembly.fasta
working directory was initialized (mkdir -p "$WORKDIR/scripts" "$WORKDIR/logs")

copied
01-run_EDTA.sh script to own scripts folder, adjusted script: directory changed and changed the path, then ran the script.

sbatch scripts/01-run_EDTA.sh

Due to reservation ending prematurely the EDTA job could not finish and had to be re-run with new reservations.

changed parameters in the 01-run_EDTA.sh script:

#SBATCH --time=4-00:00:00
#SBATCH --account=class-sbl-30004-ws-2026
#SBATCH --reservation=class-sbl-30004-2026-10-15

terminated correctly with a run time of: 11h and 19 minutes.

### OUTPUT EDTA:

Important Output Files from EDTA
copied to results/EDTA folder for oversight reasons.

1. Non-redundant TE Library: $genome.mod.EDTA.TElib.fa This FASTA file contains the TEs classified up to the superfamily level. The sequences are labeled using the three-letter naming system from Wicker et al. (2007).

2. Whole-genome TE Annotation: $genome.mod.EDTA.TEanno.gff3 This GFF3 file contains both intact and fragmented TE annotations across the entire genome.

3. Intact TE Annotation: $genome.mod.EDTA.intact.gff3 This file lists only the structurally intact TE annotations. These are typically recently inserted elements that have not yet accumulated mutations or deletions.

4. Summary of Whole-genome TE Annotation: $genome.mod.EDTA.TEanno.sum This file provides a summary of the annotated TEs, including counts and number of base pairs in the genome per superfamily and family.

5. RepeatMasker Output: $genome.mod.EDTA.anno/$genome.mod.EDTA.RM.out The RepeatMasker output reports genomic coordinates, TE classifications and sequence divergence relative to the library reference. Thee sequence divergence can provide an approximate TE amplification history, which is crucial for understanding TE evolutionary dynamics.

### 1.2: Intact full length LTR-RTs and TEsorter
While EDTA was still running TE annotations were visualized.
Focus on structure-based annotation of full-length LTR retrotransposons (LTR-RTs).
Used the intact GFF3 under output/EDTA/assembly.fasta.mod.EDTA.raw/, together with assembly.fasta.mod.LTR.intact.raw.fa.

(checked with ls -lh assembly.fasta.mod.EDTA.raw/*.intact.raw.* )

then adjusted the paths and ran script 02 with:

sbatch scripts/02-run_TEsorter_full_length_LTRs.sh

run time : ca. 30s

#### Plot LTR-RT identity by clade and globally for Copia versus Gypsy
last part of the script ran on an interactive node:

srun --partition=pibu_el8 --account=class-sbl-30004-ws-2026 \
--reservation=class-sbl-30004-2026-10-14 \
--cpus-per-task=2 --mem=4G --time=00:30:00 --pty bash

Important Output Files <input.fa>.rexdb-plant.dom.faa: Contains annotated protein sequences. These sequences can be used for downstream analyses like TE phylogenetic analysis. <input.fa>.rexdb-plant.cls.tsv: Contains the classification of TEs into their respective classes, orders, and families. This file is key for assessing TE diversity within the genome

information about each full length LTRs
ltr_identity, when the copy inserts, based on mutations we can think about how long ago this element changed position in the genome. so to date these elements.
generated some plots/historgrams taking and extracting these LTR identities from the gff3 files, also with the information of the superfamily.

gff3 files have no information about the protein. all the TEs have proteins and enzymes, so that the TEs can make copies and insert themselves, own machinery. we tried to find the proteins in these elements using the TE sorter.

we discussed that there are some databases, rex database in TE sorter to look at it.

TE sorter generated several outputs, plant.cls.tsv file. from there we were trying to extract the information . script looks at Clade, database has files for the clades and for each of the proteins, in the final column it tells you what it was able to identify. 
in ouput/EDTA/LTR_full_length/intact_LTR.fa.rexdb-plant.cls.tsv
columns can be complete or not. if complete, all proteins needed for the TE to function were found in the element.

also the intact_LTR.fa.rexdb-plant.cls.pep

### 1.4: Plot LTR-RT identity by clade and globally for Copia versus Gypsy:

Adter TE sorter completed the following was done:

defined the variables:

COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/mrohrer/genome_annotation_course
OUTDIR="$WORKDIR/output/LTR_full_length"
unset SINGULARITY_BIND APPTAINER_BIND SINGULARITY_TMPDIR

then ran the code on the interactive node and piped into a .txt file:

apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" --pwd "$OUTDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$COURSEDIR/scripts/03-full_length_LTRs_identity_copy.R" > summary_R_script.txt

guiding questions:

- Are there differences in the number of full length LTR-RTs between the clades?

From the summary_R_script.txt:
The intact set has 290 elements,
Copia 164, Gypsy 113, and 13 with no superfamily (`NA`). By clade:
**Copia:** Ale 76, Ivana 38, Bianca 15, Angela 2, Alesia 1, SIRE 5, TAR 2. Ale is by far the biggest, accounting for about half of all Copia.
**Gypsy:** Athila 57, Tork 25 (this one is Copia in rexdb-plant, so see below), Reina 17, Retand 16, Tekay 11, CRM 10.
**Unknown/NA:** 2 unknown, 13 NA.
Yes, the numbers differ a lot!

- Are there any clades with High percent identity (e.g., 99-100%) or relatively younger insertions and Low percent identity (e.g., 80-90%) or relatively older insertions?

To answer the second question, a code block was added to the R script to determine the age of the insertion by percent identity, the ouput was piped to a .txt file:
> apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" --pwd "$PWD" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$WORKDIR/scripts/03-full_length_LTRs_identity_copy.R" > clade_identity_summary.txt

clade level, profile of which clade in my accession is more recent.
Copia has many recent insertions, within there mostly Ale and ivana were very recent. This can also be seen in the clade_identity_summary.txt

## 2. Visualizing and comparing TE annotations from EDTA  
21.10.
### 2.1 Compare the TE Annotations summary file from EDTA

Information from /output/EDTA/assembly.fasta.mod.EDTA.TEanno.sum

Total Sequences: 155
Total Length: 134281593 bp

percentage of the genome that each class of each superfamily occupies.
Total                  27964        18914658     14.09%
 
The genome is 134,281,593 bp in 155 sequences, and 18,914,658 bp (14.09%) are annotated as interspersed TEs.

- Which TE superfamily is the most abundant in the genome?

Gypsy is the most abundant superfamily by genomic occupancy: 5.84 Mb, 4.35%. Next come helitrons (3.95 Mb, 2.94%), Mutator (3.50 Mb, 2.61%) and Copia (1.97 Mb, 1.46%).

- Which TE superfamilies differ most in genomic occupancy between accessions?

Count and bp rank differently. Helitrons are the most numerous (7,259 copies) but rank second in bp. Gypsy has fewer copies than helitrons or Mutator but covers more sequence, because LTR retrotransposons are long. For “most abundant” both can be significant, but bp is the better measure of genomic proportion.

### 2.2 Visualizing TE Annotations

21.10.
the following steps were done:

To create plots for different TE superfamilies using the circlize package in R, the script was copied from the COURSEDIR.

Before running it, samtools was used to create an assembly.fasta.fai used for downstream analysis.
done on an interactive node:
srun --partition=pibu_el8 --account=class-sbl-30004-ws-2026 \
--reservation=class-sbl-30004-2026-10-14 \
--cpus-per-task=2 --mem=4G --time=00:30:00 --pty bash

apptainer exec -C --bind "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" samtools faidx "$WORKDIR/data/assemblies/flye/assembly.fasta"
  
copied the R script from the COURSEDIR, 04-annotation_circlize.R into own scripts folder
ran script on an interactive node:

apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$WORKDIR/scripts/04-annotation_circlize.R"

Guiding questions:

- Which scaffolds or genomic regions have the highest density of Gypsy and Copia elements?
contigs 230, 183, 126, 226, 97 for Gypsy. 

- Do Gypsy, Copia and TIR elements show similar genomic distributions, or are there distinct patterns?
Very similar patterns only in contig 226 there is not, Gypsy shows distinctly higher density of elements.

#TODO what does it mean?

computing N50 using this file:

> sort -k2,2nr data/assemblies/flye/assembly.fasta.fai | awk '{L[NR]=$2; t+=$2} END{c=0; for(i=1;i<=NR;i++){c+=L[i]; if(c>=t/2){print L[i]; exit}}}'
5870153

21.10. done to have results in week 3:
## Run MAKER
script 05-run_maker.sh copied from the COURSEDIR ,
followed the instructions as in comment section
(copied directory control_files, edited absolute paths in maker_opts.ctl for Flye assembly, Trinity, and final EDTA output)

and then submit with 
sbatch scripts/05-run_maker.sh

due to a ReqNodeNotAvail message, the two #SBATCH lines for the reservations were removed and job was submitted again.
run time: 

## 3. Refining TE Classification of all TE sequences with TEsorter
### 3.1: Extract Copia and Gypsy Sequences

grep command within the 06-TE_sorter script extracts Copia and Gypsy sequences.

### 3.2: Run TEsorter

constructed script 06-TE_sorter.sh,
ran with
sbatch scripts/06-TE_sorter.sh

Guiding questions:

- Using the final TEanno.gff3 file from EDTA and the clade classification of all TEs from TEsorter can you provide
an estimate of the number of Copia and Gypsy elements in each clade?
- What are the most abundant clades in
your genome?
#TODO
The idea is a join in two steps.

Take the library ID from the first column of each cls.tsv, which is the header, e.g. TE_00000123#LTR/Copia. Strip everything from # onward to get TE_00000123, and pair it with its clade.
Count the TEanno.gff3 lines for each ID. In the GFF3, the attribute column has Name=TE_... (I’m going from memory, so look at a line with grep -m3 Copia assembly.fasta.mod.EDTA.TEanno.gff3). Then sum those counts per clade, restricted to the Copia and Gypsy feature types so you don’t count long_terminal_repeat or target_site_duplication lines. Those can be done in R with separate, left_join and count, or in awk.

The totals per clade are your estimate of the number of Copia and Gypsy elements. Sorting them gives the most abundant clades, and in Arabidopsis I’d expect things like Athila and CRM among the Gypsy clades, but check that against your own data. If the library ID doesn’t match the GFF3 name exactly (suffixes such as _LTR can differ), compare a few of each by eye first.

## 4. Dynamics of TEs

### Dating of TEs / Estimation of Insertion Age Workflow

### 4.1 Parse RepeatMasker Outputs:
- Use the Perl script parseRM.pl (available at https://github.com/4ureliek/Parsing-RepeatMasker- Outputs) to process the raw alignment outputs from RepeatMasker.
- This command plots the divergence reported in the .out file. It does not apply CpG correction or convert divergence into insertion ages.

### 4.2 Binning TE Divergence Data:
Perform the following steps for the Repeatmasker file $genome.mod.EDTA.RM.out:
- First, remove the lines with divergence values equal to 0%, as these represent perfect matches to the reference sequence, and may reflect the same library copy matching itself.

- The input file $genome.mod.EDTA.RM.out is found the EDTA output directory, typically located at $genome.mod.EDTA.anno.
important to run the script from the .anno folder:
> cd /data/users/mrohrer/genome_annotation_course/output/EDTA/assembly.fasta.mod.EDTA.anno

> awk 'NR == 1 || $2 != 0' assembly.fasta.mod.EDTA.RM.out > assembly.fasta.mod.EDTA.RM.nonzero.out

- started an interactive mode:
> srun --partition=pibu_el8 --cpus-per-task=2 --mem=4G --time=00:30:00 --pty bash
and loaded the usual variables with
> source ~/course_env.sh

- Then, ran the following command to bin the divergence values into 1% increments and generate a summary table of TE abundance per superfamily:
> apptainer exec -C --bind "$WORKDIR" --bind "$COURSEDIR" \ "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" \ perl "$COURSEDIR/scripts/05-parseRM.pl" -i "$genome.mod.EDTA.RM.nonzero.out" -l 50,1 -v

parseRM.pl reads the .out file and counts how much sequence falls into each divergence bin per TE class and family.
-i is the input .out file.
-l 50,1 asks for the landscape output, maximum divergence 50% with 1% bins.
-v is verbose.

Tables are written next to the input file, so it was run from the .anno folder.

...output from the terminal after running:
        ..printing parsed data..
          -> ./assembly.fasta.mod.EDTA.RM.nonzero.out.landscape.Div.Rname.tab
          -> ./assembly.fasta.mod.EDTA.RM.nonzero.out.landscape.Div.Rclass.tab
          -> ./assembly.fasta.mod.EDTA.RM.nonzero.out.landscape.Div.Rfam.tab
          .. done
 --- Script done
> ls -lt
showed the three outputs in the .anno folder.

the script was copied as 07-parseRM.pl into the scripts folder, even though it was ran directly from the course directory.

### 4.3 Generate a TE Landscape Plot:
- Copied the script $COURSEDIR/scripts/06-plot_div.R into own script folder, renamed as 08-plot_div.R.
- Input path was re-edited and Plots/ output directory created before running it with

interactive node, load the variables, then ran the script:
> srun --partition=pibu_el8 --cpus-per-task=2 --mem=4G --time=00:30:00 --pty bash
> source ~/course_env.sh
> apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$WORKDIR/scripts/08-plot_div.R"

That way, a landscape graph, showing TE divergence and abundance for each superfamily was created.


### 4.4 Dating TEs Using Substitution Rates:

adjusted script with last command, into 08a, again interactive node, same as above:
> srun --partition=pibu_el8 --cpus-per-task=2 --mem=4G --time=00:30:00 --pty bash
> source ~/course_env.sh
> apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$WORKDIR/scripts/08a-plot_div.R"

Date the divergence of the annotated TEs from their representative sequence using the synonymous substitution rate for Brassicaceae species. This rate is estimated at 8.22 × 10^−9 substitutions per synonymous site per year (Kagale et al., 2014). The insertion time (T) can be calculated using T = K/2r, where K is the sequence divergence, and r is the substitution rate. For RepeatMasker comparisons, this calculation provides an approximate sequence divergence time. For intact LTR retrotransposons, the same formula can be used to estimate insertion age from the divergence between their two LTRs.

The plots look similar with only the x-axis changed. In the TE_landscape_age.pdf the x-axis is "Estimated insertion age (Myr)". **Myr** means million years (so 1 Myr is 1,000,000 years).

### Guiding questions:
- Which superfamilies show peaks at low and high sequence divergence?

**Low divergence peak:** MITE/DTM at about 1-2%, with some Copia and Gypsy at 0-3%.
**Broad middle peak:** Gypsy, at about 5-12% divergence, which is roughly 3-7 Myr once converted.
**Old tail (15-35%):** a low, flat mix of Copia, Gypsy and DNA/DTC (CACTA, green), reaching about 0.37.

- Are there differences in TE dynamics between the accessions studied in the group?
#TODO


- How do the TE dynamics differ between Copia and Gypsy elements?
**Copia vs. Gypsy:** Gypsy has one large, older burst. Copia is a thinner layer that is more spread out, with a small recent bump. Check this against the age plot once it’s fixed.


# Week 3: Annotation of genes with the MAKER Pipeline

## Steps to Perform Gene Annotation with MAKER: 
## 1-4 done last week

## 5. Output Preparation

checked with several commands whether MAKER and the job finished properly:

> ls output/MAKER/maker_*.ctl
output/MAKER/maker_bopts.ctl  output/MAKER/maker_exe.ctl
output/MAKER/maker_evm.ctl    output/MAKER/maker_opts.ctl

[mrohrer@login8 genome_annotation_course]$ cd output/MAKER/
> grep -E "^(genome|est|rmlib|augustus_species|cpus)=" maker_opts.ctl
genome=/data/users/mrohrer/genome_annotation_course/data/assemblies/flye/assembly.fasta
est=/data/users/mrohrer/genome_annotation_course/data/assemblies/Trinity/trinity_out.Trinity.fasta # Absolute path to your Trinity transcript FASTA
rmlib=/data/users/mrohrer/genome_annotation_course/output/EDTA/assembly.fasta.mod.EDTA.TElib.fa # Absolute path to your EDTA TE library FASTA
augustus_species=arabidopsis #Augustus gene prediction species model
cpus=1 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)
> sacct -u $USER -S 2026-10-21 --format=JobID,JobName%25,State,Elapsed | grep -i maker
20184170         Maker_gene_annotation CANCELLED+   00:00:00 
20185096         Maker_gene_annotation     FAILED   00:00:01 
20254994         Maker_gene_annotation  COMPLETED   05:19:44 
> tail -n 5 logs/Maker_gene_annotation_*.err
==> logs/Maker_gene_annotation_20185096.err <==
cp: cannot stat '/data/users/mrohrer/genome_annotation_course/maker_opts.ctl': No such file or directory
cp: cannot stat '/data/users/mrohrer/genome_annotation_course/maker_bopts.ctl': No such file or directory
cp: cannot stat '/data/users/mrohrer/genome_annotation_course/maker_exe.ctl': No such file or directory
cp: cannot stat '/data/users/mrohrer/genome_annotation_course/maker_evm.ctl': No such file or directory

==> logs/Maker_gene_annotation_20254994.err <==
processing contig output


Maker is now finished!!!


> cut -f3 output/MAKER/*.maker.output/*_master_datastore_index.log | sort | uniq -c
    155 FINISHED
    155 STARTED


### 5.1 

Next step is to merge the individual GFF files into a single file, since they are all stored in the datastore directory

code:
created a new script 09-merge_maker_gff_files.sh

ran it with
sbatch scripts/09-merge_maker_gff_files.sh
job number 20570687
completed after 2min13s


this created the following files:
in /output/MAKER/ :
1. assembly.all.maker.gff - The merged GFF file with sequence information.
2. assembly.all.maker.noseq.gff - The merged GFF file without sequence information.
3. assembly.all.maker.proteins.fasta - The merged protein sequences.
4. assembly.all.maker.transcripts.fasta - The merged transcript sequences.

guiding questions:

- How many gene models were predicted by MAKER in your genome? Check the noseq gff file and count the number of features with the type gene in the third column.

Number of gene models:
> cut -f3 output/MAKER/assembly.all.maker.noseq.gff | grep -v "^#" | sort | uniq -c | sort -nr
4814476 match_part
 589020 match
 562925 protein_match
 191195 CDS
 182105 exon
  93619 expressed_sequence_match
  30957 mRNA
  27854 gene
  18590 three_prime_UTR
  18371 five_prime_UTR
    155 contig
This shows all feature types and how often each one occurs.

Exact count of gene features:
> awk -F'\t' '$3=="gene"' output/MAKER/assembly.all.maker.noseq.gff | wc -l

27854

A gene feature is one predicted gene locus, one gene line means one gene model, so counting these lines counts how many genes MAKER predicted.
mRNA count is bigger than the gene count, because several isoforms of mRNAs exist.
Comparison of the two numbers:
> awk -F'\t' '$3=="mRNA"' output/MAKER/assembly.all.maker.noseq.gff | wc -l
30957

Numbers seem plausible (27'000 genes expected more or less).

- Is it comparable between other accessions genomes?
#TODO check google docs.

## 6. Filtering and Refining Gene Annotations

### 6.1 Rename Genes and Transcripts

generated scripts/10-rename_ids.sh

defined the string variables in the script:
protein="assembly.all.maker.proteins.fasta"
transcript="assembly.all.maker.transcripts.fasta"
gff="assembly.all.maker.noseq.gff"
prefix="Kar-1"

What step 6.1 does:
Renaming: MAKER’s gene IDs are long and complicated. The merged files are copied into output/MAKER/final/ and every gene gets a clean ID like Kar-10000001, in the GFF and both FASTA files.


### 6.2 Run InterProScan on the Protein File
What step 6.2 does:
InterProScan: Pfam acts as the primary application in InterProScan, it searches the proteins for Pfam domains.This should be used later to keep gene models that have a domain, and to answer the guiding question about Pfam vs. AED.
Later, goterms and iprlookup outputs are added to the gff. They will provide additional functional annotations for the protein sequences.

> sbatch scripts/10-rename_ids.sh
run time: 2min11

once finished, check changed IDs:
> cut -f9 output/MAKER/final/assembly.all.maker.noseq.gff.renamed.gff | cut -d ';' -f1 | sed 's/ID=//' | head
To check whether the ID's worked with the accession prefix:
##gff-version 3
contig_174
Kar-10027805
Kar-10027805-RA
Kar-10027805-RA:1
Kar-10027805-RA:2
Kar-10027805-RA:3
Kar-10027805-RA:4
Kar-10027805-RA:5
Kar-10027805-RA:6

> sbatch scripts/11-interproscan.sh.
run time: 10min51

some quick checks before continuing:

number of pfam hits:
> wc -l output.iprscan
44909 output.iprscan

number of proteins with at least one hit:
> cut -f1 output.iprscan | sort -u | wc -l
24120

total number of proteins:
> grep -c ">" assembly.all.maker.proteins.fasta.renamed.fasta
30957

share of proteins with a Pfam domain before filtering:
24120/30957 = 77.9%

### 6.3 Update GFF with InterProScan Results
In this step the results from InterProScan are incorporated into the GFF3 file with the ipr_update_gff tool.

This is added to the assembly.all.maker.noseq.gff file.
The step is included in script 12-filter_gff.sh

> touch scripts/12-filter_gff.sh
All upcoming filtering steps were combined in script 12 and ran with one sbatch command.

### 6.4 Examine AED Values

Annotation Edit Distance (AED) is a metric that shows how well gene models are supported by the evidence, such as RNA-seq or protein homology alignments. The MAKER's script AED_cdf_generator.pl was used here to summarize the AED values of the annotation as a cumulative distribution.
This was also incorporated in script 12.

After running this it was chekced whether most genes fall within the AED range of 0-0.5:
The file is
output/MAKER/final/assembly.all.maker.renamed.gff.AED.txt

at an AED of 0.5 the value is 0.976, which means that 97.6% are in an AED below 0.5.
Lower AED indicates better agreement with the supplied evidences. 

Then a small R script was used to plot the cumulative AED distribution.
> touch scripts/13-plot_AED.R

interactive node, load variables and run the script:
> srun --partition=pibu_el8 --account=class-sbl-30004-ws-2026 --reservation=class-sbl-30004-2026-10-28 --cpus-per-task=2 --mem=4G --time=00:30:00 --pty bash
> source ~/course_env.sh
> apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla scripts/13-plot_AED.R

output:
   AED cumulative
21 0.5      0.976
and plot can be found in
plots/AED_cumulative.pdf

### 6.5 Filter the GFF File for Quality
GFF file was filtered based on the AED values and/or functional annotations from InterProScan.


### 6.6 Filter the GFF File for Gene Features
Only gene features and subfeatures in the third column of the gff file are kept. Filtering step, also included in script 12.


### 6.7 Extract the remaining mRNA sequences
List of remaining mRNA IDs was extracted from the filtered GFF3 file, and used to filter the transcript and protein FASTA files.

This step writes ${transcript}.renamed.filtered.fasta and ${protein}.renamed.filtered.fasta in $FINALDIR, containing sequences corresponding to the retained gene models.

> sbatch scripts/12-filter_gff.sh
run time: 1min08

The final annotation outputs in the final directory are:
- filtered.genes.renamed.gff3: filtered gene models and their subfeatures.
- ${protein}.renamed.filtered.fasta: protein sequences for the retained models.
- ${transcript}.renamed.filtered.fasta: transcript sequences for the retained models.

awk command to select all mRNA lines and saves them with their _AED= value in the mRNA.tsv file.
> awk -F'\t' '$3=="mRNA"{id="";aed="";n=split($9,a,";");for(i=1;i<=n;i++){if(a[i]~/^ID=/)id=substr(a[i],4);if(a[i]~/^_AED=/)aed=substr(a[i],6)}print id"\t"aed}' assembly.all.maker.noseq.gff.renamed.gff > mRNA_AED.tsv
> wc -l mRNA_AED.tsv
30957 mRNA_AED.tsv
this is the same number as from the output of 6.2 total number of proteins.

to get the Pfam protein list with at least one Pfam domain:
> cut -f1 output.iprscan | sort -u > pfam_ids.txt
> wc -l pfam_ids.txt
24120 pfam_ids.txt

awk command to find low vs. high AED, prints Pfam fraction for models with AED =< 0.5 and for models with AED > 0.5. 
> awk -F'\t' 'NR==FNR{pf[$1]=1;next} {g=($2<=0.5)?"AED<=0.5":"AED>0.5"; tot[g]++; if($1 in pf) hit[g]++} END{for(g in tot) printf "%s\ttotal=%d\twith_Pfam=%d\tfraction=%.3f\n", g, tot[g], hit[g]+0, hit[g]/tot[g]}' pfam_ids.txt mRNA_AED.tsv


| AED group | Models | Share of all models | With Pfam | Without Pfam | Pfam fraction |
|---|---|---|---|---|---|
| Well supported (AED ≤ 0.5) | 30,227 | 97.6% | 23,876 | 6,351 | 79.0% |
| Weakly supported (AED > 0.5) | 730 | 2.4% | 244 | 486 | 33.4% |
| **All models** | **30,957** | 100% | **24,120** | **6,837** | **77.9%** |

short summary:
30,957 mRNAs = 30,957 proteins (from 6.2). Each transcript has one protein, mRNA_AED.tsv & protein FASTA describe the same set of models.
44,909 lines in output.iprscan are Pfam hits (6.2). That is more than the number of proteins, because one protein can have several domains.
24,120 proteins have at least one Pfam hit (6.7). This is the unique count that matters, and it is also the number of lines in pfam_ids.txt.
24,120 / 30,957 = 77.9% of the proteins have a Pfam domain.
AED 0.5 → 0.976 means 97.6% of the models have an AED of 0.5 or lower.

Guiding questions:
- What is the significance of the Annotation Edit Distance (AED) in assessing the quality of gene annotations?

0 means the predicted gene model is in perfect agreement with the experimental evidence like RNA-seq alignments. Score of 1 indicates a lack of evidence supporting the predicted model. Having low AED scores across the predicted gene models supports validity and correctness of a gene annotation.
A cumulative curve is used to judge a whole annotation. Since in my case 97.6% of the models have an AED of 0.5 or lower the annotation is well supported by the evidence (consistent with Trinity transcripts and protein references). 

- What proportion of predicted proteins have a Pfam domain, and how does this differ between low- and high-AED models?

From the predicted proteins, 77.9% contain at least one Pfam domain. This fraction is strongly dependent on the AED. 79% of models (AED<=0.5) have a Pfam domain, whereas only 33.4% of models with low AED (>0.5) have one. Models that are not supported by the evidence are therefore less likely to have an encodable protein domain, meaning they are likely false positives.


to get number of filtered genes:
> awk -F'\t' '$3=="gene"' filtered.genes.renamed.gff3 | wc -l
27'854
same as unfiltered, no models removed, since no model has AED = 1

## Quality Assessment of Gene Annotations
### 1. BUSCO: Quality Assessment of Gene Annotations

Checks genome or annotation completeness. Classifies highly conserved single-copy orthologs in the annotation into single copy, duplicated, fragmented or missing.

compare BUSCO analysis on the annotated genes aswell as the assembly from course before.
difference will give an idea of the quality of the gene annotation, more missing compared to assembly - means that maybe annotation was incomplete

#### 1.1: Run BUSCO on MAKER annotations

To run BUSCO on the MAKER-produced longest protein sequences or longest transcript sequences first they are extracted.

Start from the filtered protein and transcript FASTA files. You can get the length of each entry in a FASTA file. Gene name is everything before -R, whereas -RA, -RB, -RC etc. are different isoforms. Select one longest record per gene, resolving ties by keeping one record. Save the results in $FINALDIR as ${protein}.renamed.longest.fasta and ${transcript}.renamed.longest.fasta, matching the commands below.

After preparing the longest protein and transcript FASTA files the next script was generated and BUSCO was run.

> touch scripts/14-busco.sh

"longest" part of the script extracts the longest protein and transcription sequence length.

> sbatch scripts/14-busco.sh
run time: 51min40


#### 1.2: Interpret BUSCO results
After BUSCO finished, looked at the summary and created this summary table. 


summary table:
| | Complete | Single | Duplicated | Fragmented | Missing |
|---|---|---|---|---|---|
| Proteins | 96.9% (4,454) | 95.3% | 1.6% (72)	| 0.5% (22)	| 2.6% (120)
| Transcripts |98.1% (4,509) | 94.0%	| 4.1% (190) | 0.5% (21) | 1.4% (66)|

Filtered and raw gene counts have identical numbers, only models with AED = 1 are removed, which are 0 in this case.

Complete (C) is the main quality number. Nearly 97-98% of the conserved genes are present in full, so very few genes are missed.
Duplicated (D) is low in the protein run. Since you used only the longest isoform per gene, there is no sign of redundant gene models. Some duplicates are expected anyway, because Arabidopsis has an ancient whole-genome duplication.
Fragmented (F) and missing (M) are small. The 120 missing BUSCOs (2.6%) may be genes absent from the assembly or missed by the gene finder.
Transcripts vs. proteins: the transcript run finds more complete genes (98.1% vs. 96.9%) and more duplicates (4.1% vs. 1.6%). The two modes use different search methods, and transcripts include UTRs. I’d treat the difference as a method effect, not a quality difference, and report the protein run as the main result.

#### 1.3: AGAT: Annotation statistics
AGAT was used to generate statistics about the final gene annotations gff3 file.

> touch scripts/15-agat.sh
> sbatch scripts/15-agat.sh
run time: 3min06

the statistics file can be found in output/MAKER/final/annotation.stat , summarized in the table below.

- Mean gene length (about 2.4 kb), exon number (about 6) and intron length (about 160 bp) are close to A. thaliana reference [no source].
- UTRs are incomplete. Only 44% of the models have a UTR, so UTR lengths shouldn’t be over-interpreted.
- Suspicious values for curation: a 6 bp gene can’t be real, and 6,736 single-exon genes (24%) probably include short fragments or TE-derived models. The longest gene, 199,883 bp with an 85,311 bp CDS, may be several genes merged. -> candidates for the JBrowse question “which models need manual curation”.

Guiding questions:
- What are the key metrics provided by BUSCO for assessing gene annotation quality for your dataset?

BUSCO reports the percentage of 4,596 conserved Brassicales genes that are complete (single-copy and duplicated), fragmented or missing. For the MAKER proteins, 96.9% were complete (95.3% single-copy, 1.6% duplicated), 0.5% fragmented and 2.6% missing, so the annotation recovers nearly all conserved genes with little redundancy. The transcript run gave similar results (98.1% complete).

- Based on AGAT statistics, what is the average gene length (min,max), similarly average transcript length, Monoexonic Genes, Exons per Gene Mean, etc. in your MAKER annotations?

| Question                    | Value                                 |
|-----------------------------|---------------------------------------|
| Genes                       | 27,854                                |
| mRNAs (with isoforms)       | 30,930 (1.1 per gene)                 |
| Mean gene length             | 2,372 bp (median 1,761)               |
| Gene length, min / max      | 6 bp / 199,883 bp                     |
| Mean mRNA length             | 2,361 bp (2,421 bp with all isoforms) |
| Mean CDS length              | 1,289 bp                              |
| Monoexonic genes             | 6,736 (24.2% of genes)                |
| Mean exons per mRNA          | 6.4 (5.4 introns)                     |
| Mean exon / intron length    | 232 bp / 164 bp                       |
| mRNAs with at least one UTR | 12,185 (43.7%)                        |
| Overlapping genes            | 990                                   |


- Can you visualize the Gene annotation track with TE annotations from EDTA in your previous circlize R script?
#TODO

- How does the Gene density compare to the TE density along the scaffolds?
#TODO

## 2. Check your Gene Annotation with JBrowse 2

JBrowse 2 is a free, open-source genome browser.

### 2.1: Install and open your Genome
1. Desktop version of JBrowse 2 was downloaded (https://jbrowse.org/jb2/) and used to inspect the MAKER gene models alongside the EDTA TE annotations.

2. Genome FASTA and annotation files were copied from IBU to the computer using
> scp mrohrer@login8.hpc.binf.unibe.ch:/data/users/mrohrer/genome_annotation_course/data/assemblies/flye/assembly.fasta* .
> scp mrohrer@login8.hpc.binf.unibe.ch:/data/users/mrohrer/genome_annotation_course/output/MAKER/final/filtered.genes.renamed.gff3 .
> scp mrohrer@login8.hpc.binf.unibe.ch:/data/users/mrohrer/genome_annotation_course/output/EDTA/assembly.fasta.mod.EDTA.TEanno.gff3 .
> scp mrohrer@login8.hpc.binf.unibe.ch:/data/users/mrohrer/genome_annotation_course/output/MAKER/final/*_iprscan_quality_filtered.gff .

3. JBrowse 2 Desktop opened using a terminal:
> chmod +x ~/Downloads/jbrowse-desktop*.AppImage
, then start it with
> ./jbrowse-desktop*.AppImage
from the terminal. Open new genome, Selected assembly.fasta and followed the prompts, providing a FASTA index (.fai) if requested.

4. Open a Linear Genome View.

### 2.2: Add annotation tracks
Use File → Open track… to load the files copied above.
The following three were added as a track, with default options: MAKER genes: filtered.genes.renamed.gff3, Quality-filtered annotation with InterProScan attributes and retained transcript/protein evidence alignments: assembly.all.maker.noseq.gff_iprscan_quality_filtered.gff
. EDTA TEs: assembly.fasta.mod.EDTA.TEanno.gff3

### 2.3: Inspect gene models
Gene and TE tracks were displayed together. Exons, introns, CDS features and transcript isoforms were inspected. To jump to a region, coordinates such as scaffold_1:100000- 120000 were entered in the location box.


Guiding questions:
- Do the genes have plausible exon and intron structures?
- Are there alternative isoforms?
- Are there genes that overlap TEs? How will you identify which gene models need manual curation

To answer these questions the following regions were inspected:

checking the 'weird' regions in the genome:
| Signal | Why it is suspicious	| Your numbers |
| ---------- | ---------- | ---------- |
| AED > 0.5 and no Pfam domain | weak evidence and no known domain	| about 486 models |
| Very short genes | 6 bp can’t encode a protein	shortest gene | 6 bp |
| Very long genes | possibly several genes merged	longest | 199,883 bp |
| Single-exon genes | often fragments or TE-derived	| 6,736 |
| Overlapping genes | may be merged or duplicated	| 990 |
| Gene lying on a TE | possible TE-derived false gene	| needs an overlap check |

> awk -F'\t' 'NR==FNR{pf[$1]=1;next} $2>0.5 && !($1 in pf){print $1}' pfam_ids.txt mRNA_AED.tsv > curate_ids.txt
> wc -l curate_ids.txt
486 curated IDs

> awk -F'\t' 'NR==FNR{ids[$1]=1;next} $3=="mRNA"{split($9,a,";"); id=substr(a[1],4); if(id in ids) print $1":"$4".."$5"\t"id}' curate_ids.txt filtered.genes.renamed.gff3 > curate_regions.tsv
> head curate_regions.tsv
shows the regions that can be inspected more in detail.
Every candidate in this list has the two properties:
- AED above 0.5, (weak agreement with the evidence)
- no Pfam hit (no recognizable protein domain).

> awk -F'\t' '{split($1,a,/[:.]+/); print $2"\t"$1"\t"(a[3]-a[2]+1)}' curate_regions.tsv | sort -k3,3nr > curate_by_length.tsv
generates a .tsv with the lengths of the weird or to-be-curated models.
They span from 199517 bp (Kar-10027192-RA	contig_157:506111..705627) to 21 bp (Kar-10009795-RA	contig_100:2533381..2533401).

contig_157:97873..199893 :
When loooking at these sequences often you can see that one gene from the annotation (top) matched with several different Arabidopsis proteins (AT2G08986.1, AT2G07981.1, AT1G40104.1, AT4G05612.1, AT1G38630.1, AT1G38790.1) over the same long stretch. 
A 200 kb gene with many exons is a typical sign of merged models or a false prediction. Real Arabidopsis genes are almost never that long.
an augustus_masked-...-abinit-gene-5.1 prediction spanning the whole window, with many tiny exons
A single gene normally matches one protein family. Here many different proteins align over one region with large gaps. A long prediction with tiny exons and no RNA-seq support is usually a false or merged model. Possible explanations:
- Augustus joined several protein-coding fragments, perhaps from different genes, into one model.
- The region contains many scattered, degenerate copies of genes or gene fragments (like pseudogene cluster, an unannotated TE, or an organelle-derived insertion). Nuclear genomes often carry these inserts, and Flye assemblies sometimes include organelle contigs.


# Week 4: 

Overview of last chunk of work:

Part	What it does	Your script
1. BLASTp	Compares your proteins to UniProt and TAIR10, then adds putative functions	16-run_blastp.sh
2. GENESPACE inputs	Builds five BED/FASTA pairs (yours, TAIR10, three accessions)	commands on the login node
3. GENESPACE run	Orthology and synteny	17-genespace.R and 18-run_genespace.sh
4. Pangenome analysis	Core, accessory and specific genes, copy numbers	19-process_pangenome.R (course script)
5. Synteny plots	Dotplots and riparian plots	R code from the sheet

## 1. Sequence homology to functionally validated proteins (UniProt
database and TAIR10)

### 1.1 run blastp
created and ran script 16
sbatch

chagned reservation, added mail.

run time: 12min49
When the job finishes successfully, output/comparisons contains blastp_uniprot.tsv, blastp_TAIR10.tsv and their
.besthits.tsv tables.


#TODO once the job finishes:


Add the UniProt functions to copies of your filtered protein and gene annotations:

created script 19
ran it: run time 
failed , not clear why (error in pearl script?)


By the end one should have the annotated GFF3 and FASTA files with putative functions from
UniProt database, pfam domains, and GO terms. You will also have the best blast hit to Arabidopsis thaliana
TAIR10 representative gene models.


Guiding questions:
- What proportion of proteins have a significant hit to well‑annotated proteins (with curated functions) vs.
uncharacterized proteins?

on interactive node the following commands were ran:
cd "$WORKDIR/output/comparisons"
PROT="$WORKDIR/output/MAKER/final/assembly.all.maker.proteins.fasta.renamed.filtered.fasta"
UNIPROT="$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"

> echo "total proteins: $(grep -c '>' $PROT)"
total proteins: 30956
> echo "UniProt hits:   $(wc -l < blastp_uniprot.besthits.tsv)"
UniProt hits:   23235
> echo "TAIR10 hits:    $(wc -l < blastp_TAIR10.besthits.tsv)"
TAIR10 hits:    30378

UniProt viridiplantae reviewed is a curated (Swiss-Prot) database, so a hit already means a protein with a curated function. To also count hits whose description says “uncharacterized”:
> awk '/^>/{split($1,a,"|"); d=$0; sub(/^[^ ]+ /,"",d); sub(/ OS=.*/,"",d); print a[2]"\t"d}' "$UNIPROT" > uniprot_desc.tsv
> awk -F'\t' 'NR==FNR{d[$1]=$2;next} {n++; if(tolower(d[$2])~/uncharacteri[sz]ed/) u++} END{print n" hits, "u+0" to uncharacterized proteins"}' uniprot_desc.tsv blastp_uniprot.besthits.tsv
23235 hits, 555 to uncharacterized proteins


| | Proteins | Share of 30,956 |
|---|---|---|
| UniProt hit (reviewed plant proteins, e-value ≤ 1e-5) | 23,235 | 75.1% |
| of these: hit to an "uncharacterized" protein | 555 | 1.8% |
| UniProt hit with a described function | 22,680 | 73.3% |
| No UniProt hit | 7,721 | 24.9% |
| TAIR10 hit (e-value ≤ 1e-5) | 30,378 | 98.1% |

About 75% of the predicted proteins have a significant hit to a curated UniProt protein, and almost all of these (22,680) match proteins with a described function. Only 555 (1.8%) hit proteins annotated as uncharacterized. The TAIR10 share is higher (98.1%) because TAIR10 is the same species, whereas the reviewed UniProt set covers selected proteins from many plant species.


- Are there length or completeness biases in proteins without UniProt hits (e.g., short fragments)?

compares the two groups on mean length, the share of proteins under 100 aa, and the share starting with methionine (a rough completeness check). Higher short-protein shares, or fewer “M” starts, among the no-hit proteins would suggest fragments.

> awk '/^>/{if(id)print id"\t"len"\t"m; id=substr($1,2); len=0; m=""; next} {if(m=="")m=substr($0,1,1); len+=length($0)} END{print id"\t"len"\t"m}' "$PROT" > prot_len.tsv
> awk -F'\t' 'NR==FNR{h[$1]=1;next} {g=($1 in h)?"hit":"nohit"; n[g]++; s[g]+=$2; if($2<100)sh[g]++; if($3=="M")met[g]++} END{for(g in n) printf "%s\tn=%d\tmean_len=%.0f\tshare_<100aa=%.3f\tshare_start_M=%.3f\n", g, n[g], s[g]/n[g], sh[g]/n[g], met[g]/n[g]}' <(cut -f1 blastp_uniprot.besthits.tsv) prot_len.tsv
hit     n=23235 mean_len=448    share_<100aa=0.048      share_start_M=0.977
nohit   n=7721  mean_len=361    share_<100aa=0.249      share_start_M=0.961

 | Proteins | Mean length (aa) | Share < 100 aa | Share starting with M |
|---|---|---|---|---|
| With UniProt hit | 23,235 | 448 | 4.8% | 97.7% |
| Without UniProt hit | 7,721 | 361 | 24.9% | 96.1% |

Proteins without a UniProt hit are shorter on average (361 vs. 448 aa), and about five times more of them are shorter than 100 aa (24.9% vs. 4.8%). This suggests that many of them are fragments, small ORFs or weak gene models. Short proteins also reach a significant e-value less easily, so part of the bias comes from detection power. The share of proteins starting with methionine is similar in both groups (96.1% vs. 97.7%), so there is no strong completeness bias by this measure.

- Do you find the FLC gene (AT5G10140) in your annotation? What is its putative function that you can guess from GO terms and pfam domains (check the gff files from exercise Week 3)?

> grep -P "AT5G10140" blastp_TAIR10.besthits.tsv
Kar-10020806-RA AT5G10140.1     100.000 196     0       0       1       196     1       196     8.89e-142  392

> gene=Kar-10020806
> grep "^${gene}-R" blastp_TAIR10.besthits.tsv
Kar-10020806-RA AT5G10140.1     100.000 196     0       0       1       196     1       196     8.89e-142  392

will give TAIR10 best hit. shows AT5G10140 in column 2, with the identity and e-value. This confirms the gene is FLC!

> grep "^${gene}-R" blastp_uniprot.besthits.tsv
Kar-10020806-RA Q9S7Q7  100.000 196     0       0       1       196     1       196     1.28e-141       392

will give UniProt best hit. It shows the best hit in the curated database, and the candidate is a protein from A.Thaliana:
> grep -m1 "Q9S7Q7" "$COURSEDIR/data/uniprot_viridiplantae_reviewed.fa"
sp|Q9S7Q7|FLC_ARATH MADS-box protein FLOWERING LOCUS C OS=Arabidopsis thaliana OX=3702 GN=FLC PE=1 SV=1

> grep -P "\tgene\t" "$WORKDIR/output/MAKER/final/filtered.genes.renamed.gff3" | grep "ID=${gene};"
contig_165      maker   gene    194066  200149  .       +       .       ID=Kar-10020806;Name=Kar-10020806;Alias=maker-contig_165-augustus-gene-2.74;Dbxref=InterPro:IPR002100,InterPro:IPR002487,Pfam:PF00319,Pfam:PF01486;Ontology_term=GO:0003677,GO:0003700,GO:0005634,GO:0006355,GO:0046983;

Yes. FLC is annotated as gene `Kar-10020806` (`contig_165:194,066..200,149`, + strand). Its protein (`Kar-10020806-RA`) is identical to the TAIR10 FLC protein `AT5G10140.1` (100% identity over all 196 aa, e-value 8.9e-142), and its best UniProt hit is `Q9S7Q7` (100% identity, e-value 1.3e-141).

| Evidence | Value |
|---|---|
| Pfam | PF00319 (SRF-type transcription factor, MADS-box), PF01486 (K-box) |
| InterPro | IPR002100, IPR002487 |
| GO terms | DNA binding (GO:0003677), DNA-binding transcription factor activity (GO:0003700), nucleus (GO:0005634), regulation of DNA-templated transcription (GO:0006355), protein dimerization activity (GO:0046983) |

The domains and GO terms indicate a nuclear MADS-box transcription factor that binds DNA and acts as a dimer. FLC is known as a repressor of flowering that is silenced by vernalization. Close relatives (the MAF genes) share the same domains, so the domains alone do not identify FLC. The full-length, 100%-identical match to AT5G10140 does.
---

## 2. Comparative Genomics with OrthoFinder and GENESPACE


### 2.1: Prepare inputs for five genomes

following steps as not computationally heavy, were done on the login node.

1. first ran all variables, create directories:

bash
COURSEDIR=/data/courses/genome_annotation_resources/2026
WORKDIR=/data/users/mrohrer/genome_annotation_course
Accession=Kar_1
FINALDIR="$WORKDIR/output/MAKER/final"
GENES="$FINALDIR/filtered.genes.renamed.gff3"
LONGEST_PROTEINS="$FINALDIR/assembly.all.maker.proteins.fasta.renamed.longest.fasta"
OUTDIR="$WORKDIR/output/comparisons"
GENESPACE_DIR="$OUTDIR/GENESPACE"
mkdir -p "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide" "$GENESPACE_DIR/tmp"

Accession=Kar_1 uses an underscore on purpose. Only the file names change; your gene IDs keep their hyphen (Kar-10027805).

2. Your accession: BED and FASTA

bash
grep -P "\tgene\t" "$GENES" > "$GENESPACE_DIR/temp_genes.gff3"

#Get the the first attribute in column 9 which is ID=gene_name.
awk 'BEGIN{OFS="\t"} {split($9,a,";"); split(a[1],b,"="); print $1, $4-1, $5, b[2]}' "$GENESPACE_DIR/temp_genes.gff3" > "$GENESPACE_DIR/bed/${Accession}.bed"

#Remove transcript suffixes and descriptions from FASTA headers.
sed '/^>/s/ .*//' "$LONGEST_PROTEINS" | sed '/^>/s/-R[A-Z]*$//' > "$GENESPACE_DIR/peptide/${Accession}.fa"

The BED has four columns: contig, 0-based start (GFF start minus 1), end, gene ID.
The FASTA is the longest-isoform file, with the -RA suffix and descriptions removed from the headers. This is the file the instructor stressed. The headers then match the BED gene IDs.

Quick check: both counts should be 27,854.

bash
wc -l "$GENESPACE_DIR/bed/${Accession}.bed"
27854 /data/users/mrohrer/genome_annotation_course/output/comparisons/GENESPACE/bed/Kar_1.bed
grep -c ">" "$GENESPACE_DIR/peptide/${Accession}.fa"
27854
head -n 2 "$GENESPACE_DIR/bed/${Accession}.bed"
contig_174      0       15545   Kar-10027805
contig_10       2       353     Kar-10027853

grep ">" "$GENESPACE_DIR/peptide/${Accession}.fa" | head -n 2
>Kar-10027805
>Kar-10027853
The first IDs in both files should be the same gene IDs, for example Kar-10027805.

3. Add TAIR10
Copy the BED and FASTA files from the course directory. The supplied TAIR10 FASTA already uses
gene IDs and contains one protein per gene.
bash
cp "$COURSEDIR/data/TAIR10.bed" "$GENESPACE_DIR/bed/TAIR10.bed"
cp "$COURSEDIR/data/TAIR10.fa" "$GENESPACE_DIR/peptide/TAIR10.fa"


4. Add three other accessions

First see which ones are available:

bash
ls "$COURSEDIR/data/Lian_et_al/GENESPACE/bed"

Pick three. Skip your own accession. Then copy them, replacing the three names:

bash
for other in Etna_2 Ice_1 Taz_0; do cp "$COURSEDIR/data/Lian_et_al/GENESPACE/bed/${other}.bed" "$GENESPACE_DIR/bed/${other}.bed"; cp "$COURSEDIR/data/Lian_et_al/GENESPACE/peptide/${other}.fa" "$GENESPACE_DIR/peptide/${other}.fa"; done


Altai-5 is from china, Kar-1 from Kyrgizstan, Etna-2 from Italy, Ice-1 from Iceland, Taz-0 from Morocco, Est-0 from Estonia.


ls "$GENESPACE_DIR/bed" "$GENESPACE_DIR/peptide"
/data/users/mrohrer/genome_annotation_course/output/comparisons/GENESPACE/bed:
Etna_2.bed  Ice_1.bed  Kar_1.bed  TAIR10.bed  Taz_0.bed

/data/users/mrohrer/genome_annotation_course/output/comparisons/GENESPACE/peptide:
Etna_2.fa  Ice_1.fa  Kar_1.fa  TAIR10.fa  Taz_0.fa

shows 

5. Validate the IDs

The sheet requires no duplicates and no differences between BED and FASTA IDs for every accession:

bash
cd "$GENESPACE_DIR"
for f in bed/*.bed; do a=$(basename "$f" .bed); cut -f4 "$f" | sort > "$OUTDIR/tmp/$a.bed.ids"; grep ">" "peptide/$a.fa" | sed 's/>//; s/ .*//' | sort > "$OUTDIR/tmp/$a.fa.ids"; echo "$a bed_dup=$(uniq -d "$OUTDIR/tmp/$a.bed.ids" | wc -l) fa_dup=$(uniq -d "$OUTDIR/tmp/$a.fa.ids" | wc -l) only_bed=$(comm -23 "$OUTDIR/tmp/$a.bed.ids" "$OUTDIR/tmp/$a.fa.ids" | wc -l) only_fa=$(comm -13 "$OUTDIR/tmp/$a.bed.ids" "$OUTDIR/tmp/$a.fa.ids" | wc -l)"; done

Etna_2 bed_dup=0 fa_dup=0 only_bed=0 only_fa=0
Ice_1 bed_dup=0 fa_dup=0 only_bed=0 only_fa=0
Kar_1 bed_dup=0 fa_dup=0 only_bed=0 only_fa=0
TAIR10 bed_dup=0 fa_dup=0 only_bed=0 only_fa=0
Taz_0 bed_dup=0 fa_dup=0 only_bed=0 only_fa=0

ls bed peptide

bed:
Etna_2.bed  Ice_1.bed  Kar_1.bed  TAIR10.bed  Taz_0.bed

peptide:
Etna_2.fa  Ice_1.fa  Kar_1.fa  TAIR10.fa  Taz_0.fa

Every line reads bed_dup=0 fa_dup=0 only_bed=0 only_fa=0, and ls should list five BED and five FASTA files with matching names. 

### 2.2: Prepare GENESPACE in R

created script 17

### 2.3: Run GENESPACE

created script 18

sbatch script 18 (17 called from within)
run time: 23min22s

What to expect

GENESPACE runs OrthoFinder (via DIAMOND) on the five proteomes, then builds the synteny blocks and the pan-gene table. Two hours should be enough for five small genomes, but check the log if it runs long.
Your accession has 155 contigs, and many of them are small with few genes. GENESPACE needs at least five matching gene pairs for a block (the sheet says so), so small contigs won’t form synteny blocks. The riparian plots may show many short contigs for Kar_1, and the dotplots will have empty rows. That’s expected for a fragmented assembly, not an error.
When it finishes, check the log with tail logs/genespace_*.err and ls output/comparisons/GENESPACE. You should see results/, pangenes/ (with TAIR10_pangenes.txt.gz) and pangenome_matrix.rds.

### 2.4: Process your pangenome

copy the script from the coursedirectory
cp $COURSEDIR/scripts/XX-process_pangenome.R ./scripts/20-process_pangenome.R

change wd and focal_genome variables on top of the script 20.

created script 21:
submit job
sbatch scripts/21-run_process_pangenome.sh
run time: 18s

printed summary is now found in logs/process_pangenome_21013016.out

plots are located here:
> find . -name "pangenome*.pdf"
./output/comparisons/GENESPACE/process_pangenome/plots/pangenome_presence_frequency.pdf

manually copied to global plots folder WORKDIR/plots/

**Guiding questions**
- Report: Core and accession-specific entry counts

### GENESPACE pan-genome (Kar_1, TAIR10, Etna_2, Ice_1, Taz_0)

| Category | Entries | Share |
|---|---|---|
| Core | 23,877 | 71.7% |
| Accessory | 6,990 | 21.0% |
| Accession-specific | 2,441 | 7.3% |

- **Does a core entry contain exactly one gene in every accession?**
No. A core entry only requires at least one gene in each accession, so copy numbers can differ (tandem arrays, duplications, non-syntenic orthologs). 1,512 core entries differ in copy number when all recorded genes are counted.

### 2.5: Compare copy-variable core entries

The computational part of this chapter was already done in 2.4, as it was included in script 21.

plot of pangenome_presence_frequency.pdf
Copy-variable core entries

The panels show different entries, so compare the pgID labels.

The ranking is by Kar_1 copies, so Kar_1 is highest by design. Don’t read this as “Kar_1 has more copies than the others”. Your unique gene counts argue against that (Kar_1 has 27,555, which is lower than Etna_2 at 28,891 or Taz_0 at 28,099).
Left panel (all recorded genes): the extreme entry is 8645, with 42 copies in Etna_2, 43 in Ice_1, 13 in Kar_1, 11 in Taz_0 and only 1 in TAIR10. That looks like a large, dispersed gene family. Many of these copies are probably non-syntenic orthologs, since they disappear in the right panel. It could also be TE-derived gene models. That is a guess, and you can check it by looking at the TAIR10 gene in that entry (the sheet suggests filtering pg by pgID).
Right panel (syntenic + array genes): counts are much smaller. Kar_1 has 5 copies in entries 3762 and 22993, against 1 in most other accessions. For 22993, the left panel shows the same 5 vs. 1, which means all five Kar_1 copies are syntenic or in tandem. That is a candidate for a real tandem expansion in Kar_1, or an assembly artifact.

Guiding questions

- **How many Copy-variable core entries remain when only syntenic genes are counted?**
589 (script counts PASS + array genes), about 61% fewer than with all recorded genes. Most copy-number differences therefore come from genes outside conserved positions.
589 is for PASS plus tandem-array genes (checked with grep -n "PASS\|array" "$WORKDIR/scripts/20-process_pangenome.R").

- **What evidence confirms that an extra copy is real?**
Read depth across the copy is the same as for single-copy regions (not doubled or halved), HiFi reads span the copy together with unique flanking sequence, the copy is in a syntenic or at least plausible position, it diverges from the other copy (it is not identical), and it is supported by RNA-seq reads that map uniquely to it or by a second assembly of the same accession.

- **How could haplotigs inflate gene copy counts?**
If two haplotypes of a heterozygous region are assembled as separate contigs, both are annotated, which gives two nearly identical copies in one accession. Typical signs are copies with about 100% identity on short, non-syntenic contigs, and roughly half the expected read depth. Inbred Arabidopsis lines should have few haplotigs, but residual heterozygosity or misassembly can still create them.

### 2.6: Visualize Synteny

with GENESPACE dotplots were already generated in

/data/users/mrohrer/genome_annotation_course/output/comparisons/GENESPACE/riparian
and ""/dotplots

in addition to these, another R and bash script was created

touch scripts/22-riparian.R
touch scripts/23-run_riparian.sh

ran the script
run time: 38s

The PDFs land in output/comparisons/GENESPACE/processed_riparian/

Tair10 vs Kar-1 syntenic hits:
- No large contig links two TAIR10 chromosomes. Each big contig (contig_100, 171, 191, 167, 2, 118, 160...) is one continuous diagonal inside a single chromosome. So no misjoins and no large translocations are visible. The riparian plot agrees: every braid keeps its chromosome colour.
- Slopes show orientation, not rearrangements. Contigs that run upward (contig_100, 171, 132, 104, 155, 160) are in the same orientation as TAIR10. Contigs that run downward (contig_191, 167, 2, 118, 165, 211, 139, 189) are inverted relative to it. Flye assembles each contig in an arbitrary direction, so this is expected, and it explains all the bow-ties in the riparian plot.
- Each chromosome is split into several contigs, for example chr1 into contig_100, 104, 132, 171 and 155. The breaks between them are where there are no syntenic genes.

Kar_1 vs. Kar_1 (the two plots)

Use the first one (all BLAST hits, score > 50) for the report. Besides the main diagonal (each gene against itself), it shows a few short diagonal segments scattered off the diagonal. Those are duplicated regions inside your genome, in the range of the old duplications that Arabidopsis is known to retain, and there is no large block of duplicated sequence. The second plot (same orthogroup) is mostly empty, with some clusters in the rows and columns of small contigs. It adds little, but it hints that gene families may be concentrated on small contigs.


Guiding questions:
Do you see any major structural rearrangements between accessions? Choose one unusual connection. Could
incorrect scaffold joins, missing or fragmented gene models, or scaffold ordering in the plot explain the
pattern instead?


Kar_1 is highly collinear with TAIR10 and with the other accessions. In the TAIR10 vs. Kar_1 syntenic dotplot each large contig maps as one continuous diagonal to a single TAIR10 chromosome, with no large translocations or internal inversions. Several contigs (contig_191, 167, 2, 118, 165, 211, 139, 189) run in the opposite direction; this reflects contig orientation in the Flye assembly, not inversions, and flipping them straightens the riparian braids. Each chromosome is covered by 2-5 contigs. One unusual connection is the small contigs, for example contig_126 on chr3 and contig_97 on chr5, which map to short stretches between larger contigs at positions where the centromeres are expected. This is more likely an assembly gap in repetitive centromeric sequence (few anchoring genes, TE-rich) than a true rearrangement, but this was not tested directly. Scaffold ordering in the plot, not the biology, explains the twisting of the braids.


## 3. finishing the class table

to get Genes with Blast hits and Genes without Blast hits:

from ~/output/comparisons run
> cut -f1 blastp_uniprot.besthits.tsv | sed -E 's/-R[A-Z]+$//' | sort -u | wc -l
20923
genes with at least one UniProt hit (transcript ID -> gene ID by removing -RA, -RB ...)

genes without blast hit is the total number of filtered genes, so 27854 - 20923 and results in 6931.

to get Genes in core Orthogroups and Genes in Accession specific orthogroups:

in ~/output/comparisons/GENESPACE/results run
> awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)c[$i]=i; next} {n=0; for(i=2;i<=NF;i++) if($i!="") n++; k=$c["Kar_1"]; if(k=="") next; m=split(k,a,", "); if(n==5){core+=m; nc++} else if(n==1){spec+=m; ns++}} END{print "core OGs with Kar_1:", nc, "| Kar_1 genes in them:", core; print "Kar_1-specific OGs:", ns, "| Kar_1 genes in them:", spec}' Orthogroups.tsv

> awk -F'\t' 'NR==1{for(i=1;i<=NF;i++)c[$i]=i;next} {k=$c["Kar_1"]; if(k=="")next; n=0; for(i=2;i<=NF;i++) if($i!="")n++; m=split(k,a,", "); g[n]+=m; o[n]++; t+=m} END{for(n in g) print n" accessions: "o[n]" OGs, "g[n]" Kar_1 genes"; print "Kar_1 genes in any OG: "t}' Orthogroups.tsv | sort
2 accessions: 131 OGs, 442 Kar_1 genes
3 accessions: 1191 OGs, 1382 Kar_1 genes
4 accessions: 861 OGs, 1131 Kar_1 genes
5 accessions: 20754 OGs, 24256 Kar_1 genes
Kar_1 genes in any OG: 27211
Kar_1 genes in no OG: 643

