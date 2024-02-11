#!/usr/bin/perl
use strict;
use warnings;

use Math::Random::MT;
my $gen = Math::Random::MT->new(154);
my $seed = $gen->get_seed();


open my $render_fh, '>', "_render-me.bash" or die "Can't open file $!";
print $render_fh "#!/bin/bash\n";

my @character_order = (
    't', 'a', 'e', 'n', 'o', 'i', 's', '1', '4', 'r', 'h', 'd', 'l',
    '2', '5', 'c', 'u', 'm', 'w', '3', '6', '?', 'f', 'y', 'p', 'g',
    '7', '9', '/', 'b', 'v', 'k', 'j', '8', '0', '<BT>', 'x', 'q', 'z',
    '<BK>', '.'
);

sub safe_character_for_filename {
    my $chr = $_[0];

    if($chr eq '/') {
        return 'Slash';
    } elsif($chr eq '<BT>') {
        return 'BT';
    } elsif($chr eq '.') {
        return 'Period';
    } elsif($chr eq '<BK>') {
        return 'BK';
    } elsif($chr eq '?') {
        return 'Question Mark'
    } else {
        return $chr;
    }
}

sub get_file_name {
    my $chr = $_[0];
    my $grouping_letter = $_[1];
    my $grouping_desc = $_[2];

    for(my $i=0; $i<(scalar @character_order); $i++) {
        my $base_filename = "Lesson";
        if($character_order[$i] eq $chr) {
            my $character = $character_order[$i];
            my $char_desc = "";

            if ($character =~ m/^[A-Za-z]$/) {
                $char_desc = "Letter ";
            } elsif ($character =~ m/^[0-9]$/) {
                $char_desc = "Number ";
            }

            my $filename = $base_filename . " " . (sprintf '%02d', $i+1) . $grouping_letter . " - " . $char_desc . safe_character_for_filename($character) . " - " . $grouping_desc . ".txt";

            return $filename;
        } elsif($chr eq 'All Letters' || $chr eq 'All Characters') {
            my $filename = $base_filename . " " . (sprintf '%02d', 42) . $grouping_letter . " - ". $chr . " - " . $grouping_desc . ".txt";

            return $filename;
        }

    }

    die "chr $chr not found while creating filename";
}

sub get_safe_output {
    my $in = $_[0];

    # simple - x x x or
    if($in =~ m/^([^[]+)$/) {
        $in =~ s/\./\\./g;
        $in =~ s/\?/\\?/g;

    # x x x [x x x]
    } elsif ($in =~ m/^([^[]+)(\[[^\|]+]\s*\^?\s*)$/) {
        my $part1 = $1;
        my $part2 = $2;

        $part1 =~ s/\./\\./g;
        $part1 =~ s/\?/\\?/g;

        $part2 =~ s/\./ period /g;
        $part2 =~ s/\?/ question mark /g;
        $part2 =~ s/\// slash /g;

        # [x,<XX>] -> [x, <XX>]
        $part2 =~ s/(.*?),(<.*>)/$1, $2/g;

        # [<XX>,x] -> [<XX>, x]
        $part2 =~ s/(<.*>),(.*?)/$1, $2/g;

        # [9,8] -> [9, 8]
        $part2 =~ s/(\d+),(\d+)/$1, $2/g;

        $in = $part1 . $part2;

    } elsif ($in =~ m/^([^[]+)(\[[^\|]+)(\|.*]\s*\^?\s*)$/) {
        my $part1 = $1;
        my $part2 = $2;
        my $part3 = $3;

        $part1 =~ s/\./\\./g;
        $part1 =~ s/\?/\\?/g;

        $part2 =~ s/\./ period /g;
        $part2 =~ s/\?/ question mark /g;
        $part2 =~ s/\// slash /g;

        $part3 =~ s/\./\\./g;
        $part3 =~ s/\?/\\?/g;

        $in = $part1 . $part2 . $part3;
    }

    $in =~ s/\s+]/]/;

    return $in;

}

sub generate_lesson_a {

    # Lesson A - Generate files to introduce each letter
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        my $filename = get_file_name($character, "a", "Introduce Letter");
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 --charactermultiplier 8 --norepeat --nocourtesytone\n";

        my $line = get_safe_output((($character) x 4) . " [" . $character . "|" . $character . "]^\n");
        my $output = (($line x 5) . "\n") x 4;

        print $fh $output;
        close $fh;
    }
}

