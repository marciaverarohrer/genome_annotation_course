# Documentation of the practical part in step-by-step manner, TE Annotation and Classification

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

- Are there any clades with High percent identity (e.g., 99-100%) or relatively younger insertions and Low percent identity (e.g., 80-90%) or relatively older insertions?

clade level, profile of which clade in my accession is more recent.
Copia has many recent insertions, within there mostly Ale and ivana were very recent. 


then a output/EDTA/assembly.fasta.mod.EDTA.final/ folder
there the assembly.fasta.mod.EDTA.intact.fa

EDTA/assembly.fasta.mod.EDTA.TEanno.gff3
first entry, 9th column was it identified by homology? library sequence matched to the genome, or identified by structure, by the full length pipeline.
also gives a classification.


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
> apptainer exec -C --bind "$WORKDIR" --pwd "$WORKDIR" "$COURSEDIR/containers/Annotation_analysis_R4.4.sif" Rscript --vanilla "$WORKDIR/scripts/08-plot_div.R"

Date the divergence of the annotated TEs from their representative sequence using the synonymous substitution rate for Brassicaceae species. This rate is estimated at 8.22 × 10^−9 substitutions per synonymous site per year (Kagale et al., 2014). The insertion time (T) can be calculated using T = K/2r, where K is the sequence divergence, and r is the substitution rate. For RepeatMasker comparisons, this calculation provides an approximate sequence divergence time. For intact LTR retrotransposons, the same formula can be used to estimate insertion age from the divergence between their two LTRs.



### Guiding questions:
- Which superfamilies show peaks at low and high sequence divergence?
- Are there differences in TE dynamics between the accessions studied in the group?
- How do the TE dynamics differ between Copia and Gypsy elements?