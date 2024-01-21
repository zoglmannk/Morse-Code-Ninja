#!/usr/bin/perl

use strict;
use Cwd;

my $speak_max_words = 3;

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

# ./render.pl -i spoken-part-of-sentences-from-top-2grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5
# ./render.pl -i spoken-part-of-sentences-from-top-3grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 1.5

# ./render.pl -i spoken-part-of-sentences-from-top-4grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2
# ./render.pl -i spoken-part-of-sentences-from-top-5grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2.3
# ./render.pl -i spoken-part-of-sentences-from-top-6grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2.5
# ./render.pl -i spoken-part-of-sentences-from-top-7grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2.5
# ./render.pl -i spoken-part-of-sentences-from-top-8grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2.5
# ./render.pl -i spoken-part-of-sentences-from-top-9grams.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sc 1.5 --sm 2.5

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

my $num_random_ngrams = scalar @ngrams;

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

    my $sentence = $ngrams[$random_word_index];
    my @parts = split /\s/, $sentence;

    my $num_words = 0;
    my $spoken_part = "";
    foreach (@parts) {
        if($num_words <= $speak_max_words) {
            $spoken_part .= " " . $parts[$num_words];
        }
        $num_words += 1;
    }
    $spoken_part .= ", blank.";

    print "{ $spoken_part } ^\n";
    print "$sentence ^\n\n";
}