# returns a random integer between 1 and max (inclusive)
my @last_picks = (0,0,0); #limit to no more than 3 consecutive picks of the same number
sub pick_random{
    my $max = $_[0];
    my $increase_chance_of_last_character = $_[1];

    my $ret = 0;
    while(1==1) {

        # Ensure there is at least a 10% chance of seeing the new character
        if(int($gen->rand(100)) <= 10 && $increase_chance_of_last_character == 1) {
            $ret = $max-1;
        } else {
            $ret = int($gen->rand($max-1))+1;
        }

        if(
            ($max <= 5 && !($last_picks[0]==$last_picks[1] && $last_picks[1]==$last_picks[2]) || $ret!=$last_picks[2]) ||
            ($max > 5 && $ret != $last_picks[2])
        ) {
            shift @last_picks;
            push @last_picks, $ret;
            last;
        }
    }

    return $ret;
}

# Lesson B - Hear a letter 3x
# T T T [T|T]^
sub generate_lesson_b {

    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, "b", "Character Repeated 3x");
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 --charactermultiplier 8 --norepeat --nocourtesytone\n";

        my $num_entries = 600;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @available_chars, 1);
            my $selected_char = $available_chars[$rand_index];

            my $line = (($selected_char) x 3) . "[$selected_char|$selected_char]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }
}


# Lesson C
# T ^
sub generate_lesson_c_thru_h {
    my $which_lesson = $_[0];
    my $lesson_filename_desc = "";
    my $extra_render_arguments = "";

    if($which_lesson eq "c") {
        $lesson_filename_desc = "Single Character";
        $extra_render_arguments = "--sm 1.5";
    } elsif($which_lesson eq "d") {
        $lesson_filename_desc = "Single Character - Quick";
        $extra_render_arguments = "";
    } elsif($which_lesson eq "e") {
        $lesson_filename_desc = "Single Character - Fast";
        $extra_render_arguments = "--sm 0.6";
    } elsif($which_lesson eq "f") {
        $lesson_filename_desc = "Single Character - Rapid-Fire";
        $extra_render_arguments = "--sm 0.2 -sv 0.3 -ss 0.3";
    } elsif($which_lesson eq "g") {
        $lesson_filename_desc = "Single Character - Mind-Melt";
        $extra_render_arguments = "--norepeat --nocourtesytone -ss 0.2 -sm 0.2 -sv 0.2";
    } elsif($which_lesson eq "h") {
        $lesson_filename_desc = "Single Character - Speed-Racing";
        $extra_render_arguments = "-s 25 -z 1";
    } else {
       die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }

    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 600;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @available_chars, 1);
            my $selected_char = $available_chars[$rand_index];
            my $line = "$selected_char [$selected_char]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }
}

# Lesson D - Hear two letter
# T A ^
sub generate_lesson_i_thru_n {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "i") {
        $lesson_filename_desc = "Two Characters - 8x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 8 --standardspeedrepeat 1 --sm 0.1 --ss 0.5";
    } elsif($which_lesson eq "j") {
        $lesson_filename_desc = "Two Characters - 6x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 6 --standardspeedrepeat 1 --sm 0.3 --ss 0.6";
    } elsif($which_lesson eq "k") {
        $lesson_filename_desc = "Two Characters - 4x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 4 --standardspeedrepeat 1 --sm 0.7 --ss 0.7";
    } elsif($which_lesson eq "l") {
        $lesson_filename_desc = "Two Characters - 3x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 3 --standardspeedrepeat 1 --sm 0.8 --ss 0.8";
    } elsif($which_lesson eq "m") {
        $lesson_filename_desc = "Two Characters - 2x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 2 --standardspeedrepeat 1 --sm 0.9 --ss 0.9";
    }elsif($which_lesson eq "n") {
        $lesson_filename_desc = "Two Characters - Standard Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }


    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 600;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $line = "";
            my $line2 = "";
            for(my $k = 0; $k<2; $k++) {
                my $rand_index = pick_random(scalar @available_chars, 1);
                my $selected_char = $available_chars[$rand_index];
                if($k !=0) {
                    $line2 .= " ";
                }
                $line .= $selected_char;
                $line2 .= $selected_char;
            }

            my $line_ending = $line2;
            $line_ending =~ s/ /,/g;

            $line .= " [" . $line_ending . "]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }
}

