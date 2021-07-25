#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-prefixes-suffixes.pl > ../prefixes-and-suffixes.txt                                                        Sun Jul 11 16:09:15 2021
# ./generate-prefixes-suffixes.pl > ../prefixes-and-suffixes-speed-racing.txt

my $num_random_words = 1500;


#in order of most common
#based on this list -- http://teacher.scholastic.com/reading/bestpractices/vocabulary/pdf/prefixes_suffixes.pdf
#ignoring single letters
my @prefixes_and_suffixes = qw(
    anti de dis en em fore in im il ir inter mid mis non over pre re semi sub super
    trans un under able ible al ial ed er est ful ic ing ion tion ation ition
    ity ty ive ative itive less ly ment ness ous eous ious es
);

# Polly pronuciation guide -- https://docs.aws.amazon.com/polly/latest/dg/ph-table-english-us.html
my %pronunciations = (
    'anti'  => '<speak><prosody rate="65%"><phoneme alphabet="x-sampa" ph="{n%ti">anti</phoneme></prosody> as in, antifreeze\.</speak>',
    'de'    => 'dee',
    'dis'   => 'diss',
    'en'    => 'en',
    'em'    => 'em',
    'fore'  => 'fore',
    'in'    => 'in',
    'im'    => 'im',
    'il'    => 'ill',
    'ir'    => '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="I%r">ir</phoneme></prosody>, as in irrational\.</speak>',
    'inter' => 'inter',
    'mid'   => '<speak><prosody rate="85%"><phoneme alphabet="x-sampa" ph="mI%d">mid</phoneme></prosody>, as in middle\.</speak>',
    'mis'   => 'miss',
    'non'   => 'non',
    'over'  => 'over',
    'pre'   => 'pre',
    're'    => 're',
    'semi'  => 'semi',
    'sub'   => 'sub',
    'super' => 'super',
    'trans' => '<speak><prosody rate="85%">trans</prosody></speak>',
    'un'    => 'un',
    'under' => 'under',
    'able'  => '<speak><prosody rate="85%"><phoneme alphabet="x-sampa" ph="@\.bl">able</phoneme></prosody>, as in comfortable\.</speak>',
    'ible'  => '<speak><prosody rate="85%"><phoneme alphabet="x-sampa" ph="I%bl">ible</phoneme></prosody>, as in, visible\.</speak>',
    'al'    => '<speak><phoneme alphabet="x-sampa" ph="A\.l">al</phoneme>, as in, personal\.</speak>',
    'ial'   => '<speak><prosody rate="85%"><phoneme alphabet="x-sampa" ph="E%l">ial</phoneme></prosody>, as in, substantial\.</speak>',
    'ed'    => 'ed',
    'er'    => 'er',
    'est'   => 'est',
    'ful'   => '<speak><prosody rate="55%">full</prosody></speak>',
    'ic'    => '<speak><prosody rate="55%"><phoneme alphabet="x-sampa" ph="Ik">ik</phoneme></prosody>, as in, public\.</speak>',
    'ing'   => 'ing',
    'ion'   => '<speak><prosody rate="85%"><phoneme alphabet="x-sampa" ph="V\.n">ion</phoneme></prosody>, as in, occasion\.</speak>',
    'tion'  => '<speak><prosody rate="85%"><phoneme alphabet="x-sampa" ph="%SVn">tion</phoneme></prosody>, as in, hospitalization\.</speak>',
    'ation' => 'ation',
    'ition' => 'ition',
    'ity'   => '<speak><prosody rate="65%"><phoneme alphabet="x-sampa" ph="E\.ti">ity</phoneme></prosody>, as in, infinity\.</speak>',
    'ty'    => 'tea',
    'ive'   => '<speak><prosody rate="65%"><phoneme alphabet="x-sampa" ph="Iv">ive</phoneme>, <phoneme alphabet="x-sampa" ph="aIv">ive</phoneme></prosody>,<prosody rate="85%"> as in give and drive\.</prosody></speak>',
    'ative' => '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="@\.tIv">tive</phoneme></prosody>, as in, cumulative\.</speak>',
    'itive' => '<speak><prosody rate="75%"><phoneme alphabet="x-sampa" ph="It\.tIv">itive</phoneme></prosody>, as in, positive\.</speak>',
    'less'  => 'less',
    'ly'    => 'ly',
    'ment'  => 'ment',
    'ness'  => 'ness',
    'ous'   => '<speak><prosody rate="75%">us</prosody>, as in, joyous\.</speak>',
    'eous'  => '<speak><prosody rate="55%"><phoneme alphabet="x-sampa" ph="I\.Vs">eous</phoneme></prosody> as in, spontaneous\.</speak>',
    'ious'  => '<speak><prosody rate="55%"><phoneme alphabet="x-sampa" ph="IVs">ious</phoneme></prosody> as in, previous\.</speak>',
    'es'    => 'es'
);


my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@prefixes_and_suffixes)));

        if(scalar keys %prev_picked >= scalar(@prefixes_and_suffixes)) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $num_random_words; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    my $prefix_or_suffix = $prefixes_and_suffixes[$random_word_index];
    my $pronunciation = $pronunciations{$prefix_or_suffix};
    print "$prefix_or_suffix [$pronunciation] ^\n";
}
