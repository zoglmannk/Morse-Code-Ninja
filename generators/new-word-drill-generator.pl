#!/usr/bin/perl

use strict;
use warnings;


my %previous_uniq_words;
my %new_uniq_words;

sub find_new_words_for {
  my $read_file_name = $_[0];
  my $write_file_name = $_[1];

  foreach my $word (sort keys %new_uniq_words) {
    delete($new_uniq_words{$word});
  }

  open(my $READ_FH, '<', $read_file_name) or die $!;
  open(my $WRITE_FH2, '>', $write_file_name) or die $!;

  while(<$READ_FH>) {
    my $in = $_;
    chomp($in);
    $in = lc($in);

    $in =~ s/\.|\?|,|-//g;
    my @words = split /\s/, $in;
    foreach my $word (@words) {
      if(! defined $previous_uniq_words{$word} && $word ne 'tqhen') {
        $new_uniq_words{$word} = 1;
        $previous_uniq_words{$word} = 1;
      }

    }
  }

  my $first = 1;
  foreach my $word (sort keys %new_uniq_words) {
    if(length($word) >= 1) {
      if($first == 1) {
        $first = 0;
      } else {
        print $WRITE_FH2 "\n";
      }
      print $WRITE_FH2 "$word";
    }
  }

  close($READ_FH);
  close($WRITE_FH2);
}

my $last_picked = "";
my %prev_picked;

sub pick_uniq_pangram_index {
  my $last_pick = $_[0];

  while(1) {
    my $next_pick = int(rand(scalar keys %new_uniq_words));

    if(scalar keys %prev_picked >= scalar keys %new_uniq_words) {
      %prev_picked = ();
    }

    if($prev_picked{$next_pick} != 1) {
      $prev_picked{$next_pick} = 1;
      return $next_pick;
    }
  }
}

my $num_times = 10;

sub generate_practice_for_new_words {
  my $write_file_name = $_[0];

  $last_picked = "";
  %prev_picked = {};

  open(my $WRITE_FH, '>', $write_file_name) or die $!;

  my $num_words = (scalar keys %new_uniq_words) * $num_times;
  for (my $i=0; $i < $num_words; $i++) {
    my $random_word_index = pick_uniq_pangram_index();

    if($i != 0) {
      print $WRITE_FH "\n";
    }
    print $WRITE_FH (keys %new_uniq_words)[$random_word_index] . " ^";
  }

  close($WRITE_FH);
}

for(my $i=1; $i <= 16; $i++) {

  my $read_fn = '/Users/kaz/git/Morse-Code-Ninja/practice-sets/Sentences from Top '. $i . '00 words.txt';
  my $write_fn = '/Users/kaz/git/Morse-Code-Ninja/Sentences-from-Top-'. $i . '00-words-uniq-alt.txt';
  find_new_words_for($read_fn, $write_fn);
  generate_practice_for_new_words('/Users/kaz/git/Morse-Code-Ninja/Sentences-from-Top-'. $i . '00-words-prepare-alt.txt');

  # if($i == 10) {
  #   for(my $j=1; $j <= 7; $j++) {
  #     my $read_fn = "/Users/kaz/git/Morse-Code-Ninja/practice-sets/Sentences from Top 1000 Words - Review Part $j.txt";
  #     my $write_fn = "/Users/kaz/git/Morse-Code-Ninja/Sentences-from-Top-1000-Words-Review-Part-${j}-uniq.txt";
  #     find_new_words_for($read_fn, $write_fn);
  #     generate_practice_for_new_words("/Users/kaz/git/Morse-Code-Ninja/Sentences-from-Top-1000-Words-Review-Part-${j}-prepare.txt");
  #   }
  # }

}

for(my $i=1; $i <= 16; $i++) {

  print "./render.pl -i Sentences-from-Top-${i}00-words-prepare-alt.txt -s 15 17 20 22 25 28 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 --sm 0.5 --ss 0.5 --sv 0.5; ";

  # if($i == 10) {
  #   for (my $j = 1; $j <= 7; $j++) {
  #     print "./render.pl -i Sentences-from-Top-${i}000-Words-Review-Part-{j}-prepare.txt -s 15 17 20 22 25 28 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 --sm 0.5 --ss 0.5 --sv 0.5; ";
  #   }
  # }

}




