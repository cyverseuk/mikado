#!/bin/bash

rmthis=`ls`
echo ${rmthis}

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
echo ${CMDLINEARG};
echo running docker now

docker run -v `pwd`:/data cyverseuk/mikado:v1.0 /bin/bash -c "${CMDLINEARG}";

rmthis=`echo ${rmthis} | sed s/.*\.out// -`
rmthis=`echo ${rmthis} | sed s/.*\.err// -`
rm --verbose ${rmthis}

exit 0
