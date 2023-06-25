#!/usr/bin/perl
use strict;
use warnings;

use Math::Random::MT;
my $gen = Math::Random::MT->new(54);
my $seed = $gen->get_seed();

# Render everything but Call Signs and Words
# ls -1 | grep 'txt' | grep -v 'Call Signs' | grep -v 'Words' | grep -E '\d+ Lesson' | xargs -IXX ./render.pl -e STANDARD -i "XX" -s 20/10 25/10 30/10 --norepeat --nocourtesytone --sm 0.4
#
# Render Words and Call Signs
# ls -1 | grep 'txt' |  grep -E 'Call Signs|Words' | grep -E '\d+ Lesson' | xargs -IXX ./render.pl -e STANDARD -i "XX" -s 20/10 25/10 30/10 --sm 0.4 --sv 1

# Render ramp up
# ./render.pl -e STANDARD -i '256 Lesson 42a Words 12.txt' -s 20/12 25/12 30/12 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '257 Lesson 42b Words 14.txt' -s 20/14 25/14 30/14 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '258 Lesson 42c Words 16.txt' -s 20/16 25/16 30/16 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '259 Lesson 42d Words 18.txt' -s 20/18 25/18 30/18 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '260 Lesson 42e Words 20.txt' -s 20/20 25/20 30/20 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '261 Lesson 42f Words 22.txt' -s 25/22 30/22 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '262 Lesson 42g Words 25.txt' -s 25/25 30/25 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '263 Lesson 42h Words 28.txt' -s 30/28 --sm 0.6 --sv 1
# ./render.pl -e STANDARD -i '264 Lesson 42i Words 30.txt' -s 30/30 --sm 0.6 --sv 1

my @character_order = (
    't', 'a', 'e', 'n', 'o', 'i', 's', '1', '4', 'r', 'h', 'd', 'l',
    '2', '5', 'c', 'u', 'm', 'w', '3', '6', '?', 'f', 'y', 'p', 'g',
    '7', '9', '/', 'b', 'v', 'k', 'j', '8', '0', '<BT>', 'x', 'q', 'z',
    '<BK>', '.'
);

sub safe_character_for_filename {
    my $chr = $_[0];

    if($chr eq '/') {
        return 'slash';
    } elsif($chr eq '<BT>') {
        return 'BT';
    } elsif($chr eq '.') {
        return 'period';
    } elsif($chr eq '<BK>') {
        return 'BK';
    } elsif($chr eq '?') {
        return 'question_mark'
    } else {
        return $chr;
    }
}

