#!/usr/bin/perl
use strict;
use Cwd;

my $num_qsos = 100;
my $which_parts = 0; # 0=ALL, 1 =P1/Intro, 2=P2/Info, 3=P3/More_Info, 4=P4/Ending

### Load Names
open my $in, "<", "data/Names.txt";
my @lines = <$in>;
close $in;

my @names;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    push @names, $line;
}

### Load cities and states
open my $in, "<", "data/US-Cities.txt";
@lines = <$in>;
close $in;

my @locations;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    push @locations, $line;
}


my %greeting_opening = (
    'GM' => "Good morning",
    'GA' => "Good afternoon",
    'GE' => "Good evening"
);

my %common_rst = (
    '599' => "5 9 9",
    '5NN' => "5 N N",
    '559' => "5 5 9"
);
my @common_weather = ('Sun', 'Clear', 'Clouds', 'Rain');

my %rigs = (
    'IC7300'    => "ICOM 73 hundred",
    'IC7100'    => "ICOM 71 hundred",
    'IC718'     => "ICOM 7 18",
    'IC705'     => "ICOM 7 O 5",
    'FT991A'    => "Yaesu FT, 9 9 1 A",
    'FT DX3000' => "Yaesu FT, DX 3000",
    'FT DX10'   => "Yaesu FT, DX 10",
    'FT450D'   => "Yaesu 450 D",
    'K4'        => "K 4",
    'K3S'       => "K 3 S",
    'KX2'       => "K X 2",
    'KX3'       => "K X 3",
    'K2'        => "K 2",
    'Home brew' => "Home Brew",
    'TS 590SG ' => "Kenwood TS-590SG",
    'Ten Tec Eagle' => "Ten Tec Eagle"
);

my @common_watts = ('5', '10', '25', '50', '100');
my @common_antenna_heights = ('15', '20', '25', '30', '40', '50', '75', '100');

my %common_antennas = (
    'DIPOLE'    => 'Dipole',
    'BEAM'      => 'Beam',
    '3 EL BEAM' => 'Three element beam',
    '2 EL BEAM' => 'Two element beam',
    'VERT'      => 'Vertical',
    'EFHW'      => 'End fed, half-wave',
    'OCF'       => 'Off-center fed dipole'
);

my %common_occupations = (
    'Driver'        => 'Truck Driver',
    'Nurse'         => 'Registered Nurse',
    'Supervisor'    => 'Supervisor',
    'Retail'        => 'Retail Sales',
    'IT'            => 'Software Developer',
    'Service'       => 'Customer Service Rep',
    'Manager'       => 'Marketing Manager',
    'Support'       => 'Computer Support Specialist',
    'Networking'    => 'Network Administrator',
    'Web'           => 'Web Developer',
    'Analyst'       => 'Management Analyst',
    'Medial'        => 'Medical Health Services',
    'Accountant'    => 'Accountant',
    'IT'            => 'IT Project Manager',
    'Manager'       => 'Sales Manager',
    'Engineer'      => 'Industrial Engineer',
    'Assistant'     => 'Executive Assistant',
    'Sales'         => 'Sales Representative',
    'Manufacturing' => 'Manufacturing',
    'Social'        => 'Social Worker',
    'Health'        => 'Nursing Assistant',
    'Food'          => 'Food Preparation',
    'LPN'           => 'Licensed Practical Nurse',
    'Manager'       => 'General Manager',
    'Manager'       => 'Operations Manager',
    'Manager'       => 'Financial Manager',
    'Manager'       => 'Branch Manager',
    'Agent'         => 'Insurance Sales Agent',
    'Finance'       => 'Financial Services Agent',
    'Nurse'         => 'Critical Care Nurse',
    'Cashier'       => 'Cashier',
    'Engineer'      => 'Computer Systems Engineer',
    'Engineer'      => 'Industrial Engineer',
    'Engineer'      => 'Civil Engineer',
    'Engineer'      => 'Electronics Engineer',
    'Engineer'      => 'Aerospace Engineer',
    'Architect'     => 'Software Architect',
    'Analyst'       => 'Market Research Analyst',
    'Therapist'     => 'Physical Therapist',
    'Secretary'     => 'Medical Secretary',
    'Laborer'       => 'Day Laborer',
    'Guard'         => 'Security Guard',
    'Doctor'        => 'Family Practitioner',
    'Doctor'        => 'General Practitioner'
);

