#!/bin/bash

module load singularity
singularity run ${SINGDIR}/fastp-v0.23.1.sif \
    --in1 ${TMPDIR}/${SAMPLERAW}_F.fastq.gz \
    --in2 ${TMPDIR}/${SAMPLERAW}_R.fastq.gz \
    --out1 ${OUTPUT}/trim/${SAMPLERAW}_trimmed_F.fq.gz \
    --out2 ${OUTPUT}/trim/${SAMPLERAW}_trimmed_R.fq.gz \
    --thread ${SLURM_CORES} -h \
    ${OUTPUT}/logs/${SAMPLERAW}_fastp.html -j \
    ${OUTPUT}/logs/${SAMPLERAW}_fastp.json
