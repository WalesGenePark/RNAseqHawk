#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out

module load singularity/3.7.0

singularity run ${singjob}/SARTools.simg

echo "SARTools singularity done"
cat $SLURM_JOB_ID.out >> /scratch/$USER/$JobID/$JobID.log
