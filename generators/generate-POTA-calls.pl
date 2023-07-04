#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Cwd;

# Usage:
#cat data/pota-top-activators-2023.txt | ./generate-POTA-calls.pl > ../pota-activator-callsigns.txt
#cat data/pota-top-hunters-2023.txt | ./generate-POTA-calls.pl > ../pota-top-hunter-callsigns-2023.txt
#
# ./render.pl -i pota-activator-callsigns.txt -s 15 17 20 22 25 28 30 35 40 45 50 -sm 2.5

my @pota_calls;
my $repeat = 1;


while(<>) {

    my $entry = $_;
    if($entry =~ m/^\s*([A-Za-z0-9]+)\s*?$/) {
        my $call = $1;
        push @pota_calls, $call;
        #print "OKAY with $call\n";
    } else {
        #print "problem with $entry\n";
    }

}

my $top_x_calls = scalar @pota_calls;
my $num_random_calls = 1500; #$top_x_calls * 1;

my %prev_picked = ();

sub pick_uniq_call_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($top_x_calls));

        if(scalar keys %prev_picked >= $top_x_calls) {
            %prev_picked = ();
        }


        if(!defined $prev_picked{$next_pick} || $prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

sub get_pronouncable_call {
    my $call = $_[0];
    my $ret = "";
    my $is_first = 1;
    my $was_natural_pause = 0;

    for my $c (split //, $call) {
        if($c eq "0") {
            $c = "zero";
        } elsif($c eq "/") {
            $c = "slash";
        }

        if($is_first == 1) {
            $is_first = 0;
            $ret = $c;
        } elsif ($c =~ m/[0-9]|zero|slash/) {
            if($was_natural_pause == 1) {
                $ret = $ret . ", " . $c;
            } else {
                $ret = $ret . " " . $c;
            }

            $was_natural_pause = 1;
        } elsif ($was_natural_pause == 1) {
            $was_natural_pause = 0;
            $ret = $ret . ", " . $c;
        } else {
            $ret = $ret . " " . $c;
        }
    }

    return $ret;
}

for (my $i=0; $i < $num_random_calls; $i++) {
    my $random_call_index = pick_uniq_call_index();
    my $prouncable_call = get_pronouncable_call($pota_calls[$random_call_index]);

    if($repeat == 1) {
        print "$pota_calls[$random_call_index] [$prouncable_call] ^\n";
    } else {
        my $repeated_word = "$pota_calls[$random_call_index] " x $repeat;
        print "$repeated_word [$prouncable_call|$pota_calls[$random_call_index]]^\n";
    }
}

