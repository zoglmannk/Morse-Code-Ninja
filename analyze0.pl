#!/usr/bin/perl

use strict;
use warnings;

my $previous;
while(<>) {
    my $in = $_;
    chomp($in);

    if(defined $previous) {
        print "$previous to $in\n";
    }

    $previous = $in;
}