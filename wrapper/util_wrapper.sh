#!/bin/bash

ARGS="${pos_arg} ${region} ${chromosome} ${as} ${start} ${end} ${gtf} ${gf} ${out_format} ${id_file} ${gff} ${ann} ${xml}"

UTIL="${pos_arg}"
CHR="${chromosome}"
REG="${region}"
GTF="${gtf}"
GF="${gf}"
OUTFOR="${out_format}"
ID_FILE="${id_file}"
GFF="${gff}"
ANN="${ann}"
XML="${xml}"

#########awk_gtf validity check and command line
if [ "${UTIL}" == "awk_gtf " ]
  then
    if [ -z "${GTF}" ]
      then
        echo "gtf file is required for awk_gtf utility"
        exit 1;
    fi
    if [ -z "${CHR}" ] && [ -z "${REG}" ]
      then
        echo "one of the two options --chrom or --region is required for awk_gtf utility"
        exit 1;
    fi
    if [  -n "${CHR}" ] && [ -n "${REG}" ]
      then
          echo "--chrom and --region are mutually exclusive options"
          exit 1;
    fi
    CMDLINEARG="mikado util ""${UTIL} ${REG} ${CHR} ${as} ${start} ${end} ${GTF} awk_gtf.out"
fi

##########convert validity check and command line
if [ "${UTIL}" == "convert " ]
  then
    if [ -z "${GF}" ]
      then
        echo "input file is required for convert utility"
        exit 1;
    fi
    if [ -z "${OUTFOR}" ]
      then
        echo "choose output format for the conversion"
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTIL} ${OUTFOR} ${GF} convert.out"
fi

###########grep validity check and command line
if [ "${UTIL}" == "grep " ]
  then
    if [ -z "${ID_FILE}" ] || [ -z "${GFF}" ]
      then
        echo "id file and gff are required for grep utility"
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTIL} ${grep_v} ${genes} ${ID_FILE} ${GFF} grep.out"
fi

##########stats validity check and command line
if [ "${UTIL}" == "stats " ]
  then
    if [ -z "${GFF}" ]
      then
        echo "gff file is required for stats utility"
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTIL} ${only_coding} ${GFF} stats.out"
fi

#######trim validity check and command line
if [ "${UTIL}" == "trim " ]
  then
    if [ -z "${ANN}" ]
      then
        echo "annotation file is required for trim utility"
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTIL} ${max_len} ${as_gtf} ${ANN} trim.out"
fi

#########merge_blast validity check and command line
if [ "${UTIL}" == "merge_blast " ]
  then
    if [ -z "${XML}" ]
      then
        echo "xml files are required for merge_blast utility"
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTIL} ${verbose} --log merge_blast.log --out merge_blast.out ${XML}"
fi

echo arguments are "${CMDLINEARG}"
INPUTS="${gtf}, ${gf}, ${id_file}, ${gff}, ${xml}, ${ann}"
echo input files are "${INPUTS}"

chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/mikado:v1.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTS}, launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/rosysnake/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0
