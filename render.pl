#!/usr/bin/perl

use strict;
use warnings;

use utf8;
use Cwd;
use File::Basename;
use File::Copy;
use File::Path;
use File::Spec;
use Getopt::Long;
use Digest::SHA qw(sha256_hex sha256_base64);
use POSIX;

my @speeds;
sub print_usage;

GetOptions(
  'i|input=s'         => \(my $input_filename),
  'o|output=s'        => \(my $output_directory = '.'),
  'c|cache=s'         => \(my $cache_directory = './cache/'),
  's|speeds=s{1,}'    => \@speeds,
  'charactermultiplier=s' => \(my $character_multiplier = "1"),
  'standardspeedrepeat=s' => \(my $standard_speed_repeat = 0), #flag. 0 == false; 1 == true
  'm|maxprocs=i'      => \(my $max_processes = 10),
  'z|racing=i'        => \(my $speed_racing = 0), #flag. 0 == false; 1 == true
  'rr|racingrepeat=i' => \(my $speed_racing_repeat = 0), #flag. 0 == false; 1 == true
  'test'              => \(my $test = ''), # flag. 1 = don't render audio -- just show what will be rendered -- useful when encoding text
  'l|limit=i'         => \(my $word_limit = -1), # 14 works great... 15 word limit for long sentences; -1 disables it
  'norepeat'          => \(my $no_repeat_morse), # flag
  'nospoken'          => \(my $no_spoken), # flag
  'nocourtesytone'    => \(my $no_courtesy_tone), # flag
  'e|engine=s'        => \(my $text_to_speech_engine = "neural"), # neural | standard
  'sm|silencemorse=s' => \(my $silence_between_morse_code_and_spoken_voice = "1"),
  'ss|silencesets=s'  => \(my $silence_between_sets = "1"), # typically "1" sec
  'st|silencemanualcourtesytone=s' => \(my $silence_before_manual_courtesy_tone = "1"), # This ONLY comes into play when the practice set manually specifies a courtesy tone with <courtesyTone>
  'sv|silencevoice=s' => \(my $silence_between_voice_and_repeat = "1"), # typically 1 second
  'sc|silencecontext=s' => \(my $silence_between_context_and_morse_code = "1"),
  'x|extraspace=s'    => \(my $extra_word_spacing = 0), # 0 is no extra spacing. 0.5 is half word extra spacing. 1 is twice the word space. 1.5 is 2.5x the word space. etc
  'precise'           => \(my $precise = ''), # flag. 1 = precise timing -- useful if using very tight times between morse code and spoken answer
  'l|lang=s'          => \(my $lang = "ENGLISH"), # ENGLISH | GERMAN | SWEDISH
  'p|pitchtone=i'     => \(my $pitch_tone = 700), # tone in Hz for pitch
  'pr|pitchrandom'    => \(my $pitch_tone_random = '0'), # flag. 0 == false, random pitch tone
  'speedAdjustRegex=s'=> \(my $speedAdjustRegex = "") # format Eg., s/<speed1>/1.5/,s/<speed2>/2.5/
) or print_usage();

if("$input_filename" eq "") {
  print("***************************************\n");
  print("Error: An input text file is required!!\n");
  print("***************************************\n\n");
  print("Example:\n");
  print("./render.pl -i example.txt");
  print("\n\n\n");

  print_usage();
}

# There is some overhead in the concatentation process, so we'll subtract it out
if($precise) {
  $silence_between_morse_code_and_spoken_voice -= "0.11";
  if($silence_between_morse_code_and_spoken_voice <= 0) {
    $silence_between_morse_code_and_spoken_voice = "0.03";
  }
}

my $speed_racing_multiplier = 1.5;
my $speed_racing_iterations = 3;

my @random_tones = (500, 550, 600, 650, 700, 750, 800, 850, 900);

# set default value for speeds here as it is too complex to do it inside the GetOptions call above
my $speedSize = @speeds;
@speeds = ($speedSize > 0) ? @speeds : ("15", "17", "20", "22", "25", "28", "30", "35", "40", "45", "50");

if (! -d "$output_directory") {
  mkdir "$output_directory";
}

$cache_directory = File::Spec->rel2abs( $cache_directory ) . "/" ;
if (! -d "$cache_directory") {
  mkdir "$cache_directory";
}

my $lower_lang_chars_regex = "a-z";
my $upper_lang_chars_regex = "A-Z";
if($lang eq "SWEDISH") {
  $lower_lang_chars_regex = "a-zåäö";
  $upper_lang_chars_regex = "A-ZÄÅÖ";
}
if($lang eq "GERMAN") {
  $lower_lang_chars_regex = "a-züäöß";
  $upper_lang_chars_regex = "A-ZÜÄÖß";
}

binmode(STDOUT, ":encoding(UTF-8)");

my $cmd;
my @cmdLst;

# text2speech.py error codes (coordinate with text2speech.py error return codes)
my $t2sIOError = 2;

my $filename = File::Spec->rel2abs($input_filename);

print "processing file $filename\n";

my ($file, $dirs, $suffix) = fileparse($filename, qr/\.[^.]*/);
print "dirs: $dirs, file: $file, suffix: $suffix\n";
$dirs = File::Spec->catfile($dirs, $output_directory);
my $filename_base = File::Spec->catpath("", $dirs, $file);
print "filename base: $filename_base\n";
my $filename_base_without_path = $file;

