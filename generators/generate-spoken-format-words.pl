#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use Cwd;

# Usage:
# ./generate-spoken-format-words.pl > '../Top 1000 Words - Spelled Out - X-Slow.txt'
#
# ./render2.pl -i 'Top 1000 Words - Spelled Out - Fast - No Repeat.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - Fast.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - Medium - No Repeat.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - Medium.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - Slow - No Repeat.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - Slow.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - X-Fast - No Repeat.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - X-Fast.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - X-Slow - No Repeat.txt' --nocourtesytone 1
# ./render2.pl -i 'Top 1000 Words - Spelled Out - X-Slow.txt' --nocourtesytone 1

my $min_word_size = 4;
my $max_word_size = 10;
my $num_trials = 2000;
my $repeat = 0;

open my $in, "<", "data/top-2000-words.txt";
my @lines = <$in>;
close $in;

my $counter = 0;
my @top_1000_words = ();
foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line =~ m/^(.*?),\s*(\d+)$/) {
        my $word = $1;
        if($counter < 1000 && length($word) >= 4 and length($word) <= 10) {
            push(@top_1000_words, $word);
            #print("word: $word\n");
        }
        $counter += 1;
    }
}

#print "size of word array: " . scalar(@top_1000_words) . "\n";


my $time_between_segments = "2000ms";

# x-slow
#my $rate = "x-slow";
#my $time_between_letters = "400ms"; #10ms
#my $time_between_words = "1300ms"; #500ms

## slow
#my $rate = "x-slow";
#my $time_between_letters = "200ms"; #10ms
#my $time_between_words = "1000ms"; #500ms

## medium
#my $rate = "slow";
#my $time_between_letters = "10ms";
#my $time_between_words = "500ms";

## fast
#my $rate = "medium";
#my $time_between_letters = "10ms";
#my $time_between_words = "500ms";

## extra-fast
my $rate = "x-fast";
my $time_between_letters = "5ms";
my $time_between_words = "300ms";

sub get_spoken {
    my $input = $_[0];
    my $rate = $_[1];
    my $ret = "<speak>";

    my $spelled_out = "<prosody rate=\"$rate\">";

    my @words = split(/\s+/, $input);
    my $first_word = 1;
    foreach(@words) {
        my $word = $_;

        if($first_word == 1) {
            $first_word = 0;
        } else {
            $spelled_out .= "<break time=\"$time_between_words\"/>";
        }

        my @letters = split(//, $word);
        my $first_letter = 1;
        foreach(@letters) {
            my $letter = $_;
            if($first_word == 1) {
                $first_word = 0;
            } else {
                $spelled_out .= "<break time=\"$time_between_letters\"/>";
            }

            $letter =~ s/\./Period/;
            $letter =~ s/\?/Question-mark/;
            $letter =~ s/,/Comma/;

            $spelled_out .= $letter;
        }
        #$ret .= $word;
    }

    $spelled_out .= "</prosody>";


    $ret .= "${spelled_out}<break time=\"$time_between_segments\"/>";
    $ret .= "<prosody rate=\"slow\">" . $input . "</prosody>";
    $ret .= "<break time=\"$time_between_segments\"/>";
    if($repeat == 1) {
        $ret .= "${spelled_out}";
    }
    $ret .= "</speak>";

    return $ret;

}

my $last_picked_word = "";
sub pick_random_element {
    while(1 == 1) {

        my $next_picked_word = @top_1000_words[int(rand(scalar @top_1000_words))];
        if($next_picked_word ne $last_picked_word) {
            $last_picked_word = $next_picked_word;
            return $next_picked_word;
        }

    }
}

my $prev_in = "";
for(my $i=0; $i < $num_trials; $i++) {
    my $random_word = pick_random_element();

    my $spoken_version = get_spoken($random_word, $rate);
    print "$spoken_version\n";

}