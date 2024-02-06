#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-n-letter-words.pl > top-100-german-words.txt
# ./render.pl -i top-100-german-words.txt -s 15 17 20 22 25 28 30 35 40 45 50 --lang GERMAN
#

my $repeat = 1; #number of times to repeat
my $max_word_frequency = 500;
my $num_random_words = 1500;


# This list came from this web page - https://strommeninc.com/1000-most-common-german-words-frequency-vocabulary/
open(my $fh, '<:encoding(UTF-8)', "data/german-word-frequency.csv")
    or die "Could not open data/german-word-frequency.csv";
binmode(STDOUT, ":encoding(UTF-8)");

my @words;
while(my $line = <$fh>) {
    $line =~ m/^(\d+),(\p{L}+),(\p{L}+)/;
    my $frequency = $1;
    my $german_word = $2;
    my $in_english = $3;

    if($frequency =~ m/^[0-9]+$/ && int($frequency) <= $max_word_frequency) {
        #print "$frequency: $german_word\n";
        push @words, $german_word;
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
