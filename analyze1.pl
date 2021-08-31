#!/usr/bin/perl

use strict;
use warnings;
use POSIX "fmod";

my $min_length = 0.7; #have been using 0.3 (0.3 to 1.0 is often needed)

my $current_position = 0;
my @positions = (
    'Morse',
    'Voice',
    'MorseRepeat',
    'Chirp'
);
sub get_position {
    my $type = $_[0];

    #if($current_position == 190 || $current_position == 1096) {
    #    $current_position ++;
    #}
    #print "   $current_position\n";

    if($type eq 'QUIET') {
        return "Quiet";
    } else {
        my $index = $current_position % scalar(@positions);
        $current_position++;
        return $positions[$index];
    }
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

my $previous_type = "QUIET";
my $previous_time_index = 0;
my $collapsing = 0;
my $collapsing_start_index = 0;
while(<>) {
    my $in = $_;
    chomp($in);

    if($in =~ m/^(NOISY|QUIET):\s+(\d+\.\d+) to (NOISY|QUIET):\s+(\d+\.\d+)/) {
        my $type = $1;
        my $current_time_index = $2;
        my $next_type = $3;
        my $next_time_index = $4;
        my $previous_length = $current_time_index - $previous_time_index;
        my $current_length = $next_time_index - $current_time_index;
        #print "   $previous_type  $previous_time_index len:$previous_length  .. incoming: $next_type $next_time_index .. current: $type  len:$current_length => collapsing:$collapsing\n";

        if($previous_type eq 'NOISY' && ($previous_length < $min_length || $current_length < 0.1) && $collapsing == 0) {
            $collapsing = 1;
            $collapsing_start_index = $previous_time_index;
        } elsif($previous_type eq 'QUIET' && $previous_length > $min_length && $collapsing == 1) {
            $collapsing = 0;
            $previous_length = $previous_time_index - $collapsing_start_index;
            my $position = get_position("NOISY");
            my $formatted_collapsing_start_index = format_time($collapsing_start_index);
            my $formatted_previous_time_index = format_time($previous_time_index);
            print "$position, NOISY, $collapsing_start_index - $previous_time_index, $previous_length, $formatted_collapsing_start_index - $formatted_previous_time_index\n";
            $position = get_position($previous_type);
            my $formatted_current_time_index = format_time($current_time_index);
            print "$position, $previous_type, $previous_time_index - $current_time_index, $previous_length, $formatted_previous_time_index - $formatted_current_time_index\n";
        } elsif($collapsing == 0) {
            my $position = get_position($previous_type);
            my $formatted_previous_time_index = format_time($previous_time_index);
            my $formatted_current_time_index = format_time($current_time_index);
            print "$position, $previous_type, $previous_time_index - $current_time_index, $previous_length, $formatted_previous_time_index - $formatted_current_time_index\n";
        }

        $previous_type = $type;
        $previous_time_index = $current_time_index;

    }


}