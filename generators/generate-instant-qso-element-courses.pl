#!/usr/bin/perl

use strict;
use Cwd;

## ./generate-instant-qso-element-course.pl


open(my $WRITE_RENDER_FH, '>', "render_courses.bash") or die $!;

my $working_delay = 1000;
my $probability_of_selecting_new_element = 40; # out of 100
my $num_of_runs = 600;
my $max_repeats = 3;

my @working_elements = ();
my @elements = ();
my @all_previous_course_elements = ();
my %all_previous_element_hash = ();
my %pronunciations = ();
my $course_num = 1;

sub load_elements {
    my $filename = $_[0];
    my $is_previous_course = $_[1];

    #print "load words from: $filename\n";
    if($is_previous_course == 0) {
        @elements = ();
        @working_elements = ();
    }

    open my $in, "<", $filename or
        die "couldn't open file $filename: $!";
    my @lines = <$in>;
    close $in;

    foreach(@lines) {
        my $line = $_;
        chomp($line);

        if($line =~ m/^([^\[]+?)\s+\[([^\]]+)]/) {
            my $element = $1;
            my $pronunciation = $2;

            $pronunciations{$element} = $pronunciation;
            #print "word: ${word}  pronunciation: $pronunciation\n";
            if($is_previous_course == 0) {
                push(@elements, $element);
            }
            push(@all_previous_course_elements, $element);
            $all_previous_element_hash{$element} = 1;
        } else {
            print "bad line: $line\t\t in filename: $filename\n";
            exit 1;
        }
    }
}

sub load_elements_for_course {
    my $course_num = $_[0];

    for(my $i=1; $i <= $course_num; $i++) {
        my $filename = "data/instant-qso-element-course-" . $i . ".txt";
        if($i == $course_num) {
            load_elements($filename, 0);
        } else {
            load_elements($filename, 1);
        }
    }
}


my $last_pick = "";
my $num_repeated = 0;
sub pick_random_element {
    my $new_element = $_[0];
    my $allow_repeat = $_[1];
    my $pick_from_previous_courses = $_[2];

    while(1 == 1) {
        my $ret = "";

        if(int(rand(100)) <= $probability_of_selecting_new_element) {
            $ret = $new_element;
        } elsif ($pick_from_previous_courses == 1) {
            my $next_pick = @all_previous_course_elements[int(rand(scalar @all_previous_course_elements))];
            $ret = $next_pick;
        } else {
            my $next_pick = @working_elements[int(rand(scalar @working_elements))];
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

sub right_pad {
    my $str = $_[0];
    my $len = $_[1];
    my $chr = $_[2];

    return substr($str . ($chr x $len), 0, $len);
}

sub generate_introduction {
    my $element = $_[0];
    my $lesson_num = $_[1];

    my $safe_element = $element;
    $safe_element =~ s/\\//g;

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($safe_element) . " - Introduce New Element.txt";
    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    my $pronunciation = $pronunciations{$element};

    for(1..20) {
        print $WRITE_FH "$element |S$working_delay $element |S$working_delay $element |S$working_delay $element [$pronunciation | $element]^\n";
    }

    close($WRITE_FH);

}

sub generate_single_element_repeated_3x {
    my $new_element = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_elements = $_[3];
    my $is_review_all_previous_courses = $_[4];

    my $safe_new_element = $new_element;
    $safe_new_element =~ s/\\//g;

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($safe_new_element) . " - Single Element Repeated 3x.txt";
    if($is_review_all_previous_courses == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review All Elements - Single Element Repeated 3x.txt";
    } elsif($is_review_all_elements == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review Course Elements - Single Element Repeated 3x.txt";
    }
    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_element = pick_random_element($new_element, $allow_repeat, $is_review_all_previous_courses);
        my $pronunciation = $pronunciations{$rand_element};
        print $WRITE_FH "$rand_element |S$working_delay $rand_element |S$working_delay $rand_element [$pronunciation | $rand_element]^\n";
    }

    close($WRITE_FH);

}

sub generate_single_element {
    my $new_element = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_elements = $_[3];
    my $is_review_all_previous_courses = $_[4];

    my $safe_new_element = $new_element;
    $safe_new_element =~ s/\\//g;

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($safe_new_element) . " - Single Element.txt";
    if($is_review_all_previous_courses == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review All Elements - Single Element.txt";
    } elsif($is_review_all_elements == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review Course Elements - Single Element.txt";
    }
    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_element = pick_random_element($new_element, $allow_repeat, $is_review_all_previous_courses);
        my $pronunciation = $pronunciations{$rand_element};
        print $WRITE_FH "$rand_element [$pronunciation]^\n";
    }

}

sub generate_two_elements {
    my $new_element = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_elements = $_[3];
    my $is_review_all_previous_courses = $_[4];

    my $safe_new_element = $new_element;
    $safe_new_element =~ s/\\//g;

    my $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - " . uc($safe_new_element) . " - Two Elements.txt";
    if($is_review_all_previous_courses == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review All Elements - Two Elements.txt";
    } elsif($is_review_all_elements == 1) {
        $write_file_name = "Course " . (sprintf '%02d', $course_num) . " - Lesson " . (sprintf '%03d', $lesson_num) . " - Review Course Elements - Two Elements.txt";
    }

    print $WRITE_RENDER_FH "./render.pl -i '$write_file_name' -s 40 50\n";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_element1 = pick_random_element($new_element, $allow_repeat, $is_review_all_previous_courses);
        my $rand_element2 = pick_random_element($new_element, $allow_repeat, $is_review_all_previous_courses);

        my $pronunciation1 = $pronunciations{$rand_element1};
        my $pronunciation2 = $pronunciations{$rand_element2};

        print $WRITE_FH "$rand_element1 |S$working_delay $rand_element2 [$pronunciation1, $pronunciation2]^\n";
    }

}


