#!/bin/bash

module load singularity
singularity run ${SINGDIR}/fastp-v0.23.1.sif \
    --in1 ${TMPDIR}/${SamplesRaw}_F.fastq.gz \
    --in2 ${TMPDIR}/${SamplesRaw}_R.fastq.gz \
    --out1 ${OUTPUT}/trim/${SamplesRaw}_trimmed_F.fq.gz \
    --out2 ${OUTPUT}/trim/${SamplesRaw}_trimmed_R.fq.gz 
    --thread ${SLURM_CORES} -h \
    ${OUTPUT}/logs/${SamplesRaw}_fastp.html -j \
    ${OUTPUT}/logs/${SamplesRaw}_fastp.json
