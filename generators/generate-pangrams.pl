#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-pangrams.pl > pangram-challenge.txt
# process settings: 2 second pause, neural

my $num_random_pangrams = 126*3;

my @pangrams;
open my $fh, '<', 'data/pangrams.txt';
while (my $line = <$fh>) {
    chomp $line;
    $line = ucfirst(lc($line)) . '.';
    $line =~ s/!//g; # Will also need to get rid
    #print "$line\n";
    push @pangrams, $line;
}
close $fh;


my %prev_picked;
sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@pangrams)));

        if(scalar keys %prev_picked >= scalar(@pangrams)) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_random_pangrams; $i++) {
    my $random_pangram_index = pick_uniq_pangram_index();

    my $pangram = $pangrams[$random_pangram_index];
    $pangram =~ s/(\.|\?)/\\$1/g;

    my $morse_safe_pangram = $pangram;
    $morse_safe_pangram =~ s/--/, /g;
    $morse_safe_pangram =~ s/[^A-Za-z0-9,\.\?\\ ]//g;

    print "$morse_safe_pangram [$pangram]^\n";
}
