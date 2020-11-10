#!/usr/bin/env bash
export HOME=/home/`whoami`

mkdir ants
mv ./antsApplyTransforms ants/

# tar xvzf ants_linux.tar.gz
chmod -R a=wrx ants
export PATH=$PWD/ants:$PATH

templateFile=`basename $1`
inputFile=`basename $2`
inputAffineEPItoT1=`basename $3`
inputAffineT1toTemplate=`basename $4` 
outputFile=`basename $5`

antsApplyTransforms -d 3 -i $inputFile -r $templateFile -o $outputFile -n Linear -t $inputAffineT1toTemplate -t $inputAffineEPItoT1
