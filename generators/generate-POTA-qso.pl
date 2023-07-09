#!/usr/bin/perl

use warnings FATAL => 'all';
use strict;


# Proofing command
# ./generate-POTA-qso.pl > test-pota-qsos.txt
# cat test-pota-qsos.txt | perl -e 'while(<>){ $in = $_; chomp($in); $in =~ s/\[(?!New POTA).*\]//g; $in =~ s/\|f\d+ //g; print "$in\n"; }'

# ./generate-POTA-qso.pl > ../pota-qsos.txt
# ./render.pl -i pota-qsos.txt -s 15 17 20 22 25 28 30 35 40 45 50 --sm 2.5

my $num_qsos = 250;
my $proofing = 0;

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


### Load Activator USA Call Signs
open $in, "<", "data/pota-top-activators-2023.txt";
@lines = <$in>;
close $in;

my @activator_call_signs;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line =~ m/^(K|W|A|N).*$/) {
        push @activator_call_signs, $line;
    }
}


### Load Hunter USA Call Signs
open $in, "<", "data/pota-top-hunters-2023.txt";
@lines = <$in>;
close $in;

my @hunter_call_signs;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line =~ m/^(K|W|A|N).*$/) {
        push @hunter_call_signs, $line;
    }
}


### Load most common activated parks
open $in, "<", "data/pota-top-parks-2023.csv";
@lines = <$in>;
close $in;

my @parks;

foreach(@lines) {
    my $line = $_;
    chomp($line);

    #example line:
    #K-3791,Trail of Tears National Historic Trail,US-AL, + 8,EM66,2231,2183,82474,0,0

    if($line =~ m/^([^,]+)/) {
        #print "$1\n";
        my $park = $1;
        push @parks, $park;
    }

}

my %greeting_opening = (
    'GM' => "Good morning",
    'GA' => "Good afternoon",
    'GE' => "Good evening"
);

my %common_rst = (
    '599' => "5 9 9",
    '5NN' => "5 9 9",
    '57N' => "5 7 9",
    '559' => "5 5 9",
);

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

# Typical Exchange
sub print_qso_type1 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU ES $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, And $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation ES 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }

}

