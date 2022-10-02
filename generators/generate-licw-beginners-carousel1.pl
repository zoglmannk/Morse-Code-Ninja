#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-licw-beginners-carousel1.pl
#
# ./render.pl -i licw-beginners-carousel-2-lesson-1.txt -s 12 -z 1

my @carosel_1_lessons = (
    ['R', 'E', 'A'],
    ['T', 'I', 'N'],
    ['P', 'S', 'G'],
    ['L', 'C', 'D'],
    ['H', 'O', 'F'],
    ['U', 'W', 'B']
);

my %prononciation = (
    'P'    => '<prosody rate="x-slow">P</prosody>',
    'K'    => 'K.',
    'T'    => 'T.',
    'U'    => '<prosody rate="x-slow">U</prosody>',
    'V'    => 'V.'
);

my $number_of_runs = 800;
my $chance_of_new_letter = 50;

sub pick_rand_carosel_1_character {
    my $last_pick = $_[0];
    my $lesson = $_[1];

    while(1) {
        my $next_pick = $carosel_1_lessons[$lesson][int(rand(scalar @{ $carosel_1_lessons[$lesson]}))];

        if($next_pick ne $last_pick) {
            return $next_pick;
        }
    }
}

my $last_random_character = "";

sub create_lesson {
    my $lesson_num = $_[0];

    my $lesson_num_in_filename = $lesson_num + 1;
    my $write_file_name = "licw-beginners-carousel-1-lesson-${lesson_num_in_filename}a.txt";
    open(my $WRITE_FH2, '>', $write_file_name) or die $!;

    for (my $i=0; $i < $number_of_runs; $i++) {
        my $random_character = "";

        $random_character = pick_rand_carosel_1_character($last_random_character, $lesson_num);
        #print "new letter: $random_character\n";

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
    my $lesson_num = $_[0];
    my $num_in_each_rep = $_[1];

    my $lesson_num_in_filename = $lesson_num + 1;
    my $write_file_name = "licw-beginners-carousel-1-lesson-${lesson_num_in_filename}" . (chr(ord('a')+$num_in_each_rep-1)). ".txt";
    open(my $WRITE_FH2, '>', $write_file_name) or die $!;

    for (my $i=0; $i < $number_of_runs; $i++) {
        my $random_character = "";
        my $random_characters = "";
        my $random_safe_prounciations = "";

        for (my $j=0; $j < $num_in_each_rep; $j++) {

            $random_character = pick_rand_carosel_1_character($last_random_character, $lesson_num);
            #print "new letter: $random_character\n";

            my $random_letter_safe = $random_character;
            $random_letter_safe =~ s/(\.|\?)/\\\1/;

            $last_random_character = $random_character;
            $random_characters .= $random_letter_safe;

            if (defined $prononciation{$random_character}) {
                my $random_safe_prounciation = $prononciation{$random_character};
                $random_safe_prounciation =~ s/\.//;
                if($random_safe_prounciations ne "") {
                    if($lesson_num == 1) {
                        $random_safe_prounciations .= ", ";
                    } else {
                        $random_safe_prounciations .= ",";
                    }

                }
                $random_safe_prounciations .= $random_safe_prounciation;
            }
            else {
                if($random_safe_prounciations ne "") {
                    if($lesson_num == 1) {
                        $random_safe_prounciations .= ", ";
                    } else {
                        $random_safe_prounciations .= ",";
                    }
                }
                $random_safe_prounciations .= $random_letter_safe;
            }
        }

        if($random_safe_prounciations =~ m/prosody/) {
            $random_safe_prounciations = "<speak>" . $random_safe_prounciations . "</speak>";
        }


        print $WRITE_FH2 "$random_characters [$random_safe_prounciations]^\n";

    }

    close($WRITE_FH2);
}


my $num_lessons = scalar @carosel_1_lessons;
for(my $i=0; $i < $num_lessons; $i++) {
    create_lesson($i);
    create_lesson2($i, 2);
    create_lesson2($i, 3);
}
