#! /bin/bash 

export ANTSPATH=$ANTSPATH/ ;
/bin/rm -f template_SY_test_2chan*nii.gz

#Notes: -a 2 would change the summary statistic to median of images (rather than mean of normalized intensities - default - or 0 for mean
# -g adjusts step size, which may help for finer details, but maybe not
#-k is the KEY to MULTIMODAL = # of modalities
#can feed in an array of weights via -w option
#-p will prepend pretty much any string, so if you really need something to run scripts on CONDOR, probably better to feed it in here than toy with the main shell script
#will have to play with CC metric radius, not clear if those are mm or voxels, I'll assume voxels for now
#THEY HAVE ARGUMENTS LIKE -v that could store requests for submit files if ever wanted to steal them
# when we get to the ponit of specifying -z targets, you do it by repeating not by entering an array?? per their instructions: For multiple modalities, specify -z modality1.nii.gz -z modality2.nii.gz...

command="nice -n 19 bash ./brendonsCONDORantsMultivariateTemplateConstruction.sh -d 3 -c 6 -i 4 -o template_SY_test_2chan -m CC -t SyN -n 0 -k 2 s2??abcd_axbig_resamp_N4_ave_*hyperedge.nii.gz";

echo $command ; eval $command ;
