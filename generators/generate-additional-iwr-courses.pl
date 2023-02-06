#!/usr/bin/perl

use strict;
use Cwd;

## ./generate-additional-iwr-courses.pl

open(my $WRITE_RENDER_FH, '>', "render_courses.bash") or die $!;

my $working_delay = 1000;
my $probability_of_selecting_new_word = 40; # out of 100
my $num_of_runs = 600;
my $max_repeats = 3;

my @working_words = ();
my @words = ();
my %all_previous_word_hash = ();
my @sentences = ();
my $course_num = 2;

my %taste_of_iwr_words = (
    can   => 1,
    not   => 1,
    here  => 1,
    bad   => 1,
    how   => 1,
    there => 1,
    do    => 1,
    did   => 1,
    more  => 1,
    like  => 1,
    her   => 1,
    get   => 1,
    what  => 1,
    tell  => 1,
    she   => 1,
    to    => 1,
    you   => 1,
    will  => 1,
    me    => 1,
    where => 1,
    it    => 1,
    is    => 1,
    know  => 1,
    would => 1,
    about => 1
);

sub load_words {
    my $filename = $_[0];
    my $is_previous_course = $_[1];

    #print "load words from: $filename\n";
    if($is_previous_course == 0) {
        @words = ();
        @working_words = ();
    }

    open my $in, "<", $filename or
        die "couldn't open file $filename: $!";
    my @lines = <$in>;
    close $in;

    foreach(@lines) {
        my $line = $_;
        chomp($line);

        if($line =~ m/^(\d+:)\s*(\w+)$/) {
            my $word = $2;
            #print "$word\n";
            if($is_previous_course == 0) {
                push(@words, $word);
            }
            $all_previous_word_hash{$word} = 1;
        } else {
            print "bad line: $line\t\t in filename: $filename\n";
            exit 1;
        }
    }
}

sub load_words_for_course {
    my $course_num = $_[0];

    for(my $i=2; $i <= $course_num; $i++) {
        my $filename = "data/iwr-course-" . $i . "-words.txt";
        if($i == $course_num) {
            load_words($filename, 0);
        } else {
            load_words($filename, 0);
        }
    }
}

sub load_sentences {
    my $course_num = $_[0];
    my $filename = "data/iwr-course-" . $course_num . "-sentences.txt";

    @sentences = ();

    open my $in, "<", $filename or
        die "couldn't open $filename: $!";
    my @lines = <$in>;
    close $in;

    foreach(@lines) {
        my $line = $_;
        chomp($line);
        $line = lc($line);

        $line =~ s/^\s+|\s+$//;
        if($line ne "") {
            my @words = split(/\s+/, $line);
            foreach(@words) {
                my $word = $_;
                $word =~ s/,|\.|\?//g;
                if($all_previous_word_hash{$word} != 1 && $taste_of_iwr_words{$word} != 1) {
                    print "bad word: XXXX${word}XXXX\t sentence:\"$line\"\t in file:$filename\n";
                    exit 1;
                }
            }
            #print "$line\n";
            push(@sentences, $line);
        }
    }
}


my $last_pick = "";
my $num_repeated = 0;
sub pick_random_word {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];

    while(1 == 1) {
        my $ret = "";

        if(int(rand(100)) <= $probability_of_selecting_new_word) {
            $ret = $new_word;
        } else {
            my $next_pick = @working_words[int(rand(scalar @working_words))];
            $ret = $next_pick;
        }

        if( ($allow_repeat == 1 && $num_repeated+1 < $max_repeats) || $ret ne $last_pick) {
            if($last_pick eq $ret) {
                $num_repeated += 1;
            } else {
                $num_repeated = 0;
            }
            $last_pick = $ret;
            return $ret;
        }
    }
}

my $last_pick_sentence = "";
sub pick_random_sentence {
    while(1 == 1) {

        my $next_pick_sentence = @sentences[int(rand(scalar @sentences))];
        if($next_pick_sentence ne $last_pick_sentence) {
            $last_pick_sentence = $next_pick_sentence;
            return $next_pick_sentence;
        }

    }
}

sub right_pad {
    my $str = $_[0];
    my $len = $_[1];
    my $chr = $_[2];

    return substr($str . ($chr x $len), 0, $len);
}

sub generate_introduction {
    my $word = $_[0];
    my $lesson_num = $_[1];

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($word) . " - Introduce New Word.txt";
    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..20) {
        print $WRITE_FH "$word |S$working_delay $word |S$working_delay $word |S$working_delay $word [$word|$word]^\n";
    }

    close($WRITE_FH);
}

sub generate_single_word_repeated_3x {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_words = $_[3];

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($new_word) . " - Single Word Repeated 3x.txt";
    if($is_review_all_words == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review All Words - Single Word Repeated 3x.txt";
    }
    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_word = pick_random_word($new_word, $allow_repeat);
        print $WRITE_FH "$rand_word |S$working_delay $rand_word |S$working_delay $rand_word [$rand_word|$rand_word]^\n";
    }

}

