#!/usr/bin/perl

# Used to specifically parse the 2012 mit results. Key things to look
# for:
#
# Event name: <TITLE>EVENT_NAME</TITLE>
# 
# Competitor: /<TR><TD>.+1">/
# 
# Points:
# 5 skaters: 5,4,3,2,1
# 4 skaters: 4,3,2,1
# 3 skaters: 3,2,1
# 2 skaters: 3,2
# 1 skater:  1
# Championship Jr/Sr FS and Int. Dance: +2 to all places
#
# TODO: Ties?

$filename = "corpus/2012_mit_results.html";

open FILE, "<", $filename or die "Unable to open $filename";

$num_found = 0;
@lines = <FILE>;
foreach (@lines){
    if ($_ =~ m/<TITLE>/){
	$placement = 0;
	$_ =~ s/<.+  //;
	$_ =~ s/<.+$//;
	print $_;
	$num_found++;
    }
    if ($_ =~ m/<TR><TD>.+1">/){
	$placement++;
	if ($_ =~ m/TIE/){
	    $tie = 1;
	}
	else{
	    $tie = 0;
	}
	if ($_ =~ m/Withdrawn/){
	    $_ =~ s/<.+1">//;
	    $_ =~ s/<.+$//;
	    print "  W,$_";
	}
	else{
	    $_ =~ s/<.+1">//;
	    $_ =~ s/<.+$//;
	    print "  $placement,$_";
	}
	if ($tie){
	    $placement--;
	}
    }
}
print "Found $num_found unique events\n";

close FILE;

