#!/bin/bash

################################################################################################################
#                                                                                                              #
#                                                Set Parameters                                                #
#                                                                                                              #
################################################################################################################

#Addional guidance
#If you're wanting a bespoke STAR genome, then run STARG.sh and either copy to $STARgenome for longterm storage or $STARgdir for short term use.

#Extra jobs
SKIPCONTAMQC=TRUE        #Set to TRUE to skip
SKIPCOPYRAW=       #Set to TRUE to skip
SKIPQCTRIM=             #Set to TRUE to skip
SKIPMERGE=TRUE              #Set to TRUE to skip
SKIPMAP=                #Set to TRUE to skip
SKIPSARTOOLS=TRUE            #Set to TRUE to skip
MULTIQC=                #Set to TRUE to skip

SINGLE_END=            #set to TRUE to run!


#User to change
JobID=JOB86
LocationRaw1=/scratch/c.c1060258/JOB86/awk
#LocationRaw2=/gluster/wgp/wgp/projects/JOB86/inputs/E18.5/210426_NB501042_0257_AHT7NTBGXH-fastqs
#LocationRaw3=/gluster/wgp/wgp/sequencing/illumina/miseq/151002_M00766_0139_000000000-AH6C2/Data/Intensities/BaseCalls
#LocationRaw4=/gluster/wgp/wgp/sequencing/illumina/miseq/151013_M00766_0141_000000000-AJGKH/Data/Intensities/BaseCalls



SamplesRaw="ROJ01_12136
ROJ01_12137
ROJ01_12138
ROJ01_12139
ROJ01_12140
ROJ01_12141
ROJ01_12142
ROJ01_12155
ROJ01_12157
ROJ01_12158
ROJ01_12159
ROJ01_12161
ROJ01_12162
ROJ01_12165
ROJ01_12175
ROJ01_12176
ROJ01_12177
ROJ01_12178
ROJ01_12183
ROJ01_12205
ROJ01_12206
ROJ01_12207
ROJ01_12220
ROJ01_12221
ROJ01_12222
ROJ01_12224
ROJ01_12227
ROJ01_12229
ROJ01_12235
ROJ01_12236
ROJ01_12237
"

Samples2merge="ROJ01_12136
ROJ01_12137
ROJ01_12138
ROJ01_12139
ROJ01_12140
ROJ01_12141
ROJ01_12142
ROJ01_12155
ROJ01_12157
ROJ01_12158
ROJ01_12159
ROJ01_12161
ROJ01_12162
ROJ01_12165
ROJ01_12175
ROJ01_12176
ROJ01_12177
ROJ01_12178
ROJ01_12183
ROJ01_12205
ROJ01_12206
ROJ01_12207
ROJ01_12220
ROJ01_12221
ROJ01_12222
ROJ01_12224
ROJ01_12227
ROJ01_12229
ROJ01_12235
ROJ01_12236
ROJ01_12237
"
#If no merging required, use same list as SamplesRaw else samples name without lane e.g R173-A-001_S1

#Default is 2 conditions. If more modify TREATMENT to CONDITION_1, CONDITION_2, etc. Then edit script near bottom at #Perform SARTools on data... section #make metadata to include new conditions
WILDTYPE="R
"

CONDITION_1="R
"

CONDITION_2="R
"

CONDITION_3="R
"

CONDITION_4="R
"

CONDITION_5="R
"

CONDITION_6="R
"

CONDITION_7="R
"

RENAME="R"

#R200-A-023-1

REFNAME=
CONDITION1NAME=
CONDITION2NAME=
CONDITION3NAME=
CONDITION4NAME=
CONDITION5NAME=
CONDITION6NAME=
CONDITION7NAME=

CV=gn                            #what do you want to perform DEseq2 on gn=gene tc=transcript ex=exon


SuffixRawF=R1_001.fastq.gz
SuffixRawR=R2_001.fastq.gz
STARgenome=/gluster/wgp/wgp/hawk/indexes/STAR/GRCm38_STAR2.7.9a/ #GRCh38 GRCm38
GENCODE=gencode.vM17.annotation.gtf #human=gencode.v27.annotation.gtf #mouse=gencode.vM17.annotation.gtf


