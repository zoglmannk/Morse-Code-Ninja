#!/usr/bin/perl

use strict;
use Cwd;

# Usage: ./generate-sst-exchanges.pl > sst-exchanges.txt
#
# ./render.pl -i sst-exchanges.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 1.8

my $number_of_runs = 300;
my $filename = "data/K1USNSST-089.txt";

my @entries = ();

my %state_name = (
    'AL' => 'Alabama',
    'AK' => 'Alaska',
    'AZ' => 'Arizona',
    'AR' => 'Arkansas',
    'CA' => 'California',
    'CO' => 'Colorado',
    'CT' => 'Connecticut',
    'DE' => 'Delaware',
    'FL' => 'Florida',
    'GA' => 'Georgia',
    'HI' => 'Hawaii',
    'ID' => 'Idaho',
    'IL' => 'Illinois',
    'IN' => 'Indiana',
    'IA' => 'Iowa',
    'KS' => 'Kansas',
    'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'ME' => 'Maine',
    'MD' => 'Maryland',
    'MA' => 'Massachusetts',
    'MI' => 'Michigan',
    'MN' => 'Minnesota',
    'MS' => 'Mississippi',
    'MO' => 'Missouri',
    'MT' => 'Montana',
    'NE' => 'Nebraska',
    'NV' => 'Nevada',
    'NH' => 'New Hampshire',
    'NJ' => 'New Jersey',
    'NM' => 'New Mexico',
    'NY' => 'New York',
    'NC' => 'North Carolina',
    'ND' => 'North Dakota',
    'OH' => 'Ohio',
    'OK' => 'Oklahoma',
    'OR' => 'Oregon',
    'PA' => 'Pennsylvania',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina',
    'SD' => 'South Dakota',
    'TN' => 'Tennessee',
    'TX' => 'Texas',
    'UT' => 'Utah',
    'VT' => 'Vermont',
    'VA' => 'Virginia',
    'WA' => 'Washington',
    'WV' => 'West Virginia',
    'WI' => 'Wisconsin',
    'WY' => 'Wyoming',
    'AB' => 'Alberta',
    'BC' => 'British Columbia',
    'MB' => 'Manitoba',
    'NB' => 'New Brunswick',
    'NL' => 'Newfoundland and Labrador'
);

open(FH, '<', $filename) or die $!;
while(<FH>) {
    my $in = $_;
    chomp($in);

    my @fields = split /,/, $in;
    if(scalar(@fields) >= 3) {
        my $call = $fields[0];
        my $name = $fields[1];
        my $exchange = $fields[2];

        $call = uc($call);
        $name = join " ", map {ucfirst} split " ", lc($name);

        if($call =~ m/^[A-Z0-9\/]+$/ && $name =~ m/^[A-Za-z]+$/ &&
           $exchange =~ m/^[A-Za-z0-9]+$/ && defined($state_name{$exchange})) {
            #print "good.. $call, $name, $exchange\n";
            push @entries, "$call, $name, $exchange";
        }
    }

}
close FH;


sub get_callsign_pronuciation {
    my $callsign = $_[0];

    $callsign = join " ", split //, $callsign;

    if($callsign =~ m/(([A-Z] ){1,2})([0-9])(.*)/) {
        $callsign = "$1$3,$4";
        $callsign =~ s/^(([A-Z] ){1,2})0,/$1zero,/;
    }
    $callsign =~ s/ \/ /, \//g;
    $callsign =~ s/((([A-Z])\s?)\3)/$3, $3/g;
    $callsign =~ s/D E/D, E/;

    return '<prosody rate="85%">' . $callsign . '</prosody>';
}


my $previous_index1 = -1;
my $previous_index2 = -1;
for(my $i=0; $i<$number_of_runs; $i++) {

    my $random_index1 = -1;
    my $random_index2 = -1;

    while($random_index1 == -1 || $random_index2 == -1 ||
          $random_index1 == $previous_index1 ||
          $random_index2 == $previous_index2 ||
          $random_index1 == $random_index2) {

        $random_index1 = int rand @entries;
        $random_index2 = int rand @entries;
    }
    $previous_index1 = $random_index1;
    $previous_index2 = $random_index2;

    my @caller = split /,\s?/, $entries[$previous_index1];
    my $caller_call = $caller[0];
    my $caller_call_pronuciation = get_callsign_pronuciation($caller_call);
    my $caller_name = $caller[1];
    my $caller_exchange = $caller[2];
    my $caller_exchange_prounciation = $caller_exchange;
    if(defined $state_name{$caller_exchange}) {
        $caller_exchange_prounciation = $state_name{$caller_exchange};
    }

    my @responder = split /,\s?/, $entries[$previous_index2];
    my $responder_call = $responder[0];
    my $responder_call_pronuciation = get_callsign_pronuciation($responder_call);
    my $responder_name = $responder[1];
    my $responder_exchange = $responder[2];
    my $responder_exchange_prounciation = $responder_exchange;
    if(defined $state_name{$responder_exchange}) {
        $responder_exchange_prounciation = $state_name{$responder_exchange};
    }

    my $greeting = "GA";
    my $greeting_pronuciation = "Good afternoon";
    if((int rand 2) == 1) {
        $greeting = "GE";
        $greeting_pronuciation = "Good evening";
    }
    #print "=============\n";
    print 'VV [<speak>New <prosody rate="85%">QS</prosody><prosody rate="75%">O</prosody></speak>]^' . "\n";
    print "CQ SST $caller_call [<speak>CQ, SST, $caller_call_pronuciation</speak>]^\n";
    print "$responder_call [<speak>$responder_call_pronuciation</speak>]^\n";
    print "$responder_call $caller_name $caller_exchange [<speak>$responder_call_pronuciation, $caller_name, $caller_exchange_prounciation</speak>]^\n";
    print "$greeting $caller_name $responder_name $responder_exchange [$greeting_pronuciation $caller_name, $responder_name, in, $responder_exchange_prounciation]^\n";
    print "TU $responder_name $caller_call SST [<speak>Thank you, $responder_name, $caller_call_pronuciation, SST</speak>]^\n";
}
