# Setup working directory and clone scripts from github
# ----------------------------------------------------------------------

mkdir -p /scratch/${USER}/${PROJECT}
cd /scratch/${USER}/${PROJECT}

git clone https://github.com/WalesGenePark/RNAseqHawk.git .


################################################################################################################
#                                                                                                              #
#                                                Set Parameters                                                #
#                                                                                                              #
################################################################################################################

# Project ID
JobID=R198

# Select genome (hg38, GRCm38 [mm10])
GENOME=hg38

# Location of fastq files
SINGLE_END=FALSE #Set to TRUE to run!
LocationRaw1=/scratch/c.wptpjg/211109_NB501042_0295_AH5J3NBGXK-fastqs
#LocationRaw2=XXXXXXXXXX
#LocationRaw3=XXXXXXXXXX
#LocationRaw4=XXXXXXXXXX

# List of samples (without suffix)
SamplesRaw="R198-N-005_S1_L001
R198-N-008_S2_L001
R198-N-014_S3_L001
R198-N-025_S4_L001
R198-N-026_S5_L001
R198-N-030_S6_L001
R198-N-031_S7_L001
R198-N-033_S8_L001
R198-N-035_S9_L001
R198-N-036_S10_L001
R198-N-037_S11_L001
R198-N-039_S12_L001
"

# Merging information  (if no merging required, use same list as SamplesRaw else samples name without lane e.g R173-A-001_S1)
Samples2merge="R198-N-005_S1
R198-N-008_S2
R198-N-014_S3
R198-N-025_S4
R198-N-026_S5
R198-N-030_S6
R198-N-031_S7
R198-N-033_S8
R198-N-035_S9
R198-N-036_S10
R198-N-037_S11
R198-N-039_S12
"

# fastq suffix settings
SuffixRawF=_R1_001.fastq.gz
SuffixRawR=_R2_001.fastq.gz


# ------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------
# User to leave (modify with care)
#-------------------------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------------------------------------------------------

# Slurm settings
SLURM_PARTITION=c_compute_wgp1
SLURM_ACCOUNT=scw1179
SLURM_CORES=12
SLURM_WALLTIME="0-6:00"