sub get_file_name {
    my $chr = $_[0];
    my $partial_name = $_[1];

    for(my $i=0; $i<(scalar @character_order); $i++) {
        if($character_order[$i] eq $chr) {
            my $character = $character_order[$i];
            my $base_filename = "lesson_";
            my $filename = $base_filename . (sprintf '%02d', $i+1) . $partial_name . "_" . safe_character_for_filename($character) . ".txt";

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

#print "e . g -> " . get_safe_output("e . g\n");
#print "? g . [? g .] -> " . get_safe_output("? g . [? g .]^\n");
#print "? g . [? g .|? g .] -> " . get_safe_output("? g . [? g .|? g .]^\n");
#print "r . r . [r . .]^ -> " . get_safe_output("r . r . [r . .]^\n");
#exit(1);

sub generate_lesson_a {

    # Lesson A - Generate files to introduce each letter
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        my $filename = get_file_name($character, "a_introduce_letter");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $line = get_safe_output((($character . " ") x 4) . " [" . $character . "|" . $character . "]^\n");
        my $output = (($line x 5) . "\n") x 4;

        print $fh $output;
        close $fh;
    }
}

# returns a random integer between 1 and max (inclusive)
my @last_picks = (0,0,0); #limit to no more than 3 consecutive picks of the same number
sub pick_random{
    my $max = $_[0];

    my $ret = 0;
    while(1==1) {

        # Ensure there is at least a 10% chance of seeing the new character
        if(int($gen->rand(100)) <= 10) {
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

        my $filename = get_file_name($character, "b_character_repeat_3x");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $num_entries = 600;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @available_chars);
            my $selected_char = $available_chars[$rand_index];

            my $line = (($selected_char . " ") x 3) . "[$selected_char|$selected_char]^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }
}


# Lesson C - Hear a letter 1x
# T ^
sub generate_lesson_c {

    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, "c_1character");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $num_entries = 600;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @available_chars);
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
sub generate_lesson_d {

    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, "d_2characters");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $num_entries = 600;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $line = "";
            for(my $k = 0; $k<2; $k++) {
                my $rand_index = pick_random(scalar @available_chars);
                my $selected_char = $available_chars[$rand_index];
                if($k !=0) {
                    $line .= " ";
                }
                $line .= $selected_char;
            }

            my $line_ending = $line;
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
sub generate_lesson_e {

    my @available_chars = [];
    for (my $i = 0; $i < (scalar @character_order); $i++) {

        my $character = $character_order[$i];
        push @available_chars, $character;

        if ($i == 0) {
            next;
        }

        my $filename = get_file_name($character, "e_3characters");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $num_entries = 400;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $line = "";
            for(my $k = 0; $k<3; $k++) {
                my $rand_index = pick_random(scalar @available_chars);
                my $selected_char = $available_chars[$rand_index];
                $line .= $selected_char . " ";
            }
            my $line_ending = $line;
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
sub generate_lesson_f {
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
            if($dict_word_length == $dict_word_remaining_char_length && length($dict_word) <= 4 ) {
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
        print "$available_chars num_words: " . (scalar @priority_dictionary) . "\n";

        my $filename = get_file_name($character, "f_words");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $num_entries = 500;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @priority_dictionary);
            my $selected_word = $priority_dictionary[$rand_index];
            my $line .= $selected_word . " ^\n";
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
sub generate_lesson_g {
    my @callsigns = load_callsigns();
    print "total callsigns: ".scalar @callsigns."\n";

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
        print "$available_chars num_calls: " . (scalar @priority_callsigns) . "\n";

        my $filename = get_file_name($character, "g_callsigns");
        open my $fh, '>', $filename or die "Can't open file $!";

        my $num_entries = 500;
        for(my $j = 0; $j < $num_entries; $j++) {
            my $rand_index = pick_random(scalar @priority_callsigns);
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
            my $line .= $selected_call . " [". $pronounced_call ."] ^\n";
            $line = get_safe_output($line);
            print $fh $line;
        }

        close $fh;
    }

}

sub rename_files {
    opendir(my $DIR, ".") or die "Failed to open directory: $!";
    my @files = sort grep { /^lesson_\d+/ && -f "$_" } readdir($DIR);
    closedir($DIR);

    my $count = 1;

    foreach my $file (@files) {
        my $new_name = sprintf("%03d %s", $count, $file);
        if ($new_name =~ /(\d+) lesson_(\d+\S)_(character_repeat_3x|introduce_letter|[^_]+)_(\S+).txt/) {
            my $num = $1;
            my $lesson_group = $2;
            my $lesson_type = $3;
            my $character = $4;

            $lesson_type =~ s/introduce_letter/Introduction/;
            $lesson_type =~ s/words/Words/;
            $lesson_type =~ s/callsigns/Call Signs/;
            $lesson_type =~ s/1character/Single Character/;
            $lesson_type =~ s/2characters/Two Characters/;
            $lesson_type =~ s/3characters/Three Characters/;
            $lesson_type =~ s/character_repeat_3x/Single Character Repeated 3x/;

            if($character =~ /^([0-9])$/) {
                $character = "Number $1";
            } elsif ($character =~ /^([a-z])$/) {
                $character = "Letter $1";
            } elsif ($character eq 'period') {
                $character = "Period";
            } elsif ($character eq 'slash') {
                $character = "Slash";
            } elsif ($character eq 'question_mark') {
                $character = "Question Mark";
            }

            $new_name = "$num Lesson $lesson_group - $character - ${lesson_type}.txt";
        }
        rename("$file", "$new_name") or die "Failed to rename file: $!";
        $count++;
    }

}

generate_lesson_a();
generate_lesson_b();
generate_lesson_c();
generate_lesson_d();
generate_lesson_e();
generate_lesson_f();
generate_lesson_g();

rename_files();