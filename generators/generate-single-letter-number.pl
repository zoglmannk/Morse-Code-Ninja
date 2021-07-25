#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-letter-number.pl > single-letter-number.txt
# Delay 0.6 seconds
#
# Rapid-Fire
# ./render.pl -i single-letter-number-rapid-fire.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 0.2 -sv 0.3 -ss 0.3

# Check distribution ./generate-single-letter-number.pl | sort | uniq -c

my $number_of_runs = 2500;
my $equal_propability_between_sets = 0;

my @letters = ('A'..'Z');
my @numbers = (0 .. 9);
my @characters = @letters; push(@characters, @numbers);

my %prononciation = (
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
            my $choose_letters = int rand 2;
            if($choose_letters == 1) {
                $random_character = $letters[int rand @letters]
            } else {
                $random_character = $numbers[int rand @numbers]
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