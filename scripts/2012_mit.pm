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

$filename = "corpus/2012_mit_results.html";

open FILE, "<", $filename or die "Unable to open $filename";

$num_found = 0;
@lines = <FILE>;
foreach (@lines){
    chomp($_);
    if ($_ =~ m/<TITLE>/){
	$placement = 0;
        if ($_ =~ m/Championship/){
            $championship = 1;
        }
        else{
            $championship = 0;
        }
	$_ =~ s/<.+  //;
	$_ =~ s/<.+$//;
        $event_name = $_."\n";
	$events_found++;
        $num_skaters = 0;
        undef @skater_array;
    }
    if ($_ =~ m/<TR><TD>.+1">/){
        $num_skaters++;
	$placement++;
        $skater_string = "";
	if ($_ =~ m/TIE/){
	    $tie = 1;
            $old_placement = $old_placement;
            $actual_placement = $old_placement + 1;
        }
        else{
            $tie = 0;
            $old_placement = $placement;
            $actual_placement = $placement;
        }
        if ($_ =~ m/Withdrawn/){
             $skater_string .= "W,";
        }
        else{
            $skater_string .= $actual_placement.",";
        }
        $_ =~ s/<.+1">//;
        $_ =~ s/<.+$//;
        $skater_string .= $_;
        push @skater_array, $skater_string;
    }
# Hash all the data
    if ($_ =~ m/<H3>Panel/){
        $hash{$event_name} = '';
        foreach (@skater_array){
            $hash{$event_name} .= "  ".$_."\n";
        }
    }
}

foreach $event_name (sort keys %hash){
    print $event_name,$hash{$event_name};
}
print "Found $events_found unique events\n";

close FILE;

