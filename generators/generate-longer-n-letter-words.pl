#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-longer-n-letter-words.pl > 8-letter-words.txt
#

my $repeat = 1; #number of times to repeat
my $word_length = 6;
my $num_random_words = 99*5;

# Number of words
# Words 8 .. 586
# Words 9 .. 464
# Words 10 .. 357
# Words 11 .. 215
# Words 12 .. 99

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
