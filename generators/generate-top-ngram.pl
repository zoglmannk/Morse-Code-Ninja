#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-top-ngram.pl > 2gram.txt
#
# Uncomment the desired ngram source file
open my $in, "<", "data/2ngram-top.txt";
#open my $in, "<", "data/3ngram-top.txt";
#open my $in, "<", "data/4ngram-top.txt";
#open my $in, "<", "data/5ngram-top.txt";

# Farnsworth timing - Extra Word Spacing
# 2 Words
# ./render.pl -i Sets-of-2-Words-4x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 3 --sm 0.2
# ./render.pl -i Sets-of-2-Words-3x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 2 --sm 0.5
# ./render.pl -i Sets-of-2-Words-2x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 1 --sm 0.7
#
# 3 Words
# ./render.pl -i Sets-of-3-Words-4x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 3 --sm 0.3
# ./render.pl -i Sets-of-3-Words-3x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 2 --sm 0.6
# ./render.pl -i Sets-of-3-Words-2x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 1 --sm 0.8
#
# 4 Words
# ./render.pl -i Sets-of-4-Words-4x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 3 --sm 0.4
# ./render.pl -i Sets-of-4-Words-3x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 2 --sm 0.7
# ./render.pl -i Sets-of-4-Words-2x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 1 --sm 0.9
#
# 5 Words
# ./render.pl -i Sets-of-5-Words-4x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 3 --sm 0.5
# ./render.pl -i Sets-of-5-Words-3x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 2 --sm 0.8
# ./render.pl -i Sets-of-5-Words-2x-Word-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 -x 1 --sm 1.0

my @lines = <$in>;
close $in;

my @ngrams;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    push @ngrams, $line;
}

my $size = scalar @ngrams;
#print "read in $size 2-ngrams\n";


my $top_x_ngrams = scalar @ngrams;
my $num_random_ngrams = 1000;

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
