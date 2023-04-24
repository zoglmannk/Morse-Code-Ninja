#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-top-20-qso-elements.pl > top-20-qso-elements.txt
#
# Set $repeat, $top_x_words, and $num_random_words as appropriate

open my $in, "<", "data/top-20-qso-elements.csv";
my @lines = <$in>;
close $in;

my @qso_elements;
my %qso_elements_pronunciation;

foreach(@lines) {
    my $line = $_;
    chomp($line);

    $line =~ s/(\.|\?)/\\$1/g;
    $line =~ m/^(.*?),(.+)$/;
    my $morse_code_part = $1;
    my $pronunciation_part = $2;

    #print "$morse_code_part     $pronunciation_part\n";
    $qso_elements_pronunciation{$morse_code_part} = $pronunciation_part;
    push @qso_elements, $morse_code_part;
}

my $multiplier = 25; # 50 for standard speeds - 25 for speed racing
my $num_random_qso_elements = scalar(@qso_elements)*$multiplier;


my %prev_picked;
sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    my $num_qso_elements = scalar(@qso_elements);
    while(1) {
        my $next_pick = int(rand($num_qso_elements));

        if(scalar keys %prev_picked >= $num_qso_elements) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_random_qso_elements; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    my $element = $qso_elements[$random_word_index];
    my $pronunciation = $qso_elements_pronunciation{$element};
    print "$element [$pronunciation]^\n";
}
