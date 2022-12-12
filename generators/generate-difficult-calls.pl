#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
# ./generate-difficult-calls.pl > ../difficult-calls.txt
# cd ../; ./render.pl -i difficult-calls.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2

my @difficult_calls;
my $num_random_calls = 1000;


open(my $READ_FH, '<', "data/difficult-callsigns.txt") or die $!;

while(<$READ_FH>) {
    my $call = $_;
    chomp($call);
    push @difficult_calls, $call;
}

my $top_x_calls = scalar @difficult_calls;
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
            if($was_natural_pause == 1 || $c =~ m/slash/) {
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
    my $prouncable_call = get_pronouncable_call($difficult_calls[$random_call_index]);

    print "$difficult_calls[$random_call_index] [$prouncable_call] ^\n";
}

