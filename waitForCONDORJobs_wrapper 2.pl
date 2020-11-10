#!/usr/bin/perl -w

use strict;

# Usage: waitForSGEQJobs.pl <verbose [1 or 0]> <delay in seconds in range 10-600> [job IDs]
#
#
# Takes as args a string of qsub job IDs and periodically monitors them. Once they all finish, it returns 0
#
# If any of the jobs go into error state, an error is printed to stderr and the program waits for the non-error
# jobs to finish, then returns 1
#

# Usual qstat format - check this at run time
# job-ID  prior   name       user         state submit/start at     queue                          slots ja-task-ID


# First thing to do is parse our input

my ($verbose, $delay, @jobIDs) = @ARGV;

# Check for user stupidity
if ($delay < 10) {
    print STDERR "Sleep period is too short, will poll queue once every 10 seconds\n";
    $delay = 10;
}
elsif ($delay > 3600) {
    print STDERR "Sleep period is too long, will poll queue once every 60 minutes\n";
    $delay = 3600;
}

print "  Waiting for " . scalar(@jobIDs) . " jobs: @jobIDs\n";

my $user=`whoami`;
my @qstatLines ;
my $qstatOutput ;
my $linecount=0 ;
my $timestamp="" ; #For debugging to make sure scope is right on current qstatOutput vars

my $lastline="" ;
#Put this in loop in case condor_q fails:
#until ($linecount > 0) { #need at least one real line
until ($lastline =~ "jobs") { #need at least one real line
	#my $qstatOutput = `qstat -u $user`;
	$qstatOutput = `condor_q @jobIDs`;
	print "Polling condor_q for jobs\n" ;

	if (!scalar(@jobIDs) || !$qstatOutput) {
	    # Nothing to do
		    exit 0;
	}

	@qstatLines = split("\n", $qstatOutput);
#	printf("Debug: %s lines in condor_q\n", $#qstatLines);
	shift @qstatLines ; # blank line
	shift @qstatLines ; # blank line
	$timestamp=shift @qstatLines ; # first is --Schedd line not real header
	printf("Debug: %s \n\n",$timestamp);
	$lastline = pop @qstatLines ; # last line is summary
	pop @qstatLines ; # blank line
	$linecount = $#qstatLines  ;
}

#No loops or matching needed, just regex:
#73 jobs; 0 completed, 0 removed, 33 idle, 40 running, 0 held, 0 suspended
# Now check on all of our jobs
#my $jobsIncomplete = 1;
my $jobsTotal = 0;
if ( $lastline =~ m/(\d+)\s+jobs;/ ) {
	$jobsTotal = $1 ;
}
#my $jobsTotal = ( $lastline =~ m/(\d+)\s+jobs;/ ) ;
printf("Debug: found %d total jobs\n",$jobsTotal);

my $jobsDone = 0;
if ( $lastline =~ m/(\d+)\s+completed,/ ) {
	$jobsDone = $1 ;
}
#my $jobsDone = ( $lastline =~ m/(\d+)\s+completed,/ ) ;
printf("Debug: found %d completed jobs\n",$jobsDone);

my $jobsIdle = 0;
if ( $lastline =~ m/(\d+)\s+idle,/ ) {
	$jobsIdle = $1 ;
}
printf("Debug: found %d waiting jobs\n",$jobsIdle);

my $jobsRunning = 0;
if ( $lastline =~ m/(\d+)\s+running,/ ) {
	$jobsRunning = $1 ;
}
printf("Debug: found %d running jobs\n",$jobsRunning);

my $jobsIncomplete=$jobsRunning + $jobsIdle ;
printf("Waiting for a total of %d idle or running jobs\n",$jobsIncomplete);
#my $jobsIncomplete = ( $lastline =~ m/(\d+)\s+idle,/ ) ;

