#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out

module load singularity/3.7.4

JobID=R200
Samples2merge="R200-A-001
R200-A-002
R200-A-003
R200-A-004
R200-A-005
R200-A-006
R200-A-007
R200-A-008
R200-A-009
R200-A-010
R200-A-011
R200-A-012
R200-A-013
R200-A-014
R200-A-015
R200-A-016
R200-A-017
R200-A-018c
R200-A-019
R200-A-020
R200-A-021
R200-A-022
R200-A-023
R200-A-024c
"
SingJob=/scratch/$USER/$JobID/Singularity
INPUT=/scratch/$USER/$JobID/STARgdir/reads
OUTPUT=/scratch/$USER/$JobID/output
#cp -u /gluster/wgp/wgp/resources/singularity/kraken2/kraken2.sif $SingJob
#cp -u /gluster/wgp/wgp/resources/singularity/kraken2/kronatools.sif $SingJob
#mkdir -p $OUTPUT/kraken2/fq

#for i in $Samples2merge; do
#singularity exec --bind /scratch/c.c1060258/kraken2/PlusPFP/ $SingJob/kraken2.sif \
#kraken2 --db /scratch/c.c1060258/kraken2/PlusPFP/ $INPUT/${i}_M_F.fq.gz $INPUT/${i}_M_R.fq.gz --threads 12 --use-names --output $OUTPUT/kraken2/${i}_test.txt --report $OUTPUT/kraken2/${i}_test.report.txt --unclassified-out $OUTPUT/kraken2/fq/${i}_unclassified.fastq --classified $OUTPUT/kraken2/fq/${i}_classified.fastq
#done

for i in $Samples2merge; do
singularity exec $SingJob/kronatools.sif \
/usr/bin/python3.6 /usr/local/bin/Krona/KronaTools/KrakenTools/kreport2krona.py -r $OUTPUT/kraken2/${i}_test.report.txt -o $OUTPUT/kraken2/${i}_test.report.krona && \
singularity exec $SingJob/kronatools.sif \
/usr/local/bin/ktImportText $OUTPUT/kraken2/${i}_test.report.krona -o $OUTPUT/kraken2/${i}_test.report.krona.html
done

