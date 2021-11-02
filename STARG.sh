#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out

genome_dir=
mapping_dir=
gtf=
genome=

STAR --runMode genomeGenerate \
    --genomeDir "${STARgdir}" \
    --genomeFastaFiles "${STARgdir}/${JobID}.genome.fasta" \
    --sjdbGTFfile "${STARgdir}/${JobID}.gtf" \
    --limitGenomeGenerateRAM 250000000 \
    --runThreadN 22