open my $fh, '<:encoding(UTF-8)', $filename or die "Can't open file $!";
my $file_content = do { local $/; <$fh> };
close $fh;

my $safe_content = $file_content;
$safe_content =~ s/\s—\s/, /g;
$safe_content =~ s/’/'/g; # replace non-standard single quote with standard one
$safe_content =~ s/\h+/ /g; #extra white space
$safe_content =~ s/(mr|mrs)\./$1/gi;
$safe_content =~ s/!|(?<!\\);/./g; #convert semi-colon and exclamation point to a period
$safe_content =~ s/\.\s+(?=\.)/./g; # turn . . . into ...

if(!$test) {
  print "---- Generating silence and sound effect mp3 files...\n";
  #create silence
  unlink "$output_directory/silence.mp3" if (-f "$output_directory/silence.mp3");
  @cmdLst = ("ffmpeg", "-f", "lavfi", "-i", "anullsrc=channel_layout=5.1:sample_rate=22050", "-t",
             "$silence_between_sets", "-codec:a", "libmp3lame", "-b:a", "256k", "$output_directory/silence.mp3");
  # print("cmd-1: @cmdLst\n");
  system(@cmdLst) == 0 or die "ERROR 1: @cmdLst failed, $!\n";

  # This is the silence between the Morse code and the spoken voice
  unlink "$output_directory/silence1.mp3" if (-f "$output_directory/silence1.mp3");
  @cmdLst = ("ffmpeg", "-f", "lavfi", "-i", "anullsrc=channel_layout=5.1:sample_rate=22050",
             "-t", "$silence_between_morse_code_and_spoken_voice", "-codec:a", "libmp3lame",
             "-b:a", "256k", "$output_directory/silence1.mp3");
  # print "cmd-2: @cmdLst\n";
  system(@cmdLst) == 0 or die "ERROR 2: @cmdLst failed, $!\n";

  # This is the silence between the Morse code and the spoken voice
  unlink "$output_directory/silence2.mp3" if (-f "$output_directory/silence2.mp3");
  @cmdLst = ("ffmpeg", "-f", "lavfi", "-i", "anullsrc=channel_layout=5.1:sample_rate=22050",
             "-t", "$silence_between_voice_and_repeat", "-codec:a", "libmp3lame",
             "-b:a", "256k", "$output_directory/silence2.mp3");
  # print "cmd-3a: @cmdLst\n";
  system(@cmdLst) == 0 or die "ERROR 3: @cmdLst failed, $!\n";

  # This is the silence between the context and the Morse code
  unlink "$output_directory/silence3.mp3" if (-f "$output_directory/silence3.mp3");
  @cmdLst = ("ffmpeg", "-f", "lavfi", "-i", "anullsrc=channel_layout=5.1:sample_rate=22050",
      "-t", "$silence_between_context_and_morse_code", "-codec:a", "libmp3lame",
      "-b:a", "256k", "$output_directory/silence3.mp3");
  # print "cmd-3b: @cmdLst\n";
  system(@cmdLst) == 0 or die "ERROR 3: @cmdLst failed, $!\n";

  # This is the silence between the context and the Morse code
  unlink "$output_directory/silence4.mp3" if (-f "$output_directory/silence4.mp3");
  @cmdLst = ("ffmpeg", "-f", "lavfi", "-i", "anullsrc=channel_layout=5.1:sample_rate=22050",
      "-t", "$silence_before_manual_courtesy_tone", "-codec:a", "libmp3lame",
      "-b:a", "256k", "$output_directory/silence4.mp3");
  # print "cmd-3c: @cmdLst\n";
  system(@cmdLst) == 0 or die "ERROR 3: @cmdLst failed, $!\n";

  #create quieter tone
  unlink "$output_directory/plink-softer.mp3" if (-f "$output_directory/plink-softer.mp3");
  $cmd = 'ffmpeg -i sounds/plink.mp3 -filter:a "volume=0.5" '.$output_directory.'/plink-softer.mp3';
  print "cmd-4: $cmd\n";
  system($cmd) == 0 or die "ERROR 4: $cmd failed, $!\n";

  #create quieter tone
  unlink "$output_directory/pluck-softer.mp3" if (-f "$output_directory/pluck-softer.mp3");
  $cmd = 'ffmpeg -i sounds/pluck.mp3 -filter:a "volume=0.5" '.$output_directory.'/pluck-softer.mp3';
  print "cmd-5: $cmd\n";
  system($cmd) == 0 or die "ERROR 5: $cmd failed, $!\n";
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
  my $is_courtesy_tone = 0;

  # example "{ weather } ^"
  # Used to provide contextual priming
  if($raw =~ m/^\s*\{(.*)\}\s*\^$/) {
    my $sentence_part = "";
    my $spoken_directive = $1;
    $spoken_directive =~ s/\\//g;
    my $repeat_part = "";
    return ($is_courtesy_tone, $sentence_part, $spoken_directive, $repeat_part);

  # example "<courtesyTone> ^"
  } elsif($raw =~ m/\<courtesyTone\>/i) {
    $is_courtesy_tone = 1;
    my $sentence_part = "";
    my $spoken_directive = "";
    my $repeat_part = "";
    return ($is_courtesy_tone, $sentence_part, $spoken_directive, $repeat_part);

  #example "MD MD MD [Maryland|MD]^"
  } elsif($raw =~ m/(.*?)\h*\[(.*?)(\|(.*?))?\]\h*([\^|\.|\?])$/) {
    my $sentence_part = $1.$5;
    my $spoken_directive = $2.$5;
    my $repeat_part = $4.$5;

    $sentence_part =~ s/\^//g;
    $spoken_directive =~ s/\^//g;
    $spoken_directive =~ s/\\\././g; #Unescape period
    $spoken_directive =~ s/\\\?/?/g; #Unescape question mark
    $spoken_directive =~ s/\\\;/;/g; #Unescape semicolon
    $repeat_part =~ s/\^//g;

    #temporarily change word speed directive so we can filter invalid characters
    if($raw !~ m/<speak>.*?<\/speak>/) {
      $sentence_part =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;
    }
    $repeat_part =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;

    #this should be moved up to safe part.. remember to add ^ and \
    $sentence_part =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>\/,'\s\|]//g;
    if($raw !~ m/<speak>.*?<\/speak>/) {
      $spoken_directive =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>,'\s]//g;
    }
    $repeat_part =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>\/,'\s]//g;

    #temporarily change word speed directive so we can filter invalid characters
    $sentence_part =~ s/XXXWORDSPEEDXXX/|/g;
    $repeat_part =~ s/XXXWORDSPEEDXXX/|/g;

    if($repeat_part =~ m/^(\.|\?)$/ || $repeat_part eq "") {
      $repeat_part = $sentence_part;
    }

    return ($is_courtesy_tone, $sentence_part, $spoken_directive, $repeat_part);
  } else {
    #temporarily change word speed directive so we can filter invalid characters

    $raw =~ s/\|(?=w\d+)/XXXWORDSPEEDXXX/g;

    $raw =~ s/\^//g;
    $raw =~ s/[^${upper_lang_chars_regex}${lower_lang_chars_regex}0-9\.\?<>,'\s]//g;

    $raw =~ s/XXXWORDSPEEDXXX/|/g;

    return ($is_courtesy_tone, $raw, $raw, $raw);
  }

}

my $punctuation_match = '(?<!\\\\)\.+(?!\w+\.)|(?<!\\\\)\?+|\^'; # Do not match escaped period or question ( \. or \? ) which can be used in spoken directive and don't match things like A.D.
my @sentences = split /($punctuation_match)/, $safe_content;
my $sentence_count = 1;
my $count = 1;
my $is_sentence = 1;
my $sentence;
my %filename_map;
open(my $fh_all, ">:encoding(UTF-8)", "$filename_base-sentences.txt");
open(my $fh_structure, ">:encoding(UTF-8)", "$filename_base-structure.txt");

my $ebookCmd;

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

    my($is_courtsey_tone, $sentence_part, $spoken_directive, $repeat_part) = split_on_spoken_directive($sentence);
    if($word_limit == -1) {
      print "is_courtesy_tone: $is_courtsey_tone\n";
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

    # Warning this logic must stay in sync with tex2speech.py
    sub get_text2speech_cached_filename {
      my ($lang, $sentence, $cache_directory) = @_;

      my $cached_filename = "";
      if($lang eq 'ENGLISH') {
        if ($sentence =~ m/<speak>.*?<\/speak>/) {
          $cached_filename = "Mathew-exact-";
        } elsif ($sentence =~ m/^\s*([A-Za-z]{1,4})\s*$/) {
          $cached_filename = "Mathew-slowly-";
        } else {
          $cached_filename = "Mathew-standard-";
        }
      } else {
        $cached_filename = "${lang}-standard-";
      }

      $cached_filename .= $text_to_speech_engine . "-" . sha256_hex($sentence) . ".mp3";
      $cached_filename = $cache_directory . $cached_filename;

      return $cached_filename;
    }

    sub get_text2speech {
      my ($counter, $spoken_text, $filename_map_key) = @_;

      # Generate spoken section
      if($word_limit != -1) {
        rename("$output_directory/sentence.txt", '$filename_base-$counter.txt');
      } else {
        open(my $fh_spoken, ">:encoding(UTF-8)", "$filename_base-$counter.txt");
        print $fh_spoken "$spoken_text\n";
        close $fh_spoken;
      }


      my $exit_code = -1;
      my $voiced_filename = get_text2speech_cached_filename($lang, "$spoken_text\n", $cache_directory);
      if(-e $voiced_filename) {
        $filename_map{$filename_map_key} = $voiced_filename;
      } else {
        while ($exit_code != 0 && (!$no_spoken || $filename_map_key =~ m/context/)) {
          my $textFile = File::Spec->rel2abs("$filename_base-${counter}");

          my $trim_silence = 0;
          if($precise) {
            $trim_silence = 1;
          }
          my $cmd = "./text2speech.py \"$textFile\" $text_to_speech_engine $lang $cache_directory $trim_silence";
          print "execute $cmd\n";

          my $output = `$cmd`;
          print "$output";
          $exit_code = $?;
          $output =~ m/Cached filename:(.*)\n/;
          my $voiced_filename = $1;
          print "voiced_filename: $voiced_filename\n";
          $filename_map{$filename_map_key} = $voiced_filename;
          if ($exit_code == -1) {
            print "ERROR: text2speech.py failed to execute: $!\n";
            exit 1;
          }
          elsif ($exit_code & 127) {
            printf "text2speech.py died with signal %d, %s coredump\n",
                ($exit_code & 127), ($exit_code & 128) ? 'with' : 'without';
            exit 1;
          }
          else {
            my $ecode = $exit_code >> 8;
            printf "text2speech.py exited with value %d\n", $ecode;

            if ($ecode == 1) {
              print "text2speech.py exit_code: $exit_code\n";
              exit 1;
            }
            elsif ($ecode == $t2sIOError) {
              print "ERROR: text2speech.py error reading aws.properties file\n";
              exit 1;
            }
          }
        }
      }

    }

    my $counter = sprintf("%05d",$count);
    if($is_courtsey_tone == 1) {
      $filename_map{"$counter-courtesyTone"} = 1;
      $count++;
    } elsif($sentence_part eq "" && $repeat_part eq "" && $spoken_directive ne "") {
      get_text2speech($counter, $spoken_directive, "$counter-context");
      $count++;
    }

    my @partial_sentence = $sentence_part;
    if($word_limit != -1) {
      @partial_sentence = split_long_sentence($sentence);
    }
    foreach(@partial_sentence) {
      print "---- loop 1 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n";
      print "---- debug: partial sentence: $_\n";

      my $num_chunks++;
      my $sentence_chunk = $_;

      if($_ !~ m/^\s*$/) {
        print $fh_structure "XXX $sentence_chunk\n";
        if($word_limit != -1) {
          print "sentence and spoken chunk: $sentence_chunk\n";
        }

        if(!$test) {
          $sentence_chunk =~ s/^\s+|\s+$//g; #extra space on the end adds new line!

          $counter = sprintf("%05d",$count);
          my $fork_count = 0;

          sub uniq {
            my %seen;
            return grep { !$seen{$_}++ } @_;
          }

          my @render_speeds = @speeds;
          if($speed_racing == 1) {
            @render_speeds = ();
            foreach(@speeds) {
              my $speed = $_;
              push(@render_speeds, $speed);

              for(my $i=1; $i<=$speed_racing_iterations; $i++) {
                my $max_speed = $speed * $speed_racing_multiplier;
                my $iteration_speed = ceil(($max_speed-$speed)/$speed_racing_iterations*$i + $speed);
                push(@render_speeds, $iteration_speed);
                print("speed:$speed  max_speed:$max_speed  iteration:$i  iteration_speed:$iteration_speed\n");
              }

            }
          }

          @render_speeds = uniq(@render_speeds);

          foreach(@render_speeds) {
            my $speed = $_;
            my $farnsworth = 0;

            if ($fork_count >= $max_processes) {
              print("XXXXXX Fork 1 xXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXX");
              print("XXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXX");
              print("waiting on forks: fork_count: $fork_count     max_processes: $max_processes\n");
              wait();
              $fork_count--;
            }

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

            if ($pitch_tone_random != 0) {
              $pitch_tone = $random_tones[ rand @random_tones ];
            }

            my $ebookCmdBase = "";
            if($precise) {
              $ebookCmdBase = "./ebook2cw-trim.bash ";
            } else {
              $ebookCmdBase = "ebook2cw ";
            }

            $ebookCmdBase = $ebookCmdBase . "$lang_option -R $rise_and_fall_time -F $rise_and_fall_time " .
                "$extra_word_spacing_option -f $pitch_tone -w $speed -s 44100 ";
            if ($farnsworth != 0) {
              $ebookCmdBase = $ebookCmdBase . "-e $farnsworth ";
            }
            if ($character_multiplier ne "1") {
              $ebookCmdBase = $ebookCmdBase . "-m $character_multiplier ";
            }

            sub get_cached_filename {
              my ($ebookCmdBase, $morse_text) = @_;

              my $cached_file_hash = sha256_base64($ebookCmdBase . $morse_text);
              $cached_file_hash =~ s/\///g;
              my $cached_file = $cached_file_hash . ".mp3";

              if (! -d "${cache_directory}ebook2cw") {
                mkdir "${cache_directory}ebook2cw";
              }

              my $cached_filepath = $cache_directory . "ebook2cw/" . substr($cached_file_hash, 0, 2) . "/";

              if (! -d "$cached_filepath") {
                mkdir "$cached_filepath";
              }

              my $cached_file_with_path = $cached_filepath . $cached_file;
              return $cached_file_with_path;
            }

            open(my $fh, ">:encoding(UTF-8)", "$output_directory/sentence-${speed}.txt");
            my $updated_sentence_chunk = $sentence_chunk;
            if($sentence_chunk ne "") {
              my @speed_regexes = split(/,/, $speedAdjustRegex);
              foreach(@speed_regexes) {
                my $regex = $_;
                if($regex =~ m/s\/(.*?)\/(.*?)\//) {
                  my $speed_text_to_substitute = $1;
                  my $multiplier = int($2 * $speed);

                  $updated_sentence_chunk =~ s/$speed_text_to_substitute/|w$multiplier/g;
                }

              }
            }
            print $fh "$updated_sentence_chunk\n";
            close $fh;

            my $cached_filename = get_cached_filename($ebookCmdBase, $sentence_chunk);
            $filename_map{"$counter-$speed"} = $cached_filename;

            my $cached_repeat_filename = get_cached_filename($ebookCmdBase, $repeat_part);
            if($character_multiplier ne "1" && $standard_speed_repeat != 0) {
              my $ebookCmdBase_for_repeat = $ebookCmdBase;
              $ebookCmdBase_for_repeat =~ s/-m \d+//;
              print "***************************************************\n";
              print "***************************************************\n";
              print "ebookCmdBase_for_repeat: $ebookCmdBase_for_repeat\n";
              $cached_repeat_filename = get_cached_filename($ebookCmdBase_for_repeat, $repeat_part);
            }

            if(!$no_repeat_morse && $word_limit == -1 && $repeat_part ne $sentence_part || ($character_multiplier ne "1" && $standard_speed_repeat != 0)) {
              $filename_map{"$counter-repeat-$speed"} = $cached_repeat_filename;
            }

            print "************** $ebookCmdBase \n";
            # Only fork if there is work to do
            if((! -f $cached_filename) || (!$no_repeat_morse && $word_limit == -1 &&
                ($repeat_part ne $sentence_part || ($character_multiplier ne "1" && $standard_speed_repeat != 0)) && (! -f $cached_repeat_filename))) {
              my $pid = fork();
              die if not defined $pid;
              if ($pid) {
                # parent
                $fork_count++;
                print "fork() -- pid: $pid\n";

              } else {

                if (!-f $cached_filename) {
                  $ebookCmd = $ebookCmdBase . "-o $output_directory/sentence-${speed} $output_directory/sentence-${speed}.txt";
                  print "DEBUG ========  ======> cached filename no go\n";
                  #print "cmd-6: $ebookCmd\n";

                  system($ebookCmd) == 0 or die "ERROR 6: $ebookCmd failed, $!\n";

                  unlink "$output_directory/sentence-lower-volume-$speed.mp3" if (-f "$output_directory/sentence-lower-volume-$speed.mp3");

                  $cmd = "ffmpeg -i $output_directory/sentence-${speed}0000.mp3 -filter:a \"volume=0.5\" $output_directory/sentence-lower-volume-${speed}.mp3\n";
                  # print "cmd-7: $cmd\n";
                  system($cmd) == 0 or die "ERROR 7: $cmd failed, $!\n";

                  @cmdLst = ("lame", "--resample", "44.1", "-a", "-b", "256",
                      "$output_directory/sentence-lower-volume-$speed.mp3",
                      "$output_directory/sentence-lower-volume-$speed-resampled.mp3");
                  # print "cmdLst-16: @cmdLst\n";
                  system(@cmdLst) == 0 or die "ERROR: @cmdLst failed, $!\n";

                  unlink "$output_directory/sentence-lower-volume-$speed.mp3" if (-f "$output_directory/sentence-lower-volume-$speed.mp3");
                  print "---- move($output_directory/sentence-lower-volume-$speed-resampled.mp3, $cached_filename)\n";
                  move("$output_directory/sentence-lower-volume-$speed-resampled.mp3", $cached_filename);
                  unlink "$output_directory/sentence-${speed}0000.mp3";
                }

                # generate repeat section if it is different than the sentence
                if (!$no_repeat_morse && $word_limit == -1 && ($repeat_part ne $sentence_part || ($character_multiplier ne "1" && $standard_speed_repeat != 0))
                    && (!-f $cached_repeat_filename)) {
                  open(my $fh_repeat, ">:encoding(UTF-8)", "$output_directory/sentence-repeat.txt");
                  print $fh_repeat "$repeat_part\n";
                  close $fh_repeat;

                  my $ebookCmdBase_for_repeat = $ebookCmdBase;
                  if($character_multiplier ne "1" && $standard_speed_repeat != 0) {
                    $ebookCmdBase_for_repeat =~ s/-m \d+//;
                  }
                  $ebookCmd = $ebookCmdBase_for_repeat . "-o $output_directory/sentence-repeat-${speed} $output_directory/sentence-repeat.txt";
                  # print "cmd-8: $ebookCmd\n";
                  system($ebookCmd) == 0 or die "ERROR 8: $cmd failed, $!\n";

                  unlink "$output_directory/sentence-repeat-lower-volume-$speed.mp3" if (-f "$output_directory/sentence-repeat-lower-volume-$speed.mp3");

                  $cmd = sprintf('ffmpeg -i ' . $output_directory . '/sentence-repeat-%d0000.mp3 -filter:a "volume=0.5" ' . $output_directory . '/sentence-repeat-lower-volume-%d.mp3', $speed, $speed);
                  # print "cmd-9: $cmd\n";
                  system($cmd);
                  if ($? == -1) {
                    print "ERROR: cmd: $cmd failed to execute: $!\n";
                    exit 9;
                  }
                  elsif ($? & 127) {
                    printf "cmd: $cmd died with signal %d, %s coredump\n",
                        ($? & 127), ($? & 128) ? 'with' : 'without';
                    exit 9;
                  }
                  else {
                    my $ecode = $? >> 8;
                    if ($ecode != 0) {
                      printf "ERROR cmd: $cmd unsuccessful: $!\n";
                      exit 9;
                    }
                  }
                  unlink "${output_directory}/sentence-repeat-${speed}0000.mp3";

                  @cmdLst = ("lame", "--resample", "44.1", "-a", "-b", "256",
                      "$output_directory/sentence-repeat-lower-volume-${speed}.mp3",
                      "$output_directory/sentence-repeat-lower-volume-${speed}-resampled.mp3");
                  # print "cmd-18: @cmdLst\n";
                  system(@cmdLst) == 0 or die "ERROR 18: @cmdLst failed, $!\n";

                  move("$output_directory/sentence-repeat-lower-volume-${speed}-resampled.mp3", $cached_repeat_filename);
                } # repeat morse if clause

                exit;

              } # child process

            }

          }  # foreach(@speeds)

          for (1 .. $fork_count) {
            wait();
          }

          print "======> Generating text 2 speech for: $spoken_directive\n";
          get_text2speech($counter, $spoken_directive, "$counter-voiced");

        }
        $count++;
      }
    }    # foreach(@partial_sentence)

    if(scalar(@partial_sentence) > 1) {
      print "saying the whole sentence: $sentence\n";

      if(!$test) {
        open(my $fh, ">:encoding(UTF-8)", $output_directory.'/sentence.txt');
        print $fh "$sentence\n";

        my $counter = sprintf("%05d",$count);
        rename("$output_directory/sentence.txt ", '$filename_base-$counter-full.txt');
        my $exit_code = -1;
        while($exit_code != 0 && $no_spoken != 0) {
          my $trim_silence = 0;
          if($precise) {
            $trim_silence = 1;
          }
          my $cmd = './text2speech.py '."$filename_base-${counter}-full $text_to_speech_engine $lang $cache_directory $trim_silence";
          my $output = `$cmd`;
          $output =~ m/^Cached filename:(.*)\n/;
          my $full_voiced_filename = $1;
          print "full voiced_filename: $full_voiced_filename\n";
          $filename_map{"$counter-full-voiced"} = $full_voiced_filename;
          $exit_code = $?;
        }

        $count++;

        close $fh;
      }
    }

  }
}      # foreach(@sentences)
################
###############
close $fh_all;
close $fh_structure;
$count--;

