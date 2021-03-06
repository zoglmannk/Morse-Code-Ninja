#!/usr/bin/perl

use strict;
use Cwd;

# Usage:
# ./generate-top-names.pl > Top-Names-3-Letters.txt
#
# Change $max_length variable as appropriate
# Rendered with: Delay 1 seconds


my $file_with_names = "data/Names.txt";
my $number_of_runs = 1200; # 3-Letters=800, 4-Letters=1200, 5-Letters=1500, All=2000
my $max_length = 4;

open(my $fh, '<', $file_with_names)
    or die "Could not open $file_with_names";

my @names;
my %name_prononciation = ( 'Rog' => 'Rodg');

while(my $name = <$fh>) {
    chomp $name;

    if(length($name) <= $max_length) {
       push @names, $name;
    }
}

#foreach my $name (@names) {
#  print "$name,\n";
#}
#exit 1;

my %prev_picked;

sub pick_uniq_name_index {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@names)));

        if(scalar keys %prev_picked >= scalar(@names)) {
            %prev_picked = ();
        }

        if($prev_picked{$next_pick} != 1) {
            $prev_picked{$next_pick} = 1;
            return $next_pick;
        }
    }
}

for (my $i=0; $i < $number_of_runs; $i++) {
    my $random_name_index = pick_uniq_name_index();
    my $name = $names[$random_name_index];

    if(!defined $name_prononciation{$name}) {
        print "$name ^\n";
    } else {
        print "$name [$name_prononciation{$name}] ^\n";
    }

}