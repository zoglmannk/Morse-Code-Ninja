#!/usr/bin/perl
use strict;
use Cwd;


# Usage:
# ./generate_states
#
# Set $repeat as desired

my $repeat = 1;

my @name = (
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware',
    'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky',
    'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico',
    'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming',
    'Ontario', 'Quebec', 'Nova Scotia', 'New Brunswick', 'Manitoba', 'British Columbia', 'Prince Edward Island',
    'Saskatchewan', 'Alberta', 'Newfoundland and Labrador', 'Yukon', 'Northwest Territories', 'Nunavut'
);

my @abbreviation = qw (
    AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE
    NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
    ON QC NS NB MB BC PE SK AB NL YT NT NU
);


my $num_random = 504;

sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar @abbreviation));

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_index = -1;
for (my $i=0; $i < $num_random; $i++) {
    my $random_index = pick_uniq_letter_combination($last_random_index);

    if($repeat == 1) {
        print "$abbreviation[$random_index] [$name[$random_index]]^\n";
    } else {
        my $repeated_abbreviation = "$abbreviation[$random_index] " x $repeat;
        print "$repeated_abbreviation [$name[$random_index]|$abbreviation[$random_index]]^\n";
    }

    $last_random_index = $random_index;
}