my @usa_callsigns = (
    'N7ON',
    'N5HZ',
    'N2OO',
    'N1LN',
    'K9FD',
    'K7BV',
    'N6PN',
    'W1RM',
    'W9GL',
    'N5KT',
    'K1RV',
    'K2TW',
    'K5TA',
    'K4EU',
    'K2CJ',
    'W3TW',
    'K7SF',
    'W1UJ',
    'K8BZ',
    'N9MM',
    'K1QX',
    'N2CX',
    'K6GT',
    'W8FJ',
    'N4CW',
    'K5KG',
    'W6NS',
    'N6EV',
    'K5LG',
    'K8IA',
    'K0ZR',
    'N0EF',
    'K0JP',
    'N0AV',
    'K8ZZ',
    'K3UA',
    'K0EJ',
    'W4PM',
    'W4ER',
    'N5WE',
    'K0EX',
    'K6PO',
    'K8NZ',
    'K7SV',
    'N7YT',
    'W7GB',
    'K3TF',
    'N2GTF',
    'N9III',
    'KB3MT',
    'N7NWW',
    'K6RHT',
    'N1DPW',
    'WA0AM',
    'N5BPJ',
    'W9KKN',
    'KI6OJ',
    'W9FTI',
    'N8GZJ',
    'N4OGD',
    'KA0DC',
    'N3PPC',
    'K1BNQ',
    'W9TAS',
    'KF9WZ',
    'K5DAC',
    'N8LQT',
    'AJ4OC',
    'N7FKN',
    'W4YMT',
    'W4RZA',
    'AC9AH',
    'N0QCJ',
    'K0ATA',
    'K4QJH',
    'N6YES',
    'N2ODI',
    'W0OFK',
    'N3HXG',
    'KM4EM',
    'KJ6KQM',
    'WB0QGR',
    'KG6HBL',
    'KC2UHW',
    'KB6AQC',
    'KD0ZRC',
    'KC5DEY',
    'KC8ITX',
    'KC3EAZ',
    'KE5MUO',
    'KE0MPF',
    'KF7FUZ',
    'WA4RDS',
    'WA6MKH',
    'KB6PKM',
    'KA9HJR',
    'KC8AZB',
    'WA9BXI',
    'KJ4CYS',
    'KD4HOO',
    'KI6LVS',
    'KJ7DSY',
    'KJ4OTQ',
    'KI7OKG',
    'KC4JAK',
    'WD4IYH',
    'KB7FLB',
    'KF7UEJ',
    'KC7SWA',
    'KE4TNB',
    'KE5JQT',
    'KK4ZTN',
    'KD9JQN',
    'KB3RGX',
    'KE6OYE',
    'KI4BEX'
);


sub generate_part1_intro {
    my $is_by_itself = $_[0];
    my $is_standard = $_[1];

    my $repeat_important_info = int(rand(2));

    my @greeting_opening_keys = keys %greeting_opening;
    my $greeting_index_pick = int(rand(scalar @greeting_opening_keys));
    my $greeting_code = $greeting_opening_keys[$greeting_index_pick];
    my $greeting_spoken = $greeting_opening{$greeting_code};

    my @rst_keys = keys %common_rst;
    my $rst_index_pick = int(rand(scalar @rst_keys));
    my $rst_code = $rst_keys[$rst_index_pick];
    my $rst_spoken = $common_rst{$rst_code};

    my $location = $locations[int(rand(scalar @locations))];
    $location =~ m/^(.+?),\s*(.*)$/;
    my $state = $2;
    my $use_near_in_location = int(rand(2));

    my $name = $names[int(rand(scalar @names))];

    if($is_by_itself == 1) {
        print "VVV [New Introduction|VVV]^\n";
    } else {
        print "VVV 1 [New QSO\\. Part 1, Introduction|VVV]^\n";
    }


    # Standard format
    if($is_standard == 1) {
        my $thanks_for_call = int(rand(2));

        if($thanks_for_call == 1) {
            print "$greeting_code ES TNX FER CALL [$greeting_spoken and thanks for call]^\n";
        } else {
            print "$greeting_code ES TNX FER RPRT [$greeting_spoken and thanks for report]^\n";
        }

        if($repeat_important_info == 1) {
            print "UR RST $rst_code $rst_code [Your, R S T, $rst_spoken]^\n";
        } else {
            print "UR RST $rst_code [Your, R S T, $rst_spoken]^\n";
        }

        if($use_near_in_location == 1) {
            if($repeat_important_info == 1) {
                print "QTH NR $location $state [Location Near $location\\. $state]^\n";
            } else {
                print "QTH NR $location [Location Near $location]^\n";
            }
        } else {
            if($repeat_important_info == 1) {
                print "QTH $location $state [Location $location\\. $state]^\n";
            } else {
                print "QTH $location [Location $location]^\n";
            }
        }

        if($repeat_important_info == 1) {
            print "Name $name $name [Name $name]^\n";
        } else {
            print "Name $name [Name $name]^\n";
        }

        print "OK HW\\? <AR> [Okay\\. How copy\\? End of message\\.]^\n";

    # else Quick format
    } else {
        print "$greeting_code TNX [$greeting_spoken, Thanks]^\n";

        if($use_near_in_location == 1) {

            if($repeat_important_info == 1) {
                print "UR RST $rst_code $rst_code NR $location $state [Your, R S T, $rst_spoken\\. Near $location]^\n";
            } else {
                print "UR RST $rst_code NR $location [Your, R S T, $rst_spoken\\. Near $location]^\n";
            }

        } else {

            if($repeat_important_info == 1) {
                print "UR RST $rst_code $rst_code $location $state [Your, R S T, $rst_spoken\\. $location]^\n";
            } else {
                print "UR RST $rst_code $location [Your, R S T, $rst_spoken\\. $location]^\n";
            }

        }

        if($repeat_important_info == 1) {
            print "Name $name $name [Name $name]^\n";
        } else {
            print "Name $name [Name $name]^\n";
        }

        print "HW\\? BK [How copy\\? Break]^\n";

    }

}


