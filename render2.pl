#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Copy;
use File::Path;
use File::Spec;
use Getopt::Long;
use Digest::SHA qw(sha256_hex sha256_base64);
use POSIX;

###
# This utility is used to generate special Letter-by-Letter practice sets. There is no Morse Code.
# (There are also some known bugs that need to be cleaned up.)
##


my %filename_map;

sub print_usage;

GetOptions(
    'i|input=s'         => \(my $input_filename),
    'o|output=s'        => \(my $output_directory = '.'),
    'c|cache=s'         => \(my $cache_directory = './cache/'),
    'e|engine=s'        => \(my $text_to_speech_engine = "neural"), # neural | standard
    'l|lang=s'          => \(my $lang = "ENGLISH"), # ENGLISH | SWEDISH
    'nocourtesytone'    => \(my $no_courtesy_tone), # flag
    'sm|silencemorse=s' => \(my $silence_between_plink = "1"),
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

if (! -d "$output_directory") {
    mkdir "$output_directory";
}
my $cwd = getcwd()."/$output_directory";

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

open(INPUT_TEXT, $filename) or die("Could not open $filename.");

#create quieter tone
unlink "$output_directory/plink-softer.mp3" if (-f "$output_directory/plink-softer.mp3");
my $cmd = 'ffmpeg -i sounds/plink.mp3 -filter:a "volume=0.5" '.$output_directory.'/plink-softer.mp3';
print "cmd-4: $cmd\n";
system($cmd) == 0 or die "ERROR 4: $cmd failed, $!\n";

unlink "$cwd/plink-softer-resampled.mp3";
$cmd = "lame --resample 44.1 -a -b 256 $cwd/plink-softer.mp3 $cwd/plink-softer-resampled.mp3";
# print "cmd-14: $cmd\n";
system($cmd) == 0 or die "ERROR 14: $cmd failed, $!\n";;


# This is the silence between the the difference sentences
unlink "$output_directory/silence1.mp3" if (-f "$output_directory/silence1.mp3");
my @cmdLst = ("ffmpeg", "-f", "lavfi", "-i", "anullsrc=channel_layout=5.1:sample_rate=22050",
    "-t", "$silence_between_plink", "-codec:a", "libmp3lame",
    "-b:a", "256k", "$output_directory/silence1.mp3");
# print "cmd-2: @cmdLst\n";
system(@cmdLst) == 0 or die "ERROR 2: @cmdLst failed, $!\n";

unlink "$cwd/silence-resampled1.mp3";
$cmd = "lame --resample 44.1 -a -b 256 $cwd/silence1.mp3 $cwd/silence-resampled1.mp3";
# print "cmd-11: $cmd\n";
system($cmd) == 0 or die "ERROR 11: $cmd failed, $!\n";


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

my $counter = 1;
foreach my $sentence (<INPUT_TEXT>)  {

    open(my $fh, '>', "$output_directory/sentence.txt");
    print $fh "$sentence\n";
    close $fh;

    print "Sent to $output_directory/sentence.txt\n";
    print "*** $sentence";

    rename("$output_directory/sentence.txt", "$filename_base-$counter.txt");

    my $exit_code = -1;
    my $voiced_filename = get_text2speech_cached_filename($lang, "$sentence\n", $cache_directory);
    if(-e $voiced_filename) {
        $filename_map{"$counter-voiced"} = $voiced_filename;
    } else {
        while ($exit_code != 0) {
            my $textFile = File::Spec->rel2abs("$filename_base-${counter}");

            my $cmd = "./text2speech.py \"$textFile\" $text_to_speech_engine $lang $cache_directory";
            print "execute $cmd\n";

            my $output = `$cmd`;
            print "$output";
            $exit_code = $?;
            $output =~ m/Cached filename:(.*)\n/;
            my $voiced_filename = $1;
            print "voiced_filename: $voiced_filename\n";
            $filename_map{"$counter-voiced"} = $voiced_filename;
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

    $counter++;
}


my $first_for_given_speed = 1;
open(my $fh_list, '>', "$filename_base-list.txt");
for (my $i=1; $i < $counter; $i++) {
    my $counter = sprintf("%05d", $i);

    if($first_for_given_speed == 1) {
        $first_for_given_speed = 0;
    } else {
        print $fh_list "file '$cwd/silence-resampled1.mp3'\n";
        if (!$no_courtesy_tone) {
            print $fh_list "file '$cwd/plink-softer-resampled.mp3'\n";
            print $fh_list "file '$cwd/silence-resampled1.mp3'\n";
        }
    }

    my $cached_voiced_filename = $filename_map{"$i-voiced"};
    print $fh_list "file '$cached_voiced_filename'\n";
}
close $fh_list;

#see -- https://superuser.com/questions/314239/how-to-join-merge-many-mp3-files  or   https://trac.ffmpeg.org/wiki/Concatenate
@cmdLst = ("ffmpeg", "-f", "concat", "-safe", "0", "-i",
    "$filename_base-list.txt", "-codec:a", "libmp3lame", "-metadata",
    "title=$filename_base_without_path", "-c", "copy",
    "$filename_base".".mp3");
# print "cmd-19: @cmdLst\n";
system(@cmdLst) == 0 or die "ERROR 19: @cmdLst failed, $!\n";



# cleanup
#remove temporary files
print "Clean up temporary files...\n";

for (my $i=1; $i <= $counter; $i++) {
    my $counter = sprintf("%05d",$i);

    unlink glob("'$filename_base-$counter.txt'");
}

unlink glob("$output_directory/silence*.mp3");
unlink glob("$output_directory/pluck*.mp3");

close INPUT_TEXT;

sub print_usage {
    print "\033[1mNAME:\033[0m\n";
    print "  render2.pl -- create Letter-By-Letter mp3 audio files defined by a text file. \n\n";

    print "\033[1mOPTIONS:\033[0m\n";
    print "  Required:\n";
    print "    -i, --input          name of the text file containing the script to render\n\n";

    print "  Optional:\n";
    print "    -i, --input          name of the text file containing the script to render\n";
    print "    -o, --output         directory to use for temporary files and output mp3 files\n";
    print "    -c, --cache          directory to use for cache specific files\n";
    print "    -l, --lang           language: ENGLISH or SWEDISH\n\n";
    print "    -e, --engine         name of Polly speech engine to use: NEURAL or STANDARD\n";
    print "    --nocourtesytone     exclude the courtesy tone\n";
    die "";
}