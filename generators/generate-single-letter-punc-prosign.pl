#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-letter-punc-prosign.pl > single-letter-number-punc-prosign.txt
# Delay 0.6 seconds

# Check distribution ./generate-single-letter-number.pl | sort | uniq -c

my $number_of_runs = 2500;
my $equal_propability_between_sets = 0;

my @letters = ('A'..'Z');
my @numbers = (0 .. 9);
my @punctuations_and_prosigns = ('.', ',', '?', '/', '<BT>', '<HH>', '<KN>', '<SK>', '<AR>');
my @characters = @letters;
push(@characters, @numbers);
push(@characters, @punctuations_and_prosigns);

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
    'P'    => 'P.',
    'K'    => 'K.',
    'T'    => 'T.',
    'U'    => 'U.',
    'V'    => 'V.'
);

my $previous_character = "";
for(my $i=0; $i<$number_of_runs; $i++) {
    my $random_character = "";
    while($random_character eq "" || $random_character eq $previous_character) {
        if($equal_propability_between_sets == 0) {
            $random_character = $characters[int rand @characters];
        } else {
            my $choose_letters = int rand 3;
            if($choose_letters == 1) {
                $random_character = $letters[int rand @letters]
            } elsif($choose_letters == 2) {
                $random_character = $numbers[int rand @numbers]
            } else {
                $random_character = $punctuations_and_prosigns[int rand @punctuations_and_prosigns]
            }
        }
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