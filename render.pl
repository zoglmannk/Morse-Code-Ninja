#!/usr/bin/perl
use strict;
use Cwd;

######################################################
#### Review and set these variables as appropriate ###
######################################################
my @speeds = ("15", "17", "20", "22", "25", "28", "30", "35", "40", "45", "50");
my $max_processes = 10;
my $test = 0; # 1 = don't render audio -- just show what will be rendered -- useful when encoding text
my $word_limit = -1; # 14 works great... 15 word limit for long sentences; -1 disables it
my $repeat_morse = 1;
my $courtesy_tone = 1;
my $text_to_speech_engine = "neural"; # neural | standard
my $silence_between_morse_code_and_spoken_voice = "1";
my $silence_between_sets = "1"; # typically "1" sec
my $silence_between_voice_and_repeat = "1"; # $silence_between_sets; # typically 1 second
my $extra_word_spacing = 0; # 0 is no extra spacing. 0.5 is half word extra spacing. 1 is twice the word space. 1.5 is 2.5x the word space. etc
my $lang = "ENGLISH"; # ENGLISH | SWEDISH
######################################################
######################################################
######################################################

my $lower_lang_chars_regex = "a-z";
my $upper_lang_chars_regex = "A-Z";
if($lang eq "SWEDISH") {
  $lower_lang_chars_regex = "a-zåäö";
  $upper_lang_chars_regex = "A-ZÄÅÖ";
}

my $filename = $ARGV[0];
print "processing file $filename\n";

$filename =~ m/^(.*?)(\..+)?$/;
my $filename_base = $1;
#print "filename base: $filename_base\n";

open my $fh, '<', $filename or die "Can't open file $!";
my $file_content = do { local $/; <$fh> };
close $fh;

my $safe_content = $file_content;
$safe_content =~ s/\s—\s/, /g;
$safe_content =~ s/’/'/g; # replace non-standard single quote with standard one
$safe_content =~ s/\h+/ /g; #extra white space
$safe_content =~ s/(mr|mrs)\./$1/gi;
$safe_content =~ s/!|;/./g; #convert semi-colon and exclamation point to a period
$safe_content =~ s/\.\s+(?=\.)/./g; # turn . . . into ...

if(!$test) {
  #create silence
  system('rm -f silence.mp3');
  system("ffmpeg -f lavfi -i anullsrc=channel_layout=5.1:sample_rate=22050 -t $silence_between_sets -codec:a libmp3lame -b:a 256k silence.mp3");

  # This is the silence between the Morse code and the spoken voice
  system('rm -f silence1.mp3');
  system("ffmpeg -f lavfi -i anullsrc=channel_layout=5.1:sample_rate=22050 -t $silence_between_morse_code_and_spoken_voice -codec:a libmp3lame -b:a 256k silence1.mp3");

  # This is the silence between the Morse code and the spoken voice
  system('rm -f silence2.mp3');
  system("ffmpeg -f lavfi -i anullsrc=channel_layout=5.1:sample_rate=22050 -t $silence_between_voice_and_repeat -codec:a libmp3lame -b:a 256k silence2.mp3");

  #create quieter tone
  system('rm -f plink-softer.mp3');
  system('ffmpeg -i sounds/plink.mp3 -filter:a "volume=0.5" plink-softer.mp3');

  #create quieter tone
  system('rm -f pluck-softer.mp3');
  system('ffmpeg -i sounds/pluck.mp3 -filter:a "volume=0.5" pluck-softer.mp3');

  # make sure the cache directory exists
  system('mkdir cache >& /dev/null');
}

# Simple string trim function
sub  trim {
  my $s = shift;
  $s =~ s/^\s+|\s+$//g;
  return $s
};

sub split_sentence_by_comma {
  my $sentence = trim($_[0]);
  my @ret = ();
  my $accumulator = "";

  my @sections = split /([^,]+,)/, $sentence;
  foreach(@sections) {
    my $section = trim($_);

    my $accumlator_size = scalar(split /\s+/, $accumulator);
    my $section_size = scalar(split /\s+/, $section);

    if($accumlator_size == 0) {
      $accumulator = trim($section);
    } elsif($word_limit != -1 && ($accumlator_size + $section_size > $word_limit) && ($accumlator_size > 0)) {
      push @ret, $accumulator;
      $accumulator = $section;
    } elsif($section_size > 0) {
      $accumulator = trim($accumulator . ' ' . $section);
    }
    
  }
  push @ret, $accumulator;

  return @ret;
}