sub generate_part2_info {
    my $is_by_itself = $_[0];
    my $is_standard = $_[1];
    my $their_name = $_[2];

    my @rig_keys = keys %rigs;
    my $rig_index_pick = int(rand(scalar @rig_keys));
    my $rig_code = $rig_keys[$rig_index_pick];
    my $rig_spoken = $rigs{$rig_code};

    my @antenna_keys = keys %common_antennas;
    my $antenna_index_pick = int(rand(scalar @antenna_keys));
    my $antenna_code = $antenna_keys[$antenna_index_pick];
    my $antenna_spoken = $common_antennas{$antenna_code};

    my $power = $common_watts[int(rand(scalar @common_watts))];
    my $antenna_height = $common_antenna_heights[int(rand(scalar @common_antenna_heights))];
    my $weather = $common_weather[int(rand(scalar @common_weather))];

    my $temp_in_f = int(rand(100));

    #print ("========\n");
    if($is_by_itself == 1) {
        print "VVV [New Info|VVV]^\n";
    } else {
        print "VVV 2 [Part 2, Info|VVV]^\n";
    }


    # Standard format
    if($is_standard == 1) {
        print "OK $their_name FB ES TNX FER RPRT [OK $their_name\\. Fine Business and thanks for report\\.]^\n";
        print "RIG $rig_code ES PWR ${power}W [Rig, $rig_spoken, and Power $power watts\\.]^\n";
        print "ANT $antenna_code UP $antenna_height FT [Antenna, ${antenna_spoken}, up $antenna_height feet\\.]^\n";
        print "WX $weather ES TEMP ${temp_in_f}F [Weather ${weather}, and temperature ${temp_in_f} fahrenheit\\.]^\n";
        print "OK HW\\? <AR> [Okay\\. How copy\\? End of message\\.]^\n";
    # else Quick format
    } else {
        print "TNX RPRT [Thanks report]^\n";
        print "RIG $rig_code ${power}W $antenna_code UP $antenna_height FT [Rig, $rig_spoken, Power $power watts, ${antenna_spoken} up $antenna_height feet\\.]^\n";
        print "WX ${temp_in_f}F $weather [Weather ${temp_in_f} fahrenheit, ${weather}\\.]^\n";
        print "HW\\? BK [How copy\\? Break]^\n";
    }

}

