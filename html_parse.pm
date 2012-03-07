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
        if ($_ =~ m/Withdrawn/){
             $skater_string .= "W,";
        }
        else{
            $skater_string .= $placement.",";
        }
        $_ =~ s/<.+1">//;
        $_ =~ s/<.+$//;
        $skater_string .= $_;
	if ($_ =~ m/TIE/){
	    $placement--;
        }
        push @skater_array, $skater_string;
    }
# Hash all the data
    if ($_ =~ m/<H3>Panel/){
        $hash{$event_name} = '';
        if ($num_skaters >= 5){
            $points = 5 + $championship * 2;
        }
        elsif ($num_skaters >= 4){
            $points = 4 + $championship * 2;
        }
        elsif ($num_skaters >= 2){
            $points = 3 + $championship * 2;
        }
        else {
            $points = 1 + $championship * 2;
        }
        foreach (@skater_array){
            $hash{$event_name} .= "  ".$_.",$points\n";
            if ($points > 0 + $championship*3){
                $points--;
            }
            else{
                $points = 0;
            }
        }
    }
}

foreach $event_name (sort keys %hash){
    print $event_name,$hash{$event_name};
}
print "Found $events_found unique events\n";

close FILE;

