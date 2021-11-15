#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes 1 
#SBATCH --cpus-per-task 8 
#SBATCH --ntasks-per-node=1
#SBATCH --error=%J.err
#SBATCH --output=%J.out



cat $workingdir/output/trim/${SAMPLE}_*F.fq.gz >> $STARgdir/reads/${SAMPLE}_M_F.fq.gz;

cat $workingdir/output/trim/${SAMPLE}_*R.fq.gz >> $STARgdir/reads/${SAMPLE}_M_R.fq.gz;