sub generate_part3_more_info {
    my $is_by_itself = $_[0];
    my $is_standard = $_[1];
    my $their_name = $_[2];

    my @occupation_keys = keys %common_occupations;
    my $occupation_index_pick = int(rand(scalar @occupation_keys));
    my $occupation_code = $occupation_keys[$occupation_index_pick];
    my $occupation_code_full = $common_occupations{$occupation_code};

    my $age = int(rand(80))+20;
    my $ham_for = int($age-18);

    my $is_retired = int(rand(2));
    if($age <= 55) {
        $is_retired = 0;
    } elsif($age >= 70) {
        $is_retired = 1;
    }

    my $how_long_retired = 1;
    if($age >= 70) {
        $how_long_retired = $age - 65 + int(rand(3));
    } else {
        $how_long_retired = int(rand(5));
    }

    #print ("========\n");
    if($is_by_itself == 1) {
        print "VVV [New Part, More Info|VVV]^\n";
    } else {
        print "VVV 3 [Part 3, More Info|VVV]^\n";
    }


    # Standard format
    if($is_standard == 1) {
        print "OK $their_name SOLID COPY [OK $their_name\\. Solid Copy\\.]^\n";
        print "BEEN HAM FER $ham_for YRS [Been ham for $ham_for years\\.]^\n";
        print "AGE HR $age YRS [Age here, $age years\\.]^\n";
        if($is_retired == 1) {
            if($how_long_retired==1) {
                print "RETIRED $occupation_code_full ABT $how_long_retired YR AGO [Retired $occupation_code_full about $how_long_retired year ago\\.]^\n";
            } else {
                print "RETIRED $occupation_code_full ABT $how_long_retired YRS AGO [Retired $occupation_code_full about $how_long_retired years ago\\.]^\n";
            }
        } else {
            print "$occupation_code_full [$occupation_code_full\\.]^\n";
        }
        print "OK HW\\? <AR> [Okay, how copy\\? End of message\\.]^\n";
    # else Quick format
    } else {
        print "FB $their_name TNX INFO [Fine Business, $their_name\\. Thanks Info\\.]^\n";
        print "HAM FER $ham_for YRS [Ham for $ham_for years\\.]^\n";
        print "AGE $age [Age $age\\.]^\n";
        if($is_retired == 1) {
            print "RETIRED $occupation_code [Retired $occupation_code\\.]^\n";
        } else {
            print "$occupation_code [$occupation_code\\.]^\n";
        }
        print "HW\\? BK [How Copy\\? Break\\.]^\n";
    }

}

sub get_callsign_pronuciation {
    my $callsign = $_[0];

    if($callsign =~ m/^([A-Z]+)(\d)([A-Z]+)$/) {
        my $prefix = $1;
        my $number = $2;
        my $suffix = $3;

        $prefix = join(' ', split(//, $prefix));
        $suffix = join(' ', split(//, $suffix));

        $suffix =~ s/(\w+) \1/$1, $1/g; #deal with weird pronunciation with duplicate letters

        return "$prefix $number, $suffix";
    }

    return $callsign;

}

sub generate_part4_ending {
    my $is_by_itself = $_[0];
    my $is_standard = $_[1];
    my $their_name = $_[2];

    my $caller_callsign = $usa_callsigns[int(rand(scalar @usa_callsigns))];
    my $calling_callsign = $caller_callsign;
    while($caller_callsign eq $calling_callsign) {
        $calling_callsign = $usa_callsigns[int(rand(scalar @usa_callsigns))];
    }

    my $caller_callsign_pronuciation = get_callsign_pronuciation($caller_callsign);
    my $calling_callsign_pronuciation = get_callsign_pronuciation($calling_callsign);

    #print ("========\n");
    if($is_by_itself == 1) {
        print "VVV [New Ending|VVV]^\n";
    } else {
        print "VVV 4 [Part 4, Ending|VVV]^\n";
    }


    # Standard format
    if($is_standard == 1) {
        print "OK $their_name TNX FER FB QSO ES HP CUAGN [Okay $their_name\\. Thanks for fine business, Q S O, And hope see you again\\.]^\n";
        print "73 <AR> $calling_callsign DE $caller_callsign TU <SK> [73, end of message, ${caller_callsign_pronuciation}, from, ${calling_callsign_pronuciation}, Thank you\\. End of transmission\\.]^\n";

        # else Quick format
    } else {
        print "TNX INFO ES QSO 73 CUAGN <AR> [Thanks info, and QSO, 73, see you again\\. End of message\\.]^\n";
        print "$calling_callsign DE $caller_callsign TU <SK> [${caller_callsign_pronuciation}, from, ${calling_callsign_pronuciation}, Thank you\\. End of transmission\\.]^\n";
    }

}


for(my $i = 0; $i <= $num_qsos; $i++){
    my $their_name = $names[int(rand(scalar @names))];
    my $is_standard = int(rand(2));
    my $is_by_itself = $which_parts!=0;

    if($which_parts==0 || $which_parts == 1) {
        generate_part1_intro($is_by_itself, $is_standard);
    }

    if($which_parts==0 || $which_parts == 2) {
        generate_part2_info($is_by_itself, $is_standard, $their_name);
    }

    if($which_parts==0 || $which_parts == 3) {
        generate_part3_more_info($is_by_itself, $is_standard, $their_name);
    }

    if($which_parts==0 || $which_parts == 4) {
        generate_part4_ending($is_by_itself, $is_standard, $their_name);
    }
}

