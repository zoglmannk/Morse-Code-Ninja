#!/usr/bin/perl

use strict;
use warnings;

# Usage:
# ./generate-jokes.pl > ../all-age-appropriate-jokes.txt
#
# ./render.pl -i all-age-appropriate-jokes.txt -s 15 17 20 22 25 28 30 35 40 45 -ss 1.2 -sm 2

open my $in, "<", "data/jokes-raw.txt";
my @lines = <$in>;
close $in;

my $line_num = 1;
my $joke_setup = "";
my $punchline = "";
my $count_practice_trials = 1;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line_num == 1 && $line =~ m/^Joke Setup:\s(.*)/) {
        $joke_setup = $1;
        $joke_setup =~ s/(\.|\?)/\\$1/g;
        $line_num += 1;
    } elsif ($line_num == 2 && $line =~ m/^Punchline:\s(.*)/) {
        $punchline = $1;
        $punchline =~ s/(\.|\?)/\\$1/g;
        $line_num = 1;

        print "{ $joke_setup } ^\n";
        print " $punchline ^\n";

        $count_practice_trials += 1;
    }

}

#print "Number of jokes: $count_practice_trials\n";