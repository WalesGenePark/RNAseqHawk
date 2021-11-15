#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out


module load singularity

singularity run ${singjob}/fastp-v0.23.1.sif --in1 $tmpdir/${i}_F.fastq.gz --in2 $tmpdir/${i}_R.fastq.gz --out1 $workingdir/output/trim/${i}_trimmed_F.fq.gz --out2 $workingdir/output/trim/${i}_trimmed_R.fq.gz --thread 2 -h $workingdir/output/logs/${i}_fastp.html -j $workingdir/output/logs/${i}_fastp.json
