#!/bin/bash

#usage: createAntsApplyDag.sh TemplateFile AffineEPItoT1 ffineT1toTemplate condoroutputPath images 
#TemplateFile can include whole path and it can be either nifti of nii.gz, needs full path for EPI to T1 and T1 to template if not in current directory 
TemplateFile=$1
AffineEPItoT1=$2
AffineT1toTemplate=$3
Path=$4
OutputPrefix=$5
shift 5
MyImages=`ls $*`

TemplateImage=$TemplateFile
TemplateRoot=${TemplateFile##*/}
TemplateRoot=${TemplateRoot//\.nii/};
TemplateRoot=${TemplateRoot//\.gz/};

for Image in $MyImages
  do

    ImageRoot=${Image##*/}
    ImageRoot=${ImageRoot//\.hdr/};
    ImageRoot=${ImageRoot//\.img/};
    ImageRoot=${ImageRoot//\.nii/};
    ImageRoot=${ImageRoot//\.gz/};
    
    #ImageFile=$ImageRoot.nii
    
    JobName="toTemplate_"$TemplateRoot"_"$ImageRoot

    outputFile=${OutputPrefix}_$ImageRoot.nii.gz
    
        echo "Job $JobName go_antsApply.submit"
        echo "VARS $JobName templateFile=\"$TemplateImage\" inputFile=\"$Image\" inputAffineEPItoT1=\"$AffineEPItoT1\" inputAffineT1toTemplate=\"$AffineT1toTemplate\" outputFile=\"$outputFile\" Path=\"$Path\""

done

cp /StudyDir/SCRIPTS/ANTS/go_antsApply.submit $Path
cp /StudyDir/SCRIPTS/ANTS/go_antsApply.sh $Path
