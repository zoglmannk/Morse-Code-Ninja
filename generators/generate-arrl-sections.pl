#!/usr/bin/perl

use strict;
use Cwd;


# Usage:
# ./generate-arrl-sections.pl > arrl-sections.txt

my $num_of_rand_selections = 800;
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
$section_pronunciation{'ND'} = 'North Dakota';
$section_pronunciation{'SD'} = 'South Dakota';

# Canadian Area Call Sign
$section_pronunciation{'NB'} = 'New Brunswick';
$section_pronunciation{'NS'} = 'Nova Scotia';
$section_pronunciation{'NL'} = 'Newfoundland Labrador';
$section_pronunciation{'QC'} = 'Quebec';
$section_pronunciation{'ONE'} = 'Ontario East';
$section_pronunciation{'ONN'} = 'Ontario North';
$section_pronunciation{'ONS'} = 'Ontario South';
$section_pronunciation{'PE'} = 'Prince Edward Island';
$section_pronunciation{'GH'} = 'Golden Horseshoe';
$section_pronunciation{'MB'} = 'Manitoba';
$section_pronunciation{'SK'} = 'Saskatchewan';
$section_pronunciation{'AB'} = 'Alberta';
$section_pronunciation{'BC'} = 'British Columbia';
$section_pronunciation{'TER'} = 'Territories';

$section_pronunciation{'DX'} = 'DX';
my @section_abbreviations = keys %section_pronunciation;

my $last_section = "";
for(my $i=0; $i<$num_of_rand_selections; $i++) {
    my $next_section_abbreviation_index = int(rand(scalar(@section_abbreviations)));


    my $next_section = "";
    while(1==1) {
        $next_section = $section_abbreviations[$next_section_abbreviation_index];
        if($next_section ne $last_section) {
            last;
        }
    }

    my $spoken_section = $section_pronunciation{$next_section};
    print "$next_section [$spoken_section]^\n";

}