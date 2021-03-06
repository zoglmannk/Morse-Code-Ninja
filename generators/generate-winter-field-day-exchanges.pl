#!/usr/bin/perl

use strict;
use Cwd;


# Usage:
# ./generate-winter-field-day-exchanges.pl > winter-field-day-exchange-random-contest-distribution.txt
# Rendered with 2.3 second delay

my $use_actual_distribution = 0;
my $num_of_rand_selections = 800;

# Winter Field Day Rules - https://www.n9rjv.org/wp-content/uploads/2019/12/WFD-2020.pdf

# Winter Field Day Results 2018 - https://www.winterfieldday.com/2018-results
# See generate-winter-field-day-data.py

my @class_distribution;
my @section_distribution;

open(FH, '<', "data/wfd-2018-data.txt") or die $!;
while(<FH>) {
    my ($callsign,$section,$mult,$pwr,$x,$bonus,$claimed,$score,$calculated,$score,$class) = split(/,/, $_);
    chomp($class);
    if(length($section)>=1 && length($class)>=1) {
        #print "$section $class\n";
        push @class_distribution, $class;
        push @section_distribution, $section;
    }
}
close(FH);

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

if($use_actual_distribution == 0) {
    @section_distribution = keys %section_pronunciation;
    @class_distribution = (
        "1I", "2I", "3I", "4I", "5I", "6I", "7I", "8I",
        "1O", "2O", "3O", "4O", "5O", "6O",
        "1H", "2H", "3H", "4H", "5H", "6H", "7H"
    );
}


my $last_exchange = "";
for(my $i=0; $i<$num_of_rand_selections; $i++) {
    my $next_class_index = int(rand(scalar(@class_distribution)));
    my $next_section_index = int(rand(scalar(@section_distribution)));

    my $next_exchange = "";
    while(1==1) {
        $next_exchange = $class_distribution[$next_class_index] . " " .
            $section_distribution[$next_section_index];
        if($next_exchange ne $last_exchange) {
            last;
        }
    }

    my $spoken_location = $section_pronunciation{$section_distribution[$next_section_index]};
    if($class_distribution[$next_class_index] =~ m/^(\d+\w)(\d+\w)$/) {
        my $class1 = $1;
        my $class2 = $2;

        print "$next_exchange [$class1, $class2, $spoken_location]^\n";
    } else {
        $class_distribution[$next_class_index] =~ m/^(\d+)(.*)$/;
        my $num_operators = $1;
        my $station_type = $2;

        print "$next_exchange [$num_operators $station_type, $spoken_location]^\n";
    }
}