Requirements  = ( OpSys == "LINUX" && Arch =="X86_64" )    

# Set some min requirements... memory in MB, disk in KB
request_cpus = 1
request_memory = 2G
request_disk = 200M
image_size = 90M


 notification = never
# getenv = True

Executable = go_ants_nifti.sh
Universe = vanilla
Log = $(Path)/$(outputFile)_go_ants.log
Error = $(Path)/$(outputFile)_go_ants.error
Output = $(Path)/$(outputFile)_go_ants.output

should_transfer_files = yes
when_to_transfer_output = ON_EXIT


transfer_input_files = /StudyDir/bin/antsApplyTransforms,$(templateFile),$(inputFile),$(inputAffineEPItoT1),$(inputAffineT1toTemplate)

transfer_output_files = $(outputFile)

Arguments = $(templateFile) $(inputFile) $(inputAffineEPItoT1) $(inputAffineT1toTemplate) $(outputFile)

Queue
