#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-n-letter-words-3-letters-given.pl > 6-letter-words-first-3-letters-given.txt
#
# ./render.pl -i 5-letter-words-first-3-letters-given.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5
# ./render.pl -i 6-letter-words-first-3-letters-given.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5
# ./render.pl -i 7-letter-words-first-3-letters-given.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5
# ./render.pl -i 8-letter-words-first-3-letters-given.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5
# ./render.pl -i 9-letter-words-first-3-letters-given.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5
# ./render.pl -i 10-letter-words-first-3-letters-given.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2
#

my $word_length = 5;

open(my $fh, '<', "data/word-list.txt")
    or die "Could not open data/word-list.txt";

my @words;
while(my $line = <$fh>) {
    $line =~ m/^(\w+)$/;
    my $word = $1;

    if(length($word) == $word_length) {
        push @words, $word;
        #print "word: $word\n";
    }

}

#print "number of words found: " . scalar(@words) . "\n";
#exit 1;

my $num_random_words = scalar(@words)*3;

# Number of words
# Words 5 .. 708
# Words 6 .. 777
# Words 7 .. 731
# Words 8 .. 586
# Words 9 .. 464
# Words 10 .. 357
# Words 11 .. 215
# Words 12 .. 99


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
    my $word = $words[$random_word_index];
    my $beginning_of_word = join(', ', split(//, uc(substr($word, 0, 3))));

    print "{ A word starting with, $beginning_of_word } ^\n";
    print "$word ^\n";
}
