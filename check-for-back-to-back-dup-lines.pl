#!/usr/bin/perl

# Helpful utility for double checking input files that might contain back to back duplicate lines
# Usage: cat some-text-file.txt | ./check-for-back-to-back-dup-lines.pl

use warnings;
use strict;

my $prev_line = "";
my $num = 1;

while(<>) {
    my $line = $_;

    if($line eq $prev_line) {
        print "Duplicate line $num: $line";
    }

    $num++;
    $prev_line = $line;
}
