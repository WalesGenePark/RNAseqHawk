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
N=$STAR_N
open_sem $N

for i in $Samples2merge; do

run_with_lock  STAR	--genomeDir "$STARgdir" \
        		--readFilesCommand zcat \
			--readFilesIn "$STARgdir/reads/${i}_M_F.fq.gz" "$STARgdir/reads/${i}_M_R.fq.gz" \
		        --chimSegmentMin 15 \
		        --outFilterMultimapNmax 1 \
		        --twopassMode Basic \
		        --runThreadN 8 \
			--outSAMtype BAM SortedByCoordinate \
			--outFileNamePrefix "$STARgdir/Mapped/${i}_map"
done



for i in $Samples2merge; do

#run_with_lock \
if [ "$CV" = "tc" ];
 then ${singjob}/./featureCounts -p -s 2 --donotsort -B -t "exon" -g "transcript_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${i}.tc.out $STARgdir/Mapped/${i}_mapAligned.sortedByCoord.out.bam && cut -f1,7 "$OUTPUT/STAR/Mapped/${i}.tc.out" > $OUTPUT/STAR/Mapped/${i}.tc.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${i}.tc.out.tab"
elif [ "$CV" = "gn" ];
 then ${singjob}/./featureCounts -p -s 2 --donotsort -B -t "exon" -g "gene_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${i}.gn.out $STARgdir/Mapped/${i}_mapAligned.sortedByCoord.out.bam &&cut -f1,7 "$OUTPUT/STAR/Mapped/${i}.gn.out" > $OUTPUT/STAR/Mapped/${i}.gn.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${i}.gn.out.tab"
elif [ "$CV" = "ex" ];
 then ${singjob}/./featureCounts -p -s 2 --donotsort -B -t "exon" -g "exon_id" -a ${STARgdir}/${GENCODE} -o $OUTPUT/STAR/Mapped/${i}.ex.out $STARgdir/Mapped/${i}_mapAligned.sortedByCoord.out.bam && cut -f1,7 "$OUTPUT/STAR/Mapped/${i}.ex.out" > $OUTPUT/STAR/Mapped/${i}.ex.out.tab; sed -i 1,2d "$OUTPUT/STAR/Mapped/${i}.ex.out.tab" 
else
  echo "error in featureCounts"
fi

done

#development
#for i in $Samples2merge; do

#run_with_lock \
#java -jar $PICARD MarkDuplicates I=$STARgdir/Mapped/${i}_mapAligned.sortedByCoord.out.bam O=$STARgdir/Mapped/${i}_dupsmarked.bam METRICS_FILE=${i}_dup.txt REMOVE_DUPLICATES=FALSE VALIDATION_STRINGENCY=SILENT TMP_DIR=tmp
#singularity run DiffExpUtils.simg R dupradar.R $STARgdir/Mapped/${i}_mapAligned.sortedByCoord.out.bam ${STARgenome}${GENCODE} 1 TRUE $OUTPUT/STAR/Mapped/ $N
#done

mv $STARgdir/Mapped/*.final.out $OUTPUT/logs/STAR
echo "Mapping finished" >>/scratch/$USER/$JobID/${JobID}.log
