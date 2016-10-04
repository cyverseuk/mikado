#!/bin/bash

ARGS=" ${reference} ${targets} ${prediction} ${distance} ${protein_coding} ${lenient} ${exclude_utr} ${verbose} -l compare.log"
#echo $ARGS

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
echo arguments are "${CMDLINEARG}"
REF=(${REF})
INPUTS="${REF[@]:1}, ${prediction}"
echo inputs are "${INPUTS}"

chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/mikado:v1.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTS}, launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = output/compare.log, output/mikado_compare.refmap, output/mikado_compare.stats, output/mikado_compare.tmap, output/${REF[@]:1}.midx >> lib/condorSubmitEdit.htc

cat /mnt/data/rosysnake/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0

