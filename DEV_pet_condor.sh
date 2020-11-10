#copy tempalte to processing directory 
timept=$1
cd /StudyDir/DEV/${timept}
cp /StudyDir/DEV/n592/DEVmean_in_592.nii.gz ./
cp /StudyDir/DEV/pet/go_pet_toT1_xiao.submit ./
cp /StudyDir/DEV/pet/go_pet_toT1.sh ./

ls *_pet.nii | awk '{print "gzip "$0""}' | bash
mkdir condor_output
vim ImageRoot.txt
condor_submit go_pet_toT1_xiao.submit


