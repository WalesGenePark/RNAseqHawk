#!/bin/bash

cat ${OUTPUT}/trim/${SAMPLE}_*F.fq.gz >> ${STARGDIR}/reads/${SAMPLE}_M_F.fq.gz;
cat ${OUTPUT}/trim/${SAMPLE}_*R.fq.gz >> ${STARGDIR}/reads/${SAMPLE}_M_R.fq.gz;