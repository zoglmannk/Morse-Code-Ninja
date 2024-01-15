#!/usr/bin/perl

use strict;
use warnings;

# Usage:
# ./speed-racing-with-contextual-priming-converter.pl > ../easy-speed-racing-with-contextual-priming.txt
#
# ./render.pl -i test.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 1.3 --sc 1.7 --ss 1.5  --norepeat --nospoken --nocourtesytone --speedAdjustRegex 's/<speed1>/1/,s/<speed2>/1.3/'

#open my $in, "<", "data/easy-speed-racing-with-contextual-priming-raw.txt";
open my $in, "<", "data/difficult-speed-racing-with-contextual-priming-raw.txt";
my @lines = <$in>;
close $in;

my $line_num = 1;
my $context1 = "";
my $context2 = "";
my $answer = "";
my $is_first = 1;
my $count_practice_trials = 1;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line_num == 1 && $line =~ m/^General Context:\s(.*)/) {
        $context1 = $1;
        $context1 =~ s/(\.|\?)/\\$1/g;
        $line_num += 1;
    } elsif ($line_num == 2 && $line =~ m/^(More Specific Context|Additional General Context):\s(.*)/) {
        $context2 = $2;
        $context2 =~ s/(\.|\?)/\\$1/g;
        $line_num += 1;
    } elsif ($line_num == 3 && $line =~ m/^Answer:\s(.*)/) {
        $answer = $1;
        $answer =~ s/\.|\?//g;
        $line_num = 1;

        if($is_first == 1) {
            print "{ $context1 } ^\n";
            $is_first = 0;
        } else {
            print "<courtesyTone> ^\n";
            print "{ $context1 } ^\n";
        }
        print "<speed2> $answer ^\n";
        print "{ $context2 } ^\n";
        print "<speed1> $answer ^\n";
        print "{ $answer } ^\n";
        print "<speed2> $answer ^\n";

        $count_practice_trials += 1;
    }

}

#print "Number of practice trials: $count_practice_trials\n";