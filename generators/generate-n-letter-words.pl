#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-n-letter-words.pl > top-500-words.txt
#

my $repeat = 1; #number of times to repeat
my $word_length = 3;
my $num_random_words = 1500;

open(my $fh, '<', "data/top-2000-words.txt")
    or die "Could not open data/top-2000-words.txt";

my @words;
while(my $line = <$fh>) {
    $line =~ m/^(\w+),/;
    my $word = $1;

    if(length($word) == $word_length) {
        push @words, $word;
    }

}

my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@words)));

        if(scalar keys %prev_picked >= scalar(@words)) {
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

    if($repeat == 1) {
        print "$words[$random_word_index] ^\n";
    } else {
        my $repeated_word = "$words[$random_word_index] " x $repeat;
        print "$repeated_word [$words[$random_word_index]|$words[$random_word_index]]^\n";
    }
}
