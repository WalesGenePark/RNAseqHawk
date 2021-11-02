#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out



open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
# this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
# push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
}
N=$FastP_N
open_sem $N

for i in ${SamplesRaw}; do
run_with_lock  $singjob/fastp/bin/./fastp --in1 $tmpdir/${i}_F.fastq.gz --in2 $tmpdir/${i}_R.fastq.gz --out1 $workingdir/output/trim/${i}_trimmed_F.fq.gz --out2 $workingdir/output/trim/${i}_trimmed_R.fq.gz --thread 2 -h $workingdir/output/logs/${i}_fastp.html -j $workingdir/output/logs/${i}_fastp.json
done
wait
date
echo "QualTrim finished" >>/scratch/$USER/$JobID/${JobID}.log
