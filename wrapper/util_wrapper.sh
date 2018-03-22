#!/bin/bash

function debug {
  echo "creating debugging directory"
mkdir .debug
for word in ${rmthis}
  do
    if [[ "${word}" == *.sh ]] || [[ "${word}" == lib ]]
      then
        mv "${word}" .debug;
      fi
  done
}

rmthis=`ls`
echo ${rmthis}

ARGS="${pos_arg} ${region} ${chromosome} ${as} ${start} ${end} ${gtf} ${gf} ${out_format} ${id_file} ${gff} ${ann} ${xml}"

UTILU="${pos_arg}"
CHRU="${chromosome}"
REGU="${region}"
GTFU="${gtf}"
GFU="${gf}"
OUTFORU="${out_format}"
ID_FILEU="${id_file}"
GFFU="${gff}"
ANNU="${ann}"
XMLU="${xml}"

#########awk_gtf validity check and command line
if [ "${UTILU}" == "awk_gtf " ]
  then
    if [ -z "${GTFU}" ]
      then
        >&2 echo "gtf file is required for awk_gtf utility"
        debug
        exit 1;
    fi
    if [ -z "${CHRU}" ] && [ -z "${REGU}" ]
      then
        >&2 echo "one of the two options --chrom or --region is required for awk_gtf utility"
        debug
        exit 1;
    fi
    if [  -n "${CHRU}" ] && [ -n "${REGU}" ]
      then
          >&2 echo "--chrom and --region are mutually exclusive options"
          debug
          exit 1;
    fi
    CMDLINEARG="mikado util ""${UTILU} ${REGU} ${CHRU} ${as} ${start} ${end} ${GTFU} awk_gtf.out"
fi

##########convert validity check and command line
if [ "${UTILU}" == "convert " ]
  then
    if [ -z "${GFU}" ]
      then
        >&2 echo "input file is required for convert utility"
        debug
        exit 1;
    fi
    if [ -z "${OUTFORU}" ]
      then
        >&2 echo "choose output format for the conversion"
        debug
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTILU} ${OUTFORU} ${GFU} convert.out"
fi

###########grep validity check and command line
if [ "${UTILU}" == "grep " ]
  then
    if [ -z "${ID_FILEU}" ] || [ -z "${GFFU}" ]
      then
        >&2 echo "id file and gff are required for grep utility"
        debug
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTILU} ${grep_v} ${genes} ${ID_FILEU} ${GFFU} grep.out"
fi

##########stats validity check and command line
if [ "${UTILU}" == "stats " ]
  then
    if [ -z "${GFFU}" ]
      then
        >&2 echo "gff file is required for stats utility"
        debug
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTILU} ${only_coding} ${GFFU} stats.out"
fi

#######trim validity check and command line
if [ "${UTILU}" == "trim " ]
  then
    if [ -z "${ANNU}" ]
      then
        >&2 echo "annotation file is required for trim utility"
        debug
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTILU} ${max_len} ${as_gtf} ${ANNU} trim.out"
fi

#########merge_blast validity check and command line
if [ "${UTILU}" == "merge_blast " ]
  then
    if [ -z "${XMLU}" ]
      then
        >&2 echo "xml files are required for merge_blast utility"
        debug
        exit 1;
    fi
    CMDLINEARG="mikado util ""${UTILU} ${verbose} --log merge_blast.log --out merge_blast.out ${XMLU}"
fi


echo arguments are "${CMDLINEARG}"
INPUTSU="${gtf}, ${gf}, ${id_file}, ${gff}, ${xml}, ${ann}"
echo input files are "${INPUTSU}"

chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/mikado:v1.1.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/rosysnake/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
