#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --ntasks 1 
#SBATCH --cpus-per-task 8
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out



cat $workingdir/output/trim/${SAMPLE}_*F.fq.gz >> $STARgdir/reads/${SAMPLE}_M_F.fq.gz;

cat $workingdir/output/trim/${SAMPLE}_*R.fq.gz >> $STARgdir/reads/${SAMPLE}_M_R.fq.gz;