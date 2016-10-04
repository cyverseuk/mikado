#!/bin/bash

FILELIST=`ls [!\_]*`
#echo ${FILELIST}
eval "$@"
mkdir output
rm ${FILELIST}
mv [!\_]* output/
