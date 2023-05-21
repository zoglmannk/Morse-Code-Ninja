#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-punc-prosign.pl > single-punctuation-prosign.txt
# Delay 0.6 seconds
#
# Rapid-Fire
# ./render.pl -i single-punc-prosign-rapid-fire.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 0.2 -sv 0.3 -ss 0.3
#
# Mind Melt
# ./render.pl -i single-punc-prosign-mind-melt.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nocourtesytone -ss 0.2 -sm 0.2 -sv 0.2


my $number_of_runs = 2500;

my @punctuations_and_prosigns = ('.', ',', '?', '/', '<BT>', '<HH>', '<KN>', '<SK>', '<AR>');


my %prononciation = (
    '.'    => 'period',
    ','    => 'comma',
    '?'    => 'question mark',
    '/'    => 'stroke',
    '<BT>' => 'B T',
    '<HH>' => 'correction',
    '<KN>' => 'K N',
    '<SK>' => 'S K',
    '<AR>' => 'A R',
);

my $previous_character = "";
for(my $i=0; $i<$number_of_runs; $i++) {
    my $random_character = "";
    while($random_character eq "" || $random_character eq $previous_character) {
        $random_character = $punctuations_and_prosigns[int rand @punctuations_and_prosigns]
    }
    $previous_character = $random_character;

    my $random_letter_safe = $random_character;
    $random_letter_safe =~ s/(\.|\?)/\\\1/;
    if(defined $prononciation{$random_character}) {
        my $random_safe_prounciation = $prononciation{$random_character};
        $random_safe_prounciation =~ s/\./\\./;
        print "$random_letter_safe [$random_safe_prounciation]^\n";
    } else {
        print "$random_letter_safe [$random_letter_safe]^\n";
    }
}