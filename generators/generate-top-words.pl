#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-top-words.pl > top-500-words.txt
#
# Set $repeat, $top_x_words, and $num_random_words as appropriate

# For generating alternate Character 8x character spacing with standard speed repeat
# ./render.pl -i Top-100-Words-8x-Character-Spacing.txt -s 15 17 20 22 25 28 30 35 40 45 50 --charactermultiplier 2 --standardspeedrepeat 1 --sm 0.5 --ss 0.5 --sv 0.5

my $repeat = 1;
my $top_x_words = 500;  # Maximum value is 500 - There are only 500 words available
my $num_random_words = 1600;


#in order of most common
my @words = qw(
    the of to and a in is it you that he was for on are with as I his they be at one have this from or had by hot but
    some what there we can out other were all your when up use word how said an each she which do their time if will
    way about many then them would write like so these her long make thing see him two has look more day could go
    come did my sound no most number who over know water than call first people may down side been now find any
    new work part take get place made live where after back little only round man year came show every good
    me give our under name very through just form much great think say help low line before turn cause same
    mean differ move right boy old too does tell sentence set three want air well also play small end put home
    read hand port large spell add even land here must big high such follow act why ask men change went
    light kind off need house picture try us again animal point mother world near build self earth father head stand
    own page should country found answer school grow study still learn plant cover food sun four thought let
    keep eye never last door between city tree cross since hard start might story saw far sea draw left late run
    dont while press close night real life few stop open seem together next white children begin got walk example
    ease paper often always music those both mark book letter until mile river car feet care second group carry
    took rain eat room friend began idea fish mountain north once base hear horse cut sure watch color face
    wood main enough plain girl usual young ready above ever red list though feel talk bird soon body dog family
    direct pose leave song measure state product black short numeral class wind question happen complete ship area
    half rock order fire south problem piece told knew pass farm top whole king size heard best hour better true
    during hundred am remember step early hold west ground interest reach fast five sing listen six table travel
    less morning ten simple several vowel toward war lay against pattern slow center love person money serve appear
    road map science rule govern pull cold notice voice fall power town fine certain fly unit lead cry dark machine
    note wait plan figure star box noun field rest correct able pound done beauty drive stood contain front teach
    week final gave green oh quick develop sleep warm free minute strong special mind behind clear tail produce fact
    street inch lot nothing course stay wheel full force blue object decide surface deep moon island foot yet busy
    test record boat common gold possible plane age dry wonder laugh thousand ago ran check game shape yes hot miss
    brought heat snow bed bring sit perhaps fill east weight language among
);

my %prev_picked;

sub pick_uniq_pangram_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($top_x_words));

        if(scalar keys %prev_picked >= $top_x_words) {
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

    if($repeat == 1) {
        print "$words[$random_word_index]^\n";
    } else {
        my $repeated_word = "$words[$random_word_index] " x $repeat;
        print "$repeated_word [$words[$random_word_index]|$words[$random_word_index]]^\n";
    }
}
