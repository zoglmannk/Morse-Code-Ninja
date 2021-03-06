#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-dit-practice.pl  > dit-challenge-phrases.txt


open my $in, "<", "data/dit-challenge.txt";
my @lines = <$in>;
close $in;

my @dit_phrases;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    push @dit_phrases, $line;
}

my $size = scalar @dit_phrases;
my $top_x_dit_phrases = scalar @dit_phrases;
my $num_dit_phrases = 300;

my $last_picked = "";
my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($top_x_dit_phrases));

        if(scalar keys %prev_picked >= $top_x_dit_phrases) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_dit_phrases; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    print "$dit_phrases[$random_word_index] \n";
}
