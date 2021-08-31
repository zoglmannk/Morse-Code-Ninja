#!/usr/bin/perl

use strict;
use warnings;
use POSIX "fmod";

# Usage:
#   aubioquiet -r 0 -i ~/Desktop/analyze/Single\ Letters\ 50wpm.mp3 | ./analyze0.pl | analyze1.pl | ./analyze2.pl ~/Desktop/analyze/Single\ Letters.txt > ~/Desktop/analyze/single-letters-50wpm.vtt
#   ls -1 ~/Desktop/analyze/ | grep mp3 |  xargs -IXX echo aubioquiet -r 0 -i \"/Users/kaz/Desktop/analyze/XX\" \| ./analyze0.pl \| ./analyze1.pl \| ./analyze2.pl \"/Users/kaz/Desktop/analyze/Top\ 100\ Words\ Repeated\ v2.txt\" \> \"/Users/kaz/Desktop/analyze/XX.vtt\" > runme.bash; chmod +x runme.bash;

# Create Web Video Text Tracks Format (WebVTT) -- https://developer.mozilla.org/en-US/docs/Web/API/WebVTT_API
# Closed Captioning on YouTube -- https://www.rev.com/blog/close-caption-file-format-guide-for-youtube-vimeo-netflix-and-more

my $filename   = $ARGV[0];
open(FH, '<', $filename) or die $!;

my $lower_lang_chars_regex = "a-z";
my $upper_lang_chars_regex = "A-Z";

sub split_on_spoken_directive {
    my $raw = $_[0];

    #example "MD MD MD [Maryland|MD]^"
    if($raw =~ m/(.*?)\h*\[(.*?)(\|(.*?))?\]\h*([\^|\.|\?])$/) {
        my $sentence_part = $1.$5;
        my $spoken_directive = $2.$5;
        my $repeat_part = $4.$5;

        $sentence_part =~ s/\^//g;
        $spoken_directive =~ s/\^//g;
        $spoken_directive =~ s/\\\././g; #Unescape period
        $spoken_directive =~ s/\\\?/?/g; #Unescape question mark
        $spoken_directive =~ s/\\\;/;/g; #Unescape semicolon
        $repeat_part =~ s/\^//g;

        #temporarily change word speed directive so we can filter invalid characters
        if($raw !~ m/<speak>.*?<\/speak>/) {
            $sentence_part =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;
        }
        $repeat_part =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;

        #this should be moved up to safe part.. remember to add ^ and \
        $sentence_part =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>\/,'\s]//g;
        if($raw !~ m/<speak>.*?<\/speak>/) {
            $spoken_directive =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>,'\s]//g;
        }
        $repeat_part =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>\/,'\s]//g;

        #temporarily change word speed directive so we can filter invalid characters
        $sentence_part =~ s/XXXWORDSPEEDXXX/|/g;
        $repeat_part =~ s/XXXWORDSPEEDXXX/|/g;

        if($repeat_part =~ m/^(\.|\?)$/ || $repeat_part eq "") {
            $repeat_part = $sentence_part;
        }

        return ($sentence_part, $spoken_directive, $repeat_part);
    } else {
        #temporarily change word speed directive so we can filter invalid characters

        $raw =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;

        $raw =~ s/\^//g;
        $raw =~ s/[^A-Za-z0-9\.\?<>,'\s]//g;

        $raw =~ s/XXXWORDSPEEDXXX/|/g;

        return ($raw, $raw, $raw);
    }

}

sub unencoded_speak {
    my $encoded_speak = $_[0];
    my $ret = "";

    if($encoded_speak =~ m/<speak>.*?>([A-Za-z\s]+)<.*?<\/speak>/) {
        while($encoded_speak =~ m/>([A-Za-z\s,\\\.]+)</) {
            $ret .= $1;
            $encoded_speak =~ s/>([A-Za-z\s,\\\.]+)<//;
        }
    } else {
        $ret = $encoded_speak;
    }

    $ret =~ s/^\s+|\s+$//g;

    return $ret;

}

sub format_time {
    my $time = $_[0];

    my $seconds = fmod($time, 60);
    my $mins = int($time / 60);

    if($seconds >= 59.99) {
        $seconds = 0;
        $mins++;
    }

    if($mins >= 60) {
        my $hours = int($mins / 60);
        my $mins = fmod($mins, 60);

        return sprintf(qq[%02d], $hours) . ":" . sprintf(qq[%02d], $mins) . ":" . sprintf(qq[%06.3f], $seconds);
    } else {
        return sprintf(qq[%02d], $mins) . ":" . sprintf(qq[%06.3f], $seconds);
    }

}

print "WEBVTT\n\n";

my $previous_line = "";
while(<STDIN>) {

    my $in = $_;
    #print "   $in";

    if($previous_line =~ m/Voice, NOISY, (\d+.\d+)/) {
        my $start = $1;
        if ($in =~ m/Quiet, QUIET, \d+.\d+ - (\d+.\d+)/) {
            my $end = $1;
            $start += 0.1;
            $end -= 0.1;
            my $formatted_start_time = format_time($start);
            my $formatted_end_time = format_time($end);

            my $entry = <FH>;
            (my $sentence_part, my $spoken_directive, my $repeat_part) = split_on_spoken_directive($entry);
            $spoken_directive = unencoded_speak($spoken_directive);
            $spoken_directive =~s/\.|,//g; #remove periods
            #$spoken_directive = uc($spoken_directive);

            #print "Voice, $start, $formatted_start_time, $formatted_end_time, $spoken_directive\n";
            print "$formatted_start_time --> $formatted_end_time\n$spoken_directive\n\n";

        }

    }

    $previous_line = $in;
}
