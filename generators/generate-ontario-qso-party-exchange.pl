#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-ontario-qso-party-exchange.pl > ontario-qso-party-exchange.txt
#

my $word_length = 3;
my $num_random_words = 1500;

open(my $fh, '<', "data/Ontario-QSO-Party.csv")
    or die "Could not open data/Ontario-QSO-Party.csv";

my %ontario_qth_pronunciation;
my @ontario_qth_abbreviation;
while(my $line = <$fh>) {
    chomp($line);
    my @fields = split(/,/, $line);
    my $abbrev = $fields[5];
    my $pronunciation = $fields[6];

    $abbrev =~ s/\%/,/g;
    $pronunciation =~ s/\%/,/g;

    #print("$abbrev, $pronunciation\n");

    push @ontario_qth_abbreviation, $abbrev;
    $ontario_qth_pronunciation{$abbrev} = $pronunciation;
}

my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@ontario_qth_abbreviation)));

        if(scalar keys %prev_picked >= scalar(@ontario_qth_abbreviation)) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_random_words; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    my $abbrev = $ontario_qth_abbreviation[$random_word_index];

    my $pronounce_abbrev = join(" ", split(//, $abbrev));

    my $pronunciation = $ontario_qth_pronunciation{$abbrev};
    $pronounce_abbrev =~ s/N I A/N, I, A/g;
    print "5NN $abbrev [$pronounce_abbrev, $pronunciation]^\n";
}
