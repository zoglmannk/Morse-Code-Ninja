#!/usr/bin/perl
use strict;
use Cwd;


# Usage:
# ./generate_states
#
# Set $repeat as desired

my $repeat = 1;

my @state_name = (
    'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware',
    'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky',
    'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi',
    'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico',
    'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania',
    'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont',
    'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming'
);

my @state_abbreviation = qw (
    AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE
    NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
);


my $num_random_states = 200;

sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(50));

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_state_index = -1;
for (my $i=0; $i < $num_random_states; $i++) {
    my $random_state_index = pick_uniq_letter_combination($last_random_state_index);

    if($repeat == 1) {
        print "$state_abbreviation[$random_state_index] [$state_name[$random_state_index]]^\n";
    } else {
        my $repeated_abbreviation = "$state_abbreviation[$random_state_index] " x $repeat;
        print "$repeated_abbreviation [$state_name[$random_state_index]|$state_abbreviation[$random_state_index]]^\n";
    }

    $last_random_state_index = $random_state_index;
}


