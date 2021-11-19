#!/bin/bash

module load singularity
singularity run ${SINGDIR}/fastp-v0.23.1.sif \
    --in1 ${TMPDIR}/${SampleRaw}_F.fastq.gz \
    --in2 ${TMPDIR}/${SampleRaw}_R.fastq.gz \
    --out1 ${OUTPUT}/trim/${SampleRaw}_trimmed_F.fq.gz \
    --out2 ${OUTPUT}/trim/${SampleRaw}_trimmed_R.fq.gz 
    --thread ${SLURM_CORES} -h \
    ${OUTPUT}/logs/${SampleRaw}_fastp.html -j \
    ${OUTPUT}/logs/${SampleRaw}_fastp.json