#User to leave (modify with care)
workingdir=/scratch/$USER/$JobID
tmpdir=/scratch/$USER/$JobID/tmp
singhome=/gluster/wgp/wgp/resources/singularity
singjob=/scratch/$USER/$JobID/Singularity
FEATURECOUNTS=/gluster/wgp/wgp/hawk/RNAseq
STARgdir=/scratch/$USER/$JobID/STARgdir
OUTPUT=/scratch/$USER/$JobID/output
FastP_N=12 #number of jobs for fastp to parallel (Assuming 24 nodes, 2 threads per task, then max is 12)
STAR_N=3 #number of jobs for STARM to parallel (Assuming 24 nodes, then 8 threads most efficient and therefor max jobs is 3)
F_COUNTS=12 #number of jobs for featureCounts to parallel (Assuming 24 nodes, 2 threads per task, then max is 12)

#Setup
mkdir -p /scratch/$USER/$JobID
exec &>> /scratch/$USER/$JobID/${JobID}.log
mkdir -p /scratch/$USER/$JobID/Singularity
mkdir -p /scratch/$USER/$JobID/output/logs
mkdir -p /scratch/$USER/$JobID/output/logs/STAR
mkdir -p /scratch/$USER/$JobID/output/trim
mkdir -p /scratch/$USER/$JobID/output/SARTools
mkdir -p /scratch/$USER/$JobID/output/STAR/Mapped
mkdir -p /scratch/$USER/$JobID/tmp
mkdir -p /scratch/$USER/$JobID/STARgdir
mkdir -p /scratch/$USER/$JobID/STARgdir/reads
mkdir -p /scratch/$USER/$JobID/STARgdir/Mapped

#check for singularities and programs
cp -u $singhome/ContamCheckv3.simg $singjob
cp -u $singhome/SARTools.simg $singjob
cp -r -u /gluster/wgp/wgp/resources/localprograms/fastp/ $singjob
cp -u $FEATURECOUNTS/featureCounts $singjob

#Copy raw data for analysis
if [ "$SKIPCOPYRAW" = "TRUE" ];
  then echo "Skipping copyraw"
elif [ "$SINGLE_END" = "TRUE" ]; then
      for i in $SamplesRaw; do
       cat $LocationRaw1/${i}*${SuffixRawF} >> $tmpdir/${i}_F.fastq.gz
       cat $LocationRaw2/${i}*${SuffixRawF} >> $tmpdir/${i}_F.fastq.gz
      done
else
      for i in $SamplesRaw; do
       cat $LocationRaw1/${i}*${SuffixRawF} >> $tmpdir/${i}_F.fastq.gz
       cat $LocationRaw1/${i}*${SuffixRawR} >> $tmpdir/${i}_R.fastq.gz
      done
#for i in $SamplesRaw;do
#cat $LocationRaw2/${i}_*${SuffixRawF} >> $tmpdir/${i}_F.fastq.gz
#cat $LocationRaw2/${i}_*${SuffixRawR} >> $tmpdir/${i}_R.fastq.gz
#done
#for i in $SamplesRaw;do
#cat $LocationRaw3/${Prefix}*${i}_*${SuffixRawF} >> $tmpdir/${i}_F.fastq.gz
#cat $LocationRaw3/${Prefix}*${i}_*${SuffixRawR} >> $tmpdir/${i}_R.fastq.gz
#done
#for i in $SamplesRaw;do
#cat $LocationRaw4/${Prefix}*${i}_*${SuffixRawF} >> $tmpdir/${i}_F.fastq.gz
#cat $LocationRaw4/${Prefix}*${i}_*${SuffixRawR} >> $tmpdir/${i}_R.fastq.gz
#done
fi

