#!/usr/bin/perl

use warnings FATAL => 'all';
use strict;
my $num_qsos = 200;

### Load Names
open my $in, "<", "data/Names-Simple.txt";
my @lines = <$in>;
close $in;

my @names;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    push @names, $line;
}


my %greeting_opening = (
    'GM' => "Good morning",
    'GA' => "Good afternoon",
    'GE' => "Good evening"
);

my %common_rst = (
    '599' => "5 9 9",
    '5NN' => "5 9 9",
    '559' => "5 5 9"
);

#random 25 summits in the USA
my @sota_summits = (
    'W0C/PR-035',
    'W0C/PR-024',
    'W0C/PR-037',
    'W0C/PR-042',
    'W0C/RP-003',
    'W0C/RP-077',
    'W0C/RP-123',
    'W0C/WE-002',
    'W0C/WE-047',
    'W0C/WE-042',
    'W0C/MZ-040',
    'K0M/SE-001',
    'K0M/SE-004',
    'K0M/CW-001',
    'W5N/SM-004',
    'W5N/SM-013',
    'W5N/SM-036',
    'W6/NS-001',
    'W6/NS-030',
    'W8O/SE-006',
    'W8O/SE-020',
    'W8O/SE-032',
    'W5T/SB-001',
    'W5T/SB-017',
    'W5T/SB-004'
);

my @usa_callsigns = (
    'K7ME',
    'WE9E',
    'AF7S',
    'KJ4G',
    'K1BM',
    'KQ3G',
    'KB7J',
    'NS6I',
    'W8LI',
    'KT5L',
    'W2PA',
    'N4JP',
    'KG2I',
    'W1HS',
    'KI2Z',
    'NP2G',
    'KT5D',
    'NJ5B',
    'NM5U',
    'K3YY',
    'WZ7G',
    'K5QV',
    'K8TL',
    'N8XC',
    'N8JT',
    'WW9D',
    'NM3G',
    'K6DD',
    'N3RB',
    'NK9V',
    'K8NE',
    'WG1L',
    'K8HV',
    'K4CF',
    'K7QA',
    'KS8D',
    'N3CF',
    'KE7L',
    'N8TM',
    'WX9D',
    'WJ7Q',
    'NQ0C',
    'KG7X',
    'W6KN',
    'WW7J',
    'N7GR',
    'N9UF',
    'AK0J',
    'NR6H',
    'NI7H',
    'K5VRS',
    'N1CYW',
    'AD6VV',
    'K6OKG',
    'W2PPJ',
    'K4KTX',
    'N6PJG',
    'N0WLL',
    'KM5VH',
    'W0IST',
    'K2JWW',
    'W6WYS',
    'AF7QL',
    'N4UXX',
    'W6JQA',
    'KD5KZ',
    'N7YWM',
    'W4VLA',
    'K7ZAM',
    'N6IJT',
    'K6AAD',
    'KH6FD',
    'K8HZK',
    'AC6GB',
    'K9NPD',
    'N9SNW',
    'KD5TB',
    'AE7YY',
    'N0TDN',
    'K7RIV',
    'KF6CJ',
    'K1RPC',
    'K1AFS',
    'KC4FO',
    'KJ5WP',
    'N7SLC',
    'W0TEM',
    'AG4MO',
    'AD5JD',
    'N6AOT',
    'K5SMG',
    'N1MLM',
    'AE5UR',
    'AJ4GE',
    'K6VAN',
    'W8RAS',
    'KB3BV',
    'W5RWT',
    'KV4IK',
    'K9CNR',
    'W0SFK',
    'WP4LM',
    'N9VAB',
    'KD9MC',
    'W1LYQ',
    'N7SOQ',
    'W0WSK',
    'K4SAG',
    'N2MGO',
    'W4GCM',
    'N3MLF',
    'N0GJP',
    'W7POD',
    'N0NCS',
    'K4BUN',
    'W1DEE',
    'AG4JP',
    'WW5LW',
    'W4OMA',
    'N4ASK',
    'N7KJK',
    'W3IJW',
    'K5TRX',
    'W4SMG',
    'N8PAN',
    'KD9HP',
    'W7PTL',
    'N4BAR',
    'N4NOC',
    'K9VTR',
    'KD8FJ',
    'N4HQU',
    'N6XDX',
    'N5DSV',
    'N2HDV',
    'W1ITU',
    'W6PRC',
    'W9LCM',
    'N9ZXW',
    'KB1NU',
    'KE6IR',
    'AA5TR',
    'AF6YG',
    'AF6KN',
    'N6WIY',
    'KK7PW',
    'K7SRL',
    'N6NGS',
    'AD0HD',
    'N4WPQ',
    'KJ4KBF',
    'KD4ILY',
    'WB2IUR',
    'KF6GLW',
    'KG4WZM',
    'KI6MZY',
    'KD0BQX',
    'KC6GFB',
    'KC0JMZ',
    'KF4ZPD',
    'WA0VEB',
    'WP4MFH',
    'KJ4SIG',
    'KA6IAM',
    'KB5YFN',
    'KG4JSW',
    'KG5KQS',
    'KA1IEZ',
    'KD9FXE',
    'KD7PQW',
    'KA1RXF',
    'WB8NHV',
    'KC8AIA',
    'KK4UTN',
    'WY0WYO',
    'KF4DFC',
    'WB9ICL',
    'KI4ZPC',
    'KK4ZEH',
    'KR8ZZY',
    'WA7VGW',
    'KG5GNV',
    'KC0LOV',
    'KM6ZFW',
    'KB3LDI',
    'KM6BYS',
    'WD4NWW',
    'WA4CNE',
    'KA2OTX',
    'KA6WTI',
    'KB0QJQ',
    'WB2TBF',
    'KC1GUF',
    'KC7YES',
    'KA2PHK',
    'KK4TGO',
    'KJ7CBT',
    'KA1JBZ',
    'WA4FCM',
    'KE8AXL'
);

