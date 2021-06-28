#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-field-day-exchanges.pl > fd-exchanges.txt
# Rendered with 2.3 second delay

my $use_actual_distribution = 1;
my $num_of_rand_selections = 800;

#Allow one to base probability on 2019 data and one with equal distribution

# ===== Field Day Exchanges ======
# Number of Simultaneous Transmitters

# Class A through F
#  A = Club or 3+ person group on Battery
#  B = 1 or 2 person portable on/off battery
#  C = Mobile
#  D = Home Stations
#  E = Home Station on Emergency Power
#  F = Emergency Operations CEnter

# Station Type = Number of Simultaneous Transmitters and Class

# Exchange = Station Type + RAC or DX
# e.g. "3A CT" or "2A DX"

# Data is based on 2019 Field Day
# https://contests.arrl.org/ContestResults/2019/Field-Day-2019-FinalQSTResults.pdf

my %transmitter_count_by_class;

$transmitter_count_by_class{'1A'} = 142;
$transmitter_count_by_class{'2A'} = 358;
$transmitter_count_by_class{'3A'} = 309;
$transmitter_count_by_class{'4A'} = 141;
$transmitter_count_by_class{'5A'} = 83;
$transmitter_count_by_class{'6A'} = 37;
$transmitter_count_by_class{'7A'} = 19;
$transmitter_count_by_class{'8A'} = 7;
$transmitter_count_by_class{'9A'} = 6;
$transmitter_count_by_class{'10A'} = 3;


$transmitter_count_by_class{'11A'} = 1;
$transmitter_count_by_class{'12A'} = 2;
$transmitter_count_by_class{'13A'} = 0;
$transmitter_count_by_class{'14A'} = 1;
$transmitter_count_by_class{'20A'} = 1;
$transmitter_count_by_class{'1AB'} = 14;
$transmitter_count_by_class{'2AB'} = 6;
$transmitter_count_by_class{'3AB'} = 10;
$transmitter_count_by_class{'4AB'} = 3;
$transmitter_count_by_class{'5AB'} = 4;
$transmitter_count_by_class{'6AB'} = 3;
$transmitter_count_by_class{'7AB'} = 0;


$transmitter_count_by_class{'8AB'} = 1;
$transmitter_count_by_class{'9AB'} = 2;
$transmitter_count_by_class{'1AC'} = 16;
$transmitter_count_by_class{'2AC'} = 42;
$transmitter_count_by_class{'3AC'} = 37;
$transmitter_count_by_class{'4AC'} = 21;
$transmitter_count_by_class{'5AC'} = 8;
$transmitter_count_by_class{'1B1'} = 129;
$transmitter_count_by_class{'1B1B'} = 131;
$transmitter_count_by_class{'2B1B'} = 2;


$transmitter_count_by_class{'1B1C'} = 17;
$transmitter_count_by_class{'1B2'} = 39;
$transmitter_count_by_class{'2B2'} = 24;
$transmitter_count_by_class{'1B2B'} = 19;
$transmitter_count_by_class{'2B2B'} = 11;
$transmitter_count_by_class{'1B2C'} = 1;
$transmitter_count_by_class{'2B2C'} = 2;
$transmitter_count_by_class{'1C'} = 42;
$transmitter_count_by_class{'2C'} = 1;
$transmitter_count_by_class{'3C'} = 1;


$transmitter_count_by_class{'1D'} = 725;
$transmitter_count_by_class{'2D'} = 30;
$transmitter_count_by_class{'3D'} = 11;
$transmitter_count_by_class{'4D'} = 3;
$transmitter_count_by_class{'1E'} = 391;
$transmitter_count_by_class{'2E'} = 32;
$transmitter_count_by_class{'3E'} = 15;
$transmitter_count_by_class{'4E'} = 10;
$transmitter_count_by_class{'5E'} = 3;
$transmitter_count_by_class{'7E'} = 1;


$transmitter_count_by_class{'1F'} = 32;
$transmitter_count_by_class{'2F'} = 75;
$transmitter_count_by_class{'3F'} = 56;
$transmitter_count_by_class{'4F'} = 19;
$transmitter_count_by_class{'5F'} = 7;
$transmitter_count_by_class{'6F'} = 4;
$transmitter_count_by_class{'7F'} = 1;
$transmitter_count_by_class{'8F'} = 1;
$transmitter_count_by_class{'9F'} = 0;
$transmitter_count_by_class{'10F'} = 0;
$transmitter_count_by_class{'11F'} = 0;
$transmitter_count_by_class{'12F'} = 1;

