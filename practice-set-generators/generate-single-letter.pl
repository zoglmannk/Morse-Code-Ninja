#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-letter.pl > single-letters.txt
# Delay 0.6 seconds

my $number_of_runs = 1600;

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
