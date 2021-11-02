#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out

module load singularity/3.7.0


singularity run ${singjob}/ContamCheckv3.simg bash

#calculated percentile
grep -c '>' ${tmpdir}/2.fa > ${tmpdir}/pc.txt
grep -c 'Homo' ${tmpdir}/2.txt >> ${tmpdir}/pc.txt
awk 'NR==1{a=$0}NR==2{print $0/a}' ${tmpdir}/pc.txt >> ${tmpdir}/pc.txt
Multi=$(sed '3q;d' ${tmpdir}/pc.txt)
echo $Multi*100 | bc >> ${tmpdir}/pc.txt
#echo tail -n 1
tmpPC=$( tail -n 1 $tmpdir/pc.txt )
echo ${tmpPC%.*} >> ${tmpdir}/pc.txt
PC=$( tail -n 1 $tmpdir/pc.txt )

if (( ${PC} >= 80  )); then
    echo "ContamCheck has now COMPLETED";
else echo "ContamCheck has now FAILED"
fi
echo "******"
cat $SLURM_JOB_ID.out >> /scratch/$USER/$JobID/$JobID.log
