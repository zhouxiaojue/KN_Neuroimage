#!/bin/bash

#usage: templatefile t1image normalization(NL/L/R) condorerroroutputdirectory TemplateMaskFile this generate a single job dag file to to run alignment between t1 and template images 
TemplateFile=$1
T1Image=$2
Normalization=$3
Directory=$4
if [ $# -eq 5 ]; then
TemplateMaskFile=$5
cp -f $TemplateMaskFile ./
elif [ $# -gt 5 ]; then
echo "too much input arguments"
fi

cp -f $TemplateFile ./
cp -f $T1Image ./

TemplateImage=$TemplateFile
TemplateRootC=${TemplateFile##*/};
TemplateRoot=${TemplateRootC//\.nii/};
TemplateRoot=${TemplateRoot//\.gz/};

TemplateMaskImage=$TemplateMaskFile
TemplateMaskRootC=${TemplateMaskFile##*/};
TemplateMaskRoot=${TemplateMaskRootC//\.nii/};
TemplateMaskRoot=${TemplateMaskRoot//\.gz/};

ImageRootC=${T1Image##*/};
ImageRoot=${ImageRootC//\.nii/};
ImageRoot=${ImageRoot//\.gz/};

#ImageFile=$ImageRoot.nii
JobName="to"$TemplateRoot"_"$ImageRoot

outputFile=to"$TemplateRoot"_from_"$ImageRoot".nii.gz
affineFile="to"$TemplateRoot"_from_"$ImageRoot"Affine.txt"
warpFile="to"$TemplateRoot"_from_"$ImageRoot"Warp.nii.gz"
InverseWarp="to"$TemplateRoot"_from_"$ImageRoot"InverseWarp.nii.gz" 

if [ $Normalization = NL ];then

echo "Job $JobName go_ants_nifti_xiao.submit"
echo "VARS $JobName templateFile=\"$TemplateRootC\" inputFile=\"$ImageRootC\" outputFile=\"$outputFile\" outputAffine=\"$affineFile\" outputWarp=\"$warpFile\" Directory=\"$Directory\""

elif [ $Normalization = L ];then
echo "Job $JobName go_ants_nifti_L_xiao.submit"
echo "VARS $JobName templateFile=\"$TemplateRootC\" inputFile=\"$ImageRootC\" outputFile=\"$outputFile\" outputAffine=\"$affineFile\"  Directory=\"$Directory\""

elif [ $Normalization = R ];then
echo "Job $JobName go_ants_nifti_R_xiao.submit"
echo "VARS $JobName templateFile=\"$TemplateRootC\" inputFile=\"$ImageRootC\" outputFile=\"$outputFile\" outputAffine=\"$affineFile\" outputWarp=\"$warpFile\" outputInverseWarp=\"$InverseWarp\" Directory=\"$Directory\" templateMaskFile=\"$TemplateMaskRootC\" nativeMaskFile=\"mask_${ImageRootC}\""

fi
