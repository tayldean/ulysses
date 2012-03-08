#!/usr/bin/perl

# Do withdrawls affect the number of points that are awarded?

#$filename = "corpus/2012_mit_results.txt";
$filename = "corpus/2012_cornell_results.txt";

open FILE, "<", $filename or die "Unable to open $filename";

@lines = <FILE>;

foreach (@lines){
    # Ignore line
    if ($_ =~ m/###/){
    }
    # Line is a group
    elsif ($_ =~ m/^[a-zA-Z]/){
        chomp($_);
        $event_name = $_;
    }
    # Line is a skater
    else{
        push @{$event_hash{$event_name}}, $_;
    }
}

foreach $event (sort keys %event_hash){
    $num_skaters = 0;
    # check for championship event
    if ($event =~ m/Championship/){
        $championship = 1;
    }
    else{
        $championship = 0;
    }
    # compute number of skaters
    foreach (@{$event_hash{$event}}){
# If the number of points awarded decreases as a result of a
# withdrawl, the commented out section below should be used.
        # if ($_ !~ m/^  W,/){
        #     $num_skaters++;
        # }
        $num_skaters++;
    }
    # compute starting point value
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
    # compute tie array
    $old_placement = 0;
    $skater_count = 0;
    $tie_count = 1;
    foreach (@{$event_hash{$event}}){
        if ($_ =~ m/($old_placement)/){
            $tie_count++;
        }
        else {
            $old_placement++;
            if ($skater_count > 0){
                $points_total = 0;
                for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
                    chomp(@{$event_hash{$event}}[$i]);
                    $points_total += $points;
                    if ($points > 0 + $championship * 3){
                        $points --;
                    }
                    else {
                        $points = 0;
                    }
                }
                $points_total /= $tie_count;
                for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
                    @{$event_hash{$event}}[$i] .= ",$points_total";
                }
                $tie_count = 1;
            }
        }
        $skater_count++;
    }
    # last place skater handling
    $points_total = 0;
    for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
        chomp(@{$event_hash{$event}}[$i]);
        $points_total += $points;
        if ($points > 0 + $championship * 3){
            $points --;
        }
        else {
            $points = 0;
        }
    }
    $points_total /= $tie_count;
    for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
        @{$event_hash{$event}}[$i] .= ",$points_total";
    }
}

foreach $event_name (sort keys %event_hash){
    print $event_name."\n";
    foreach (@{$event_hash{$event_name}}){
        print $_."\n";
    }
}

foreach $event_name (sort keys %event_hash){
    foreach (@{$event_hash{$event_name}}){
        $school = $_;
        $school =~ s/^  [0-9W]+,[a-zA-Z-'. ]+,//;
        $points = $school;
        $school =~ s/,.+//;
        $points =~ s/^.+,//;
        $total_hash{$school} += $points;
        $event_hash_total{$event_name}{$school} += $points;
    }
}

foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
    print $school_name,",",$total_hash{$school_name},"\n";
}

#foreach $school_name (sort keys %total_hash){
#    print $school_name,",",$total_hash{$school_name},"\n";
#}

foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
    print ",",$school_name;
}

foreach $event_name (sort keys %event_hash){
    print "\n",$event_name;
    foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
        $points = 0;
        foreach $skater_info (@{$event_hash{$event_name}}){
            if ($skater_info =~ m/$school_name/){
                $points = $event_hash_total{$event_name}{$school_name};
            }
        }
        print ",",$points;
    }
}
