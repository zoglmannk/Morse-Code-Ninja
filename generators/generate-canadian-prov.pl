#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
# ./generate-canadian-prov.pl > canadian_province.txt
#
# Set $repeat as desired

my $repeat = 3;

# list from https://en.wikipedia.org/wiki/Provinces_and_territories_of_Canada
my @province_name = (
    'Ontario', 'Quebec', 'Nova Scotia', 'New Brunswick', 'Manitoba', 'British Columbia', 'Prince Edward Island',
    'Saskatchewan', 'Alberta', 'Newfoundland and Labrador', 'Yukon', 'Northwest Territories', 'Nunavut'
);

my @prov_abbreviation = qw (
    ON QC NS NB MB BC PE SK AB NL YT NT NU
);


my $num_random_states = 200;

sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar @prov_abbreviation));

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_state_index = -1;
for (my $i=0; $i < $num_random_states; $i++) {
    my $random_state_index = pick_uniq_letter_combination($last_random_state_index);

    if($repeat == 1) {
        print "$prov_abbreviation[$random_state_index] [$province_name[$random_state_index]]^\n";
    } else {
        my $repeated_abbreviation = "$prov_abbreviation[$random_state_index] " x $repeat;
        print "$repeated_abbreviation [$province_name[$random_state_index]|$prov_abbreviation[$random_state_index]]^\n";
    }

    $last_random_state_index = $random_state_index;
}