# Lesson E - Hear three letters
# T A A ^
sub generate_lesson_o_thru_t {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "o") {
        $lesson_filename_desc = "Three Characters - 8x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 8 --standardspeedrepeat 1 --sm 0.1 --ss 0.5";
    } elsif($which_lesson eq "p") {
        $lesson_filename_desc = "Three Characters - 6x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 6 --standardspeedrepeat 1 --sm 0.3 --ss 0.6";
    } elsif($which_lesson eq "q") {
        $lesson_filename_desc = "Three Characters - 4x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 4 --standardspeedrepeat 1 --sm 0.7 --ss 0.7";
    } elsif($which_lesson eq "r") {
        $lesson_filename_desc = "Three Characters - 3x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 3 --standardspeedrepeat 1 --sm 0.8 --ss 0.8";
    } elsif($which_lesson eq "s") {
        $lesson_filename_desc = "Three Characters - 2x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 2 --standardspeedrepeat 1 --sm 0.9 --ss 0.9";
    }elsif($which_lesson eq "t") {
        $lesson_filename_desc = "Three Characters - Standard Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }

    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 400;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $line = "";
            my $line2 = "";
            for(my $k = 0; $k<3; $k++) {
                my $rand_index = pick_random(scalar @available_chars, 1);
                my $selected_char = $available_chars[$rand_index];
                $line .= $selected_char;
                $line2 .= $selected_char . " ";
            }
            $line .= " ";
            my $line_ending = $line2;
            $line_ending =~ s/ /,/g;
            chop($line_ending);

            $line .= "[" . $line_ending . "]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }
}

sub load_dictionary {
    my @dictionary;

    open my $fh, "<", "data/morse-camp-words-js.txt" or die "Can't open dictionary $!";
    while(my $line = <$fh>) {
        #  ["the", "a", 22038615, "Word"],

        if($line =~ m/^\s*\["(.*?)",\s*".*?",\s*\d+,\s*"(.*?)"\s*\],\s*$/) {
            if($2 eq "Word") {
                my $word = $1;
                push @dictionary, $word;
                #print "$word\n";
            }
        }

    }

    close $fh;
    return @dictionary;
}

# Lesson F - Random words based on letters introduced
# C A T ^
sub generate_lesson_u_thru_z {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "u") {
        $lesson_filename_desc = "Words - 8x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 8 --standardspeedrepeat 1";
    } elsif($which_lesson eq "v") {
        $lesson_filename_desc = "Words - 6x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 6 --standardspeedrepeat 1";
    } elsif($which_lesson eq "w") {
        $lesson_filename_desc = "Words - 4x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 4 --standardspeedrepeat 1";
    } elsif($which_lesson eq "x") {
        $lesson_filename_desc = "Words - 3x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 3 --standardspeedrepeat 1";
    } elsif($which_lesson eq "y") {
        $lesson_filename_desc = "Words - 2x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 2 --standardspeedrepeat 1";
    }elsif($which_lesson eq "z") {
        $lesson_filename_desc = "Words - Standard Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }


    my @dictionary = load_dictionary();

    my $available_chars = "";
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        $available_chars .= $character;

        if ($i < 2 || $character !~ m/[a-z]/) {
            next;
        }

        #find matching words in dictionary
        my @available_dictionary;
        my @priority_dictionary;
        for(my $j=0; $j < (scalar @dictionary); $j++) {
            my $dict_word = $dictionary[$j];
            my $dict_word_length = length($dict_word);
            my $dict_word_mod = $dict_word =~ s/[^$available_chars]//gr;
            my $dict_word_remaining_char_length = length($dict_word_mod);
            if($dict_word_length == $dict_word_remaining_char_length && length($dict_word) <= 4 && $dict_word ne 'ie') {
                #print "$available_chars  matches  $dict_word  .. $dict_word_mod\n";
                if($dict_word =~ m/[$character]/) {
                    push @priority_dictionary, $dict_word;
                } else {
                    push @available_dictionary, $dict_word;
                }
            }
        }
        #print "$available_chars match num_Priority_words: ".(scalar @priority_dictionary)."  num_other_words: ".(scalar @available_dictionary)."\n";

        foreach my $available_word (@available_dictionary) {
            if(scalar @priority_dictionary < 150) {
                push @priority_dictionary, $available_word;
            } else {
                last;
            }
        }
        if($which_lesson eq "u") {
            print "$available_chars num_words: " . (scalar @priority_dictionary) . "\n";
        }

        my $filename = get_file_name($character, $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 500;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @priority_dictionary, 1);
            my $selected_word = $priority_dictionary[$rand_index];
            my $line .= $selected_word . "^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }

}


