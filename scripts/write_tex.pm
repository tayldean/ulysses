#!/usr/bin/perl

use strict;
use warnings;

if ($#ARGV+1 == 1) {
    print $ARGV[0],"\n";
}
else {
    die "Expected 1 inputs to write_tex.pm, found ",$#ARGV+1;
}

my $file_tex = $ARGV[0];
my $file_dat = $file_tex;
$file_dat =~ s/tex$/dat/;
my $year;
my $competition;
if ($file_tex =~ /^results\/([0-9]+)_([a-zA-Z]+)\.tex/) {
    $year = $1;
    $competition = ucfirst($2);
}
else {
    die "Bad input file? $file_tex";
}

open FILE_TEX, ">", "$file_tex" or die "Unable to open >$file_tex";

my $tex = <<END;
\\documentclass{beamer}

\\usepackage{pgfplotstable}
\\usepackage{booktabs}

\\usetheme{Warsaw}
\\setbeamertemplate{caption}[numbered]
\\setbeamertemplate{navigation symbols}{}

\\begin{document}

\\title[$competition $year Results]{$competition $year Unofficial Team Standings}
%%\\author[Schuyler Eldridge,
%%  Boston University]{Schuyler Eldridge}

\\begin{frame}[t,fragile]{$competition $year Unofficial Team Standings}
  \\begin{table}
    \\centering
    \\setlength{\\tabcolsep}{1pt}
    \\vspace{-25pt}
    \\pgfplotstableset{
      every head row/.style={
        before row=\\toprule,
        after row=\\midrule,
        typeset cell/.code={
          \\ifnum\\pgfplotstablecol=\\pgfplotstablecols
          \\pgfkeyssetvalue{/pgfplots/table/\@cell content}{\\rotatebox{90}{\#\#1}\\\\}%
          \\else
          \\ifnum\\pgfplotstablecol=1
          \\pgfkeyssetvalue{/pgfplots/table/\@cell content}{\#\#1&}%
          \\else
          \\pgfkeyssetvalue{/pgfplots/table/\@cell content}{\\rotatebox{90}{\#\#1}&}%
          \\fi
          \\fi
        }
      },
      every last row/.style={after row=\\bottomrule}
    }

    \\pgfplotstabletypeset[
      column type=r,
      col sep=comma,
      columns/School/.style={string type},
      font=\\tiny,
    ]
                         {$file_dat}
  \\end{table}
\\end{frame}

\\end{document}
END

print FILE_TEX $tex;

close FILE_TEX;
