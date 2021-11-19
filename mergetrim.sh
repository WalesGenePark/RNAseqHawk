#!/bin/bash

cat ${OUTPUT}/trim/${SAMPLE}_*F.fq.gz >> ${STARgdir}/reads/${SAMPLE}_M_F.fq.gz;
cat ${OUTPUT}/trim/${SAMPLE}_*R.fq.gz >> ${STARgdir}/reads/${SAMPLE}_M_R.fq.gz;