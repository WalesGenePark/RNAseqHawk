#!/bin/bash

module load singularity

singularity run ${SINGDIR}/STAR-2.7.1a.sif \
  --readFilesCommand zcat \
  --twopassMode Basic \
  --runThreadN 8 \
  --chimSegmentMin 15 \
  --outFilterMultimapNmax 1 \
  --outSAMtype BAM SortedByCoordinate \
  --readFilesIn "$STARgdir/reads/${SAMPLE}_M_F.fq.gz" "$STARgdir/reads/${SAMPLE}_M_R.fq.gz" \
  --genomeDir "$STARgdir" \
  --outFileNamePrefix "$STARgdir/Mapped/${SAMPLE}_map"


singularity run ${SINGDIR}/featurecounts-2.0.3.sif -p -s 2 --donotsort -B -t "exon" -g "transcript_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${SAMPLE}.tc.out $STARgdir/Mapped/${SAMPLE}_mapAligned.sortedByCoord.out.bam && cut -f1,7 "$OUTPUT/STAR/Mapped/${SAMPLE}.tc.out" > $OUTPUT/STAR/Mapped/${SAMPLE}.tc.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${SAMPLE}.tc.out.tab"

singularity run ${SINGDIR}/featurecounts-2.0.3.sif -p -s 2 --donotsort -B -t "exon" -g "gene_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${SAMPLE}.gn.out $STARgdir/Mapped/${SAMPLE}_mapAligned.sortedByCoord.out.bam &&cut -f1,7 "$OUTPUT/STAR/Mapped/${SAMPLE}.gn.out" > $OUTPUT/STAR/Mapped/${SAMPLE}.gn.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${SAMPLE}.gn.out.tab"

singularity run ${SINGDIR}/featurecounts-2.0.3.sif -p -s 2 --donotsort -B -t "exon" -g "exon_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${SAMPLE}.ex.out $STARgdir/Mapped/${SAMPLE}_mapAligned.sortedByCoord.out.bam && cut -f1,7 "$OUTPUT/STAR/Mapped/${SAMPLE}.ex.out" > $OUTPUT/STAR/Mapped/${SAMPLE}.ex.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${SAMPLE}.ex.out.tab" 


mv $STARgdir/Mapped/*.final.out $OUTPUT/logs/STAR
echo "Mapping finished" >>/scratch/$USER/$JobID/${JobID}.log