# Lesson F - Random words based on letters introduced
# C A T ^
sub generate_lesson_42_a_thru_f {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "a") {
        $lesson_filename_desc = "Words - 8x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 8 --standardspeedrepeat 1";
    } elsif($which_lesson eq "b") {
        $lesson_filename_desc = "Words - 6x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 6 --standardspeedrepeat 1";
    } elsif($which_lesson eq "c") {
        $lesson_filename_desc = "Words - 4x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 4 --standardspeedrepeat 1";
    } elsif($which_lesson eq "d") {
        $lesson_filename_desc = "Words - 3x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 3 --standardspeedrepeat 1";
    } elsif($which_lesson eq "e") {
        $lesson_filename_desc = "Words - 2x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 2 --standardspeedrepeat 1";
    }elsif($which_lesson eq "f") {
        $lesson_filename_desc = "Words - Standard Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }


    my @dictionary = load_dictionary();

    #find matching words in dictionary
    my @available_dictionary;
    for(my $j=0; $j < (scalar @dictionary); $j++) {
        my $dict_word = $dictionary[$j];
        if(length($dict_word) <= 4 && $dict_word ne 'ie') {
            push @available_dictionary, $dict_word;
        }
    }

    my $filename = get_file_name("All Letters", $which_lesson, $lesson_filename_desc);
    open my $fh, '>', $filename or die "Can't open file $!";
    print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

    my $num_entries = 500;
    for(my $j = 0; $j < $num_entries; $j++) {
        my $rand_index = pick_random(scalar @available_dictionary, 0);
        my $selected_word = $available_dictionary[$rand_index];
        my $line .= $selected_word . "^\n";
        $line = get_safe_output($line);
        print $fh $line;
    }

    close $fh;

}