#Copy STAR genome or make another (see top)
cp -u $STARgenome/* $STARgdir


#Run a contamination check through singularity
if [ "$SKIPCONTAMQC" = "TRUE" ];
  then echo "Skipping contamination QC"
  else 
    if [[ ! -e $tmpdir/${JobID}_F.fastq ]]; then
     zcat $tmpdir/*_F.fastq.gz >> $tmpdir/${JobID}_F.fastq
    fi

    if [[ ! -e $tmpdir/${JobID}_R.fastq ]]; then
     zcat $tmpdir/*_R.fastq.gz >> $tmpdir/${JobID}_R.fastq
    fi
    sbatch --export=singjob="$singjob",tmpdir="$tmpdir",JobID="$JobID" ContamCheck.sh -p scw1179
fi

#Check for job to finish
if grep -qe "ContamCheck has now COMPLETED" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  elif grep -qe "Skipping contamination QC" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  else (tail -f -n1 /scratch/$USER/$JobID/${JobID}.log & ) | grep -qe "ContamCheck has now COMPLETED" && echo "ContamCheck has now COMPLETED and QualTrim starting"
fi


##################################################################################################################################################
#Run QC and trimming. N=number of jobs that can run at once. Assuming 24 nodes and 2 threads per task, then 12 jobs can run parallel at one time #
##################################################################################################################################################

#Send off job with variables from this script
if [ "$SKIPQCTRIM" = "TRUE" ];
  then echo "Skipping Quality trimming and assessment"
elif [ "$SINGLE_END" = "TRUE" ];
  then sbatch --export=SamplesRaw="$SamplesRaw",tmpdir="$tmpdir",workingdir="$workingdir",singjob="$singjob",JobID="$JobID",FastP_N="$FastP_N" QualTrimSE.sh -p scw1179 &
else sbatch --export=SamplesRaw="$SamplesRaw",tmpdir="$tmpdir",workingdir="$workingdir",singjob="$singjob",JobID="$JobID",FastP_N="$FastP_N" QualTrim.sh -p scw1179 &
fi

#Check for job to finish
if grep -qe "QualTrim finished" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  elif grep -qe "Skipping Quality trimming and assessment" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  else (tail -f -n1 /scratch/$USER/$JobID/${JobID}.log & ) | grep -qe "QualTrim finished" && echo "..."
fi





##################################################################################################################################################
#Merge multiple lanes/dates                                                                :not zcat not needed for combining 2+ gz files        #
##################################################################################################################################################
if [ "$SKIPMERGE" = "TRUE" ];
   then 
     if [ "$SINGLE_END" = "TRUE" ]; 
      then
        for i in $Samples2merge;
        do ln -s $workingdir/output/trim/${i}_*F.fq.gz $STARgdir/reads/${i}_M_F.fq.gz
        done
     else
        for i in $Samples2merge;
        do ln -s $workingdir/output/trim/${i}_*F.fq.gz $STARgdir/reads/${i}_M_F.fq.gz
           ln -s $workingdir/output/trim/${i}_*R.fq.gz $STARgdir/reads/${i}_M_R.fq.gz
        done
     fi
   else
    rm $STARgdir/reads/*
     if [ "$SINGLE_END" = "TRUE" ]; 
      then
        for i in $Samples2merge;
        do cat $workingdir/output/trim/${i}_*F.fq.gz >> $STARgdir/reads/${i}_M_F.fq.gz
        done
     else
      for i in $Samples2merge;
      do cat $workingdir/output/trim/${i}_*F.fq.gz >> $STARgdir/reads/${i}_M_F.fq.gz;
         cat $workingdir/output/trim/${i}_*R.fq.gz >> $STARgdir/reads/${i}_M_R.fq.gz;
      done
     fi
fi


##################################################################################################################################################
#Run mapping. N=number of jobs that can run at once. Assuming 24 nodes and x threads per task, then y jobs can run parallel at one time          #
##################################################################################################################################################

#Send off job with variables from this script
if [ "$SKIPMAP" = "TRUE" ];
  then echo "Skipping Mapping"
elif [ "$SINGLE_END" = "TRUE" ];
    then sbatch --export=Samples2merge="$Samples2merge",singjob="$singjob",STARgdir="$STARgdir",JobID="$JobID",STAR_N="$STAR_N",F_COUNTS="$F_COUNTS",OUTPUT="$OUTPUT",GENCODE="$GENCODE",CV="$CV" STARM_SE.sh -p scw1179 &
else sbatch --export=Samples2merge="$Samples2merge",singjob="$singjob",STARgdir="$STARgdir",JobID="$JobID",STAR_N="$STAR_N",F_COUNTS="$F_COUNTS",OUTPUT="$OUTPUT",GENCODE="$GENCODE",CV="$CV" STARM.sh -p scw1179 &
fi

#Check for job to finish
if grep -qe "Mapping finished" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  elif grep -qe "Skipping Mapping" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  else (tail -f -n1 /scratch/$USER/$JobID/${JobID}.log & ) | grep -qe "Mapping finished" && echo "..."
fi
  
# run multiqc on log files
 if [ "MULTIQC" = "TRUE" ];
  then echo "Skipping MultiQC"
  else module load multiqc/1.7 && multiqc --force $OUTPUT/logs  -o ${OUTPUT}
 fi



##################################################################################################################################################
#Run SARTools                                                                                                                                    #
##################################################################################################################################################

if [ "$SKIPSARTOOLS" = "TRUE" ];
 then echo "Skipping SARTools"${OUTPUT}/SARTools/metadata.txt
 else
  cp $singhome/SARTools.R ${OUTPUT}/SARTools                                                       #copy the R script
  sed -i 's,REPLACE1,'"${OUTPUT}"\/SARTools',' ${OUTPUT}/SARTools/SARTools.R                          #modify Rscript to personal run
  sed -i 's,REPLACE2,'"${JobID}"',' ${OUTPUT}/SARTools/SARTools.R
  sed -i 's,REPLACE3,'"${USER}"',' ${OUTPUT}/SARTools/SARTools.R
  sed -i 's,REPLACE4,'"${OUTPUT}"\/SARTools\/metadata\.txt',' ${OUTPUT}/SARTools/SARTools.R
  sed -i 's,REPLACE5,'"${OUTPUT}"\/STAR',' ${OUTPUT}/SARTools/SARTools.R
  sed -i 's,REPLACE6,'"${REFNAME}"',' ${OUTPUT}/SARTools/SARTools.R
  rm ${OUTPUT}/SARTools/metadata.txt
  echo -e "Sample_ID\tFile.Name\tTreatment" >> ${OUTPUT}/SARTools/metadata.txt                        #make metadatafile
    for i in $WILDTYPE;                                                                               #might need to change this
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${REFNAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$REFNAME/" "${OUTPUT}/SARTools/metadata.txt"
     done
    for i in $CONDITION_1;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION1NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION1NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done
    for i in $CONDITION_2;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION2NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION2NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done
    for i in $CONDITION_3;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION3NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION3NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done
    for i in $CONDITION_4;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION4NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION4NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done
    for i in $CONDITION_5;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION5NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION5NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done
    for i in $CONDITION_6;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION6NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION6NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done
    for i in $CONDITION_7;                                                                              #might need to change this e.g. CONDITION_1 or TREATMENT
     do
      echo -e "${i}\tMapped/${i}.${CV}.out.tab\t${CONDITION7NAME}" >> ${OUTPUT}/SARTools/metadata.txt; sed -i "0,/^$RENAME/s//$CONDITION7NAME/" "${OUTPUT}/SARTools/metadata.txt"   #also check condition name
     done



  sbatch --export=JobID="$JobID",singjob="$singjob",OUTPUT="$OUTPUT" DiffExp.sh -p scw1179
fi

#Check for job to finish
if grep -qe "Skipping SARTools" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  elif grep -qe "SARTools singularity done" /scratch/$USER/$JobID/${JobID}.log;
   then echo "..."
  else (tail -f -n1 /scratch/$USER/$JobID/${JobID}.log & ) | grep -qe "SARTools singularity done" && echo "..."
fi

#Grab clean files
if grep -qe "SARTools singularity done" /scratch/$USER/$JobID/${JobID}.log;
 then 
  tabbing=$(find ${OUTPUT}/SARTools/tables/*.complete.txt -type f);
  for i in $tabbing
  do
    awk '
    NR==1 {
     for (i=1; i<=NF; i++) {
       f[$i] = i
      }
    }
   { print $(f["Id"]), $(f["log2FoldChange"]), $(f["padj"]) }
   ' ${i} >> ${i}.trim
   sed -e 's/ /\t/g' ${i}.trim > ${i}.trim.tabbed
  done
 else grep -qe "Skipping SARTools" /scratch/$USER/$JobID/${JobID}.log
  echo "..."
fi


