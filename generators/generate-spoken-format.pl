#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
# cat ../practice-sets/Sentences\ from\ Top\ 100\ words.txt | shuf | ./generate-spoken-format.pl > ../Sentences-from-Top-100-Words-Spelled-X-Slow.txt
#
# ./render2.pl -i Sentences-from-Top-100-Words-Spelled-X-Slow.txt;

my $repeat = 0;

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

my $prev_in = "";
while(<>) {
    my $in = $_;
    chomp($in);

    if($prev_in ne $in) {
        my $spoken_version = get_spoken($in, $rate);
        print "$spoken_version\n";
    }

    $prev_in = $in;

}


