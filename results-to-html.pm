#!/usr/bin/perl

use strict;
use warnings;

sub usage() {
    my $usage = <<"END";
Usage: ./results-to-html.pm [INPUT SCORES FILE] [OUTPUT HTML FILE]
END
}

if ($#ARGV != 1) {
    usage();
    die "[ERROR] Incorrect number of command line arguments";
}

my $file_scores = $ARGV[0];
my $file_html = $ARGV[1];

open FILE_SCORES, "<", $file_scores or die "Unable to open <$file_scores";
open FILE_HTML, ">", $file_html or die "Unable to open >$file_html";

# HTML boilerplat
my $boilerplate_header = <<"END";
<!DOCTYPE html>
<html>
<head>
<title>Ulysses Results</title>
</head>
<body>
<table border="1">
END
my $boilerplate_footer = <<"END";
</table>
</body>
</html>
END

print FILE_HTML $boilerplate_header;

my $found_team_results = 0;
while (<FILE_SCORES>) {
    # Skip comments
    if ($_ =~ m/^#/) {
        next;
    }


    # Match that we've hit the team points and starts
    if ($_ =~ m/Team Points & Starts/) {
        $found_team_results = 1;
        next;
    }

    # If we haven't found the team results then goto the next line
    if (!$found_team_results) {
        next;
    }

    chomp($_);
    if ($_ =~ m/^School/) {
        print FILE_HTML "<tr>";
        foreach my $line (split(",", $_)) {
            print FILE_HTML "<th>$line</th>";
        }
        print FILE_HTML "</tr>\n";
        next;
    }

    $_ =~ s/^ *//;
    print FILE_HTML "<tr>";
    foreach my $line (split(",", $_)) {
        print FILE_HTML "<td>$line</td>";
    }
    print FILE_HTML "</tr>\n";
}

print FILE_HTML $boilerplate_footer;
close FILE_SCORES;
close FILE_HTML;
