#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-single-letter-single-number.pl > single-letter-single-number.txt

my $number_of_runs = 2500;

my @letters = ('A'..'Z');
my @numbers = (0 .. 9);


my $previous_characters = "";
for(my $i=0; $i<$number_of_runs; $i++) {
    my $random_characters = "";
    while($random_characters eq "" || $random_characters eq $previous_characters) {
        my $choose_letter_first = int rand 2;
        if($choose_letter_first == 1) {
            $random_characters = $letters[int rand @letters] . $numbers[int rand @numbers];
        } else {
            $random_characters = $numbers[int rand @numbers] . $letters[int rand @letters];
        }
    }
    $previous_characters = $random_characters;
    my $random_characters_safe = $random_characters;
    $random_characters_safe =~ s/(\.|\?)/\\\1/;

    my $random_pronunciation = join(" ", split //, $random_characters);

    my $random_pronunciation_safe = $random_pronunciation;
    $random_pronunciation_safe =~ s/(\.|\?)/\\\1/;
    print "$random_characters_safe [$random_pronunciation_safe]^\n";

}