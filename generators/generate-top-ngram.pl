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