# Set colours for 'echo' outputs
NOCOLOR='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; ORANGE='\033[0;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; 
LIGHTGRAY='\033[0;37m'; DARKGRAY='\033[1;30m'; LIGHTRED='\033[1;31m'; LIGHTGREEN='\033[1;32m'; YELLOW='\033[1;33m'; LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'; LIGHTCYAN='\033[1;36m'; WHITE='\033[1;37m'

# Detect genome and select files
if [ ${GENOME} == "hg38" ]; then
    STARgenome=/gluster/wgp/wgp/hawk/indexes/STAR/GRCh38/
    GENCODE=gencode.v27.annotation.gtf
fi

if [ ${GENOME} == "m38" ]; then
    STARgenome=/gluster/wgp/wgp/hawk/indexes/STAR/GRCm38/ 
    GENCODE=gencode.vM17.annotation.gtf 

fi

# Define directories
WORKINGDIR=/scratch/${USER}/${JobID}

# Setup directories
TMPDIR=${WORKINGDIR}/tmp
SINGDIR=${WORKINGDIR}/Singularity
STARGDIR=${WORKINGDIR}/STARgdir
OUTPUT=${WORKINGDIR}/output

echo -e "${CYAN}Creating output directories${NOCOLOR}"
mkdir -p ${WORKINGDIR}
mkdir -p ${SINGDIR}
mkdir -p ${OUTPUT}/logs
mkdir -p ${OUTPUT}/logs/STAR
mkdir -p ${OUTPUT}/trim
mkdir -p ${OUTPUT}/SARTools
mkdir -p ${OUTPUT}/STAR/Mapped
mkdir -p ${TMPDIR}
mkdir -p ${STARGDIR}
mkdir -p ${STARGDIR}/reads
mkdir -p ${STARGDIR}/Mapped

# Clone scripts from github
cd ${WORKINGDIR}
git clone https://github.com/WalesGenePark/RNAseqHawk.git .

# Check for singularities and programs
echo -e "${CYAN}Copying singularity shells and other programs${NOCOLOR}"
curl -s -o ${SINGDIR}/STAR-2.7.1a.sif https://wotan.cardiff.ac.uk/containers/STAR-2.7.1a.sif
curl -s -o ${SINGDIR}/featurecounts-2.0.3.sif https://wotan.cardiff.ac.uk/containers/featurecounts-2.0.3.sif
curl -s -o ${SINGDIR}/fastp-v0.23.1.sif https://wotan.cardiff.ac.uk/containers/fastp-v0.23.1.sif
curl -s -o ${SINGDIR}/multiqc-v1.11.sif https://wotan.cardiff.ac.uk/containers/multiqc-v1.11.sif


##################################################################################################################################################
# Copy data to working directory
##################################################################################################################################################

echo -e "${CYAN}Copying raw data to working directory${NOCOLOR}"
#Copy raw data for analysis
if [ "$SKIPCOPYRAW" = "TRUE" ];
  then echo "Skipping copyraw"
elif [ "$SINGLE_END" = "TRUE" ]; then
      for i in $SamplesRaw; do
       cat $LocationRaw1/${i}*${SuffixRawF} >> $TMPDIR/${i}_F.fastq.gz
       cat $LocationRaw2/${i}*${SuffixRawF} >> $TMPDIR/${i}_F.fastq.gz
      done
else
      for i in $SamplesRaw; do
       cat $LocationRaw1/${i}*${SuffixRawF} >> $TMPDIR/${i}_F.fastq.gz
       cat $LocationRaw1/${i}*${SuffixRawR} >> $TMPDIR/${i}_R.fastq.gz
      done
#for i in $SamplesRaw;do
#cat $LocationRaw2/${i}_*${SuffixRawF} >> $TMPDIR/${i}_F.fastq.gz
#cat $LocationRaw2/${i}_*${SuffixRawR} >> $TMPDIR/${i}_R.fastq.gz
#done
#for i in $SamplesRaw;do
#cat $LocationRaw3/${Prefix}*${i}_*${SuffixRawF} >> $TMPDIR/${i}_F.fastq.gz
#cat $LocationRaw3/${Prefix}*${i}_*${SuffixRawR} >> $TMPDIR/${i}_R.fastq.gz
#done
#for i in $SamplesRaw;do
#cat $LocationRaw4/${Prefix}*${i}_*${SuffixRawF} >> $TMPDIR/${i}_F.fastq.gz
#cat $LocationRaw4/${Prefix}*${i}_*${SuffixRawR} >> $TMPDIR/${i}_R.fastq.gz
#done
fi


##################################################################################################################################################
# #Copy STAR genome 
##################################################################################################################################################

echo -e "${CYAN}Copying STAR indexes${NOCOLOR}"
cp -u ${STARgenome}/* ${STARGDIR}


##################################################################################################################################################
# With each sample
##################################################################################################################################################

FINALWAITFOR=""
for SAMPLE in $Samples2merge
do
    echo $SAMPLE


    ##################################################################################################################################################
    # With each sample fastq pairs
    ##################################################################################################################################################

    WAITFOR=""
    for SAMPLERAW in `echo $SamplesRaw | tr " " "\n" |  grep $SAMPLE`;
    do
    
        SLURM_OUT="slurm-trim_${SAMPLERAW}.out"
        SLURM_ERR="slurm-trim_${SAMPLERAW}.err" 
    
        RETVAL=`sbatch \
            --account=${SLURM_ACCOUNT} --partition=${SLURM_PARTITION} --nodes=1 --ntasks-per-node=1 --cpus-per-task=${SLURM_CORES} --time=${SLURM_WALLTIME} \
            --error=${SLURM_ERR} --output=${SLURM_OUT} \
            --export=SAMPLERAW="${SAMPLERAW}",TMPDIR="$TMPDIR",OUTPUT="$OUTPUT",SINGDIR="$SINGDIR",SLURM_CORES="$SLURM_CORES" \
            QualTrim2.sh`

        JOBID=`echo $RETVAL | sed "s/Submitted batch job //"`
        WAITFOR=`echo "${WAITFOR}|${JOBID}"`

    done
    WAITFOR=`echo $WAITFOR | sed "s/^|//" | sed "s/|/:/g"`
    echo ${WAITFOR}


    ##################################################################################################################################################
    # Merge trimmed fastq files
    ##################################################################################################################################################

    SLURM_OUT="slurm-merge_${SAMPLE}.out"
    SLURM_ERR="slurm-merge_${SAMPLE}.err"

    RETVAL=`sbatch \
        --account=${SLURM_ACCOUNT} --partition=${SLURM_PARTITION} --nodes=1 --ntasks-per-node=1 --cpus-per-task=1 --time=${SLURM_WALLTIME} \
        --error=${SLURM_ERR} --output=${SLURM_OUT} \
        --export=SAMPLE="$SAMPLE",STARGDIR="$STARGDIR",OUTPUT="$OUTPUT" \
        --dependency=afterany:${WAITFOR} \
        mergetrim.sh`

    WAITFOR=`echo $RETVAL | sed "s/Submitted batch job //"`
    echo ${WAITFOR}


    ##################################################################################################################################################
    # Map data and run feature counts
    ##################################################################################################################################################

    SLURM_OUT="slurm-map_${SAMPLE}.out"
    SLURM_ERR="slurm-map_${SAMPLE}.err"

    RETVAL=`sbatch \
        --account=${SLURM_ACCOUNT} --partition=${SLURM_PARTITION} --nodes=1 --ntasks-per-node=1 --cpus-per-task=${SLURM_CORES} --time=${SLURM_WALLTIME} \
        --error=${SLURM_ERR} --output=${SLURM_OUT} \
        --export=SAMPLE="$SAMPLE",SINGDIR="$SINGDIR",STARGDIR="$STARGDIR",OUTPUT="$OUTPUT",GENCODE="$GENCODE",SLURM_CORES="$SLURM_CORES" \
        --dependency=afterany:${WAITFOR} \
        STARM2.sh`

    JOBID=`echo $RETVAL | sed "s/Submitted batch job //"`
    FINALWAITFOR=`echo "${FINALWAITFOR}|${JOBID}"`


done

FINALWAITFOR=`echo ${FINALWAITFOR} | sed "s/^|//" | sed "s/|/:/g"`
echo ${FINALWAITFOR}


##################################################################################################################################################
# Run multiQC when all finished     
##################################################################################################################################################

SLURM_OUT="slurm-multiqc.out"
SLURM_ERR="slurm-multiqc.err"
       
RETVAL=`sbatch \
        --account=${SLURM_ACCOUNT} --partition=${SLURM_PARTITION} --nodes=1 --ntasks-per-node=1 --cpus-per-task=1 --time=${SLURM_WALLTIME} \
        --error=${SLURM_ERR} --output=${SLURM_OUT} \
        --export=OUTPUT="$OUTPUT",TMPDIR="$TMPDIR",STARGDIR="$STARGDIR",Samples2merge="$Samples2merge",JobID="$JobID",WORKINGDIR="$WORKINGDIR",SINGDIR="$SINGDIR" \
        --dependency=afterany:${FINALWAITFOR} \
        MultiQC.sh`

WAITFOR=`echo $RETVAL | sed "s/Submitted batch job //"`


##################################################################################################################################################
# Hold script until job completes
##################################################################################################################################################


STATUS=""
while [[ ${STATUS} != "COMPLETED" ]]; do

        STATUS=`sacct -j ${WAITFOR} --format=state | sed "1,2d" | head -n 1 | sed "s/ //g"`
        TIME=`date "+%R"`
        echo -ne "${TIME} ${STATUS}\r"
        sleep 30
done

echo "FINISHED!"

