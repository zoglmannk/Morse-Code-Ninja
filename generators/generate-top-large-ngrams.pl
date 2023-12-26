#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-top-large-ngrams.pl
#
# Uncomment the desired ngram source file
#open my $in, "<", "data/top-250-6-gram.txt";
#open my $in, "<", "data/top-250-7-gram.txt";
#open my $in, "<", "data/top-250-8-gram.txt";
open my $in, "<", "data/top-115-9-gram.txt";

#
# time ./render.pl -i Sets-of-6-Words.txt -s 15 17 20 22 25 28 30 35 40 45 50 -sm 2.5
# time ./render.pl -i Sets-of-7-Words.txt -s 15 17 20 22 25 28 30 35 40 45 50 -sm 2.5
# time ./render.pl -i Sets-of-8-Words.txt -s 15 17 20 22 25 28 30 35 40 45 50 -sm 2.6
# time ./render.pl -i Sets-of-9-Words.txt -s 15 17 20 22 25 28 30 35 40 45 50 -sm 2.7


my @lines = <$in>;
close $in;

my @ngrams;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if(/^(.*?):\s\d+$/) {
        my $ngram = $1;
        print "$ngram ^\n";
        push @ngrams, $ngram;
    }

}

my $size = scalar @ngrams;
my $top_x_ngrams = scalar @ngrams;
my $num_random_ngrams = $top_x_ngrams*2;

my $last_picked = "";
my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($top_x_ngrams));

        if(scalar keys %prev_picked >= $top_x_ngrams) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_random_ngrams; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    print "$ngrams[$random_word_index] ^\n";
}
