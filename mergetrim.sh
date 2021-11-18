#!/bin/bash
#SBATCH --error=%J.err
#SBATCH --output=%J.out



cat $workingdir/output/trim/${SAMPLE}_*F.fq.gz >> $STARgdir/reads/${SAMPLE}_M_F.fq.gz;

cat $workingdir/output/trim/${SAMPLE}_*R.fq.gz >> $STARgdir/reads/${SAMPLE}_M_R.fq.gz;