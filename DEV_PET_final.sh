ls r?????_time?_trim_swapped_norm_orig_masked.nii.gz | awk -F_masked.nii '{print "WarpImageMultiTransform 3 "$0" to592Template_"$1"_masked_combined.nii.gz -R /StudyDir/DEV/n592/DEVmean_in_592.nii.gz to592Template_"$1"combinedWarp.nii.gz"}' | bash

#concatenate trasnformations 
ls r?????_time1_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt DEV_time1"$1"Warp.nii.gz DEV_time1"$1"Affine.txt"}' | bash
#other thant time1 needs to edit 
ls r?????_time2_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt /StudyDir/DEV/morphometry_template/time2_registration/time2_to_time1_InverseWarp.nii.gz /StudyDir/DEV/morphometry_template/time2_registration/time2_to_time1_Affine.txt DEV_time2"$1"Warp.nii.gz DEV_time2"$1"Affine.txt"}' | bash
cd #time3 directory 
ls r?????_time3_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt /StudyDir/DEV/morphometry_template/time3_registration/time3_to_time1_InverseWarp.nii.gz /StudyDir/DEV/morphometry_template/time3_registration/time3_to_time1_Affine.txt DEV_time3"$1"Warp.nii.gz DEV_time3"$1"Affine.txt"}' | bash
cd ../time4
ls r?????_time4_trim_swapped_norm_orig.nii.gz | awk -F.nii '{print "ComposeMultiTransform 3 to592Template_"$1"combinedWarp.nii.gz -R /StudyDir/DEV/n592/meanT1_592.nii /StudyDir/DEV/n592/DEV_in_592Warp.nii.gz /StudyDir/DEV/n592/DEV_in_592Affine.txt /StudyDir/DEV/morphometry_template/time4_registration/time4_to_time1_InverseWarp.nii.gz /StudyDir/DEV/morphometry_template/time4_registration/time4_to_time1_Affine.txt DEV_time4"$1"Warp.nii.gz DEV_time4"$1"Affine.txt"}' | bash

cd /StudyDir/DEV/new_t1_final
#copy all pet files 
#flip the pet images 
ls *_pet.nii.gz | awk -F.nii.gz '{print "fslswapdim "$0" x y -z tmp/"$0""}' | awk
ls *_p*_pet.nii.gz | awk -F. '{print "3drefit -orient LIP "$0""}' | bash

cp /StudyDir/OF15/n20_new_analysis/createPETdag_bothnifti.sh ./
sh createPETdag_bothnifti.sh DEV_POP_in_592.nii.gz r?????_time?_trim_swapped_norm_orig_masked.nii.gz > DEV_pet_bothnifti.dag
condor_submit_dag DEV_pet_bothnifti.dag

#creat template mask
fslmaths DEV_POP_in_592.nii.gz -thr 0.001 DEV_POP_in_592_m.nii.gz

#Grand mean scaled and blur PET 
sh GrandMeanScale.sh toT1_r?????_time?_pet.nii
nedit GrandMeanScale.sh
ls *_GM.nii.gz | awk '{print "gunzip "$0""}' | bash
./Blur4mm.sh *pet_GM.nii
