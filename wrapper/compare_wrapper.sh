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

ARGS=" ${reference} ${targets} ${prediction} ${distance} ${protein_coding} ${lenient} ${exclude_utr} ${verbose} -l compare.log"
#echo $ARGS

TARGETSU="${targets}"
REFU="${reference}"

if [  "${TARGETSU}" == "--prediction " ]
  then
    if [ -z "${prediction}" ]
      then
        >&2 echo "prediction file is needed for --prediction option"
        debug
        exit 1;
    fi
fi

CMDLINEARG="mikado compare ""${REFU}"" --index; mikado compare ""${ARGS}"
echo arguments are "${CMDLINEARG}"
REFU=(${REFU})
INPUTSU="${REFU[@]:1}, ${prediction}"
echo inputs are "${INPUTSU}"

chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/mikado:v1.1.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = output/compare.log, output/mikado_compare.refmap, output/mikado_compare.stats, output/mikado_compare.tmap, output/${REFU[@]:1}.midx >> lib/condorSubmitEdit.htc

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
