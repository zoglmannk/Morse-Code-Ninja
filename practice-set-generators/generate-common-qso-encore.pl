#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-common-qso-encore.pl > qso-phrases.txt

my $filename = 'data/qso-phrases-encore.txt';
open(my $fh, '<', $filename)
    or die "Could not open file '$filename' $!";

my @entries;
while(<$fh>) {
    my $line = $_;
    chop($line);
    if($line =~ m/\[.*\]/) {
        push @entries, $line;
    }
}

my $num_entries = scalar(@entries);
my $num_random_entries = 3 * $num_entries;

my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($num_entries));

        if(scalar keys %prev_picked >= $num_entries) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_random_entries; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    my $entry = "$entries[$random_word_index]";
    print "$entry\n";
}
