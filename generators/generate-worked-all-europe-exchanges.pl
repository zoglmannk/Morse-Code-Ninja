#!/usr/bin/perl

use warnings FATAL => 'all';
use strict;

# See this page for details -- https://www.darc.de/der-club/referate/conteste/wae-dx-contest/en/wae-rules/

my $num_exchanges = 200;
my $max_QTC_serial_number = 200;
my $max_serial_number = 900;
my $include_misses = 1;
my $random_chance_of_miss = 0;


# Usage: ./generate-worked-all-europe-exchanges.pl > worked-all-europe-exchanges.txt
#
# ./render.pl -i worked-all-europe-exchanges.txt -s 15 17 20 22 25 28 30 35 40 45 50

### Load Names
open my $in, "<", "data/Worked-All-Europe-DX-Contest-2022-Results.csv"
    or die "Cannot open CSV file";
my @lines = <$in>;
close $in;

my @callsigns;

foreach(@lines) {
    my $line = $_;
    chomp($line);
    if($line =~ m/^([^,]+),/) {
        push @callsigns, $1;
    }
}

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

sub get_random_qtc_exchange {
    my $exchange = "|f700 qtc ";
    $exchange .= int(rand($max_QTC_serial_number)) . "/10 <BT> qru? |S700 |f650 r ";
    return $exchange;
}

sub get_pronounceable_qtc_exchange {
    my $exchange = $_[0];

    my $ret = "";

    if($exchange =~ m/qtc (\d+)\/(\d+) <BT> qru\?/) {
        $ret = "<speak>First station, QTC <break time=\"0\\.25s\"/> <prosody rate=\"slow\"> $1 <break time=\"0\\.25s\"/> slash <break time=\"0\\.25s\"/> $2</prosody> <break time=\"0\\.25s\"/> Have you anything for me\\? <break time=\"0\\.3s\"/>  Second station, Received</speak>";
    } else {
        die "malformatted exchange: $exchange";
    }

    return $ret;
}

sub print_qtc_lead_exchange {
    my $qtc_exchange = get_random_qtc_exchange();
    my $safe_qtc_exchange = $qtc_exchange;
    $safe_qtc_exchange =~ s/\?/\\?/g;
    my $pronounceable_qtc_exchange = get_pronounceable_qtc_exchange($qtc_exchange);
    print "$safe_qtc_exchange [$pronounceable_qtc_exchange]^\n";
}

sub get_random_UTC_time {
    return (int(rand(14))+10) . sprintf('%02d',int(rand(60)));
}

sub get_qtc_line {
    my $random_callsign = $callsigns[int(rand(scalar(@callsigns)))];
    my $random_serial_num = int(rand($max_serial_number));
    my $ret = "|f700 " . get_random_UTC_time() . " " . $random_callsign . " " . $random_serial_num;

    return $ret;
}

sub get_pronounceable_qtc_line {
    my $line = $_[0];

    my $ret = "";

    if($line =~ m/\|f\d+ (\d+) (\S+) (\d+)/) {
        my $utc = $1;
        my $callsign = $2;
        my $serial = $3;
        my $pronounceable_utc = $utc;
        $pronounceable_utc =~ s/(\d{2})(\d{2})/$1, $2/;
        my $pronounceable_callsign = get_pronouncable_call($callsign);
        $ret = "First station, $pronounceable_utc <break time=\"0\\.3s\"/> $pronounceable_callsign <break time=\"0\\.3s\"/> $serial ";
    } else {
        die "malformatted qtc line: $line";
    }

    return $ret;
}

sub print_qtc_exchange {
    my $qtc_line = get_qtc_line();
    my $pronounceable_qtc_line = get_pronounceable_qtc_line($qtc_line);
    my $qtc_line_received = "|S700 |f650 r";

    if($include_misses == 1 && int(rand(scalar(100))) <= $random_chance_of_miss && $random_chance_of_miss >= 1.0) {
        my $random_miss = int(rand(scalar(100)));
        if($random_miss <= 33) {
            #print "   **** agn qtc_line:$qtc_line\n";
            #print "   **** agn pronounceable_qtc_line:$pronounceable_qtc_line\n";
            $qtc_line =~ m/^.*?\|f700\s(.*?)$/;
            my $partial_qtl_line = $1;
            $pronounceable_qtc_line =~ m/^.*?First station,\s(.*?)$/;
            my $partial_pronounceable_qtc_line = $1;
            print $qtc_line . " |f650 AGN |S1000 |f700 $partial_qtl_line $qtc_line_received [<speak>$pronounceable_qtc_line <break time=\"0\\.3s\"/> Second station, Again <break time=\"0\\.3s\"/> First station, $partial_pronounceable_qtc_line <break time=\"0\\.3s\"/>  Second station, Received</speak>]^\n";
        } elsif ($random_miss <= 66) {
            #print "   **** serial\n";
            $qtc_line =~ m/^.*?\|f700\s.*?\s.*?\s(\d+).*?$/;
            my $serial = $1;
            print $qtc_line . " |f650 NR\\? |S1000 |f700 $serial $qtc_line_received [<speak>$pronounceable_qtc_line <break time=\"0\\.3s\"/> Second station, Number, question mark <break time=\"0\\.3s\"/> First station, $serial <break time=\"0\\.3s\"/>  Second station, Received</speak>]^\n";
        } else {
            #print "   **** call\n";
            $qtc_line =~ m/^.*?\|f700\s.*?\s(.*?)\s\d+.*?$/;
            my $call = $1;
            $pronounceable_qtc_line =~ m/^.*?Second station,\s.*?>\s(.*?)\s<.*$/;
            my $pronounceable_call = $1;
            print $qtc_line . " |f650 CALL\\? |S1000 |f700 $call $qtc_line_received [<speak>$pronounceable_qtc_line <break time=\"0\\.3s\"/> Second station, Call sign, question mark <break time=\"0\\.3s\"/> First station, $pronounceable_call <break time=\"0\\.3s\"/>  Second station, Received</speak>]^\n";
        }
    } else {
        print "$qtc_line $qtc_line_received [<speak>$pronounceable_qtc_line <break time=\"0\\.3s\"/>  Second station, Received</speak>]^\n";
    }
}

for(my $i = 0; $i <= $num_exchanges; $i++) {
    print "VVV [New QTC Exchange]^\n";
    print_qtc_lead_exchange();
    for(my $j = 0; $j < 10; $j++) {
        print_qtc_exchange();
    }
}

