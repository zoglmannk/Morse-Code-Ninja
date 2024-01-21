#!/usr/bin/perl

use strict;
use warnings;

# Usage:
# ./generate-build-a-word > ../Build-A-Word-xxxxx.txt
#
# ./render.pl -i Build-A-Word-3-Letters.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --st 0.6
# ./render.pl -i Build-A-Word-4-Letters.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --st 0.6
# ./render.pl -i Build-A-Word-5-Letters.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --st 0.6
# ./render.pl -i Build-A-Word-3-to-5-Letters.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --st 0.6

# ./render.pl -i Build-A-Word-4-Letters-2-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.5 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-6-Letters-2-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.5 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-8-Letters-2-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.5 --sv 0.5 --st 0.5

# ./render.pl -i Build-A-Word-6-Letters-3-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.5 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-8-Letters-3-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.5 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-9-Letters-3-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.5 --sv 0.5 --st 0.5

# ./render.pl -i Build-A-Word-8-Letters-4-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.6 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-10-Letters-4-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.6 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-11-Letters-4-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.6 --sv 0.5 --st 0.5
# ./render.pl -i Build-A-Word-12-Letters-4-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.6 --sv 0.5 --st 0.5

# ./render.pl -i Build-A-Word-10-Letters-5-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.7 --sv 0.6 --st 0.5
# ./render.pl -i Build-A-Word-12-Letters-5-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.7 --sv 0.6 --st 0.5

# ./render.pl -i Build-A-Word-12-Letters-6-Letters-At-A-Time.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nospoken --nocourtesytone --sm 1.8 --sv 0.7 --st 0.5

my $word_length = 5;
my $num_random_words = 1000;
my $num_letters_at_a_time = 1;

my $variable_word_length = 0; # Set this to 1 if you want a mix of word lengths
my $min_word_length = 3;
my $max_word_length = 5;

open my $in, "<", "data/word-list.txt";
my @lines = <$in>;
close $in;

my @words;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if(
        ($variable_word_length != 1 && length($line) == $word_length) ||
        ($variable_word_length == 1 && length($line) >= $min_word_length && length($line) <= $max_word_length)
    ) {
        #print "$line\n";
        push @words, $line;
    }
}


my %prev_picked =  ();

sub pick_uniq_word_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@words)));

        if(scalar keys %prev_picked >= scalar(@words)) {
            %prev_picked = ();
        }

        if((not defined $prev_picked{$next_pick}) || $prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

# Helper function to get the minimum of two values
sub min {
    my ($a, $b) = @_;
    return $a < $b ? $a : $b;
}

for (my $i=0; $i < $num_random_words; $i++) {
    my $random_word_index = pick_uniq_word_index();
    my $word = $words[$random_word_index];
    my @letters = split(//, $word);
    my @working_set;

    for (my $j = 0; $j < @letters; $j += $num_letters_at_a_time) {
        my $substring = join('', @letters[$j .. min($j + $num_letters_at_a_time - 1, $#letters)]);
        push @working_set, split(//, $substring);

        #print morse code version
        foreach(@working_set) {
            my $working_letter = $_;
            print "$working_letter"
        }
        print " ^\n";

        #print spoken version
        print "{ ";
        my $is_first = 1;
        foreach(@working_set) {
            my $working_letter = uc($_);
            if($is_first == 1) {
                $is_first = 0;
            } else {
                print ", ";
            }
            print "$working_letter"
        }
        if(scalar(@working_set) == length($word)) {
            print "\\.\\.\\. $word\\. } ^\n";
        } else {
            print "\\. } ^\n";
        }

    }
    # final repeat in Morse Code
    print "$word ^\n";

    print "<courtesyTone> ^\n";
}

