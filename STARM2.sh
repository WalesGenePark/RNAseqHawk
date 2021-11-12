#!/bin/bash
#SBATCH --partition=c_compute_wgp1
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=250000
#SBATCH --error=%J.err
#SBATCH --output=%J.out

module load raven
module load STAR/2.7.0e

STAR \
    --genomeDir "$STARgdir" \
    --readFilesCommand zcat \
    --readFilesIn "$STARgdir/reads/${SAMPLE}_M_F.fq.gz" "$STARgdir/reads/${SAMPLE}_M_R.fq.gz" \
    --chimSegmentMin 15 \
    --outFilterMultimapNmax 1 \
    --twopassMode Basic \
    --runThreadN 8 \
    --outSAMtype BAM SortedByCoordinate \
    --outFileNamePrefix "$STARgdir/Mapped/${SAMPLE}_map"


${singjob}/./featureCounts -p -s 2 --donotsort -B -t "exon" -g "transcript_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${SAMPLE}.tc.out $STARgdir/Mapped/${SAMPLE}_mapAligned.sortedByCoord.out.bam && cut -f1,7 "$OUTPUT/STAR/Mapped/${SAMPLE}.tc.out" > $OUTPUT/STAR/Mapped/${SAMPLE}.tc.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${SAMPLE}.tc.out.tab"

${singjob}/./featureCounts -p -s 2 --donotsort -B -t "exon" -g "gene_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${SAMPLE}.gn.out $STARgdir/Mapped/${SAMPLE}_mapAligned.sortedByCoord.out.bam &&cut -f1,7 "$OUTPUT/STAR/Mapped/${SAMPLE}.gn.out" > $OUTPUT/STAR/Mapped/${SAMPLE}.gn.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${SAMPLE}.gn.out.tab"

${singjob}/./featureCounts -p -s 2 --donotsort -B -t "exon" -g "exon_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${SAMPLE}.ex.out $STARgdir/Mapped/${SAMPLE}_mapAligned.sortedByCoord.out.bam && cut -f1,7 "$OUTPUT/STAR/Mapped/${SAMPLE}.ex.out" > $OUTPUT/STAR/Mapped/${SAMPLE}.ex.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${SAMPLE}.ex.out.tab" 



mv $STARgdir/Mapped/*.final.out $OUTPUT/logs/STAR
echo "Mapping finished" >>/scratch/$USER/$JobID/${JobID}.log
