#!/usr/bin/perl

use strict;
use warnings;
use POSIX "fmod";

my $min_length = 0.5; #have been using 0.3 (0.3 to 1.0 is often needed)
my $secondary_length = 0.3; # typically 0.1

my $current_position = 0;
my @positions = (
    'Voice',
    'Chirp'
);

my @positions2 = (
    'Morse',
    'Voice',
    'MorseRepeat',
    'Chirp'
);

# If using this option for the 4x, 3x, 2x word spacing
# rm ~/Desktop/analyze/*.vtt; ls -1 ~/Desktop/analyze/ | grep mp3 |  xargs -IXX echo aubioquiet -r 0 -i \"/Users/kaz/Desktop/analyze/XX\" \| ./analyze0.pl \| ./analyze1.pl \"/Users/kaz/Desktop/analyze/Sentences\ from\ Top\ 100\ Words\ -\ 4x\ Word-Spacing\ 15wpm.txt\" \| ./analyze2.pl \"/Users/kaz/Desktop/analyze/Sentences\ from\ Top\ 100\ Words\ -\ 4x\ Word-Spacing\ 15wpm.txt\" \> \"/Users/kaz/Desktop/analyze/XX.vtt\" | perl -e 'while(<>) { $in = $_; $in =~ s/\.mp3\.vtt/.vtt/g; print "$in"; }' > runme.bash; chmod +x runme.bash;
# Edit runme.bash and match text files to run
# ./runme.bash
# change get_position function to reference @position3
#my @positions3 = ();
#my $filename   = $ARGV[0];
#open(FH, '<', $filename) or die $!;
#while(<FH>) {
#    my $in = $_;
#    chomp($in);
#    my @words = split(/\s+/, $in);
#    for(@words) {
#        push @positions3, "Morse";
#    }
#    push @positions3, "Voice";
#    for(@words) {
#        push @positions3, "Morse";
#    }
#    push @positions3, "Chirp";
#}
#close FH;
#print "@positions3\n";

my $which_position = 1;
sub get_position {
    my $type = $_[0];

    #if( $current_position == 3) {
    #    $current_position++;
    #}
    #print "   $current_position\n";

    if($type eq 'QUIET') {
        return "Quiet";
    } else {
        # if($which_position == 1) {
        #     if($current_position >= scalar(@positions)) {
        #         $which_position = 2;
        #         $current_position = 0;
        #         #print "got here\n";
        #     } else {
        #         my $index = $current_position % scalar(@positions);
        #         $current_position++;
        #         return $positions[$index];
        #     }
        # }

        # if($which_position == 2) {
            my $index = $current_position % scalar(@positions2);
            $current_position++;
            return $positions2[$index];
        # }

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
while(<STDIN>) {
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

        if($previous_type eq 'NOISY' && ($previous_length < $min_length || $current_length < $secondary_length) && $collapsing == 0) {
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
            # Hack for rare missing repeat
            #if($previous_length >= 3.3 && $position ne 'Voice') {
            #    get_position("NOISY");
            #    #print "Got here\n";
            #}
        }

        $previous_type = $type;
        $previous_time_index = $current_time_index;

    }


}