print "\n\nTotal sentences: $sentence_count\t segments: $count\n";
if(!$test) {
  my $cwd = getcwd()."/$output_directory";

  #lame documentation -- https://svn.code.sf.net/p/lame/svn/trunk/lame/USAGE
  unlink "$cwd/silence-resampled.mp3";
  my $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence.mp3 $cwd/silence-resampled.mp3";
  # print "cmd-10: $cmd\n";
  system($cmd) == 0 or die "ERROR 10: $cmd failed, $!\n";

  unlink "$cwd/silence-resampled1.mp3";
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence1.mp3 $cwd/silence-resampled1.mp3";
  # print "cmd-11: $cmd\n";
  system($cmd) == 0 or die "ERROR 11: $cmd failed, $!\n";

  unlink "$cwd/silence-resampled2.mp3";
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence2.mp3 $cwd/silence-resampled2.mp3";
  # print "cmd-12: $cmd\n";
  system($cmd) == 0 or die "ERROR 12: $cmd failed, $!\n";

  unlink "$cwd/silence-resampled3.mp3";
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence3.mp3 $cwd/silence-resampled3.mp3";
  # print "cmd-12: $cmd\n";
  system($cmd) == 0 or die "ERROR 12: $cmd failed, $!\n";

  unlink "$cwd/silence-resampled4.mp3";
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/silence4.mp3 $cwd/silence-resampled4.mp3";
  # print "cmd-12: $cmd\n";
  system($cmd) == 0 or die "ERROR 12: $cmd failed, $!\n";

  unlink "$cwd/pluck-softer-resampled.mp3";
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/pluck-softer.mp3 $cwd/pluck-softer-resampled.mp3";
  # print "cmd-13: $cmd\n";
  system($cmd) == 0 or die "ERROR 13: $cmd failed, $!\n";

  unlink "$cwd/plink-softer-resampled.mp3";
  $cmd = "lame --resample 44.1 -a -b 256 $cwd/plink-softer.mp3 $cwd/plink-softer-resampled.mp3";
  # print "cmd-14: $cmd\n";
  system($cmd) == 0 or die "ERROR 14: $cmd failed, $!\n";;

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
      print("XXXXXX Fork 2 xXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXX\n");
      print("XXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXXXXXXXXxXXXXXXXXXXXXXXXXX\n");
      print("waiting on forks: fork_count: $fork_count     max_processes: $max_processes\n");
      wait();
      $fork_count--;
    }

    my $pid = fork();
    die if not defined $pid;
    if($pid) {
      # parent
      $fork_count++;

    } else {
      unlink "$filename_base-${speed}wpm.mp3";
      my $voiced_context = 0;

      open(my $fh_list, ">:encoding(UTF-8)", "$filename_base-list-${speed}wpm.txt");
      for (my $i=1; $i <= $count; $i++) {
        my $counter = sprintf("%05d",$i);
        my $next_counter = sprintf("%05d",$i+1);

        my $cached_context_filename = $filename_map{"$counter-context"};
        if($filename_map{"$counter-courtesyTone"} == 1){
          #print $fh_list "file '$cwd/silence-resampled4.mp3'\n";
          print $fh_list "file '$cwd/plink-softer-resampled.mp3'\n";

          my $next_cached_context_filename = $filename_map{"${next_counter}-context"};
          # if next thing is voiced context, then we need to add the default amount of silence
          if(-e $next_cached_context_filename) {
            print $fh_list "file '$cwd/silence-resampled.mp3'\n";
          }

        } elsif(-e $cached_context_filename) {
          if($first_for_given_speed == 1) {
            $first_for_given_speed = 0;
          } elsif (!$no_courtesy_tone) {
            print $fh_list "file '$cwd/plink-softer-resampled.mp3'\n";
            print $fh_list "file '$cwd/silence-resampled.mp3'\n";
          }

          print "Voicing context\n";
          $voiced_context = 1;
          print $fh_list "file '$cached_context_filename'\n";

          # else if full sentence
        } elsif (-e "$filename_base-$counter-full-voice.mp3") {

          my $cached_full_voiced_filename = $filename_map{"$counter-full-voiced"};
          print $fh_list "file '$cwd/pluck-softer-resampled.mp3'\nfile '$cwd/silence-resampled.mp3'\nfile '$cached_full_voiced_filename'\nfile '$cwd/silence-resampled.mp3'\n";

        } else {
          # Not full sentence\n";
          if($first_for_given_speed == 1) {
            $first_for_given_speed = 0;
          } elsif (!$no_courtesy_tone && $voiced_context != 1) {
            print $fh_list "file '$cwd/plink-softer-resampled.mp3'\n";
          }

          my $cached_voiced_filename = $filename_map{"$counter-voiced"};
          if($speed_racing == 1) {
            for(my $i=$speed_racing_iterations; $i>=0; $i--) {
              my $max_speed = $speed * $speed_racing_multiplier;
              my $iteration_speed = ceil(($max_speed-$speed)/$speed_racing_iterations*$i + $speed);

              my $cached_filename = $filename_map{"$counter-$iteration_speed"};
              print $fh_list "file '$cwd/silence-resampled1.mp3'\nfile '$cached_filename'\n";
            }
            if(!$no_spoken) {
              print $fh_list "file '$cwd/silence-resampled1.mp3'\nfile '$cached_voiced_filename'\n";
            }
          } else {
            my $cached_filename = $filename_map{"$counter-$speed"};
            if($voiced_context == 1) {
              print "cached_voiced_filename: $cached_voiced_filename\n";
              if($no_spoken) {
                print $fh_list "file '$cwd/silence-resampled3.mp3'\nfile '$cached_filename'\n";
              } else {
                print $fh_list "file '$cwd/silence-resampled3.mp3'\nfile '$cached_filename'\nfile '$cwd/silence-resampled1.mp3'\nfile '$cached_voiced_filename'\n";
              }
            } elsif($no_spoken) {
              print $fh_list "file '$cwd/silence-resampled.mp3'\nfile '$cached_filename'\n";
            } else {
              print "cached_voiced_filename: $cached_voiced_filename\n";
              print $fh_list "file '$cwd/silence-resampled.mp3'\nfile '$cached_filename'\nfile '$cwd/silence-resampled1.mp3'\nfile '$cached_voiced_filename'\n";
            }
          }

          if($no_repeat_morse) {
            my $next_cached_context_filename = $filename_map{"${next_counter}-context"};

            # if next thing is a manual courtesy tone then use the special spacing
            if($filename_map{"${next_counter}-courtesyTone"} == 1) {
              print $fh_list "file '$cwd/silence-resampled4.mp3'\n";

            # if next thing is voiced context, then we need to use --sm, --silencemorse length of silence between Morse code and spoken voice
            } elsif(-e $next_cached_context_filename) {
              print $fh_list "file '$cwd/silence-resampled1.mp3'\n";

            # other wise use the default spacing
            } else {
              print $fh_list "file '$cwd/silence-resampled.mp3'\n";
            }

          } else {
            print $fh_list "file '$cwd/silence-resampled2.mp3'\n";

            my $cached_repeat_filename = $filename_map{"$counter-repeat-$speed"};
            if (-e "$cached_repeat_filename") {
              print $fh_list "file '$cached_repeat_filename'\nfile '$cwd/silence-resampled.mp3'\n";
            } else {

              if($speed_racing == 1) {
                my $max_speed = ceil($speed * $speed_racing_multiplier);
                my $cached_filename = $filename_map{"$counter-$max_speed"};
                if($speed_racing_repeat == 1) {
                  print $fh_list "file '$cwd/silence-resampled1.mp3'\nfile '$cached_filename'\n";
                }
                print $fh_list "file '$cwd/silence-resampled1.mp3'\nfile '$cached_filename'\n";
                print $fh_list "file '$cwd/silence-resampled.mp3'\n";

              } else {
                my $cached_filename = $filename_map{"$counter-$speed"};
                print $fh_list "file '$cached_filename'\nfile '$cwd/silence-resampled.mp3'\n";
              }


            }
          }

          $voiced_context = 0;

        }
      }
      close $fh_list;
      #see -- https://superuser.com/questions/314239/how-to-join-merge-many-mp3-files  or   https://trac.ffmpeg.org/wiki/Concatenate
      @cmdLst = ("ffmpeg", "-nostdin", "-f", "concat", "-safe", "0", "-i",
                 "$filename_base-list-${speed}wpm.txt", "-codec:a", "libmp3lame", "-metadata",
                 "title=$filename_base_without_path ${speed}wpm", "-c", "copy",
                 "$filename_base-$speed"."wpm.mp3");
      # print "cmd-19: @cmdLst\n";
      system(@cmdLst) == 0 or die "ERROR 19: @cmdLst failed, $!\n";

      if($speed_racing == 1) {
        my $filename_speeds = "";
        for(my $i=$speed_racing_iterations; $i>=0; $i--) {
          my $max_speed = $speed * $speed_racing_multiplier;
          my $iteration_speed = ceil(($max_speed - $speed) / $speed_racing_iterations * $i + $speed);
          if($i != $speed_racing_iterations) {
            $filename_speeds .= "-";
          }
          $filename_speeds .= "$iteration_speed";
        }
        move("$filename_base-${speed}wpm.mp3", "$filename_base-$filename_speeds.wpm.mp3");
      }

      exit;
    }
    # end of fork

  }     # foreach(@speeds)

  for (1 .. $fork_count) {
    wait();
  }

  #remove temporary files
  print "Clean up temporary files...\n";
  
  for (my $i=1; $i <= $count; $i++) {
    my $counter = sprintf("%05d",$i);

    unlink glob("'$filename_base-$counter-*.mp3'");
    unlink glob("'$filename_base-$counter.txt'");
  }

  my $speed;
  foreach(@speeds) {
    if ($_ =~ m/(\d+)\//) {
        $speed = $1;
    }
    else {
        $speed = $_;
    }
    unlink "$output_directory/sentence-${speed}0000.mp3", "$output_directory/sentence-repeat-${speed}0000.mp3",
           "$filename_base-list-${speed}wpm.txt", "$output_directory/silence.mp3", "$output_directory/sentence-${speed}.txt",
           "$output_directory/sentence-${speed}-orig0000.mp3";
  }
  unlink "$filename_base-structure.txt", "$filename_base-sentences.txt";
  unlink glob("$output_directory/silence*.mp3");
  unlink glob("$output_directory/pluck*.mp3");
  unlink glob("$output_directory/plink*.mp3");
  unlink "$output_directory/sentence.txt";
  unlink "$output_directory/sentence-repeat.txt";
}