sub generate_single_word {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_words = $_[3];

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($new_word) . " - Single Word.txt";
    if($is_review_all_words == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review All Words - Single Word.txt";
    }
    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_word = pick_random_word($new_word, $allow_repeat);
        print $WRITE_FH "$rand_word^\n";
    }

}

sub generate_two_words {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_words = $_[3];

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($new_word) . " - Two Words.txt";
    if($is_review_all_words == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review All Words - Two Words.txt";
    }

    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_word1 = pick_random_word($new_word, $allow_repeat);
        my $rand_word2 = pick_random_word($new_word, $allow_repeat);
        print $WRITE_FH "$rand_word1 |S$working_delay $rand_word2 [$rand_word1, $rand_word2]^\n";
    }

}

sub generate_sentences {
    my $lesson_num = $_[0];
    my $extra_word_spacing = $_[1];

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Sentences - ". $extra_word_spacing ."x Word Spacing.txt";
    if ($extra_word_spacing == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Sentences - Standard Spacing.txt";
    }

    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_sentence = pick_random_sentence();
        print $WRITE_FH "$rand_sentence^\n";
    }
}

my $original_probability_of_selecting_new_word = $probability_of_selecting_new_word;
sub generate_course {
    my $lesson_num=1;
    $probability_of_selecting_new_word = $original_probability_of_selecting_new_word;

    for(my $i=0; $i < scalar(@words); $i++) {
        my $word = $words[$i];
        generate_introduction($word, $lesson_num);
        $lesson_num += 1;
        my $is_review_all_words = 0;

        if($i > 0) {
            my $allow_back_to_back_repeats = 1;
            if ($i >= 4) {
                $allow_back_to_back_repeats = 0;
            }
            generate_single_word_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
            $lesson_num += 1;

            generate_single_word($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
            $lesson_num += 1;

            generate_two_words($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
            $lesson_num += 1;
        }
        push(@working_words, $word);

    }

    my $word = $words[scalar(@words)-1];
    my $allow_back_to_back_repeats = 0;
    my $is_review_all_words = 1;
    $probability_of_selecting_new_word = -1; #disables boosting probability of selecting new word. This is a review after all. :)
    generate_single_word_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
    $lesson_num += 1;

    generate_single_word($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
    $lesson_num += 1;

    generate_two_words($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
    $lesson_num += 1;

    generate_sentences($lesson_num, 8);
    $lesson_num += 1;
    generate_sentences($lesson_num, 6);
    $lesson_num += 1;
    generate_sentences($lesson_num, 4);
    $lesson_num += 1;
    generate_sentences($lesson_num, 3);
    $lesson_num += 1;
    generate_sentences($lesson_num, 2);
    $lesson_num += 1;
    generate_sentences($lesson_num, 1);
    $lesson_num += 1;
}

print $WRITE_RENDER_FH "#!/bin/bash\n\n";
print $WRITE_RENDER_FH "\n\n# Watch output\n";
print $WRITE_RENDER_FH "# watch '/bin/ls -1 Course*.mp3 | grep Course | tail -n 20'\n\n";
for($course_num = 2; $course_num <= 8; $course_num++) {
    load_words_for_course($course_num);
    load_sentences($course_num);
    generate_course();

    print $WRITE_RENDER_FH "./render.pl -i 'Course " . (sprintf '%02d', $course_num) . " - Lesson 101 - Sentences - 8x Word Spacing.txt' -s 40 50 -x 8 --sm 1.5\n";
    print $WRITE_RENDER_FH "./render.pl -i 'Course " . (sprintf '%02d', $course_num) . " - Lesson 102 - Sentences - 6x Word Spacing.txt' -s 40 50 -x 6 --sm 1.5\n";
    print $WRITE_RENDER_FH "./render.pl -i 'Course " . (sprintf '%02d', $course_num) . " - Lesson 103 - Sentences - 4x Word Spacing.txt' -s 40 50 -x 4 --sm 1.5\n";
    print $WRITE_RENDER_FH "./render.pl -i 'Course " . (sprintf '%02d', $course_num) . " - Lesson 104 - Sentences - 3x Word Spacing.txt' -s 40 50 -x 3 --sm 1.5\n";
    print $WRITE_RENDER_FH "./render.pl -i 'Course " . (sprintf '%02d', $course_num) . " - Lesson 105 - Sentences - 2x Word Spacing.txt' -s 40 50 -x 2 --sm 1.5\n";
    print $WRITE_RENDER_FH "./render.pl -i 'Course " . (sprintf '%02d', $course_num) . " - Lesson 106 - Sentences - Standard Spacing.txt' -s 40 50 --sm 1.5\n\n";
}
close($WRITE_RENDER_FH);