my @transmitter_count_by_class_distribution;

foreach my $class (keys %transmitter_count_by_class) {
    my $count = $transmitter_count_by_class{$class};
    #print "  $class : $count\n";

    if($use_actual_distribution == 1) {
        for(my $i=0; $i<$count; $i++) {
            push @transmitter_count_by_class_distribution, $class;
        }
    } else {
        push @transmitter_count_by_class_distribution, $class;
    }

}

#print "\ntransmitter_count_by_class_distribution: " . scalar(@transmitter_count_by_class_distribution) . "\n";


my %section_pronunciation;

# taken from -- http://www.arrl.org/section-abbreviations
# Call Sign Area 1
$section_pronunciation{'CT'} = 'Connecticut';
$section_pronunciation{'EMA'} = 'Eastern  Massachusetts';
$section_pronunciation{'ME'} = 'Maine';
$section_pronunciation{'NH'} = 'New Hampshire';
$section_pronunciation{'RI'} = 'Rhode Island';
$section_pronunciation{'VT'} = 'Vermont';
$section_pronunciation{'WMA'} = 'Western Massachusetts';

# Call Sign Area 2
$section_pronunciation{'ENY'} = 'Eastern New York';
$section_pronunciation{'NLI'} = 'Long Island';
$section_pronunciation{'NNJ'} = 'Northern New Jersey';
$section_pronunciation{'NNY'} = 'Northern New York';
$section_pronunciation{'SNJ'} = 'Southern New Jersey';
$section_pronunciation{'WNY'} = 'Western New York';

# Call Sign Area 3
$section_pronunciation{'DE'} = 'Delaware';
$section_pronunciation{'EPA'} = 'Eastern Pennsylvania';
$section_pronunciation{'MDC'} = 'Maryland DC';
$section_pronunciation{'WPA'} = 'Western Pennsylvania';

# Call Sign Area 4
$section_pronunciation{'AL'} = 'Alabama';
$section_pronunciation{'GA'} = 'Georgia';
$section_pronunciation{'KY'} = 'Kentucky';
$section_pronunciation{'NC'} = 'North Carolina';
$section_pronunciation{'NFL'} = 'Northern Florida';
$section_pronunciation{'SC'} = 'South Carolina';
$section_pronunciation{'SFL'} = 'Southern Florida';
$section_pronunciation{'WCF'} = 'West Central Florida';
$section_pronunciation{'TN'} = 'Tennessee';
$section_pronunciation{'VA'} = 'Virginia';
$section_pronunciation{'PR'} = 'Puerto Rico';
$section_pronunciation{'VI'} = 'Virgin Islands';

# Call Sign Area 5
$section_pronunciation{'AR'} = 'Arkansas';
$section_pronunciation{'LA'} = 'Louisiana';
$section_pronunciation{'MS'} = 'Mississippi';
$section_pronunciation{'NM'} = 'New Mexico';
$section_pronunciation{'NTX'} = 'North Texas';
$section_pronunciation{'OK'} = 'Oklahoma';
$section_pronunciation{'STX'} = 'South Texas';
$section_pronunciation{'WTX'} = 'West Texas';

# Call Sign Area 6
$section_pronunciation{'EB'} = 'East Bay';
$section_pronunciation{'LAX'} = 'Los Angeles';
$section_pronunciation{'ORG'} = 'Orange';
$section_pronunciation{'SB'} = 'Santa Barbara';
$section_pronunciation{'SCV'} = 'Santa Clara Valley';
$section_pronunciation{'SDG'} = 'San Diego';
$section_pronunciation{'SF'} = 'San Francisco';
$section_pronunciation{'SJV'} = 'San Joaquin Valley';
$section_pronunciation{'SV'} = 'Sacramento Valley';
$section_pronunciation{'PAC'} = 'Pacific';

# Call Sign Area 7
$section_pronunciation{'AZ'} = 'Arizona';
$section_pronunciation{'EWA'} = 'Eastern Washington';
$section_pronunciation{'ID'} = 'Idaho';
$section_pronunciation{'MT'} = 'Montana';
$section_pronunciation{'NV'} = 'Nevada';
$section_pronunciation{'OR'} = 'Oregon';
$section_pronunciation{'UT'} = 'Utah';
$section_pronunciation{'WWA'} = 'Western Washington';
$section_pronunciation{'WY'} = 'Wyoming';
$section_pronunciation{'AK'} = 'Alaska';

# Call Sign Area 8
$section_pronunciation{'MI'} = 'Michigan';
$section_pronunciation{'OH'} = 'Ohio';
$section_pronunciation{'WV'} = 'West Virginia';