sub get_pronouncable_call {
    my $call = $_[0];
    my $ret = "";
    my $is_first = 1;
    my $was_natural_pause = 0;

    for my $c (split //, $call) {
        if($c eq "0") {
            $c = "zero";
        } elsif($c eq "/") {
            $c = "slash";
        }

        if($is_first == 1) {
            $is_first = 0;
            $ret = $c;
        } elsif ($c =~ m/[0-9]|zero|slash/) {
            if($was_natural_pause == 1) {
                $ret = $ret . ", " . $c;
            } else {
                $ret = $ret . " " . $c;
            }

            $was_natural_pause = 1;
        } elsif ($was_natural_pause == 1) {
            $was_natural_pause = 0;
            $ret = $ret . ", " . $c;
        } else {
            $ret = $ret . " " . $c;
        }
    }

    return $ret;
}

sub print_qso_type1 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);

    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser
    print "|f650 $chaser1_callsign [<speak><prosody rate=\"slow\">$chaser1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$chaser1_callsign $greeting_abbreviation $chaser1_name UR $rst_code1 $rst_code1 <BK> [$chaser1_callsign_prounounceable, $greeting_spoken $chaser1_name, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser
    print "|f650 RR $activator_name UR $rst_code2 $rst_code2 [Received, Received, $activator_name, You are, $rst_spoken2, $rst_spoken2]^\n";
    #Activator
    print "RR TU ES 73S EE [Received, Received, Thank You, Best Regards, dit dit]^\n";
    #Chaser
    print "|f650 EE [dit dit]^\n";
    #print "===\n";
}

