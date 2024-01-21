#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-sentences-from-top-ngrams.pl > "../Sentences-Containing-Common-2-grams.txt"
#
# Uncomment the desired ngram source file
open my $in, "<", "data/Sentences Containing Common 2-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 3-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 4-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 5-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 6-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 7-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 8-grams.txt";
#open my $in, "<", "data/Sentences Containing Common 9-grams.txt";

# ./render.pl -i Sentences-Containing-Common-2-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 1.5
# ./render.pl -i Sentences-Containing-Common-3-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 1.5
# ./render.pl -i Sentences-Containing-Common-4-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2
# ./render.pl -i Sentences-Containing-Common-5-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5
# ./render.pl -i Sentences-Containing-Common-6-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5
# ./render.pl -i Sentences-Containing-Common-7-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5
# ./render.pl -i Sentences-Containing-Common-8-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5
# ./render.pl -i Sentences-Containing-Common-9-grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5

my @lines = <$in>;
close $in;

my @ngrams;
foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line =~ m/^.*?\s*-\s*"(.*?)"$/) {
        my $sentence = $1;
        $sentence =~ s/[^A-Za-z \.\?]//g;
        push @ngrams, $sentence;
    } else {
        print "didn't match : $line\n";
    }

}

my $size = scalar @ngrams;


my $top_x_ngrams = scalar @ngrams;

my $num_random_ngrams = 1000; # for 2 through 5-grams
#my $num_random_ngrams = 500; # for 6 through 8-grams
#my $num_random_ngrams = 224; # for 9-grams

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