sub print_usage {
  print "\033[1mNAME:\033[0m\n";
  print "  render.pl -- create mp3 audio files defined by an text file. \n\n";

  print "\033[1mSYNOPSIS:\033[0m\n";
  print "  perl render.pl -i file [-o directory] [-c directory] [-s speeds] [-p pitch] [-pr] [-m max processes]\n";
  print "                 [-z 1] [-rr 1] [--test] [-l word limit] [--norepeat] [--nospoken] [--nocourtesytone]\n";
  print "                 [-e NEURAL | STANDARD] [--sm] [--ss] [--sv] [-x] [--lang ENGLISH | SWEDISH]\n\n";
  print "  Uses AWS Polly and requires valid credentials in the aws.properties file.\n\n";

  print "\033[1mOPTIONS:\033[0m\n";
  print "  Required:\n";
  print "    -i, --input          name of the text file containing the script to render\n\n";

  print "  Optional:\n";
  print "    -i, --input          name of the text file containing the script to render\n";
  print "    -o, --output         directory to use for temporary files and output mp3 files\n";
  print "    -c, --cache          directory to use for cache specific files\n";
  print "    -s, --speeds         list of speeds in WPM. example -s 15 17 20 25/10 (Farnsworth specified as character_speed/overall_speed)\n";
  print "    --charactermultiplier Special character spacing multiplier\n";
  print "    --standardspeedrepeat For use only with --charactermultiplier. Uses non Farnsworth speed on the repeat.\n";
  print "    -p, --pitchtone      tone in Hz for pitch. Default 700\n";
  print "    -pr, --pitchrandom   random pitch tone from range [500-900] Hz with step 50 Hz for every practice trial.\n";
  print "    -m, --maxprocs       maximum number of parallel processes to run\n";
  print "    -z, --racing         speed racing format\n";
  print "    -rr, --racingrepeat  repeat final repeat. Use with -z (Speed Racing format).\n";
  print "    --test               don't render audio -- just show what will be rendered -- useful when encoding text\n";
  print "    -l, --limit          word limit. 14 works great... 15 word limit for long sentences; -1 disables it\n";
  print "    --norepeat           exclude repeat morse after speech.\n";
  print "    --nospoken           exclude spoken\n";
  print "    --nocourtesytone     exclude the courtesy tone\n";
  print "    -e, --engine         name of Polly speech engine to use: NEURAL or STANDARD\n";
  print "    -sm, --silencemorse length of silence between Morse code and spoken voice. Default 1 second.\n";
  print "    -ss, --silencesets  length of silence between courtesy tone and next practice set. Default 1 second.\n";
  print "    -sv, --silencevoice length of silence between spoken voice and repeated morse code. Default 1 second.\n";
  print "    -sc, --silencecontext length of silence between spoken context and morse code. Default 1 second.\n";
  print "    -st, --silencemanualcourtesytone length of silence between Morse code and manually specified courtesy tone <courtesyTone>. Default 1 second.\n";
  print "    -x, --extraspace     0 is no extra spacing. 0.5 is half word extra spacing. 1 is twice the word space. 1.5 is 2.5x the word space. etc\n";
  print "    --precise            trim AWS Polly and ebook2cw audio -- useful when specifying very short time with -sm, --silencemorse length of silence between Morse code and spoken voice.\n";
  print "                         ****Be sure*** to clear the cache directory if you are switching between precise and non-precise timing.\n";
  print "    -l, --lang           language: ENGLISH, GERMAN, or SWEDISH\n\n";
  die "";
}
