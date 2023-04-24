#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-multi-letter-number.pl > 2-letter-number.txt
#
# 2-character = 1 second between morse and spoken voice
# 3-character = 1.5 second between morse and spoken voice
# 4-character = 2 second between morse and spoken voice


# Check distribution ./generate-single-letter-number.pl | sort | uniq -c

my $number_of_runs = 1000;
my $equal_propability_between_sets = 1;
my $letter_group_size = 2;

my @letters = ('A'..'Z');
my @numbers = (0 .. 9);
my @characters = @letters; push(@characters, @numbers);


my $previous_character = "";
sub pick_uniq_letter_combination {
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
            #print "Got here: random_character=$random_character previous_character=$previous_character choose_letters=$choose_letters\n";
        }
    }
    $previous_character = $random_character;
    #print "returning\n";
    return $random_character;
}

sub pick_uniq_set {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = "";
        for(my $i=0; $i < $letter_group_size; $i++) {
            $next_pick .= pick_uniq_letter_combination();;
        }

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}

my $last_random_letter_group = "";
for(my $i=0; $i<$number_of_runs; $i++) {
    my $random_characters = pick_uniq_set($last_random_letter_group);
    $last_random_letter_group = $random_characters;

    my $random_pronounciation = join ", ", split //, $random_characters;
    print "$random_characters [$random_pronounciation]^\n";
}