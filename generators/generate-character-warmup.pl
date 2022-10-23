#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-set-of-character-warmup.bash
# "Mind Melt"
# perl -e 'for my $i (1..100) { print "$i\n"; }' | xargs -IXX ./render.pl -i character-warmup-XX.txt -s 15 17 20 22 25 28 30 35 40 45 50 --norepeat --nocourtesytone -ss 0.2 -sm 0.2 -sv 0.2

# Check distribution ./generate-single-letter-number.pl | sort | uniq -c


my @letters = ('A'..'Z');
my @numbers = (0 .. 9);
my @punctuations_and_prosigns = ('.', ',', '?', '/', '<BT>', '<HH>', '<KN>', '<SK>', '<AR>');
my @characters;
push(@characters, @letters);
push(@characters, 'A'); #need even number of elements
push(@characters, @numbers);
push(@characters, @punctuations_and_prosigns);

my %prononciation = (
    '.'    => 'period',
    ','    => 'comma',
    '?'    => 'question mark',
    '/'    => 'stroke',
    '<BT>' => 'B T',
    '<HH>' => 'correction',
    '<KN>' => 'K N',
    '<SK>' => 'S K',
    '<AR>' => 'A R',
);

sub get_random_character() {
    my $random_character = "";
    while($random_character eq "") {
        $random_character = $characters[int rand @characters];

        my $index = 0;
        $index++ until $characters[$index] eq $random_character;
        splice(@characters, $index, 1);
    }
    return $random_character;
}


my $number_of_elements = scalar(@characters) / 2;
for(my $i=0; $i<$number_of_elements; $i++) {
    my $random_character1 = get_random_character();
    my $random_letter_safe1 = $random_character1;
    $random_letter_safe1 =~ s/(\.|\?)/\\\1/;

    my $random_safe_prounciation1 = $random_letter_safe1;
    if(defined $prononciation{$random_character1}) {
        $random_safe_prounciation1 = $prononciation{$random_character1};
        $random_safe_prounciation1 =~ s/\./\\./;
    }

    my $random_character2 = get_random_character();
    my $random_letter_safe2 = $random_character2;
    $random_letter_safe2 =~ s/(\.|\?)/\\\1/;

    my $random_safe_prounciation2 = $random_letter_safe2;
    if(defined $prononciation{$random_character2}) {
        $random_safe_prounciation2 = $prononciation{$random_character2};
        $random_safe_prounciation2 =~ s/\./\\./;
    }

    print "${random_letter_safe1}${random_letter_safe2} [${random_safe_prounciation1}, ${random_safe_prounciation2}]^\n";

}