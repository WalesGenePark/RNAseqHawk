#!/bin/bash

# Set colours for 'echo' outputs
NOCOLOR='\033[0m'; RED='\033[0;31m'; GREEN='\033[0;32m'; ORANGE='\033[0;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; 
LIGHTGRAY='\033[0;37m'; DARKGRAY='\033[1;30m'; LIGHTRED='\033[1;31m'; LIGHTGREEN='\033[1;32m'; YELLOW='\033[1;33m'; LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'; LIGHTCYAN='\033[1;36m'; WHITE='\033[1;37m'


# Get directory from ARGV or use current directory
DIR=$1

if [[ -z ${DIR} ]];
then
   DIR=`pwd`
fi

echo -e "${GREEN}Finding fastq files in '${DIR}'${NOCOLOR}" 


# ----------------------------------------------------------------
# Get list of fastq files
# ----------------------------------------------------------------

FASTQ_LIST=""

for FILE in `find $DIR -type f | sort`;
do

    # Check for fq.gz file
    RETVAL=`echo ${FILE} | grep "fastq.gz"`
    if [[ ! -z ${RETVAL} ]];
    then
        FASTQ_LIST=`echo "${FASTQ_LIST};${FILE}"`
    fi

    # Check for fq.gz file
    RETVAL=`echo ${FILE} | grep "fq.gz"`
    if [[ ! -z ${RETVAL} ]];
    then
        FASTQ_LIST=`echo "${FASTQ_LIST};${FILE}"`
    fi

done

FASTQ_LIST=`echo ${FASTQ_LIST} | sed "s/^;//"`


# ----------------------------------------------------------------
# Report number of files
# ----------------------------------------------------------------

FASTQ_COUNT=`echo ${FASTQ_LIST} | tr ";" "\n" | wc -l`
FASTQ_COUNT_DIV2=`echo $(( ${FASTQ_COUNT} / 2 ))`

if [[ ${FASTQ_COUNT} > 0 ]]; 
then 
    echo -e ">> ${GREEN}${FASTQ_COUNT} fastq files found${NOCOLOR}" 
else 
    echo -e ">> ${RED}WARNING: No fastq files found in ${DIR} ${NOCOLOR}"
fi

# ----------------------------------------------------------------
# Check if Illumina format
# ----------------------------------------------------------------

ILLUMINA_FORMAT=0
OTHER_FORMAT=0

for FILE in `echo $FASTQ_LIST | tr ";" "\n"`;
do

    if [[ ${FILE} =~ _S[0-9]+_L[0-9][0-9][0-9]_R[12]_001.f ]]; 
    then 
        ILLUMINA_FORMAT=$((ILLUMINA_FORMAT + 1))
    else 
        OTHER_FORMAT=$((OTHER_FORMAT + 1))
    fi

done

if [[ ${ILLUMINA_FORMAT} > 0 ]]; 
then 
    echo -e ">> ${GREEN}${ILLUMINA_FORMAT} fastq files with illumina name formatting${NOCOLOR}" 
fi

if [[ ${OTHER_FORMAT} > 0 ]]; 
then 
    echo -e ">> ${YELLOW}${OTHER_FORMAT} fastq files with non-illumina formatting${NOCOLOR}" 
fi

# ----------------------------------------------------------------
# Detect single or paired end
# ----------------------------------------------------------------


R1_COUNT=`echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep "_R1" | wc -l`
R2_COUNT=`echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep "_R2" | wc -l`

if [[ ${R1_COUNT} == $FASTQ_COUNT ]];
then
    echo -e ">> ${YELLOW}Single-end reads detected${NOCOLOR}"   
elif [[ ${R1_COUNT} == $R2_COUNT ]];
then
    echo -e ">> ${GREEN}Paired-end reads detected${NOCOLOR}"   
else
    echo -e ">> ${YELLOW}Possible mix of single and paired end reads detected${NOCOLOR}"   
fi

# ----------------------------------------------------------------
# Detect lanes
# ----------------------------------------------------------------


LANES_STR="";

for FILE in `echo $FASTQ_LIST | tr ";" "\n"`;
do

    if [[ ${FILE} =~ _L00[0-9] ]]; 
    then 
        LANE=`echo $FILE | sed "s/.*_\(L00[0-9]\).*/\1/"`
        LANES_STR=`echo "${LANES_STR};${LANE}"`
    fi

done

LANES_STR=`echo ${LANES_STR} | sed "s/^;//" | tr ";" "\n" | sort | uniq | tr "\n" "," | sed "s/,$//"`
LANES=`echo $LANES_STR | tr "," "\n" | wc -l`

if [[ ${LANES} > 0 ]]; 
then 
    echo -e ">> ${GREEN}${LANES} lane(s) identified (${LANES_STR})${NOCOLOR}" 

fi



# ----------------------------------------------------------------
# Get common suffix
# ----------------------------------------------------------------


COUNT=1
STRLEN=0
while [ ${COUNT} -le 1 ];
do
    STRLEN=$((STRLEN + 1))
    COUNT=`echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep -v -i undetermined | sed "s/_R1/_Rn/" | sed "s/_R2/_Rn/" | rev | cut -c 1-${STRLEN} | sort | uniq | wc -l`
done
STRLEN=$((STRLEN - 1))

if [[ ${STRLEN} > 0 ]]; 
then 
    COMMON_SUFFIX=`echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep -v -i undetermined | sed "s/_R1/_Rn/" | sed "s/_R2/_Rn/"| rev | cut -c 1-${STRLEN} | sort | uniq | rev`
    echo -e ">> ${GREEN}'${COMMON_SUFFIX}' identified as a common suffix${NOCOLOR}" 
else 
    COMMON_SUFFIX=""
    echo -e ">> ${YELLOW}No common suffix identified${NOCOLOR}"
fi


# ----------------------------------------------------------------
# Get common prefix
# ----------------------------------------------------------------

COUNT=1
STRLEN=0
while [ ${COUNT} -le 1 ];
do
    STRLEN=$((STRLEN + 1))
    COUNT=`echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep -v -i undetermined | cut -c 1-${STRLEN} | sort | uniq | wc -l`
done
STRLEN=$((STRLEN - 1))

if [[ ${STRLEN} > 0 ]]; 
then 
    COMMON_PREFIX=`echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep -v -i undetermined | cut -c 1-${STRLEN} | sort | uniq`
    echo -e ">> ${GREEN}'${COMMON_PREFIX}' identified as a common prefix${NOCOLOR}" 
else 
    COMMON_PREFIX=""
    echo -e ">> ${YELLOW}No common prefix identified${NOCOLOR}"
fi


# ----------------------------------------------------------------
# Get WGP format samples
# ----------------------------------------------------------------

WGP_SAMPLES="";
WGP_PROJECTS="";

for FILE in `echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///"`;
do

    if [[ ${FILE} =~ ^[A-Z][0-9][0-9][0-9]-[A-Z]-[0-9][0-9][0-9]-*[0-9]*_ ]]; 
    then 
        SAMPLE=`echo $FILE | sed "s/_S[0-9]\\+_L[0-9][0-9][0-9]_R[12]_001.f.*//"`
        PROJECT=`echo $FILE | sed "s/-[A-Z]-[0-9][0-9][0-9]-*[0-9]*_.*//"`
        WGP_SAMPLES=`echo "${WGP_SAMPLES};${SAMPLE}"`
        WGP_PROJECTS=`echo "${WGP_PROJECTS};${PROJECT}"`
    fi 

done

# Get unique
WGP_SAMPLES=`echo ${WGP_SAMPLES} | tr ";" "\n" | sort | uniq | tr "\n" ";"`
WGP_PROJECTS=`echo ${WGP_PROJECTS} | tr ";" "\n" | sort | uniq | tr "\n" ";"`

# Tidy up
WGP_SAMPLES=`echo ${WGP_SAMPLES} | sed "s/^;//"`
WGP_PROJECTS=`echo ${WGP_PROJECTS} | sed "s/^;//"`
WGP_SAMPLES=`echo ${WGP_SAMPLES} | sed "s/;$//"`
WGP_PROJECTS=`echo ${WGP_PROJECTS} | sed "s/;$//"`

# Get counts
if [[ ! -z ${WGP_SAMPLES} ]];
then
    WGP_SAMPLE_COUNT=`echo ${WGP_SAMPLES} | tr ";" "\n" | sort | uniq | wc -l`
else
    WGP_SAMPLE_COUNT=0
fi

if [[ ! -z ${WGP_PROJECTS} ]];
then
    WGP_PROJECT_COUNT=`echo ${WGP_PROJECTS} | sed "s/^;//" | tr ";" "\n" | sort | uniq | wc -l`
else
    WGP_PROJECT_COUNT=0
fi

# Output total WGP samples
#if [[ ${WGP_SAMPLE_COUNT} > 0 ]]; 
#hen 
 #   echo -e ">> ${GREEN}${WGP_SAMPLE_COUNT} sample(s) found with a WGP format${NOCOLOR}" 
#fi

# Output totals for each project
for WGP_PROJECT in `echo $WGP_PROJECTS | tr ";" "\n" | sed "s/.*\///"`;
do
    COUNT=`echo ${WGP_SAMPLES} | tr ";" "\n" | grep ${WGP_PROJECT} | wc -l`
    echo -e ">> ${GREEN}${COUNT} sample(s) found for WGP project ${WGP_PROJECT}${NOCOLOR}" 
done



# ----------------------------------------------------------------
# Set R1 and R2 suffixes
# ----------------------------------------------------------------

COMMON_SUFFIX_R1=`echo ${COMMON_SUFFIX} | sed "s/_Rn/_R1/"`
COMMON_SUFFIX_R2=`echo ${COMMON_SUFFIX} | sed "s/_Rn/_R2/"`

COUNT_R1=`echo $FASTQ_LIST | tr ";" "\n" | grep ${COMMON_SUFFIX_R1} | wc -l`
COUNT_R2=`echo $FASTQ_LIST | tr ";" "\n" | grep ${COMMON_SUFFIX_R2} | wc -l`

if [[ ${COUNT_R1} == $FASTQ_COUNT  ]] || [[ ${COUNT_R1} == $FASTQ_COUNT_DIV2 ]];
then
    SuffixRawF=${COMMON_SUFFIX_R1}
    echo -e "${PURPLE}SuffixRawF=${SuffixRawF}${NOCOLOR}"
fi

if [[ ${COUNT_R2} == $FASTQ_COUNT_DIV2  ]];
then
    SuffixRawR=${COMMON_SUFFIX_R2}
    echo -e "${PURPLE}SuffixRawR=${SuffixRawR}${NOCOLOR}"
fi


# ----------------------------------------------------------------
# Get SamplesRaw
# ----------------------------------------------------------------

SamplesRaw=""

for FILE in `echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep -v -i undetermined`;
do

    SAMPLE=`echo $FILE | sed "s/${SuffixRawF}$//" | sed "s/${SuffixRawR}$//"`
    SamplesRaw=`echo "${SamplesRaw} ${SAMPLE}"`

done

SamplesRaw=`echo ${SamplesRaw} | tr " " "\n" | sort | uniq | tr "\n" " "`

COUNT=`echo ${SamplesRaw} | tr " " "\n" | wc -l`
echo -e "${PURPLE}SamplesRaw=${SamplesRaw}${NOCOLOR}" 


# ----------------------------------------------------------------
# Get Samples2merge
# ----------------------------------------------------------------

Samples2merge=""

for FILE in `echo $FASTQ_LIST | tr ";" "\n" | sed "s/.*\///" | grep -v -i undetermined`;
do

    SAMPLE=`echo $FILE | sed "s/${SuffixRawF}$//" | sed "s/${SuffixRawR}$//" | sed "s/_L00[0-9]//"`
    Samples2merge=`echo "${Samples2merge} ${SAMPLE}"`

done

Samples2merge=`echo ${Samples2merge} | tr " " "\n" | sort | uniq | tr "\n" " "`

if [[ ${SamplesRaw} == $Samples2merge  ]];
then
    Samples2merge=""
fi

COUNT=`echo ${Samples2merge} | tr " " "\n" | wc -l`
echo -e "${PURPLE}Samples2merge=${Samples2merge}${NOCOLOR}" 