# Exchange where Activator copies only part of the Hunter callsign
sub print_qso_type2 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    my $num_chars_in_partial_callsign = int(rand(3))+1;
    #print "****** num_chars_in_partial_callsign:$num_chars_in_partial_callsign\n";
    my $hunter_partial_callsign = substr($hunter1_callsign, 0, $num_chars_in_partial_callsign); # first two characters
    if(int(rand(2)) == 0) {
        #print "**** negative index\n";
        $hunter_partial_callsign = substr($hunter1_callsign, -1*$num_chars_in_partial_callsign); # last two characters
    }
    my $hunter_partial_callsign_prounounceable = get_pronouncable_call($hunter_partial_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "${hunter_partial_callsign}\? [<speak> <prosody rate=\"slow\">$hunter_partial_callsign_prounounceable</prosody>, Question Mark</speak>]^\n";
    #Hunter
    print "|f650 DE $hunter1_callsign $hunter1_callsign BK [<speak>From, <prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody>, Break</speak>]^\n";
    #Activator
    print "<BK> $hunter1_callsign TU ES $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [Break, $hunter1_callsign_prounounceable, Thank You, And $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation ES 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Alternate Exchange
sub print_qso_type3 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign DE $activator_callsign TU ES $greeting_abbreviation $hunter1_name UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, from, $activator_callsign_pronounceable, Thank You, And $greeting_spoken $hunter1_name, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> TU $activator_name UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Thank you $activator_name, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 EE [Break, Thank You, dit dit]^\n";
    #Hunter
    print "|f650 73 GL EE [Best Regards, Good Luck, dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Very similar to Typical Exchange
sub print_qso_type4 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Very similar to Typical Exchange
sub print_qso_type5 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation ES 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Minimalist Exchange
sub print_qso_type6 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Activator ends previous QSO with QRZ
sub print_qso_type7 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "<BK> TU ES 73 DE $activator_callsign QRZ\? [<speak>Break, Thank You, And Best Regards from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> Who is calling me\?</speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Contact from a faint station or QSB or QRM
sub print_qso_type8 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "AGN\? [Again, Question Mark]^\n";
    #Hunter
    print "|f650 $hunter1_callsign $hunter1_callsign <BK> [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody>, Break </speak>]^\n";
    #Activator
    print "AGN AGN\? [Again, Again, Question Mark]^\n";
    #Hunter
    print "|f650 $hunter1_callsign $hunter1_callsign $hunter1_callsign <BK> [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody>, Break </speak>]^\n";
    #Activator
    print "<BK> R R $hunter1_callsign TU $greeting_abbreviation UR 22N 22N <BK> [Received, Received, $hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are 2 2 N, 2 2 N, Break]^\n";
    #Hunter
    print "|f650 <BK> TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation $hunter_state_abbreviation 73 <BK> [Break, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, $hunter_state, Best Regards, Break]^\n";
    #Activator
    print "<BK> QSL QSL TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Q S L, Q S L, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Typical Exchange
sub print_qso_type9 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];


    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 P2P [Park to Park]^\n";
    #Activator
    print "P2P <BK> [Park to Park, Break]^\n";
    #Hunter
    print "|f650 $hunter1_callsign $hunter1_callsign P2P <BK> [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody>, Park to Park, Break</speak>]^\n";
    #Activator
    print "$hunter1_callsign TU P2P UR $rst_code1 $rst_code1 AT $activator_park $activator_park <BK> [<speak>$hunter1_callsign_prounounceable, Thank You, Park to Park, You are $rst_spoken1, $rst_spoken1, at, <prosody rate=\"slow\">$activator_park_spoken <break time=\"0\\.5s\"/> $activator_park_spoken</prosody>, Break</speak>]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 AT $hunter_park $hunter_park <BK> [<speak>Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, at, <prosody rate=\"slow\">$hunter_park_spoken <break time=\"0\\.5s\"/> $hunter_park_spoken</prosody>, Break</speak>]^\n";
    #Activator
    print "<BK> QSL QSL TU P2P ES 73 DE $activator_callsign EE [Break, Q S L, Q S L, Thank You, P2P, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 <BK> TU P2P 73 EE [Break, Thank you, Park to Park, Best regards, dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Typical Exchange