sub split_long_section {
  my $sentence = $_[0];

  my $word_count = 0;
  my $partial_sentence = "";
  my @ret = ();
  my @words = split /\s+/, $sentence;
  foreach(@words) {
    my $word = $_;

    $partial_sentence = $partial_sentence . " " . $word;
    $word_count++;
    if($word_limit != -1 && $word_count <= $word_limit) {

    } else {
      push @ret, $partial_sentence;
      $partial_sentence = "";
      $word_count = 0;
    }

  }

  if($word_count > 0) {
    push @ret, $partial_sentence;
  }

  return @ret;
}

sub split_long_sentence {
  my $sentence = $_[0];
  $sentence =~ s/[-]/ /g;
  $sentence =~ s/:/,/g; # makes sense to substitute a colon for a comma
  $sentence =~ s/[^A-Za-z0-9\.\?,'\s]//g;
  my @ret = ();

  my $accumulator = "";

  my @sections = split_sentence_by_comma($sentence);
  foreach(@sections) {
    my $section = $_;

    my @partial_sections = split_long_section($section);
    foreach(@partial_sections) {
      my $partial_section = trim($_);

      my $accumulator_size = scalar(split /\s+/, $accumulator);
      my $partial_section_size = scalar(split /\s+/, $partial_section);

      if($accumulator_size == 0) {
        $accumulator = trim($partial_section);
      } elsif($word_limit != -1 && ($accumulator_size + $partial_section_size > $word_limit) && ($accumulator_size > 0)) {
        push @ret, $accumulator;
        $accumulator = $partial_section; 
      } elsif($partial_section_size > 0) {
        $accumulator = trim($accumulator . ' ' . $partial_section);
      }

    }
  }
  push @ret, $accumulator;

  return @ret;
}

sub split_on_spoken_directive {
  my $raw = $_[0];

  #example "MD MD MD [Maryland|MD]^"
  if($raw =~ m/(.*?)\h*\[(.*?)(\|(.*?))?\]\h*([\^|\.|\?])$/) {
    my $sentence_part = $1.$5;
    my $spoken_directive = $2.$5;
    my $repeat_part = $4.$5;


    $sentence_part =~ s/\^//g;
    $spoken_directive =~ s/\^//g;
    $spoken_directive =~ s/\\\././g; #Unescape period
    $spoken_directive =~ s/\\\?/?/g; #Unescape question mark
    $repeat_part =~ s/\^//g;

    #temporarily change word speed directive so we can filter invalid characters
    $sentence_part =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;
    $repeat_part =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;

    #this should be moved up to safe part.. remember to add ^ and \
    $sentence_part =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>\/,'\s]//g;
    $spoken_directive =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>,'\s]//g;
    $repeat_part =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>\/,'\s]//g;

    #temporarily change word speed directive so we can filter invalid characters
    $sentence_part =~ s/XXXWORDSPEEDXXX/|/g;
    $repeat_part =~ s/XXXWORDSPEEDXXX/|/g;

    if($repeat_part =~ m/^(\.|\?)$/ || $repeat_part eq "") {
      $repeat_part = $sentence_part;
    }

    return ($sentence_part, $spoken_directive, $repeat_part);
  } else {
    #temporarily change word speed directive so we can filter invalid characters

    $raw =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;

    $raw =~ s/\^//g;
    $raw =~ s/[^A-Za-z0-9\.\?<>,'\s]//g;

    $raw =~ s/XXXWORDSPEEDXXX/|/g;

    return ($raw, $raw, $raw);
  }

}

my $punctuation_match = '(?<!\\\\)\.+(?!\w+\.)|(?<!\\\\)\?+|\^'; # Do not match escaped period or question ( \. or \? ) which can be used in spoken directive and don't match things like A.D.
my @sentences = split /($punctuation_match)/, $safe_content;
my $sentence_count = 1;
my $count = 1;
my $is_sentence = 1;
my $sentence;
open(my $fh_all, '>', "$filename_base-sentences.txt");
open(my $fh_structure, '>', "$filename_base-structure.txt");
foreach(@sentences) {


  my $skip;
  if($is_sentence) {
    $sentence = $_;
    $is_sentence = 0;
    if($sentence =~ m/^\s+$/) {
      $skip = 1;
    } else {
      $sentence_count++;
    }
  } else {
    $is_sentence = 1;

    if($skip == 1) {
      $skip = 0;
      next;
    }

    my $punctuation = $_;

    $sentence = $sentence . $punctuation;
    $sentence =~ s/\n/ /g; #remove extra new lines
    $sentence =~ s/^\s+//g; #remove leading white space
    print $fh_structure "======> $sentence\n";
    print $fh_all "${sentence}\n";

    my($sentence_part, $spoken_directive, $repeat_part) = split_on_spoken_directive($sentence);
    if($word_limit == -1) {
      print "sentence_part: $sentence_part\n";
      print "spoken_directive: $spoken_directive\n";
      print "repeat_part: $repeat_part\n\n";
    }
    if($word_limit != -1 && $sentence_part ne $spoken_directive) {
      print "Error: Cannot have spoken directive with word limit defined!!! Use one or the other!\n";
      print "sentence_part: $sentence_part\n";
      print "spoken_directive: $spoken_directive\n\n";
      exit 1;
    }

    my @partial_sentence = $sentence_part;
    if($word_limit != -1) {
      @partial_sentence = split_long_sentence($sentence);
    }
    foreach(@partial_sentence) {
      my $num_chunks++;
      my $sentence_chunk = $_;

      if($_ !~ m/^\s*$/) {
        print $fh_structure "XXX $sentence_chunk\n";
        if($word_limit != -1) {
          print "sentence and spoken chunk: $sentence_chunk\n";
        }

        if(!$test) {
          $sentence_chunk =~ s/^\s+|\s+$//g; #extra space on the end adds new line!
          open(my $fh, '>', 'sentence.txt');
          print $fh "$sentence_chunk\n";
          close $fh;

          my $counter = sprintf("%05d",$count);
          my $fork_count = 0;
          foreach(@speeds) {

            my $speed = $_;
            my $farnsworth = 0;

            if($fork_count >= $max_processes) {
              print("XXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXX");
              print("XXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXX");
              print("waiting on forks: fork_count: $fork_count     max_processes: $max_processes\n");
              wait();
              $fork_count--;
            }

            my $pid = fork;
                        die if not defined $pid;
            if($pid) {
              # parent
              $fork_count++;

            } else {
              #child process
              if($speed =~ m/(\d+)\/(\d+)/) {
                $speed = $1;
                $farnsworth = $2;
              }

              my $rise_and_fall_time;
              my $speed_as_num = int($speed);
              if($speed_as_num < 35) {
                $rise_and_fall_time = 100;
              } elsif($speed_as_num >= 35 && $speed_as_num <= 40) {
                $rise_and_fall_time = 150;
              } else {
                $rise_and_fall_time = 200;
              }

              my $lang_option = "";
              if($lang ne "ENGLISH") {
                $lang_option = "-u";
              }

              my $extra_word_spacing_option = "";
              if ($extra_word_spacing != 0) {
                $extra_word_spacing_option = "-W " . $extra_word_spacing;
              }


              if($farnsworth == 0) {
                system("ebook2cw $lang_option -R $rise_and_fall_time -F $rise_and_fall_time $extra_word_spacing_option -f 700 -w $speed -s 44100 -o sentence-${speed} sentence.txt");
              } else {
                system("ebook2cw $lang_option -R $rise_and_fall_time -F $rise_and_fall_time $extra_word_spacing_option -f 700 -w $speed -e $farnsworth -s 44100 -o sentence-${speed} sentence.txt");
              }


              system("rm sentence-lower-volume-${speed}.mp3");
              system("ffmpeg -i sentence-${speed}0000.mp3 -filter:a \"volume=0.5\" sentence-lower-volume-${speed}.mp3");
              system("mv sentence-lower-volume-${speed}.mp3 $filename_base-$counter-morse-$speed.mp3");


              # generate repeat section if it is different than the sentence
              if($repeat_morse != 0 && $word_limit == -1 && $repeat_part ne $sentence_part) {
                open(my $fh_repeat, '>', 'sentence-repeat.txt');
                print $fh_repeat "$repeat_part\n";
                close $fh_repeat;

                if ($farnsworth == 0) {
                  system("ebook2cw $lang_option -R $rise_and_fall_time -F $rise_and_fall_time $extra_word_spacing_option -f 700 -w $speed -s 44100 -o sentence-repeat-${speed} sentence-repeat.txt");
                }
                else {
                  system("ebook2cw $lang_option -R $rise_and_fall_time -F $rise_and_fall_time $extra_word_spacing_option -f 700 -w $speed -e $farnsworth -s 44100 -o sentence-repeat-${speed} sentence-repeat.txt");
                }
                system("rm sentence-repeat-lower-volume-${speed}.mp3");
                system("ffmpeg -i sentence-repeat-${speed}0000.mp3 -filter:a \"volume=0.5\" sentence-repeat-lower-volume-${speed}.mp3");
                system("mv sentence-repeat-lower-volume-${speed}.mp3 $filename_base-$counter-repeat-morse-$speed.mp3");


              }

              exit;

            }

          }

          for (1 .. $fork_count) {
            wait();
          }

          # Generate spoken section
          if($word_limit != -1) {
            system('mv sentence.txt '."$filename_base-${counter}.txt");
          } else {
            open(my $fh_spoken, '>', "$filename_base-${counter}.txt");
            print $fh_spoken "$spoken_directive\n";
            close $fh_spoken;
          }

          my $exit_code = -1;
          while($exit_code != 0) {
            $exit_code = system('./text2speech.py '."$filename_base-${counter} $text_to_speech_engine $lang");
          }
        }
        $count++;
      }
    }

    if(scalar(@partial_sentence) > 1) {
      print "saying the whole sentence: $sentence\n";

      if(!$test) {
        open(my $fh, '>', 'sentence.txt');
        print $fh "$sentence\n";

        my $counter = sprintf("%05d",$count);
        system('mv sentence.txt '."$filename_base-${counter}-full.txt");
        my $exit_code = -1;
        while($exit_code != 0) {
          $exit_code = system('./text2speech.py '."$filename_base-${counter}-full $text_to_speech_engine $lang");
        }

        $count++;

        close $fh;
      }
    }

  }
}
################
###############
close $fh_all;
close $fh_structure;
$count--;

print "\n\nTotal sentences: $sentence_count\t segments: $count\n";
if(!$test) {
  my $cwd = getcwd();

  #lame documentation -- https://svn.code.sf.net/p/lame/svn/trunk/lame/USAGE
  system("rm -rf $cwd/silence-resampled.mp3");
  my $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence.mp3 $cwd/silence-resampled.mp3";
  print "$cmd\n";
  system($cmd);

  system("rm -rf $cwd/silence-resampled1.mp3");
  my $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence1.mp3 $cwd/silence-resampled1.mp3";
  print "$cmd\n";
  system($cmd);

  system("rm -rf $cwd/silence-resampled2.mp3");
  my $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence2.mp3 $cwd/silence-resampled2.mp3";
  print "$cmd\n";
  system($cmd);

  system("rm -rf $cwd/pluck-softer-resampled.mp3");
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/pluck-softer.mp3 $cwd/pluck-softer-resampled.mp3";
  print "$cmd\n";
  system($cmd);

  system("rm -rf $cwd/plink-softer-resampled.mp3");
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/plink-softer.mp3 $cwd/plink-softer-resampled.mp3";
  print "$cmd\n";
  system($cmd);

  my $fork_count = 0;
  foreach(@speeds) {
    my $first_for_given_speed = 1;
    my $speed_in = $_;

    my $speed;
    if($speed_in =~ m/(\d+)\/\d+/) {
      $speed = $1;
    } else {
      $speed = $speed_in;
    }

    if($fork_count >= $max_processes) {
      print("XXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXX");
      print("XXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXX");
      print("waiting on forks: fork_count: $fork_count     max_processes: $max_processes\n");
      wait();
      $fork_count--;
    }

    my $pid = fork;
    die if not defined $pid;
    if($pid) {
      # parent
      $fork_count++;

    } else {
      system("rm -rf $cwd/$filename_base-${speed}wpm.mp3");

      open(my $fh_list, '>', "$filename_base-list-${speed}wpm.txt");
      for (my $i=1; $i <= $count; $i++) {
        my $counter = sprintf("%05d",$i);

        #if full sentence
        if(-e "$filename_base-$counter-full-voice.mp3") {
          print $fh_list "file '$cwd/pluck-softer-resampled.mp3'\nfile '$cwd/silence-resampled.mp3'\nfile '$cwd/$filename_base-$counter-full-voice-resampled-$speed.mp3'\nfile '$cwd/silence-resampled.mp3'\n";

          $cmd = "lame --resample 44.1 -a -b 256 $cwd/$filename_base-$counter-full-voice.mp3 $cwd/$filename_base-$counter-full-voice-resampled-$speed.mp3";
          print "$cmd\n";
          system($cmd);

        } else {

          #don't start with Plink sound
          if($first_for_given_speed == 1) {
            $first_for_given_speed = 0;
          } elsif ($courtesy_tone != 0) {
            print $fh_list "file '$cwd/plink-softer-resampled.mp3'\n";
          }

          $cmd = "lame --resample 44.1 -a -b 256 $cwd/$filename_base-$counter-morse-$speed.mp3 $cwd/$filename_base-$counter-morse-$speed-resampled.mp3";
          print "$cmd\n";
          system($cmd);

          $cmd = "lame --resample 44.1 -a -b 256 $cwd/$filename_base-$counter-voice.mp3 $cwd/$filename_base-$counter-voice-resampled-$speed.mp3";
          print "$cmd\n";
          system($cmd);

          print $fh_list "file '$cwd/silence-resampled.mp3'\nfile '$cwd/$filename_base-$counter-morse-$speed-resampled.mp3'\nfile '$cwd/silence-resampled1.mp3'\nfile '$cwd/$filename_base-$counter-voice-resampled-$speed.mp3'\n";

          if($repeat_morse == 0) {
            print $fh_list "file '$cwd/silence-resampled.mp3'\n";
          } else {
            print $fh_list "file '$cwd/silence-resampled2.mp3'\n";
            if (-e "$cwd/$filename_base-$counter-repeat-morse-$speed.mp3") {
              $cmd = "lame --resample 44.1 -a -b 256 $cwd/$filename_base-$counter-repeat-morse-$speed.mp3 $cwd/$filename_base-$counter-repeat-morse-$speed-resampled.mp3";
              print "$cmd\n";
              system($cmd);

              print $fh_list "file '$cwd/$filename_base-$counter-repeat-morse-$speed-resampled.mp3'\nfile '$cwd/silence-resampled.mp3'\n";

            } else {

              print $fh_list "file '$cwd/$filename_base-$counter-morse-$speed-resampled.mp3'\nfile '$cwd/silence-resampled.mp3'\n";
            }
          }


        }
      }
      close $fh_list;
      #see -- https://superuser.com/questions/314239/how-to-join-merge-many-mp3-files  or   https://trac.ffmpeg.org/wiki/Concatenate
      $cmd = "ffmpeg -f concat -safe 0 -i $filename_base-list-${speed}wpm.txt -codec:a libmp3lame -metadata title=\"$filename_base $speed"."wpm\" -c copy $filename_base-$speed"."wpm.mp3";

      print "$cmd\n";
      system($cmd);
      exit;
    }
    # end of fork

  }

  for (1 .. $fork_count) {
    wait();
  }


  #remove temporary files
  for (my $i=1; $i <= $count; $i++) {
    my $counter = sprintf("%05d",$i);
    system("rm $filename_base-$counter-*.mp3 $filename_base-${counter}*.txt");
  }
  foreach(@speeds) {
    my $speed = $_;
    system("rm -f sentence-${speed}0000.mp3 sentence-repeat-${speed}0000.mp3 $filename_base-list-${speed}wpm.txt silence.mp3");
  }
  system("rm -f $filename_base-structure.txt $filename_base-sentences.txt");
  system("rm -f silence*.mp3");
  system("rm -f pluck*.mp3");
  system("rm plink*.mp3");
  system("rm sentence.txt");
  system("rm sentence-repeat.txt");
}