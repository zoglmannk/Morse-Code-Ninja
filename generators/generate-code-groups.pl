#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-code-groups.pl > code-groups.txt
# Delay 2.5 seconds
# ./render.pl -i code-groups.txt -s 15 20 22 25 28 30 35 40 45 50 --sm 2.5

my $number_of_runs = 2000;
my $code_group_size = 5;

my @letters = ('A'..'Z');

for(my $i=0; $i<$number_of_runs; $i++) {
    my $pronounce = "";
    for(my $j=0; $j<$code_group_size; $j++) {
        if($j!=0) {
            $pronounce .= ", ";
        }
        $pronounce .= $letters[int rand @letters];
    }
    my $code = $pronounce;
    $code =~ s/,|\s//g;

    print "$code [$pronounce]^\n";
}
