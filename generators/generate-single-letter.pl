#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-letter.pl > single-letters.txt
# Delay 0.6 seconds
#
# Rapid-Fire
# ./render.pl -i single-letters-rapid-fire.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 0.2 -sv 0.3 -ss 0.3
#
# Mind Melt
# ./render.pl -i single-letters-mind-melt.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nocourtesytone -ss 0.2 -sm 0.2 -sv 0.2

my $number_of_runs = 5000;

my @letters = ('A'..'Z');

my $previous_letter = "";
for(my $i=0; $i<$number_of_runs; $i++) {
    my $random_letter = "";
    while($random_letter eq "" || $random_letter eq $previous_letter) {
     $random_letter = $letters[int rand @letters];
    }
    $previous_letter = $random_letter;
    print "$random_letter [$random_letter]^\n";
}
