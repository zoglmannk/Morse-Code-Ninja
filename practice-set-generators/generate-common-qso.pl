#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
# ./generate-common-qso.pl > common-qso-phrases-generated.txt

my @phrases;

open(my $fh, '<', "data/qso-phrases.txt")
  or die "Could not open data/qso-phrases.txt";

while(my $phrase = <$fh>) {
    chomp $phrase;
    push @phrases, $phrase;
}

my $top_x_phrases = scalar @phrases;
my $num_random_phrases = $top_x_phrases * 3;

my %prev_picked;

sub pick_uniq_phrase_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand($top_x_phrases));

        if(scalar keys %prev_picked >= $top_x_phrases) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}


for (my $i=0; $i < $num_random_phrases; $i++) {
    my $random_call_index = pick_uniq_phrase_index();

    if($phrases[$random_call_index] =~ m/\?/) {
        print "$phrases[$random_call_index]\n";
    } else {
        print "$phrases[$random_call_index] ^\n";
    }

}

