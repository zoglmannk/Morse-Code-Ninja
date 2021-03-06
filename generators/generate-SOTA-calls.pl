#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
#cat data/SOTA-Top-Activators.csv | ./generate-SOTA-calls.pl > sota-activator-callsigns.txt
#cat data/SOTA-Top-Chasers.csv | ./generate-SOTA-calls.pl > sota-chaser-callsigns.txt


my @sota_calls;
my $repeat = 1;


while(<>) {

    my $entry = $_;
    if($entry =~ m/^([A-Za-z0-9]+)\r?$/) {
        my $call = $1;
        push @sota_calls, $call;
        #print "OKAY with $call\n";
    } else {
        #print "problem with $entry\n";
    }

}

my $top_x_calls = scalar @sota_calls;
my $num_random_calls = 500; #$top_x_calls * 1;

my %prev_picked;

sub pick_uniq_call_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($top_x_calls));

        if(scalar keys %prev_picked >= $top_x_calls) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
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
    my $prouncable_call = get_pronouncable_call($sota_calls[$random_call_index]);

    if($repeat == 1) {
        print "$sota_calls[$random_call_index] [$prouncable_call] ^\n";
    } else {
        my $repeated_word = "$sota_calls[$random_call_index] " x $repeat;
        print "$repeated_word [$prouncable_call|$sota_calls[$random_call_index]]^\n";
    }
}