sub print_qso_type10 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $hunter1_name ES $greeting_abbreviation UR $rst_code1 $rst_code1 $activator_state_abbreviation $activator_state_abbreviation <BK> [$hunter1_callsign_prounounceable, Thank You, And $greeting_spoken $hunter1_name, You are $rst_spoken1, $rst_spoken1, $activator_state, $activator_state, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU $activator_name UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you $activator_name, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU TU OM 73 DE $activator_callsign EE [Break, Thank You, Thank You Old Man, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 73 EE [Best regards, dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Contact immediately following previous closing
sub print_qso_type11 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    my $hunter_state_pick = int(rand(scalar @state_abbreviation));
    my $hunter_state_abbreviation2 = $state_abbreviation[$hunter_state_pick];
    my $hunter_state2 = $state_name[$hunter_state_pick];

    #Activator
    print "BK TU $hunter_state_abbreviation2 73 DE $activator_callsign EE [<speak>Break, Thank you, $hunter_state2, Best Regards from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter 2
    print "|f600 EE [dit dit]^\n";
    #Hunter 1
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter 1
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter 1
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

my %missed_char = (
    '0' => "1",
    '1' => "2",
    '2' => "1",
    '3' => "2",
    '4' => "3",
    '5' => "4",
    '6' => "7",
    '7' => "8",
    '8' => "7",
    '9' => "8",
    'A' => 'W',
    'B' => 'D',
    'C' => 'K',
    'D' => 'B',
    'E' => 'I',
    'F' => 'L',
    'G' => 'Z',
    'H' => 'S',
    'I' => 'S',
    'J' => 'W',
    'K' => 'R',
    'L' => 'F',
    'M' => 'J',
    'N' => 'W',
    'O' => 'M',
    'P' => 'W',
    'Q' => 'Y',
    'R' => 'K',
    'S' => 'I',
    'T' => 'M',
    'U' => 'V',
    'V' => 'U',
    'W' => 'J',
    'X' => 'P',
    'Y' => 'Q',
    'Z' => 'G',
);


# Bad Callsign / TU Closing
sub print_qso_type12 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $hunter1_callsign_wrong = $hunter1_callsign;
    my $bad_char = substr($hunter1_callsign, int(rand(length($hunter1_callsign)-1)), 1);
    my $bad_char_sub = $missed_char{$bad_char};
    #print "**** bad_char: $bad_char  bad_char_sub:$bad_char_sub\n";
    $hunter1_callsign_wrong =~ s/$bad_char/$bad_char_sub/; # Just do one substitution

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);
    my $hunter1_callsign_wrong_prounceable = get_pronouncable_call($hunter1_callsign_wrong);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign_wrong TU ES $greeting_abbreviation UR 52N 52N <BK> [$hunter1_callsign_wrong_prounceable, Thank You, And $greeting_spoken, You are 5 2 N, 5 2 N, Break]^\n";
    #Hunter
    print "|f650 <BK> DE $hunter1_callsign $hunter1_callsign TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation DE $hunter1_callsign <BK> [<speak>Break, from, $hunter1_callsign_prounounceable <break time=\"0\\.5s\"/> $hunter1_callsign_prounounceable, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, from, $hunter1_callsign_prounounceable, Break</speak>]^\n";
    #Activator
    print "<BK> R R $hunter1_callsign TU $hunter_state_abbreviation ES 73 DE $activator_callsign EE [Break, Received, Received, $hunter1_callsign_prounounceable, Thank You, $hunter_state, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 TU EE [Thank You, dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Good Luck closing
sub print_qso_type13 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 73 GL EE [Best Regards, Good Luck, dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# Activator uncertain of Hunter Call Sign
sub print_qso_type14 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "${hunter1_callsign}\? [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody>, Question Mark</speak>]^\n";
    #Hunter
    print "|f650 R R R [Received, Received, Received]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, And $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# P2P Exchange
sub print_qso_type15 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> TU P2P P2P UR $rst_code2 $rst_code2 AT $hunter_park $hunter_park <BK> [<speak>Break, Thank you, Park to Park, Park to Park, You are, $rst_spoken2, $rst_spoken2, at, <prosody rate=\"slow\">$hunter_park_spoken <break time=\"0\\.5s\"/> $hunter_park_spoken</prosody>, Break</speak>]^\n";
    #Activator
    print "<BK> R R TU MY PARK $activator_park $activator_park <BK> [<speak>Break, Received, Received, Thank You, My Park, <prosody rate=\"slow\">$activator_park_spoken <break time=\"0\\.5s\"/> $activator_park_spoken</prosody>, Break</speak>]^\n";
    #Hunter
    print "|f650 AGN AGN\? [Again, Again, Question Mark]^\n";
    #Activator
    print "$activator_park $activator_park <BK> [<speak><prosody rate=\"slow\">$activator_park_spoken <break time=\"0\\.5s\"/> $activator_park_spoken</prosody>, Break</speak>]^\n";
    #Hunter
    print "|f650 <BK> QSL QSL TU P2P 73 <BK> [Break, Q S L, Q S L, Thank You, Park to Park, Best Regards, Break]^\n";
    #Activator
    print "<BK> TU TU P2P 73 DE $activator_callsign EE [Break, Thank You, Thank You, Park to Park, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# #19 in Word Document - QRT with final caller
sub print_qso_type16 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "QRT QRT DE $activator_callsign QRT 73 TU EE [<speak>Q R T, Q R T, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> QRT, Best Regards, Thank You, dit dit</speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 <BK> TU TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Thank You, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    #Activator
    print "QRT QRT DE $activator_callsign QRT 73 TU EE [<speak>Q R T, Q R T, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> QRT, Best Regards, Thank You, dit dit</speak>]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# #22 in Word Document - Exchange with Park Number
sub print_qso_type17 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU ES $greeting_abbreviation UR $rst_code1 $rst_code1 AT $activator_park <BK> [<speak>$hunter1_callsign_prounounceable, Thank You, And $greeting_spoken, You are $rst_spoken1, $rst_spoken1, at, <prosody rate=\"slow\">$activator_park_spoken</prosody>, Break</speak>]^\n";
    #Hunter
    print "|f650 <BK> R R TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Received, Received, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation ES 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

# #23 in Word Document - Exhcnage with request for park number
sub print_qso_type18 {
    my $activator_callsign = $_[0];
    my $hunter1_callsign = $_[1];
    my $hunter2_callsign = $_[2];

    my $activator_name = $_[3];
    my $hunter1_name = $_[4];
    my $hunter2_name = $_[5];

    my $rst_code1 = $_[6];
    my $rst_spoken1 = $_[7];
    my $rst_code2 = $_[8];
    my $rst_spoken2 = $_[9];

    my $greeting_abbreviation = $_[10];
    my $greeting_spoken = $_[11];

    my $activator_state_abbreviation = $_[12];
    my $activator_state = $_[13];
    my $hunter_state_abbreviation = $_[14];
    my $hunter_state = $_[15];

    my $activator_park = $_[16];
    my $activator_park_spoken = $_[17];
    my $hunter_park = $_[18];
    my $hunter_park_spoken = $_[19];

    my $print_debug_separator = $_[20];

    my $activator_callsign_pronounceable = get_pronouncable_call($activator_callsign);
    my $hunter1_callsign_prounounceable = get_pronouncable_call($hunter1_callsign);

    #Activator
    print "CQ CQ POTA DE $activator_callsign $activator_callsign [<speak>C Q, C Q POTA, from  <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody> <break time=\"0\\.5s\"/> <prosody rate=\"slow\">$activator_callsign_pronounceable</prosody></speak>]^\n";
    #Hunter
    print "|f650 $hunter1_callsign [<speak><prosody rate=\"slow\">$hunter1_callsign_prounounceable</prosody></speak>]^\n";
    #Activator
    print "$hunter1_callsign TU ES $greeting_abbreviation UR $rst_code1 $rst_code1 <BK> [$hunter1_callsign_prounounceable, Thank You, And $greeting_spoken, You are $rst_spoken1, $rst_spoken1, Break]^\n";
    #Hunter
    print "|f650 BK QTH? QTH? [Break, Q T H Question Mark, Q T H Question Mark]^\n";
    #Activator
    print "<BK> $activator_park $activator_park <BK> [<speak>Break, <prosody rate=\"slow\">$activator_park_spoken <break time=\"0\\.5s\"/> $activator_park_spoken</prosody>, Break</speak>]^\n";
    #Hunter
    print "|f650 <BK> QSL QSL TU UR $rst_code2 $rst_code2 $hunter_state_abbreviation $hunter_state_abbreviation <BK> [Break, Q S L, Q S L, Thank you, You are, $rst_spoken2, $rst_spoken2, $hunter_state, $hunter_state, Break]^\n";
    #Activator
    print "<BK> TU $hunter_state_abbreviation ES 73 DE $activator_callsign EE [Break, Thank You, $hunter_state, And Best Regards from, $activator_callsign_pronounceable, dit dit]^\n";
    #Hunter
    print "|f650 EE [dit dit]^\n";
    if($print_debug_separator == 1) {
        print "===\n";
    }
}

#============================


if($proofing == 1) {
    $num_qsos = 18;
}

for(my $i = 0; $i <= $num_qsos; $i++) {
    my $activator_callsign = $activator_call_signs[int(rand(scalar @activator_call_signs))];
    my $hunter1_callsign = $activator_callsign;
    while($activator_callsign eq $hunter1_callsign) {
        $hunter1_callsign = $hunter_call_signs[int(rand(scalar @hunter_call_signs))];
    }
    my $hunter2_callsign = $activator_callsign;
    while($activator_callsign eq $hunter2_callsign || $hunter1_callsign eq $hunter2_callsign) {
        $hunter2_callsign = $hunter_call_signs[int(rand(scalar @hunter_call_signs))];
    }

    my $activator_name = $names[int(rand(scalar @names))];
    my $hunter1_name = $activator_name;
    while($activator_name eq $hunter1_name) {
        $hunter1_name = $names[int(rand(scalar @names))];
    }
    my $hunter2_name = $activator_name;
    while($activator_name eq $hunter2_name || $hunter1_name eq $hunter2_name) {
        $hunter2_name = $names[int(rand(scalar @names))];
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

    my $activator_state_pick = int(rand(scalar @state_abbreviation));
    my $activator_state = $state_abbreviation[$activator_state_pick];
    my $activator_state_spoken = $state_name[$activator_state_pick];
    my $hunter_state_pick = int(rand(scalar @state_abbreviation));
    my $hunter_state = $state_abbreviation[$hunter_state_pick];
    my $hunter_state_spoken = $state_name[$hunter_state_pick];

    my $activator_park_pick = int(rand(scalar @parks));
    my $activator_park = $parks[$activator_park_pick]; $activator_park =~ s/-//;
    my $activator_park_spoken = $parks[$activator_park_pick]; $activator_park_spoken =~ s/\-/ dash /; $activator_park_spoken =~ s/([0-9])/ $1/g;
    my $hunter_park_pick = int(rand(scalar @parks));
    my $hunter_park = $parks[$hunter_park_pick]; $hunter_park =~ s/-//;
    my $hunter_park_spoken = $parks[$hunter_park_pick]; $hunter_park_spoken =~ s/\-/ dash /; $hunter_park_spoken =~ s/([0-9])/ $1/g;

    #print "** activator_name:$activator_name, hunter1_name:$hunter1_name, hunter2_name:$hunter2_name\n";
    #print "**** chaser_callsign:$activator_callsign, hunter1_callsign:$hunter1_callsign, hunter2_callsign:$hunter2_callsign\n";
    #print "**** activator_state:$activator_state, activate_state_spoken:$activator_state_spoken, hunter_state:$hunter_state, hunter_state_spoken:$hunter_state_spoken\n";

    my $num_qso_types = 18;
    my $which_qso = int(rand($num_qso_types))+1; # -1;

    if($proofing == 1) {
        $which_qso = $i;
        print "VVV [New POTA QSO $which_qso]^\n";
    } else {
        print "VVV [New POTA QSO]^\n";
    }


    my $print_debug_separator = $proofing;
    if($which_qso == -1) {
        print_qso_type1($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 1) {
        print_qso_type1($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 2) {
        print_qso_type2($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 3) {
        print_qso_type3($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 4) {
        print_qso_type4($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 5) {
        print_qso_type5($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 6) {
        print_qso_type6($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 7) {
        print_qso_type7($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 8) {
        print_qso_type8($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 9) {
        print_qso_type9($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 10) {
        print_qso_type10($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 11) {
        print_qso_type11($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 12) {
        print_qso_type12($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 13) {
        print_qso_type13($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 14) {
        print_qso_type14($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 15) {
        print_qso_type15($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 16) {
        print_qso_type16($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 17) {
        print_qso_type17($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } elsif ($which_qso == 18) {
        print_qso_type18($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    } else {
        print_qso_type1($activator_callsign, $hunter1_callsign, $hunter2_callsign,
            $activator_name, $hunter1_name, $hunter2_name, $rst_code1, $rst_spoken1, $rst_code2, $rst_spoken2,
            $greeting_abbreviation, $greeting_spoken, $activator_state, $activator_state_spoken, $hunter_state,
            $hunter_state_spoken, $activator_park, $activator_park_spoken, $hunter_park, $hunter_park_spoken,
            $print_debug_separator);
    }

}