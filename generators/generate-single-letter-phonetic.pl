#!/usr/bin/perl
use strict;
use Cwd;


# Usage:
# ./generate-single-letter-phonetic > single-letter-phonetic
# ./render.pl -i single-letter-phonetic.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 0.6


my $num_random = 2500;
my $repeat = 1; # number of times - Not true false

my @phonetic = (
    'Alpha',
    '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="&quot\;BrAv%oU">Bravo</phoneme></prosody></speak>',
    'Charlie', 'Delta', 'Echo', 'Foxtrot', 'Golf', 'Hotel',
    '<speak><prosody rate="65%"><phoneme alphabet="x-sampa" ph="Indi&quot\;@">India</phoneme></prosody></speak>',
    '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="dZu\.li\.E@t">Juliet</phoneme></prosody></speak>',
    'Kilo', 'Lima', 'Mike', 'November', 'Oscar', 'Papa',
    'Quebec',
    '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="Ro\.mi\.@u">Romeo</phoneme></prosody></speak>',
    'Sierra',
    '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="teIn\.go\.u">Tango</phoneme></prosody></speak>',
    'Uniform', 'Victor', 'Whiskey',
    'X-Ray', 'Yankee', 'Zulu'
);

my @letters = ('A'..'Z');


sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar @letters));

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_index = -1;
for (my $i=0; $i < $num_random; $i++) {
    my $random_index = pick_uniq_letter_combination($last_random_index);

    if($repeat == 1) {
        print "$letters[$random_index] [$phonetic[$random_index]]^\n";
    } else {
        my $repeated_letter = "$letters[$random_index] " x $repeat;
        print "$repeated_letter [$phonetic[$random_index]|$letters[$random_index]]^\n";
    }

    $last_random_index = $random_index;
}


