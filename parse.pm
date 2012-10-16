#!/usr/bin/perl

#$filename = "corpus/2012_mit_results.txt";
$filename = "corpus/2012_cornell_results.txt";
$results_dir = "./results";

chdir $results_dir or die "Directory",$results_dir,"not found!";
@files = sort(<*>);
chdir $files[scalar(@files)-1] or die "Directory",$files[scalar(@files)-1],"not found";
@files = sort(<*>);
foreach (@files){
    if ($_ =~ m/\.results$/){
        print "  Processing ",$_,"\n";
        
        $file_out = $_;
        $file_out =~ s/\..+$/\.out/;

        open FILE_RESULTS, "<", $_ or die "Unable to open $_";
        open FILE_OUT, ">", $file_out or die "Unable to open $_";

        @lines = <FILE_RESULTS>;

        foreach (@lines){
            $_ =~ s///;
            # Ignore line
            if ($_ =~ m/[#]+/){
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
            if ($event =~ m/Championship/ | $event =~ m/International/){
                $championship = 1;
            }
            else{
                $championship = 0;
            }
            # compute number of skaters
            foreach (@{$event_hash{$event}}){
# If the number of points awarded decreases as a result of a
# withdrawl, the commented out section below should be used.
                if ($_ !~ m/^[ ]+W,/){
                    $num_skaters++;
                }
                elsif ($num_skaters<5){
                    $num_skaters++;
                }
#                $num_skaters++;
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
                    if ($skater_count > 0){ # if this is not the first skater
                        $points_total = 0;
                        for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
                            chomp(@{$event_hash{$event}}[$i]);
                            $points_total += $points;
                            if (($points > 0 + $championship * 3) & 
                                !()){
                                $points --;
                            }
                            else {
                                $points = 0;
                            }
                        }
                        $points_total /= $tie_count;
                        for ($i = $skater_count - $tie_count; $i < $skater_count; $i++){
                            @{$event_hash{$event}}[$i] .= ",$points_total";
                            $school = @{$event_hash{$event}}[$i];
                            chomp($school);
                            $school =~ s/^[ ]+[0-9W]+,[a-zA-Z'\- ]+,//;
                            $school =~ s/,[0-9]+$//;
                            $skater = @{$event_hash{$event}}[$i];
                            chomp($skater);
                            $skater =~ s/^[ ]+[0-9W]+,//;
                            $skater =~ s/,.+$//;
                            $skater_start_hash{$skater} += 1;
                            $skater_school_hash{$skater} = $school;
                            $level = $event;
                            $level =~ s/^[a-zA-Z\- ]+-[ ]+//;
                            $level =~ s/[a-zA-Z\- ]+$//;
                            @{$level_starts{$school}}[$level] += 1;
                            if (@{$event_hash{$event}}[$i] !~ m/[ ]+W/){
                                $skater_point_hash{$skater} += $points_total;
                                $skater_withdrawl_hash{$skater} += 0;
                                $team_withdrawls{$school} += 0;
                                @{$level_points{$school}}[$level] += $points_total;
                                if ($event =~ m/Dance/){
                                    $dance_points{$school} += $points_total;
                                }
                                if ($event =~ m/Short/){
                                    $short_points{$school} += $points_total;
                                }
                                if ($event =~ m/Free/){
                                    if ($event =~ m/Championship/){
                                        $championship_points{$school} += $points_total;
                                    }
                                    else {
                                        $free_points{$school} += $points_total;
                                    }
                                }
                                if ($event =~ m/Team/){
                                    $team_points{$school} += $points_total;
                                }
                            }
                            else{
                                $skater_point_hash{$skater} += 0;
                                $skater_withdrawl_hash{$skater} += 1;
                                $team_withdrawls{$school} += 1;
                                @{$level_points{$school}}[$level] += 0;
                            }
                            if ($event =~ m/Dance/){
                                $dance_starts{$school} += 1;
                            }
                            if ($event =~ m/Short/){
                                $short_starts{$school} += 1;
                            }
                            if ($event =~ m/Free/){
                                if ($event =~ m/Championship/){
                                    $championship_starts{$school} += 1;
                                }
                                else {
                                    $free_starts{$school} += 1;
                                }
                            }
                            if ($event =~ m/Team/){
                                $team_starts{$school} += 1;
                            }
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
                $skater = @{$event_hash{$event}}[$i];
                chomp($skater);
                $skater =~ s/^[ ]+[0-9W]+,//;
                $skater =~ s/,.+$//;
                $school = @{$event_hash{$event}}[$i];
                chomp($school);
                $school =~ s/^.+,//;
                $level = $event;
                $level =~ s/^[a-zA-Z\- ]+-[ ]+//;
                $level =~ s/[a-zA-Z\- ]+$//;
                @{$level_starts{$school}}[$level] += 1;
                if (@{$event_hash{$event}}[$i] =~ m/[ ]+W/){
                    @{$event_hash{$event}}[$i] .= ",0";
                    $skater_point_hash{$skater} += 0;
                    $skater_withdrawl_hash{$skater} += 1;
                    $team_withdrawls{$school} += 1;
                    @{$level_points{$school}}[$level] += 0;
                }
                else{
                    @{$event_hash{$event}}[$i] .= ",$points_total";
                    $skater_point_hash{$skater} += $points_total;
                    $skater_withdrawl_hash{$skater} += 0;
                    $team_withdrawls{$school} += 0;
                    @{$level_points{$school}}[$level] += $points_total;
                    if ($event =~ m/Dance/){
                        $dance_points{$school} += $points_total;
                    }
                    if ($event =~ m/Short/){
                        $short_points{$school} += $points_total;
                    }
                    if ($event =~ m/Free/){
                        if ($event =~ m/Championship/){
                            $championship_points{$school} += $points_total;
                        }
                        else {
                            $free_points{$school} += $points_total;
                        }
                    }
                    if ($event =~ m/Team/){
                        $team_points{$school} += $points_total;
                    }
                }
                $skater_start_hash{$skater} += 1;
                $skater_school_hash{$skater} = $school;
                if ($event =~ m/Dance/){
                    $dance_starts{$school} += 1;
                }
                if ($event =~ m/Short/){
                    $short_starts{$school} += 1;
                }
                if ($event =~ m/Free/){
                    if ($event =~ m/Championship/){
                        $championship_starts{$school} += 1;
                    }
                    else {
                        $free_starts{$school} += 1;
                    }
                }
                if ($event =~ m/Team/){
                    $team_starts{$school} += 1;
                }
            }
        }

        print FILE_OUT "---------------------------------------- Event Results\n";
        foreach $event_name (sort keys %event_hash){
            print FILE_OUT $event_name."\n";
            foreach (@{$event_hash{$event_name}}){
                print FILE_OUT $_."\n";
            }
        }

        foreach $event_name (sort keys %event_hash){
            foreach (@{$event_hash{$event_name}}){
                $school = $_;
                $school =~ s/^[ ]+[0-9W]+,[a-zA-Z-'. ]+,//;
                $school =~ s/,$//;
                $points = $school;
                $school =~ s/,.+//;
                $points =~ s/^.+,//;
                $total_hash{$school} += $points;
                $total_starts_hash{$school} += 1;
                $event_hash_total{$event_name}{$school} += $points;
                $starts_hash{$event_name}{$school} += 1;
            }
        }

        print FILE_OUT "---------------------------------------- Skater Results\n";
        print FILE_OUT "Skater,School,Points,Starts,Withdrawls,Points/Start\n";
        foreach $school (sort {$skater_school_hash{$a} <=> $skater_school_hash{$b}} keys %skater_school_hash){
            foreach $skater (sort {$skater_point_hash{$b} <=> $skater_point_hash{$a}} keys %skater_point_hash){
                if ($skater_school_hash{$skater} eq $school) {
                    print FILE_OUT $skater,",",$skater_school_hash{$skater},",",$skater_point_hash{$skater},",",$skater_start_hash{$skater},",",$skater_withdrawl_hash{$skater},",",sprintf("%0.2f",$skater_point_hash{$skater}/$skater_start_hash{$skater}),"\n";
                }
            }
        }

        print FILE_OUT "---------------------------------------- Team Points & Starts\n";
        print FILE_OUT "School,Points,Starts,Withdrawls,Points/Start\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
            print FILE_OUT $school,",",$total_hash{$school},",",$total_starts_hash{$school},",",$team_withdrawls{$school},",",sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school}),"\n";
            print "    ",$school,",",$total_hash{$school},",",$total_starts_hash{$school},",",sprintf("%0.2f",$total_hash{$school}/$total_starts_hash{$school}),"\n";
        }

#foreach $school_name (sort keys %total_hash){
#    print $school_name,",",$total_hash{$school_name},"\n";
#}

        print FILE_OUT "---------------------------------------- Team Starts by Event\n";
        print FILE_OUT "School,Dance,Short,Free,Chapmionship,Team\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
            if ($dance_starts{$school}){$a=",$dance_starts{$school}";}else{$a=",0";}
            if ($short_starts{$school}){$b=",$short_starts{$school}";}else{$b=",0";}
            if ($free_starts{$school}){$c=",$free_starts{$school}";}else{$c=",0";}
            if ($championship_starts{$school}){$d=",$championship_starts{$school}";}else{$d=",0";}
            if ($team_starts{$school}){$e=",$team_starts{$school}";}else{$e=",0";}
            print FILE_OUT $school,$a,$b,$c,$d,$e,"\n";
        }

        print FILE_OUT "---------------------------------------- Team Points by Event\n";
        print FILE_OUT "School,Dance,Short,Free,Chapmionship,Team\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
            if ($dance_points{$school}){$a=",$dance_points{$school}";}else{$a=",0";}
            if ($short_points{$school}){$b=",$short_points{$school}";}else{$b=",0";}
            if ($free_points{$school}){$c=",$free_points{$school}";}else{$c=",0";}
            if ($championship_points{$school}){$d=",$championship_points{$school}";}else{$d=",0";}
            if ($team_points{$school}){$e=",$team_points{$school}";}else{$e=",0";}
            print FILE_OUT $school,$a,$b,$c,$d,$e,"\n";
        }

        print FILE_OUT "---------------------------------------- Team Points/Start by Event\n";
        print FILE_OUT "School,Dance,Short,Free,Chapmionship,Team\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
            if ($dance_points{$school} && $dance_starts{$school}){
                $a=sprintf(",%0.2f",$dance_points{$school}/$dance_starts{$school});}else{$a=",0";}
            if ($short_points{$school} && $short_starts{$school}){
                $b=sprintf(",%0.2f",$short_points{$school}/$short_starts{$school});}else{$b=",0";}
            if ($free_points{$school} && $free_starts{$school}){
                $c=sprintf(",%0.2f",$free_points{$school}/$free_starts{$school});}else{$c=",0";}
            if ($championship_points{$school} && $championship_starts{$school}){
                $d=sprintf(",%0.2f",$championship_points{$school}/$championship_starts{$school});}else{$d=",0";}
            if ($team_points{$school} && $team_starts{$school}){
                $e=sprintf(",%0.2f",$team_points{$school}/$team_starts{$school});}else{$e=",0";}
            print FILE_OUT $school,$a,$b,$c,$d,$e,"\n";
        }

        print FILE_OUT "---------------------------------------- Team Starts by Level\n";
        print FILE_OUT "School,Lv1,Lv2,Lv3,Lv4,Lv5,Lv6,Lv7,Lv8\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){        
            print FILE_OUT $school;
            for ($level = 1; $level < 9; $level ++){
                if (@{$level_starts{$school}}[$level]){
                    print FILE_OUT ",",@{$level_starts{$school}}[$level];
                }
                else{
                    print FILE_OUT ",0";
                }
            }
            print FILE_OUT "\n";
        }

        print FILE_OUT "---------------------------------------- Team Points by Level\n";
        print FILE_OUT "School,Lv1,Lv2,Lv3,Lv4,Lv5,Lv6,Lv7,Lv8\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){        
            print FILE_OUT $school;
            for ($level = 1; $level < 9; $level ++){
                if (@{$level_points{$school}}[$level]){
                    print FILE_OUT ",",@{$level_points{$school}}[$level];
                }
                else{
                    print FILE_OUT ",0";
                }
            }
            print FILE_OUT "\n";
        }

        print FILE_OUT "---------------------------------------- Team Points/Start by Level\n";
        print FILE_OUT "School,Lv1,Lv2,Lv3,Lv4,Lv5,Lv6,Lv7,Lv8\n";
        foreach $school (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){        
            print FILE_OUT $school;
            for ($level = 1;$level < 9;$level++){
                if (@{$level_starts{$school}}[$level]){
                    print FILE_OUT sprintf(",%0.2f",@{$level_points{$school}}[$level]/@{$level_starts{$school}}[$level]);
                }
                else {
                    print FILE_OUT ",0.00";
                }
            }
            print FILE_OUT "\n";
        }

        print FILE_OUT "---------------------------------------- Event Points\n";
        foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
            print FILE_OUT ",",$school_name;
        }

        foreach $event_name (sort keys %event_hash){
            print FILE_OUT "\n",$event_name;
            foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
                $points = 0;
                foreach $skater_info (@{$event_hash{$event_name}}){
                    if ($skater_info =~ m/$school_name/){
                        $points = $event_hash_total{$event_name}{$school_name};
                    }
                }
                print FILE_OUT ",",$points;
            }
        }

        print FILE_OUT "\n";
        foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
            print FILE_OUT ",",$school_name;
        }

        foreach $event_name (sort keys %event_hash){
            print FILE_OUT "\n",$event_name;
            foreach $school_name (sort {$total_hash{$b} <=> $total_hash{$a}} keys %total_hash){
#                print $school_name,": ",$starts_hash{$event_name}{$school_name},"\n";
                if ($starts_hash{$event_name}{$school_name}!=0){
                    print FILE_OUT ",",$starts_hash{$event_name}{$school_name};
                }
                else{
                    print FILE_OUT ",0";
                }
            }
        }
    }
    else {
        print "  Skipping   ",$_,"\n";
    }
    close FILE_RESULTS;
    close FILE_OUT;
}