# Lesson F - Random Two words based on letters introduced
# C A T ^
sub generate_lesson_za_thru_zd {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "za") {
        $lesson_filename_desc = "Two Words - 4x Word-Spacing";
        $extra_render_arguments = "-x 3";
    } elsif($which_lesson eq "zb") {
        $lesson_filename_desc = "Two Words - 3x Word-Spacing";
        $extra_render_arguments = "-x 2";
    } elsif($which_lesson eq "zc") {
        $lesson_filename_desc = "Two Words - 2x Word-Spacing";
        $extra_render_arguments = "-x 1";
    } elsif($which_lesson eq "zd") {
        $lesson_filename_desc = "Two Words - Standard-Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }


    my @dictionary = load_dictionary();

    my $available_chars = "";
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        $available_chars .= $character;

        if ($i < 2 || $character !~ m/[a-z]/) {
            next;
        }

        #find matching words in dictionary
        my @available_dictionary;
        my @priority_dictionary;
        for(my $j=0; $j < (scalar @dictionary); $j++) {
            my $dict_word = $dictionary[$j];
            my $dict_word_length = length($dict_word);
            my $dict_word_mod = $dict_word =~ s/[^$available_chars]//gr;
            my $dict_word_remaining_char_length = length($dict_word_mod);
            if($dict_word_length == $dict_word_remaining_char_length && length($dict_word) <= 4 && $dict_word ne 'ie') {
                #print "$available_chars  matches  $dict_word  .. $dict_word_mod\n";
                if($dict_word =~ m/[$character]/) {
                    push @priority_dictionary, $dict_word;
                } else {
                    push @available_dictionary, $dict_word;
                }
            }
        }
        #print "$available_chars match num_Priority_words: ".(scalar @priority_dictionary)."  num_other_words: ".(scalar @available_dictionary)."\n";

        foreach my $available_word (@available_dictionary) {
            if(scalar @priority_dictionary < 150) {
                push @priority_dictionary, $available_word;
            } else {
                last;
            }
        }

        my $filename = get_file_name($character, $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 500;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index1 = pick_random(scalar @priority_dictionary, 1);
            my $rand_index2 = pick_random(scalar @priority_dictionary, 1);
            my $selected_word1 = $priority_dictionary[$rand_index1];
            my $selected_word2 = $priority_dictionary[$rand_index2];
            my $line .= "$selected_word1 ${selected_word2} [$selected_word1, $selected_word2]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }

}

# Lesson F - Random Two words based on letters introduced
# C A T ^
sub generate_lesson_42_g_thru_j {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "g") {
        $lesson_filename_desc = "Two Words - 4x Word-Spacing";
        $extra_render_arguments = "-x 3";
    } elsif($which_lesson eq "h") {
        $lesson_filename_desc = "Two Words - 3x Word-Spacing";
        $extra_render_arguments = "-x 2";
    } elsif($which_lesson eq "i") {
        $lesson_filename_desc = "Two Words - 2x Word-Spacing";
        $extra_render_arguments = "-x 1";
    } elsif($which_lesson eq "j") {
        $lesson_filename_desc = "Two Words - Standard-Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }


    my @dictionary = load_dictionary();

    my $available_chars = "";
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        $available_chars .= $character;

        if ($i < 2 || $character !~ m/[a-z]/) {
            next;
        }

        #find matching words in dictionary
        my @available_dictionary;
        for(my $j=0; $j < (scalar @dictionary); $j++) {
            my $dict_word = $dictionary[$j];
            if(length($dict_word) <= 4 && $dict_word ne 'ie') {
                push @available_dictionary, $dict_word;
            }
        }
        #print "$available_chars match num_Priority_words: ".(scalar @priority_dictionary)."  num_other_words: ".(scalar @available_dictionary)."\n";

        my $filename = get_file_name("All Letters", $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 500;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index1 = pick_random(scalar @available_dictionary, 0);
            my $rand_index2 = pick_random(scalar @available_dictionary, 0);
            my $selected_word1 = $available_dictionary[$rand_index1];
            my $selected_word2 = $available_dictionary[$rand_index2];
            my $line .= "$selected_word1 ${selected_word2} [$selected_word1, $selected_word2]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }

}

sub load_callsigns {
    my @callsigns;

    open my $fh, "<", "data/easy-callsigns.txt" or die "Can't open callsigns $!";
    while(my $line = <$fh>) {

        #N0ZHE,USA
        if($line =~ m/^([^,]+),\s*USA\s*$/) {
            my $callsign = $1;
            push @callsigns, $callsign;
            #print "$callsign\n";
        }

    }
    close $fh;
    return @callsigns;
}

# Lesson G - Callsigns based on letters and numbers introduced
# AD0WE ^
sub generate_lesson_42_k_thru_p {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "k") {
        $lesson_filename_desc = "Call Signs - 8x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 8 --standardspeedrepeat 1";
    } elsif($which_lesson eq "l") {
        $lesson_filename_desc = "Call Signs - 6x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 6 --standardspeedrepeat 1";
    } elsif($which_lesson eq "m") {
        $lesson_filename_desc = "Call Signs - 4x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 4 --standardspeedrepeat 1";
    } elsif($which_lesson eq "n") {
        $lesson_filename_desc = "Call Signs - 3x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 3 --standardspeedrepeat 1";
    } elsif($which_lesson eq "o") {
        $lesson_filename_desc = "Call Signs - 2x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 2 --standardspeedrepeat 1";
    }elsif($which_lesson eq "p") {
        $lesson_filename_desc = "Call Signs - Standard Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_42_g_thru_l: $which_lesson");
    }

    my @callsigns = load_callsigns();

    my $filename = get_file_name("All Characters", $which_lesson, $lesson_filename_desc);
    open my $fh, '>', $filename or die "Can't open file $!";
    print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

    my $num_entries = 500;
    for(my $j = 0; $j < $num_entries; $j++) {
        my $rand_index = pick_random(scalar @callsigns, 0);
        my $selected_call = $callsigns[$rand_index];

        # Ensure there is at least a 15% chance of seeing the slash character
        if(int($gen->rand(100)) <= 15) {
            my $modifier = "/P";
            if(int($gen->rand(100)) <= 50) {
                $modifier = "/M";
            }
            $selected_call = $selected_call . $modifier;
        }

        my $pronounced_call = $selected_call;
        $pronounced_call =~ s/([A-Za-z0-9])/$1 /g;
        $pronounced_call =~ s/([0-9])/$1,/g;
        my $line .= $selected_call . " [". $pronounced_call ."]^\n";
        $line = get_safe_output($line);
        print $fh $line;
    }

    close $fh;

}


