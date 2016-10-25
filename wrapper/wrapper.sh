#!/bin/bash

ARGS=" ${reference} ${gff} ${list} ${scoring_file} ${junction_file} ${bt_file} ${con_full} ${con_labels} ${con_mode} ${con_scoring} ${all_strand_spec} ${con_strand_spec} ${ser_max_reg} ${ser_max_tseq} ${ser_discard} ${ser_log_lev} ${pick_monout} ${pick_prefix} ${pick_no_cds} ${pick_flank} ${pick_purge} ${pick_verbosity} ${pick_log_lev}"
#echo $ARGS
GFFU=(${gff})
GFFcomma=`echo ${gff} | sed -e 's/ /, /g'`
LISTU="${list}"
JUNCU="${junction_file}"
BTU="${bt_file}"
ORFSU="${orfs}"
ORFScomma=`echo ${ORFSU} | sed -e 's/ /, /g'`
MONOUTU="${pick_monout}"
REFU="${reference}"

CMDLINEARG=

#########
if [[ "${REFU}" =~ \.gz$ ]]
  then
    CMDLINEARG+="gunzip -c ${REFU} > ${REFU::-3} ; "
fi
CMDLINEARG+="gunzip -c ${BTU} > ${BTU::-3} ; "
REFU=`echo ${REFU} | sed -e  's/\.gz/ /'`
BTU=`echo ${BTU} | sed -e 's/\.gz/ /'`

##########configure step
CMDLINEARG+="mikado configure "
if [ -n "${LISTU}" ]
  then
    CMDLINEARG+="--list ${LISTU} "
  else
    CMDLINEARG+="--gff ${GFFcomma} "
fi
if [ -n "${JUNCU}" ]
  then
    CMDLINEARG+="--junctions ${JUNCU} "
fi
if [ -n "${BTU}" ]
  then
    CMDLINEARG+="-bt ${BTU} "
fi
CMDLINEARG+="${con_full} ${labels} ${all_strand_spec} ${con_strand_spec} ${con_mode} ${con_scoring} --reference ${REFU} configuration.yaml; "
echo "${CMDLINEARG}"

#########prepare step
CMDLINEARG+="mikado prepare -p 12 --json-conf configuration.yaml; "
echo "${CMDLINEARG}"

###########blast
if [ -n "${BTU}" ]
then
  CMDLINEARG+="makeblastdb -in ${BTU} -dbtype prot -parse_seqids > blast_prepare.log; "
  CMDLINEARG+="blastx "
  if [ -n "${max_target_seqs}" ]
    then
    CMDLINEARG+="-max_target_seqs ${max_target_seqs}"
  fi
  CMDLINEARG+=" -query mikado_prepared.fasta -outfmt 5 -db ${BTU} -evalue 0.000001 2> blast.log | sed '/^$/d' | gzip -c - > mikado.blast.xml.gz; "
fi
echo "${CMDLINEARG}"

###########serialise step
CMDLINEARG+="mikado serialise -p 12 --json-conf configuration.yaml --xml mikado.blast.xml.gz "
if [ -n "$ORFSU" ]
  then
    CMDLINEARG+="--orfs ${ORFSU}"
fi
CMDLINEARG+=" ${ser_discard} ${ser_max_reg} ${ser_log_lev} "
if [ -n "${BTU}" ]
  then
    CMDLINEARG+="--blast_targets ${BTU}"
fi
CMDLINEARG+="; "

##############pick step
CMDLINEARG+="mikado pick -p 12 --json-conf configuration.yaml --subloci_out mikado.subloci.gff3 ${pick_monout} ${pick_prefix} ${pick_no_cds} ${pick_flank} ${pick_purge} ${pick_verbosity} ${pick_log_lev};"

echo arguments are "${CMDLINEARG}"
INPUTSU="${reference}, ${GFFcomma}, ${list}, ${scoring_file}, ${junction_file}, ${bt_file}, ${ORFScomma}"


chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/mikado:v1.0 >> lib/condorSubmitEdit.htc ######
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

exit 0
