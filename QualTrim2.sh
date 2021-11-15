#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --ntasks 1 
#SBATCH --cpus-per-task 8
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out


module load singularity

singularity run ${singjob}/fastp-v0.23.1.sif --in1 $tmpdir/${SamplesRaw}_F.fastq.gz --in2 $tmpdir/${SamplesRaw}_R.fastq.gz --out1 $workingdir/output/trim/${SamplesRaw}_trimmed_F.fq.gz --out2 $workingdir/output/trim/${SamplesRaw}_trimmed_R.fq.gz --thread 8 -h $workingdir/output/logs/${SamplesRaw}_fastp.html -j $workingdir/output/logs/${SamplesRaw}_fastp.json