sub print_qso_type2 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);

    $chaser1_callsign =~ m/.*?\d(.{3})|.*?(\d.+)/;

    my $chaser_callsign_suffix = "";
    if(defined($1)) {
        $chaser_callsign_suffix = $1;
    } else {
        $chaser_callsign_suffix = $2;
    }
    my $chaser_callsign_suffix_pronounceable = join(' ', split('', $chaser_callsign_suffix));
    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser
    print "|f650 $chaser1_callsign [<speak><prosody rate=\"slow\">$chaser1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "${chaser_callsign_suffix}\? [${chaser_callsign_suffix_pronounceable}, question mark]^\n";
    #Chaser
    print "|f650 $chaser1_callsign [$chaser1_callsign_prounounceable]^\n";
    #Activator
    print "$chaser1_callsign $greeting_abbreviation $chaser1_name UR $rst_code1 $rst_code1 <BK> [$chaser1_callsign_prounounceable, $greeting_spoken $chaser1_name, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser
    print "|f650 RR $activator_name UR $rst_code2 $rst_code2 [Received, Received, $activator_name, You are, $rst_spoken2, $rst_spoken2]^\n";
    #Activator
    print "RR TU ES 73S EE [Received, Received, Thank You, and Best Regards, dit dit]^\n";

    #Chaser
    if(int(rand(100)) >= 50) {
        print "|f650 EE [dit dit]^\n";
    } else {
        print "|f650 GL ES 73S EE [Good Luck and best regards\\. dit dit]^\n";
    }

    #print "===\n";
}


sub print_qso_type3 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);

    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser
    print "|f650 $chaser1_callsign [<speak><prosody rate=\"slow\">$chaser1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$chaser1_callsign $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$chaser1_callsign_prounounceable, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser
    print "|f650 RR UR $rst_code2 $rst_code2 Name here is $chaser1_name [Received, Received, You are, $rst_spoken2, $rst_spoken2\\. Name here is ${chaser1_name}\\.]^\n";
    #Activator
    print "RR $chaser1_name NM is $activator_name TU ES 73S EE [Received, Received ${chaser1_name}, Name is ${activator_name}\\. Thank You and Best Regards, dit dit]^\n";
    #Chaser
    print "|f650 EE [dit dit]^\n";
    #print "===\n";
}

sub print_qso_type4 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);

    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser
    print "|f650 $activator_callsign DE $chaser1_callsign $chaser1_callsign <BK> [<speak><prosody rate=\"slow\">${activator_callsign_pronounceable}\\.</prosody> FROM <prosody rate=\"slow\">${chaser1_callsign_prounounceable}\\.</prosody> <prosody rate=\"slow\">${chaser1_callsign_prounounceable}\\.</prosody> Break</speak>]^\n";
    #Activator
    print "$chaser1_callsign $greeting_abbreviation $chaser1_name UR $rst_code1 $rst_code1 <BK> [$chaser1_callsign_prounounceable, $greeting_spoken $chaser1_name, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser
    print "|f650 RR $activator_name UR $rst_code2 $rst_code2 [Received, Received, $activator_name, You are, $rst_spoken2, $rst_spoken2]^\n";
    #Activator
    print "RR TU ES 73S EE [Received, Received, Thank You and Best Regards, dit dit]^\n";
    #Chaser
    print "|f650 EE [dit dit]^\n";
    #print "===\n";
}

sub print_qso_type5 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);

    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser
    print "|f650 $chaser1_callsign [<speak><prosody rate=\"slow\">$chaser1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$chaser1_callsign TU UR $rst_code1 $rst_code1 <BK> [$chaser1_callsign_prounounceable, Thank you\\. You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser
    if(int(rand(100)) >= 50) {
        print "|f650 RR TU ES $greeting_abbreviation UR $rst_code2 $rst_code2 73 <BK> [Received, Received\\. Thank you, and ${greeting_spoken}\\. You are, $rst_spoken2, $rst_spoken2\\. Best Regards\\. Break]^\n";
    } else {
        print "|f650 <BK> TU ES $greeting_abbreviation UR $rst_code2 $rst_code2 73 <BK> [Break\\. Thank you, and ${greeting_spoken}\\. You are, $rst_spoken2, $rst_spoken2\\. Best Regards\\. Break]^\n";
    }
    #Activator
    print "<BK> TU 73 EE [Break, Thank You\\. Best Regards\\. dit dit\\.]^\n";
    #print "===\n";
}