# Call Sign Area 9
$section_pronunciation{'IL'} = 'Illinois';
$section_pronunciation{'IN'} = 'Indiana';
$section_pronunciation{'WI'} = 'Wisconsin';

# Call Sign Area 0
$section_pronunciation{'CO'} = 'Colorado';
$section_pronunciation{'IA'} = 'Iowa';
$section_pronunciation{'KS'} = 'Kansas';
$section_pronunciation{'MN'} = 'Minnesota';
$section_pronunciation{'MO'} = 'Missouri';
$section_pronunciation{'NE'} = 'Nebraska';
$section_pronunciation{'SD'} = 'South Dakota';
$section_pronunciation{'ND'} = 'North Dakota';

# Canadian Area Call Sign
$section_pronunciation{'MAR'} = 'Maritime';
$section_pronunciation{'NL'} = 'Newfoundland Labrador';
$section_pronunciation{'QC'} = 'Quebec';
$section_pronunciation{'ONE'} = 'Ontario East';
$section_pronunciation{'ONN'} = 'Ontario North';
$section_pronunciation{'ONS'} = 'Ontario South';
$section_pronunciation{'GTA'} = 'Greater Toronto Area';
$section_pronunciation{'MB'} = 'Manitoba';
$section_pronunciation{'SK'} = 'Saskatchewan';
$section_pronunciation{'AB'} = 'Alberta';
$section_pronunciation{'BC'} = 'British Columbia';
$section_pronunciation{'NT'} = 'Northern Territories';

$section_pronunciation{'DX'} = 'DX';



my %entries_by_arrl_section_prefix;

$entries_by_arrl_section_prefix{'AB'} = 17;
$entries_by_arrl_section_prefix{'AK'} = 8;
$entries_by_arrl_section_prefix{'AL'} = 51;
$entries_by_arrl_section_prefix{'AR'} = 27;
$entries_by_arrl_section_prefix{'AZ'} = 87;
$entries_by_arrl_section_prefix{'BC'} = 40;
$entries_by_arrl_section_prefix{'CO'} = 72;
$entries_by_arrl_section_prefix{'CT'} = 40;
$entries_by_arrl_section_prefix{'DE'} = 9;
$entries_by_arrl_section_prefix{'EB'} = 24;

$entries_by_arrl_section_prefix{'EMA'} = 38;
$entries_by_arrl_section_prefix{'ENY'} = 33;
$entries_by_arrl_section_prefix{'EPA'} = 93;
$entries_by_arrl_section_prefix{'EWA'} = 26;
$entries_by_arrl_section_prefix{'GA'} = 66;
$entries_by_arrl_section_prefix{'GTA'} = 19;
$entries_by_arrl_section_prefix{'IA'} = 32;
$entries_by_arrl_section_prefix{'ID'} = 24;
$entries_by_arrl_section_prefix{'IL'} = 96;
$entries_by_arrl_section_prefix{'IN'} = 76;

$entries_by_arrl_section_prefix{'KS'} = 28;
$entries_by_arrl_section_prefix{'KY'} = 28;
$entries_by_arrl_section_prefix{'LA'} = 33;
$entries_by_arrl_section_prefix{'LAX'} = 55;
$entries_by_arrl_section_prefix{'MAR'} = 14;
$entries_by_arrl_section_prefix{'MB'} = 4;
$entries_by_arrl_section_prefix{'MDC'} = 51;
$entries_by_arrl_section_prefix{'ME'} = 22;
$entries_by_arrl_section_prefix{'MI'} = 102;
$entries_by_arrl_section_prefix{'MN'} = 61;

$entries_by_arrl_section_prefix{'MO'} = 61;
$entries_by_arrl_section_prefix{'MS'} = 21;
$entries_by_arrl_section_prefix{'MT'} = 20;
$entries_by_arrl_section_prefix{'NC'} = 92;
$entries_by_arrl_section_prefix{'ND'} = 10;
$entries_by_arrl_section_prefix{'NE'} = 13;
$entries_by_arrl_section_prefix{'NFL'} = 54;
$entries_by_arrl_section_prefix{'NH'} = 32;
$entries_by_arrl_section_prefix{'NL'} = 1;
$entries_by_arrl_section_prefix{'NLI'} = 27;

