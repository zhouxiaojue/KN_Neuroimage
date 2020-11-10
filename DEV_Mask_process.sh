
#make txt files with all subject.scandate(yearmonthdate,no space)
#change timepoint in the script
timepoint=time2
cd /StudyDir/DEV/${timepoint}
#####NEED TO GET SUBJECT AND SCANDATE TXT READY
sh copy_files_auto.sh
fslmerge -t t1_merge r?????_time?.nii
#check image find size of roi and find the initial reference point 
#######NEED TO CHOOSE FRAME SIZE
ls r?????_time?.nii | awk -F. '{print "fslroi "$0" "$1"_trim.nii.gz 117 160 114 143 117 145"}' | bash
ls r?????_time?_trim.nii.gz | awk '{print "3dinfo "$0""}' | bash #check if all orientations in headers are the same
ls r?????_time?_trim.nii.gz | awk '{print "3drefit -orient IAR "$0""}' | bash #make sure headers are the same
ls r?????_time?_trim.nii.gz | awk -F. '{print "fslswapdim "$0" z x -y "$1"_swapped.nii.gz"}' | bash
#check one of these to make sure the orientation is right 

#Scale image
ls r?????_time?_trim_swapped.nii.gz | awk -F. '{print "ImageMath 3 "$1"_norm.nii.gz Normalize "$0""}' | bash
#Set origin
ls r?????_time?_trim_swapped_norm.nii.gz | awk -F. '{print "SetOrigin 3 "$0" "$1"_orig.nii.gz 0 0 0"}' | bash
#chose one r16090_time2_trim_swapped_norm_orig.nii.gz as initial template
########NEED TO CHANGE AND CHOSE ONE IMAGE
buildtemplateparallel.sh -d 3 -c 2 -j 9 -m 1x0x0 -o DEV_${timepoint}_initial -z r16090_time2_trim_swapped_norm_orig.nii.gz r?????_time?_trim_swapped_norm_orig.nii.gz
rm DEV_${timepoint}_initialr*
rm -R GR_iteration_?
rm *.cfg

#actually building template 
buildtemplateparallel.sh -d 3 -c 2 -j 7 -m 30x50x20 -o DEV_${timepoint} -z DEV_${timepoint}_initialtemplate.nii.gz r?????_time?_trim_swapped_norm_orig.nii.gz &> dump_0110.txt
#note buildtemplate use CC[1,4] -SyN

#set manually drawn mask
template_mask=DEV_time3template_m.nii.gz
#3drefit -orient need to change orientations if doesn't work 
ls r?????_time?_trim_swapped_norm_orig.nii.gz | awk -F. '{print "WarpImageMultiTransform 3 DEV_time4template_m.nii.gz "$1"_m.nii.gz -R "$0" -i DEV_time4"$1"Affine.txt DEV_time4"$1"InverseWarp.nii.gz"}' | bash
#Smooth out mask by thresholding everything below 0.5
ls r?????_time?_trim_swapped_norm_orig_m.nii.gz | awk -F. '{print "fslmaths "$0" -thr 0.5 -dilM -bin -ero "$1"_thr_bin.nii.gz"}' | bash

#after hand corrected mask in mask_cleanup copy them over and binarize/erode 
#threshold, dilute binarize and erode masks
mkdir mask_cleanup
ls r?????_time?_trim_swapped_norm_orig_m_thr_bin.nii.gz | awk -F. '{print "fslchfiletype ANALYZE "$0" mask_cleanup/"$1".img"}' | bash
ls r?????_time?_trim_swapped_norm_orig.nii.gz | awk -F. '{print "fslchfiletype ANALYZE "$0" mask_cleanup/"$1".img"}' | bash

#align Doug generated DEV template to 592 space 
ANTS 3 -m MI[meanT1_592.nii,DEV_meanTemplate.nii.gz,1,32] -o DEV_in_592 -i 10x10x0 -r Gauss[1.5,0] -t Exp[0.5]

#get masked T1
cd /StudyDir/DEV/time1/mask_cleanup
#ls r?????_time1_trim_swapped_norm_orig_m_thr.hdr | awk '{print "fslchfiletype NIFTI "$0""}' | bash
#fslmaths r16055_time1_trim_swapped_norm_orig.nii.gz -mas /StudyDir/DEV/time1/mask_cleanup/r16055_time1_norm_trim_swapped_norm_orig_m_thr.img r16055_time1_trim_swapped_norm_orig_masked.nii.gz
#looks fine 
ls r?????_time?_trim_swapped_norm_orig.nii.gz | awk -F. '{print "fslmaths "$0" -mas "$1"_m_thr_bin.nii.gz "$1"_masked.nii.gz"}' | bash
ls r?????_time?_trim_swapped_norm_orig_masked.nii.gz | awk -F_masked.nii '{print "WarpImageMultiTransform 3 "$0" to592Template_"$1"_masked_combined.nii.gz -R /StudyDir/DEV/n592/DEVmean_in_592.nii.gz to592Template_"$1"combinedWarp.nii.gz"}' | bash

#concatenate trasnformations 
ls r?????_time1_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt DEV_time1"$1"Warp.nii.gz DEV_time1"$1"Affine.txt"}' | bash
#other thant time1 needs to edit 
ls r?????_time2_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt /StudyDir/DEV/morphometry_template/time2_registration/time2_to_time1_InverseWarp.nii.gz /StudyDir/DEV/morphometry_template/time2_registration/time2_to_time1_Affine.txt DEV_time2"$1"Warp.nii.gz DEV_time2"$1"Affine.txt"}' | bash
cd #time3 directory 
ls r?????_time3_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt /StudyDir/DEV/morphometry_template/time3_registration/time3_to_time1_InverseWarp.nii.gz /StudyDir/DEV/morphometry_template/time3_registration/time3_to_time1_Affine.txt DEV_time3"$1"Warp.nii.gz DEV_time3"$1"Affine.txt"}' | bash
cd ../time4
ls r?????_time4_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt /StudyDir/DEV/morphometry_template/time4_registration/time4_to_time1_InverseWarp.nii.gz /StudyDir/DEV/morphometry_template/time4_registration/time4_to_time1_Affine.txt DEV_time4"$1"Warp.nii.gz DEV_time4"$1"Affine.txt"}' | bash