# Set to 1 for any job in an error state
my $haveErrors = 0 ;
if ($lastline =~ m/(\d+)\s+held,(\d+)\s+suspended/) {
	$haveErrors = $1+$2 ;
	printf("Debug: Found %d held and %d suspended jobs\n",$1,$2);
}

printf("Debug: Found %d held or suspended jobs!\n\n", $haveErrors);

while ($jobsIncomplete) {

    # Jobs that are still showing up in qstat
    $jobsIncomplete = 0;
	# Use of backticks rather than system permits a ctrl+c to work
	`sleep $delay`;
	#$qstatOutput = `qstat -u $user`;
	#Put this in loop in case condor_q fails:
	#Put this in loop in case condor_q fails:
	#my $qstatOutput="" ; #blank this, so can use an until to make sure we get a readout, since sometimes condor_q brings back nothing!
	$qstatOutput="" ; #blank this, so can use an until to make sure we get a readout, since sometimes condor_q brings back nothing!
	until ($qstatOutput =~ "jobs") { #need at least one real line
		#my $qstatOutput = `qstat -u $user`;
		$qstatOutput = `condor_q @jobIDs`;
		print "Polling condor_q for jobs\n" ;

		if (!scalar(@jobIDs) || !$qstatOutput) {
		    # Nothing to do
			    exit 0;
		}

		@qstatLines = split("\n", $qstatOutput);
#		printf("Debug: %s lines in condor_q\n", $#qstatLines);
		shift @qstatLines ; # blank line
		shift @qstatLines ; # blank line
		$timestamp = shift @qstatLines ; # first is --Schedd line not real header
		printf("Debug: %s \n\n",$timestamp);
		$lastline = pop @qstatLines ; # last line is summary
		pop @qstatLines ; # blank line
		$linecount = $#qstatLines  ;
	}
	# Now check on all of our jobs
	#my $jobsIncomplete = 1;
	$jobsTotal = 0;
	if ( $lastline =~ m/(\d+)\s+jobs;/ ) {
		$jobsTotal = $1 ;
	}
	#my $jobsTotal = ( $lastline =~ m/(\d+)\s+jobs;/ ) ;
	printf("Debug: found %d total jobs\n",$jobsTotal);

	$jobsDone = 0;
	if ( $lastline =~ m/(\d+)\s+completed,/ ) {
		$jobsDone = $1 ;
	}
	#my $jobsDone = ( $lastline =~ m/(\d+)\s+completed,/ ) ;
	printf("Debug: found %d completed jobs\n",$jobsDone);

	$jobsRunning = 0;
	if ( $lastline =~ m/(\d+)\s+running,/ ) {
		$jobsRunning = $1 ;
	}

	printf("Debug: found %d running jobs\n",$jobsRunning);
	$jobsIdle = 0;
	if ( $lastline =~ m/(\d+)\s+idle,/ ) {
		$jobsIdle = $1 ;
	}
	printf("Debug: found %d waiting jobs\n",$jobsIdle);
	$jobsIncomplete=$jobsRunning + $jobsIdle ;
	#my $jobsIncomplete = ( $lastline =~ m/(\d+)\s+idle,/ ) ;
	printf("Waiting for a total of %d idle or running jobs\n",$jobsIncomplete);

	# Set to 1 for any job in an error state
	$haveErrors = 0 ;
	if ($lastline =~ m/(\d+)\s+held,(\d+)\s+suspended/) {
		$haveErrors = $1+$2 ;
		printf("Debug: Found %d held and %d suspended jobs\n",$1,$2);
	}

	if ($haveErrors) {
	    printf("Debug: Found %d held or suspended jobs!\n\n", $haveErrors);
	    print "  ERROR! FOUND JOBS THAT ARE HELD OR SUSPENDED, ABORTING...";
	    exit 1;
	}

}

if ($haveErrors) {
    print "  No more jobs to run - some jobs had errors\n\n";
    exit 1;
}
else {
    print "  No more jobs in queue\n\n";
    exit 0;
}




sub trim {

    my ($string) = @_;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}
