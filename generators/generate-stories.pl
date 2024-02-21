#!/usr/bin/perl

use strict;
use warnings;

# Usage:
# ./generate-stories.pl
#
# ./render.pl -i XXXX.txt -s 15 17 20 22 25 28 30 35 40 45 50 -sm 2 --ss 1.5
# ls -1 *.txt | grep Beginner | xargs -IXX ./render.pl -i XX -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2 --ss 1.5
# ls -1 *.txt | grep Intermediate | xargs -IXX ./render.pl -i XX -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5 --ss 1.5
# ls -1 *.txt | grep Advanced | xargs -IXX ./render.pl -i XX -s 15 17 20 22 25 28 30 35 40 45 50 --sm 3 --ss 1.5
# ls -1 *.txt | grep Expert | xargs -IXX ./render.pl -i XX -s 15 17 20 22 25 28 30 35 40 45 50 --sm 3.5 --ss 1.5

sub generate_practice_set {
    my @lines = @{shift()};
    my $practice_type = shift;
    my $i = shift;

    my $is_first = 1;
    my $is_first_story_line = 1;
    my $output_file_name = "";
    my $out;
    my $partial_first_line;
    foreach(@lines) {
        my $line = $_;
        chomp($line);

        if($line =~ m/^\s*$/ || $line =~ m/Segment \d/) {
            next;
        }
        if($is_first == 1) {
            $is_first = 0;
            if($line =~ m/^.*?\s(—|-)\s(.*?)(:(.*))?$/) {
                my $title = $2;
                my $sub_title = $3;
                $title =~ s/'//g;
                my $story_number = sprintf("%02d", $i);

                $output_file_name = "$practice_type Short Story ${story_number} - $title.txt";
                print "$output_file_name\n";
                open $out, ">", "../${output_file_name}" or die "Failed to open file for writing '$output_file_name': $!";
                $title =~ s/\./\\./g;
                if((!defined($sub_title)) || $sub_title eq '') {
                    $partial_first_line = "{ <speak>$practice_type Short Story, number ${i}\\. <break time=\"0\\.50s\"/> ${title}\\. <break time=\"1s\"/> Let's begin\\. <break time=\"2s\"/> ";
                } else {
                    $sub_title =~ s/\./\\./g;
                    $partial_first_line = "{ <speak>$practice_type Short Story, number ${i}\\. <break time=\"0\\.50s\"/> ${title}\\. ${sub_title}\\. <break time=\"1s\"/> Let's begin\\. <break time=\"2s\"/> ";
                }

                print $out "$partial_first_line";
            } else {
                print "The first line in the file doesn't match the expected pattern!";
                print "line: $line\n";
                exit 1;
            }
        } elsif($line =~ m/Spoken: (.*)/) {
            my $spoken_part = $1;
            $spoken_part =~ s/\./\\./g;
            if($is_first_story_line == 1) {
                $is_first_story_line = 0;
                print $out "$spoken_part </speak> } ^\n";
            } else {
                print $out "{ $spoken_part } ^\n";
            }

        } elsif($line =~ m/Code: (.*)/) {
            my $code = $1;
            $code =~ s/\./\\./g;
            $code =~ s/'//g;
            $code =~ s/-/ /g;
            print $out "$code ^\n";
        } else {
            print "Unexpected input: $line";
            exit 1;
        }

        #print "$line\n";
    }
    close $out;

}

for(my $i=1; $i <= 31; $i++) {

    my $story_file_name = "data/Beginners Story ${i}.txt";
    my @lines;
    open my $in, "<", $story_file_name or die "Failed to open file '$story_file_name': $!";
    while (my $line = <$in>) {
        push(@lines, $line);
    }
    close $in;

    generate_practice_set(\@lines, "Beginner", $i);

}

for(my $i=1; $i <= 10; $i++) {

    my $story_file_name = "data/Intermediate Story ${i}.txt";
    my @lines;
    open my $in, "<", $story_file_name or die "Failed to open file '$story_file_name': $!";
    while (my $line = <$in>) {
        push(@lines, $line);
    }
    close $in;

    generate_practice_set(\@lines, "Intermediate", $i);

}

for(my $i=1; $i <= 10; $i++) {

    my $story_file_name = "data/Advanced Story ${i}.txt";
    my @lines;
    open my $in, "<", $story_file_name or die "Failed to open file '$story_file_name': $!";
    while (my $line = <$in>) {
        push(@lines, $line);
    }
    close $in;

    generate_practice_set(\@lines, "Advanced", $i);

}

for(my $i=1; $i <= 10; $i++) {

    my $story_file_name = "data/Expert Story ${i}.txt";
    my @lines;
    open my $in, "<", $story_file_name or die "Failed to open file '$story_file_name': $!";
    while (my $line = <$in>) {
        push(@lines, $line);
    }
    close $in;

    generate_practice_set(\@lines, "Expert", $i);

}