my $original_probability_of_selecting_new_word = $probability_of_selecting_new_element;
sub generate_course {
    my $lesson_num=1;
    $probability_of_selecting_new_element = $original_probability_of_selecting_new_word;

    for(my $i=0; $i < scalar(@elements); $i++) {
        my $word = $elements[$i];

        generate_introduction($word, $lesson_num);
        $lesson_num += 1;
        my $is_review_all_words = 0;
        my $is_review_all_previous_courses = 0;

        if($i > 0) {
            my $allow_back_to_back_repeats = 1;
            if ($i >= 4) {
                $allow_back_to_back_repeats = 0;
            }
            generate_single_element_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words, $is_review_all_previous_courses);
            $lesson_num += 1;

            generate_single_element($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words, $is_review_all_previous_courses);
            $lesson_num += 1;

            generate_two_elements($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words, $is_review_all_previous_courses);
            $lesson_num += 1;
        }
        push(@working_elements, $word);

    }


    my $word = $elements[scalar(@elements)-1];
    my $allow_back_to_back_repeats = 0;
    my $is_review_all_elements = 1;
    my $is_review_all_previous_courses = 0;
    $probability_of_selecting_new_element = -1; #disables boosting probability of selecting new word. This is a review after all. :)
    generate_single_element_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_elements, $is_review_all_previous_courses);
    $lesson_num += 1;

    generate_single_element($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_elements, $is_review_all_previous_courses);
    $lesson_num += 1;

    generate_two_elements($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_elements, $is_review_all_previous_courses);
    $lesson_num += 1;

    if($course_num >= 2) {
        my $is_review_all_previous_courses = 1;
        generate_single_element_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_elements, $is_review_all_previous_courses);
        $lesson_num += 1;

        generate_single_element($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_elements, $is_review_all_previous_courses);
        $lesson_num += 1;

        generate_two_elements($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_elements, $is_review_all_previous_courses);
        $lesson_num += 1;
    }

}

print $WRITE_RENDER_FH "#!/bin/bash\n\n";
print $WRITE_RENDER_FH "\n\n# Watch output\n";
print $WRITE_RENDER_FH "# watch '/bin/ls -1 Course*.mp3 | grep Course | tail -n 20'\n\n";
for($course_num = 1; $course_num <= 4; $course_num++) {
    load_elements_for_course($course_num);
    generate_course();
}
close($WRITE_RENDER_FH);