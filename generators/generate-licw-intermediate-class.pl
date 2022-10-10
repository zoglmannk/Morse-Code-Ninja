#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-licw-intermediate-class.pl
#
# ./render.pl -i licw-bc2-class.txt -s 12 -z 1


my @letters_and_numbers = ('A'..'Z', '0'..'9');

my %prononciation = (
    'P'    => '<prosody rate="x-slow">P</prosody>',
    'K'    => 'K.',
    'T'    => 'T.',
    'U'    => '<prosody rate="x-slow">U</prosody>',
    'V'    => 'V.',
    '<AR>' => 'A R',
    '<SK>' => 'S K',
    '<BT>' => 'B T',
    '/'    => 'Slash',
    '<BK>' => 'B K',
    ','    => 'Comma',
    '.'    => 'Period'
);

my $number_of_runs = 800;


sub pick_rand_letters_and_numbers {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = $letters_and_numbers[int(rand(scalar @letters_and_numbers))];

        if($next_pick ne $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_character = "";

sub create_lesson {
    my $write_file_name = "licw-intermediate-class-a.txt";
    open(my $WRITE_FH2, '>', $write_file_name) or die $!;

    for (my $i=0; $i < $number_of_runs; $i++) {
        my $random_character = "";

        $random_character = pick_rand_letters_and_numbers($last_random_character);
        #print "old letter: $random_character\n";

        $last_random_character = $random_character;

        my $random_letter_safe = $random_character;
        $random_letter_safe =~ s/(\.|\?)/\\\1/;

        if(defined $prononciation{$random_character}) {
            my $random_safe_prounciation = $prononciation{$random_character};
            $random_safe_prounciation =~ s/\./\\./;

            if($random_safe_prounciation =~ m/prosody/) {
                $random_safe_prounciation = "<speak>" . $random_safe_prounciation . "</speak>";
            }

            print $WRITE_FH2 "$random_letter_safe [$random_safe_prounciation]^\n";
        } else {
            print $WRITE_FH2 "$random_letter_safe [$random_letter_safe]^\n";
        }

    }

    close($WRITE_FH2);
}

sub create_lesson2 {
    my $num_in_each_rep = $_[0];

    my $write_file_name = "licw-intermediate-class-" . (chr(ord('a')+$num_in_each_rep-1)). ".txt";
    open(my $WRITE_FH2, '>', $write_file_name) or die $!;

    for (my $i=0; $i < $number_of_runs; $i++) {
        my $random_character = "";
        my $random_characters = "";
        my $random_safe_prounciations = "";

        for (my $j=0; $j < $num_in_each_rep; $j++) {

            $random_character = pick_rand_letters_and_numbers($last_random_character);
            #print "old letter: $random_character\n";


            my $random_letter_safe = $random_character;
            $random_letter_safe =~ s/(\.|\?)/\\\1/;

            $random_characters .= $random_letter_safe;

            if (defined $prononciation{$random_character}) {
                my $random_safe_prounciation = $prononciation{$random_character};
                $random_safe_prounciation =~ s/\.//;
                if($random_safe_prounciations ne "" &&  $last_random_character =~ /\d/ && $random_character =~ /\d/) {
                    $random_safe_prounciations .= ", ";
                } elsif($random_safe_prounciations ne "") {
                    $random_safe_prounciations .= ",";
                }
                $random_safe_prounciations .= $random_safe_prounciation;
            }
            else {
                if($random_safe_prounciations ne "" && $last_random_character =~ /\d/ && $random_character =~ /\d/) {
                    $random_safe_prounciations .= ", ";
                } elsif ($random_safe_prounciations ne "") {
                    $random_safe_prounciations .= ",";
                }
                $random_safe_prounciations .= $random_letter_safe;
            }

            $last_random_character = $random_character;
        }

        if($random_safe_prounciations =~ m/prosody/) {
            $random_safe_prounciations = "<speak>" . $random_safe_prounciations . "</speak>";
        }

        print $WRITE_FH2 "$random_characters [$random_safe_prounciations]^\n";

    }

    close($WRITE_FH2);
}


create_lesson();
create_lesson2(2);
create_lesson2(3);