sub print_qso_type6 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);
    my $chaser2_callsign_prounounceable = get_pronouncable_call($chaser2_callsign);

    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser 1
    print "|f650 $chaser1_callsign [<speak><prosody rate=\"slow\">$chaser1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$chaser1_callsign TU UR $rst_code1 $rst_code1 <BK> [$chaser1_callsign_prounounceable, Thank you\\. You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser 1
    print "|f650 RR $greeting_abbreviation UR $rst_code2 $rst_code2 73 [Received, Received\\. ${greeting_spoken}\\. You are, $rst_spoken2, $rst_spoken2\\. Best Regards]^\n";
    #Activator
    print "\\? [Station calling\\?]^\n";
    #Chaser 2
    print "|f600 $chaser2_callsign [$chaser2_callsign_prounounceable]^\n";
    #Activator
    print "$chaser2_callsign TU UR $rst_code1 $rst_code1 <BK> [$chaser2_callsign_prounounceable\\. Thank you\\. You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Chaser 2
    print "|f600 RR TU ES $greeting_abbreviation UR $rst_code2 $rst_code2 73 [Received, Received\\. Thank you, and ${greeting_spoken}\\. You are, $rst_spoken2, $rst_spoken2\\. Best Regards]^\n";
    #Activator
    print "RR TU 73 EE [Received, Received\\. Thank you\\. Best regards\\. dit dit]^\n";
    #print "===\n";
}

