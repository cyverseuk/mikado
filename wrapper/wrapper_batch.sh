#!/bin/bash

rmthis=`ls`
echo ${rmthis}

ARGS=" ${reference} ${gff} ${list} ${scoring_file} ${junction_file} ${bt_file} ${con_full} ${con_labels} ${con_mode} ${con_scoring} ${all_strand_spec} ${con_strand_spec} ${ser_max_reg} ${ser_max_tseq} ${ser_discard} ${ser_log_lev} ${pick_monout} ${pick_prefix} ${pick_no_cds} ${pick_flank} ${pick_purge} ${pick_verbosity} ${pick_log_lev}"
#echo $ARGS
GFF=(${gff})
GFFcomma=`for el in ${GFF}; do echo ${el}", ";done`
LIST="${list}"
JUNC="${junction_file}"
BT="${bt_file}"
ORFS="${orfs}"
MONOUT="${pick_monout}"
REF="${reference}"

CMDLINEARG=

#########
if [[ "${REF}" =~ \.gz$ ]]
  then
    CMDLINEARG+="gunzip -c ${REF} > ${REF::-3} ; "
fi
CMDLINEARG+="gunzip -c ${BT} > ${BT::-3} ; "
REF=`echo ${REF} | sed -e  's/\.gz/ /'`
BT=`echo ${BT} | sed -e 's/\.gz/ /'`

##########configure step
CMDLINEARG+="mikado configure "
if [ -n "${LIST}" ]
  then
    CMDLINEARG+="--list ${LIST} "
  else
    CMDLINEARG+="--gff ${GFFcomma} "
fi
if [ -n "${JUNC}" ]
  then
    CMDLINEARG+="--junctions ${JUNC} "
fi
if [ -n "${BT}" ]
  then
    CMDLINEARG+="-bt ${BT} "
fi
CMDLINEARG+="${con_full} ${labels} ${all_strand_spec} ${con_strand_spec} ${con_mode} ${con_scoring} --reference ${REF} configuration.yaml; "
echo "${CMDLINEARG}"

#########prepare step
CMDLINEARG+="mikado prepare --json-conf configuration.yaml; "
echo "${CMDLINEARG}"

###########blast
if [ -n "${BT}" ]
then
  CMDLINEARG+="makeblastdb -in ${BT} -dbtype prot -parse_seqids > blast_prepare.log; "
  CMDLINEARG+="blastx "
  if [ -n "${max_target_seqs}" ]
    then
    CMDLINEARG+="-max_target_seqs ${max_target_seqs}"
  fi
  CMDLINEARG+=" -query mikado_prepared.fasta -outfmt 5 -db ${BT} -evalue 0.000001 2> blast.log | sed '/^$/d' | gzip -c - > mikado.blast.xml.gz; "
fi
echo "${CMDLINEARG}"

###########serialise step
CMDLINEARG+="mikado serialise --json-conf configuration.yaml --xml mikado.blast.xml.gz "
if [ -n "$ORFS" ]
  then
    CMDLINEARG+="--orfs ${ORFS}"
fi
CMDLINEARG+="${ser_log_lev} ${ser_discard} ${ser_max_reg} ${ser_log_lev} "
if [ -n "${BT}" ]
  then
    CMDLINEARG+="--blast_targets ${BT}"
fi
CMDLINEARG+="; "

##############pick step
CMDLINEARG+="mikado pick --json-conf configuration.yaml --subloci_out mikado.subloci.gff3 ${pick_monout} ${pick_prefix} ${pick_no_cds} ${pick_flank} ${pick_purge} ${pick_verbosity} ${pick_log_lev};"

echo ${CMDLINEARG};
echo running docker now

docker run -v `pwd`:/data cyverseuk/mikado:v1.0 /bin/bash -c "${CMDLINEARG}";

rmthis=`echo ${rmthis} | sed s/.*\.out// -`
rmthis=`echo ${rmthis} | sed s/.*\.err// -`
rm --verbose ${rmthis}

exit 0