# Lesson G - Callsigns based on letters and numbers introduced
# AD0WE ^
sub generate_lesson_ze_thru_zj {
    my $which_lesson = $_[0];
    my $extra_render_arguments = "";
    my $lesson_filename_desc = "";

    if($which_lesson eq "ze") {
        $lesson_filename_desc = "Call Signs - 8x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 8 --standardspeedrepeat 1";
    } elsif($which_lesson eq "zf") {
        $lesson_filename_desc = "Call Signs - 6x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 6 --standardspeedrepeat 1";
    } elsif($which_lesson eq "zg") {
        $lesson_filename_desc = "Call Signs - 4x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 4 --standardspeedrepeat 1";
    } elsif($which_lesson eq "zh") {
        $lesson_filename_desc = "Call Signs - 3x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 3 --standardspeedrepeat 1";
    } elsif($which_lesson eq "zi") {
        $lesson_filename_desc = "Call Signs - 2x Character-Spacing";
        $extra_render_arguments = "--charactermultiplier 2 --standardspeedrepeat 1";
    }elsif($which_lesson eq "zj") {
        $lesson_filename_desc = "Call Signs - Standard Spacing";
        $extra_render_arguments = "";
    } else {
        die("Should never get here. Invalid option to generate_lesson_c_thru_g: $which_lesson");
    }

    my @callsigns = load_callsigns();
    if($which_lesson eq "za") {
        print "total callsigns: ".scalar @callsigns."\n";
    }

    my $available_chars = "";
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        if(length($character) > 1 || $character =~ m/\?|\\|\./) {
            next;
        }
        $available_chars .= $character;

        #print "i: $i   ..  available_chars: ~~$available_chars~~\n";
        if($i < 2 || $available_chars !~ m/[0-9]/) {
            next;
        }

        #find matching words in dictionary
        my @available_callsigns;
        my @priority_callsigns;

        for(my $j=0; $j < (scalar @callsigns); $j++) {
            my $dict_call = $callsigns[$j];
            my $dict_call_length = length($dict_call);
            my $dict_call_mod = $dict_call =~ s/[^$available_chars]//gri;
            my $dict_call_remaining_char_length = length($dict_call_mod);
            if($dict_call_length == $dict_call_remaining_char_length ) {
                #print "$available_chars  matches  $dict_word  .. $dict_word_mod\n";
                if($dict_call =~ m/[$character]/) {
                    push @priority_callsigns, $dict_call;
                } else {
                    push @available_callsigns, $dict_call;
                }
            }
        }
        #print "$available_chars match num_Priority_calls: ".(scalar @priority_callsigns)."  num_other_calls: ".(scalar @available_callsigns)."\n";

        foreach my $available_call (@available_callsigns) {
            push @priority_callsigns, $available_call;
        }
        if($which_lesson eq "ze") {
            print "$available_chars num_calls: " . (scalar @priority_callsigns) . "\n";
        }

        my $filename = get_file_name($character, $which_lesson, $lesson_filename_desc);
        open my $fh, '>', $filename or die "Can't open file $!";
        print $render_fh "./render.pl -i \"$filename\" -s 20 25 30 35 $extra_render_arguments\n";

        my $num_entries = 500;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @priority_callsigns, 1);
            my $selected_call = $priority_callsigns[$rand_index];

            # Ensure there is at least a 25% chance of seeing the slash character for lesson 29g - Introduction of Slash
            if(int($gen->rand(100)) <= 25 && $i == 28) {
                my $modifier = "/P";
                if(int($gen->rand(100)) <= 50) {
                    $modifier = "/M";
                }
                $selected_call = $selected_call . $modifier;
            }

            my $pronounced_call = $selected_call;
            $pronounced_call =~ s/([A-Za-z0-9])/$1 /g;
            $pronounced_call =~ s/([0-9])/$1,/g;
            my $line .= $selected_call . " [". $pronounced_call ."]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }

}

