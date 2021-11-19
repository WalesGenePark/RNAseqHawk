#!/bin/bash

module load singularity
singularity exec ${singjob}/multiqc-v1.11.sif multiqc --force $OUTPUT/logs -o ${OUTPUT}

N_SAMPLES=`echo ${Samples2merge} | tr " " "\n" | wc -l`
N_FASTQ=`find ${TMPDIR} -name "*.fastq.gz" | wc -l`
N_TRIMFASTQ=`find ${OUTPUT}/trim -name "*fq.gz" | wc -l`
N_BAM=`find ${STARGDIR} -name "*.bam" | wc -l`

N_GENE=`find ${OUTPUT}/STAR -name "*gn.out" | wc -l`
N_TRANS=`find ${OUTPUT}/STAR -name "*tc.out" | wc -l`
N_EXON=`find ${OUTPUT}/STAR -name "*ex.out" | wc -l`

N_TRIMLOG=`find ${OUTPUT}/logs -name "*fastp.html" | wc -l`
N_MAPLOG=`find ${OUTPUT}/logs -name "*mapLog.final.out" | wc -l`


echo "Samples          ${N_SAMPLES}" > ${WORKINGDIR}/${JobID}_summary.txt
echo "Trimming" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "fastq files:     ${N_FASTQ}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "trimmed fastq:   ${N_TRIMFASTQ}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "trimming logs:   ${N_TRIMLOG}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "Mapping" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "BAM files:       ${N_BAM}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "mapping logs:    ${N_MAPLOG}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "Expression" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "Gene outputs:    ${N_GENE}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "Trans outputs:   ${N_TRANS}" >> ${WORKINGDIR}/${JobID}_summary.txt
echo "Exon outputs:    ${N_EXON}" >> ${WORKINGDIR}/${JobID}_summary.txt

cat ${WORKINGDIR}/${JobID}_summary.txt
