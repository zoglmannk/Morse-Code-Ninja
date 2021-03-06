#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
# ./generate-cwops-calls.pl > cwops-calls.txt
#
# Set $only_easy to 0 or 1, and $repeat as appropriate

my $only_easy = 1;
my $repeat = 3;

my @cwops_calls;

open(my $fh, '<', "data/cwops-members-2019.txt")
    or die "Could not open data/cwops-members-2019.txt";

while(my $entry = <$fh>) {

    if($entry =~ /([^\n]+)\n?/g) {
        my $line = uc($1);
        chomp $line;
        my ($exp, $call, $number, $name, $d1) = split / /, $line;

        # easy
        if($only_easy != 1 || $call =~ /^(\[A-Za-z]{2}\d[A-Za-z]|[A-Za-z]\d[A-Za-z]{2})$/) {
            #print "$call $name\n";
            push @cwops_calls, $call;
        }
    }

}

my $top_x_calls = scalar @cwops_calls;
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
    my $prouncable_call = get_pronouncable_call($cwops_calls[$random_call_index]);

    if($repeat == 1) {
        print "$cwops_calls[$random_call_index] [$prouncable_call] ^\n";
    } else {
        my $repeated_word = "$cwops_calls[$random_call_index] " x $repeat;
        print "$repeated_word [$prouncable_call|$cwops_calls[$random_call_index]]^\n";
    }
}

