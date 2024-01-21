#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-top-ngram.pl > Build-A-Phrase-2-Words.txt
#
# Uncomment the desired ngram source file
open my $in, "<", "data/2ngram-top.txt";
#open my $in, "<", "data/3ngram-top.txt";
#open my $in, "<", "data/4ngram-top.txt";
#open my $in, "<", "data/5ngram-top.txt";

# Farnsworth timing - Extra Word Spacing
# 2 Words
# ./render.pl -i "Build A Phrase - 2-Words.txt" -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone  --sm 1.1
# ./render.pl -i "Build A Phrase - 3-Words.txt" -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone  --sm 1.2
# ./render.pl -i "Build A Phrase - 4-Words.txt" -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone  --sm 1.3
# ./render.pl -i "Build A Phrase - 5-Words.txt" -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone  --sm 1.4



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
my $num_random_ngrams = 500;

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
    my $phrase = $ngrams[$random_word_index];
    my @words = split(/\s/, $phrase);

    my $partial_phrase = "";
    my $first = 1;
    foreach(@words) {
        my $word = $_;

        if($first == 1) {
            $first = 0;
        } else {
            $partial_phrase .= " ";
        }
        $partial_phrase .= $word;

        print "$partial_phrase ^\n";
        print "{ $partial_phrase } ^\n";
    }
    print "$partial_phrase ^\n";
    print "<courtesyTone> ^\n";
}
