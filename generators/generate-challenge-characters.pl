#!/usr/bin/perl
use strict;
use Cwd;


#my $letter_group_size = 2;
# Usage:
# ./generate-challenge-characters.pl > two-challenging-characters.txt
# neural, 0.7 spacing between voice and 1 for next trial

#my $letter_group_size = 3;
# Usage:
# ./generate-challenge-characters.pl > three-challenging-characters.txt
# neural, 0.8 spacing between voice and 1 for next trial

#my $letter_group_size = 4;
# Usage:
# ./generate-challenge-characters.pl > four-challenging-characters.txt
# neural, 1 spacing between voice and 1 for next trial

my $letter_group_size = 5;
# Usage:
# ./generate-challenge-characters.pl > five-challenging-characters.txt
# neural, 1 spacing between voice and 1.2 for next trial

my $num_random_letter_groups = 1600;

my @challenging_letters = qw (
    I S H 5 U V 4 D B 6 W J 1 T E
);

sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = "";
        for(my $i=0; $i < $letter_group_size; $i++) {
            $next_pick .= $challenging_letters[int(rand(scalar(@challenging_letters)))];
        }

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_letter_group = "";
for (my $i=0; $i < $num_random_letter_groups; $i++) {
    my $random_letter_group = pick_uniq_letter_combination($last_random_letter_group);
    my $pronounce_letter_group = join ", ", split //, $random_letter_group;

    print "$random_letter_group [$pronounce_letter_group] ^\n";


    $last_random_letter_group = $random_letter_group;
}


