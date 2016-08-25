#!/bin/bash

ARGS=" ${reference} ${targets} ${prediction} ${distance} ${protein_coding} ${lenient} ${exclude_utr} ${verbose} -l compare.log"
#echo $ARGS
INPUTS="${reference}, ${prediction}"

TARGETS="${targets}"
REF="${reference}"

if [  "${TARGETS}" == "--prediction " ]
  then
    if [ -z "${prediction}" ]
      then
        echo "prediction file is needed for --prediction option"
        exit 1;
    fi
fi

CMDLINEARG="mikado compare ""${REF}"" --index; mikado compare ""${ARGS}"
echo ${CMDLINEARG};

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/mikado:v0.1.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments				= ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTS} launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0
