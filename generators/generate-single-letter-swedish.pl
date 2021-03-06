#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-letter-swedish.pl > Single-Letters-Swedish.txt
# Delay 0.6 seconds and 0.5 between repeat and next

my $number_of_runs = 1600;

my @letters = ('A'..'Z', 'Å', 'Ä', 'Ö');

my $previous_letter = "";
for(my $i=0; $i<$number_of_runs; $i++) {
    my $random_letter = "";
    while($random_letter eq "" || $random_letter eq $previous_letter) {
     $random_letter = $letters[int rand @letters];
    }
    print "$random_letter [$random_letter]^\n";
}