sub print_qso_type8 {
    my $activator_callsign = $_[0];
    my $chaser1_callsign = $_[1];
    my $chaser2_callsign = $_[2];

    my $activator_name = $_[3];
    my $chaser1_name = $_[4];
    my $chaser2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $chaser1_callsign_prounounceable = get_pronouncable_call($chaser1_callsign);
    my $chaser2_callsign_prounounceable = get_pronouncable_call($chaser2_callsign);

    my $activator_summit = $sota_summits[int(rand(scalar @sota_summits))];
    my $chaser1_summit = $activator_summit;
    while($chaser1_summit eq $activator_summit) {
        $chaser1_summit = $sota_summits[int(rand(scalar @sota_summits))];
    }

    my $activator_summit_sent = $activator_summit;
    $activator_summit_sent =~ s/-//g;

    my $activator_summit_spoken = $activator_summit;
    $activator_summit_spoken =~ m/(\S+)\/([A-Za-z]{2})-(\d+)/;
    my $part1 = $1; my $part2 = $2; my $part3 = $3;
    $part2 = join(" ", split(//, $part2));
    $activator_summit_spoken = "<break time=\"0\\.5s\"/> $part1 <break time=\"0\\.25s\"/> slash <break time=\"0\\.25s\"/> $part2 <break time=\"0\\.25s\"/> $part3";

    my $chaser1_summit_sent = $chaser1_summit;
    $chaser1_summit_sent =~ s/-//g;

    my $chaser_summit_spoken = $chaser1_summit;
    $chaser_summit_spoken =~ m/(\S+)\/([A-Za-z]{2})-(\d+)/;
    $part1 = $1; $part2 = $2; $part3 = $3;
    $part2 = join(" ", split(//, $part2));
    $chaser_summit_spoken = "<break time=\"0\\.5s\"/> $part1 <break time=\"0\\.25s\"/> slash <break time=\"0\\.25s\"/> $part2 <break time=\"0\\.25s\"/> $part3";
    #W8O/SE-032


    #Activator
    print "CQ SOTA CQ SOTA DE $activator_callsign $activator_callsign [<speak>C Q SOTA, C Q SOTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Chaser 1
    print "|f650 S2S S2S [<speak><prosody rate=\"slow\">summit to summit\\.</prosody></speak>]^\n";
    #Activator
    print "S2S S2S\\? [<speak><prosody rate=\"slow\">summit to summit\\?</prosody></speak>]^\n";
    #Chaser 1
    print "|f650 DE $chaser1_callsign S2S [<speak>From, ${chaser1_callsign_prounounceable}\\.<prosody rate=\"slow\">summit to summit</prosody></speak>]^\n";
    #Activator
    print "AGN [Again]^\n";
    #Chaser 1
    print "|f650 DE $chaser1_callsign $chaser1_callsign S2S [<speak>From, <prosody rate=\"slow\">${chaser1_callsign_prounounceable} <break time=\"0\\.5s\"/> ${chaser1_callsign_prounounceable}\\. </prosody><prosody rate=\"slow\">summit to summit</prosody></speak>]^\n";
    #Activator
    print "$chaser1_callsign $greeting_abbreviation $chaser1_name 559 559 $activator_summit_sent $activator_summit_sent <BK> [<speak>${chaser1_callsign_prounounceable}, $greeting_spoken $chaser1_name\\. 5 5 9, 5 5 9, <prosody rate=\"slow\">$activator_summit_spoken\\. $activator_summit_spoken\\.</prosody> Break</speak>]^\n";
    #Chaser 1
    print "|f650 QSL QSL $greeting_abbreviation $activator_name UR 559 559 $chaser1_summit_sent $chaser1_summit_sent [<speak>Copied\\. Copied\\. $greeting_spoken $activator_name\\. You are 5 5 9, 5 5 9, <prosody rate=\"slow\">$chaser_summit_spoken\\. $chaser_summit_spoken</prosody></speak>]^\n";
    #Activator
    print "RR TU S2S 73S ES GL EE [<speak>Received\\. Received\\. Thank you, <prosody rate=\"slow\">summit to summit</prosody>, and Good Luck\\. dit dit\\.</speak>]^\n";
    #print "===\n";
}

for(my $i = 0; $i <= $num_qsos; $i++) {
    my $activator_callsign = $usa_callsigns[int(rand(scalar @usa_callsigns))];
    my $chaser1_callsign = $activator_callsign;
    while($activator_callsign eq $chaser1_callsign) {
        $chaser1_callsign = $usa_callsigns[int(rand(scalar @usa_callsigns))];
    }
    my $chaser2_callsign = $activator_callsign;
    while($activator_callsign eq $chaser2_callsign || $chaser1_callsign eq $chaser2_callsign) {
        $chaser2_callsign = $usa_callsigns[int(rand(scalar @usa_callsigns))];
    }

    my $activator_name = $names[int(rand(scalar @names))];
    my $chaser1_name = $activator_name;
    while($activator_name eq $chaser1_name) {
        $chaser1_name = $names[int(rand(scalar @names))];
    }
    my $chaser2_name = $activator_name;
    while($activator_name eq $chaser2_name || $chaser1_name eq $chaser2_name) {
        $chaser2_name = $names[int(rand(scalar @names))];
    }

    my @rst_keys = keys %common_rst;
    my $rst_index_pick1 = int(rand(scalar @rst_keys));
    my $rst_code1 = $rst_keys[$rst_index_pick1];
    my $rst_spoken1 = $common_rst{$rst_code1};
    my $rst_index_pick2 = int(rand(scalar @rst_keys));
    my $rst_code2 = $rst_keys[$rst_index_pick2];
    my $rst_spoken2 = $common_rst{$rst_code2};

    my @greeting_keys = keys %greeting_opening;
    my $greeting_index_pick = int(rand(scalar @greeting_keys));
    my $greeting_abbreviation = $greeting_keys[$greeting_index_pick];
    my $greeting_spoken = $greeting_opening{$greeting_abbreviation};

    #print "** activator_name:$activator_name, chaser1_name:$chaser1_name, chaser2_name:$chaser2_name\n";
    #print "**** chaser_callsign:$activator_callsign, chaser1_callsign:$chaser1_callsign, chaser2_callsign:$chaser2_callsign\n";
    print "VVV [New SOTA QSO]^\n";

    my $which_qso = int(rand(8))+1; # -1;
    if($which_qso == -1) {
        print_qso_type8($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } elsif ($which_qso == 1) {
        print_qso_type1($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } elsif($which_qso == 2) {
        print_qso_type2($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } elsif($which_qso == 3) {
        print_qso_type3($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } elsif($which_qso == 4) {
        print_qso_type4($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } elsif($which_qso == 5) {
        print_qso_type5($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } elsif($which_qso == 6) {
        print_qso_type6($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    } else {
        print_qso_type8($activator_callsign, $chaser1_callsign, $chaser2_callsign,
            $activator_name, $chaser1_name, $chaser2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken);
    }


}