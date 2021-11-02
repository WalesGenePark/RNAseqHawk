#!/bin/bash

################################################################################################################
#                                                                                                              #
#                                                Set Parameters                                                #
#                                                                                                              #
################################################################################################################

# Project ID
JobID=X201

# Select genomes (hg38, GRCm38 [mm10])
GENOME=m38

# Location of fastq files
SINGLE_END=FALSE #Set to TRUE to run!
LocationRaw1=/scratch/c.wptpjg/gluster/wgp/wgp/sequencing/illumina/novaseq/210916_A00748_0148_BHKGFCDRXY/fastq_files/R201
#LocationRaw2=XXXXXXXXXX
#LocationRaw3=XXXXXXXXXX
#LocationRaw4=XXXXXXXXXX

# List of samples (without suffix)
SamplesRaw="R201-A-001_S10_L001
R201-A-001_S10_L002
R201-A-002_S11_L001
R201-A-002_S11_L002
R201-A-003_S12_L001
R201-A-003_S12_L002
R201-A-004_S13_L001
R201-A-004_S13_L002
R201-A-005_S14_L001
R201-A-005_S14_L002
R201-A-006_S15_L001
R201-A-006_S15_L002
R201-A-007_S16_L001
R201-A-007_S16_L002
R201-A-008_S17_L001
R201-A-008_S17_L002
R201-A-009_S18_L001
R201-A-009_S18_L002
"

# Merging information  (if no merging required, use same list as SamplesRaw else samples name without lane e.g R173-A-001_S1)
Samples2merge="R201-A-001_S10
R201-A-002_S11
R201-A-003_S12
R201-A-004_S13
R201-A-005_S14
R201-A-006_S15
R201-A-007_S16
R201-A-008_S17
R201-A-009_S18
"

# fastq suffix settings
SuffixRawF=R1_001.fastq.gz
SuffixRawR=R2_001.fastq.gz

# Tweak which parts to run
SKIPCOPYRAW=            #Set to TRUE to skip
SKIPQCTRIM=             #Set to TRUE to skip
SKIPMERGE=TRUE          #Set to TRUE to skip
SKIPMAP=                #Set to TRUE to skip
SKIPSARTOOLS=TRUE       #Set to TRUE to skip
SKIPMULTIQC=            #Set to TRUE to skip


# ------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------
# User to leave (modify with care)
#-------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------

# Set colours for 'echo' outputs
NOCOLOR='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; ORANGE='\033[0;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; 
LIGHTGRAY='\033[0;37m'; DARKGRAY='\033[1;30m'; LIGHTRED='\033[1;31m'; LIGHTGREEN='\033[1;32m'; YELLOW='\033[1;33m'; LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'; LIGHTCYAN='\033[1;36m'; WHITE='\033[1;37m'

# Detect genome and select files
if [ ${GENOME} eq "hg38"]; then
    STARgenome=/gluster/wgp/wgp/hawk/indexes/STAR/GRCh38/
    GENCODE=gencode.v27.annotation.gtf
fi

if [ ${GENOME} eq "m38"]; then
    STARgenome=/gluster/wgp/wgp/hawk/indexes/STAR/GRCm38_STAR2.7.9a/ 
    GENCODE=gencode.vM17.annotation.gtf 

fi

# Define directories
workingdir=/scratch/$USER/$JobID
tmpdir=/scratch/$USER/$JobID/tmp
singhome=/gluster/wgp/wgp/resources/singularity
singjob=/scratch/$USER/$JobID/Singularity
FEATURECOUNTS=/gluster/wgp/wgp/hawk/RNAseq
STARgdir=/scratch/$USER/$JobID/STARgdir
OUTPUT=/scratch/$USER/$JobID/output

# Define run information
FastP_N=12 #number of jobs for fastp to parallel (Assuming 24 nodes, 2 threads per task, then max is 12)
STAR_N=3 #number of jobs for STARM to parallel (Assuming 24 nodes, then 8 threads most efficient and therefor max jobs is 3)
F_COUNTS=12 #number of jobs for featureCounts to parallel (Assuming 24 nodes, 2 threads per task, then max is 12)

# Output to log file and screen
#exec &>> /scratch/$USER/$JobID/${JobID}.log
exec &> >(tee "/scratch/$USER/$JobID/${JobID}.log")
exec 2>&1

# Setup directories
echo -e "${CYAN}Creating output directories${NOCOLOR}"
mkdir -p /scratch/$USER/$JobID
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

# Check for singularities and programs
echo -e "${CYAN}Copying singularity shells and other programs${NOCOLOR}"
cp -u $singhome/ContamCheckv3.simg $singjob
cp -u $singhome/SARTools.simg $singjob
cp -r -u /gluster/wgp/wgp/resources/localprograms/fastp/ $singjob
cp -u $FEATURECOUNTS/featureCounts $singjob

# Copy data to working directory
echo -e "${CYAN}Copying raw data to working directory${NOCOLOR}"
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
echo -e "${CYAN}Copying STAR indexes${NOCOLOR}"
cp -u $STARgenome/* $STARgdir


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

echo -e "${CYAN}Starting trimming using fastp${NOCOLOR}"
#Send off job with variables from this script
if [ "$SKIPQCTRIM" = "TRUE" ];
  then echo "Skipping Quality trimming and assessment"
elif [ "$SINGLE_END" = "TRUE" ];
  then sbatch --account=scw1179 --export=SamplesRaw="$SamplesRaw",tmpdir="$tmpdir",workingdir="$workingdir",singjob="$singjob",JobID="$JobID",FastP_N="$FastP_N" QualTrimSE.sh &
else sbatch --account=scw1179 --export=SamplesRaw="$SamplesRaw",tmpdir="$tmpdir",workingdir="$workingdir",singjob="$singjob",JobID="$JobID",FastP_N="$FastP_N" QualTrim.sh &
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

echo -e "${CYAN}Starting fastq merging${NOCOLOR}"
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

echo -e "${CYAN}Starting fastq merging${NOCOLOR}"

#Send off job with variables from this script
if [ "$SKIPMAP" = "TRUE" ];
  then echo "Skipping Mapping"
elif [ "$SINGLE_END" = "TRUE" ];
    then sbatch --account=scw1179 --export=Samples2merge="$Samples2merge",singjob="$singjob",STARgdir="$STARgdir",JobID="$JobID",STAR_N="$STAR_N",F_COUNTS="$F_COUNTS",OUTPUT="$OUTPUT",GENCODE="$GENCODE",CV="$CV" STARM_SE.sh &
else sbatch --account=scw1179 --export=Samples2merge="$Samples2merge",singjob="$singjob",STARgdir="$STARgdir",JobID="$JobID",STAR_N="$STAR_N",F_COUNTS="$F_COUNTS",OUTPUT="$OUTPUT",GENCODE="$GENCODE",CV="$CV" STARM.sh &
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