my %file_rename_map;
sub rename_files {
    opendir(my $DIR, ".") or die "Failed to open directory: $!";
    my @files = sort grep { /^Lesson \d+\S+/ && -f "$_" } readdir($DIR);
    closedir($DIR);

    my $count = 1;

    foreach my $file (@files) {
        my $new_name = sprintf("%04d %s", $count, $file);
        $file_rename_map{$file} = $new_name;
        rename("$file", "$new_name") or die "Failed to rename file: $!";
        $count++;
    }

}

sub replace_with_map {
    my $filename = "_render-me.bash";

    open my $fh, '<', $filename or die "Cannot open file: $!";
    my @lines = <$fh>;
    close $fh;

    open my $out, '>', $filename or die "Cannot open file: $!";
    foreach my $line (@lines) {
        while ($line =~ /"([^"]*)"/g) {
            my $replace_val = $file_rename_map{$1};
            $line =~ s/"$1"/"$replace_val"/g if defined $replace_val;
        }
        print $out $line;
    }
    close $out;

    system("cat _render-me.bash | sort -k1.17n > _render-me2.bash");
    system("mv _render-me2.bash _render-me.bash");
    system("chmod a+rwx _render-me.bash");
}

#Introduction
generate_lesson_a();

# Single Character repeated
generate_lesson_b();

#Single Character (Not repeated) practice sets
generate_lesson_c_thru_h("c");
generate_lesson_c_thru_h("d");
generate_lesson_c_thru_h("e");
generate_lesson_c_thru_h("f");
generate_lesson_c_thru_h("g");
generate_lesson_c_thru_h("h");

#Two Character practice sets
generate_lesson_i_thru_n("i");
generate_lesson_i_thru_n("j");
generate_lesson_i_thru_n("k");
generate_lesson_i_thru_n("l");
generate_lesson_i_thru_n("m");
generate_lesson_i_thru_n("n");

#Three Character practice sets
generate_lesson_o_thru_t("o");
generate_lesson_o_thru_t("p");
generate_lesson_o_thru_t("q");
generate_lesson_o_thru_t("r");
generate_lesson_o_thru_t("s");
generate_lesson_o_thru_t("t");

#Words
generate_lesson_u_thru_z("u");
generate_lesson_u_thru_z("v");
generate_lesson_u_thru_z("w");
generate_lesson_u_thru_z("x");
generate_lesson_u_thru_z("y");
generate_lesson_u_thru_z("z");

#2 Words
generate_lesson_za_thru_zd("za");
generate_lesson_za_thru_zd("zb");
generate_lesson_za_thru_zd("zc");
generate_lesson_za_thru_zd("zd");

#Call Signs
generate_lesson_ze_thru_zj("ze");
generate_lesson_ze_thru_zj("zf");
generate_lesson_ze_thru_zj("zg");
generate_lesson_ze_thru_zj("zh");
generate_lesson_ze_thru_zj("zi");
generate_lesson_ze_thru_zj("zj");

#Generate Words with equal probability
generate_lesson_42_a_thru_f("a");
generate_lesson_42_a_thru_f("b");
generate_lesson_42_a_thru_f("c");
generate_lesson_42_a_thru_f("d");
generate_lesson_42_a_thru_f("e");
generate_lesson_42_a_thru_f("f");

#Generate Two Words with equal probability
generate_lesson_42_g_thru_j("g");
generate_lesson_42_g_thru_j("h");
generate_lesson_42_g_thru_j("i");
generate_lesson_42_g_thru_j("j");

#Generate Call Signs with equal probability
generate_lesson_42_k_thru_p("k");
generate_lesson_42_k_thru_p("l");
generate_lesson_42_k_thru_p("m");
generate_lesson_42_k_thru_p("n");
generate_lesson_42_k_thru_p("o");
generate_lesson_42_k_thru_p("p");

close($render_fh);

rename_files();
replace_with_map();