$entries_by_arrl_section_prefix{'NM'} = 24;
$entries_by_arrl_section_prefix{'NNJ'} = 45;
$entries_by_arrl_section_prefix{'NNY'} = 45;
$entries_by_arrl_section_prefix{'NT'} = 2;
$entries_by_arrl_section_prefix{'NTX'} = 79;
$entries_by_arrl_section_prefix{'NV'} = 30;
$entries_by_arrl_section_prefix{'OH'} = 143;
$entries_by_arrl_section_prefix{'OK'} = 24;
$entries_by_arrl_section_prefix{'ONE'} = 29;
$entries_by_arrl_section_prefix{'ONN'} = 4;

$entries_by_arrl_section_prefix{'ONS'} = 30;
$entries_by_arrl_section_prefix{'OR'} = 62;
$entries_by_arrl_section_prefix{'ORG'} = 39;
$entries_by_arrl_section_prefix{'PAC'} = 10;
$entries_by_arrl_section_prefix{'PR'} = 4;
$entries_by_arrl_section_prefix{'QC'} = 28;
$entries_by_arrl_section_prefix{'RI'} = 12;
$entries_by_arrl_section_prefix{'SB'} = 21;
$entries_by_arrl_section_prefix{'SC'} = 38;
$entries_by_arrl_section_prefix{'SCV'} = 38;

$entries_by_arrl_section_prefix{'SD'} = 10;
$entries_by_arrl_section_prefix{'SDG'} = 26;
$entries_by_arrl_section_prefix{'SF'} = 10;
$entries_by_arrl_section_prefix{'SFL'} = 29;
$entries_by_arrl_section_prefix{'SJV'} = 23;
$entries_by_arrl_section_prefix{'SK'} = 4;
$entries_by_arrl_section_prefix{'SNJ'} = 23;
$entries_by_arrl_section_prefix{'STX'} = 89;
$entries_by_arrl_section_prefix{'SV'} = 45;
$entries_by_arrl_section_prefix{'TN'} = 58;

$entries_by_arrl_section_prefix{'UT'} = 33;
$entries_by_arrl_section_prefix{'VA'} = 100;
$entries_by_arrl_section_prefix{'VI'} = 5;
$entries_by_arrl_section_prefix{'VT'} = 13;
$entries_by_arrl_section_prefix{'WCF'} = 41;
$entries_by_arrl_section_prefix{'WI'} = 65;
$entries_by_arrl_section_prefix{'WMA'} = 16;
$entries_by_arrl_section_prefix{'WNY'} = 56;
$entries_by_arrl_section_prefix{'WPA'} = 47;
$entries_by_arrl_section_prefix{'WTX'} = 14;

$entries_by_arrl_section_prefix{'WV'} = 21;
$entries_by_arrl_section_prefix{'WY'} = 11;
$entries_by_arrl_section_prefix{'DX'} = 18;

my @entries_by_arrl_section_prefix_distribution;

foreach my $section_prefix (keys %entries_by_arrl_section_prefix) {
    my $count = $entries_by_arrl_section_prefix{$section_prefix};
    #print "  $section_prefix : $count\n";

    if($use_actual_distribution == 1) {
        for(my $i=0; $i<$count; $i++) {
            push @entries_by_arrl_section_prefix_distribution, $section_prefix;
        }
    } else {
        push @entries_by_arrl_section_prefix_distribution, $section_prefix;
    }

}

#print "entries_by_arrl_section_prefix_distribution: " . scalar(@entries_by_arrl_section_prefix_distribution) . "\n\n\n";

my $last_exchange = "";
for(my $i=0; $i<$num_of_rand_selections; $i++) {
    my $next_class_index;
    my $next_section_index;

    my $next_exchange = "";
    while(1==1) {
        $next_class_index = int(rand(scalar(@transmitter_count_by_class_distribution)));
        $next_section_index = int(rand(scalar(@entries_by_arrl_section_prefix_distribution)));

        $transmitter_count_by_class_distribution[$next_class_index] =~ m/^(\d+)(\w)/;
        $next_exchange = $1 . $2 . " " .
            $entries_by_arrl_section_prefix_distribution[$next_section_index];
        if($next_exchange ne $last_exchange) {
            $last_exchange = $next_exchange;
            last;
        }
    }

    my $spoken_location = $section_pronunciation{$entries_by_arrl_section_prefix_distribution[$next_section_index]};
    $transmitter_count_by_class_distribution[$next_class_index] =~ m/^(\d+)(\w)/;
    my $num_operators = $1;
    my $station_type = $2;

    #overcome mispronunciation
    if($spoken_location =~ m/Virgin Islands/ && $station_type eq 'A') {
        print "$next_exchange [$num_operators, $station_type, $spoken_location]^\n";
    } else {
        print "$next_exchange [$num_operators $station_type, $spoken_location]^\n";
    }


}