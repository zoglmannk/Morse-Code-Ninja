#!/usr/bin/perl

use strict;
use warnings;
use Cwd;

# Usage: ./generate-licw-kids-course.pl

# Render with:
# ls -1 | grep licw | grep speed-racing | xargs -IXX  ./render.pl -i XX -s 20 22 25 -z 1 -sm 0.6
# ls -1 | grep licw | grep -v speed-racing | grep txt | xargs -IXX  ./render.pl -i XX -s 20 22 25 28 30 -sm 0.6

my $number_of_runs_in_lesson = 500;

# 1- KMRS
# 2. KMRSUAPT
# 3. KMRAUAPTLOWI
# 4. KMRSUAPTLOWI(period)NJE
# 5. KMRSUAPTLOWI(period)NJEF0Y(comma)
# 6. KMRSUAPTLOWI(period)NJEF0Y(comma)VG5/
# 7. KMRSUAPTLOWI(period)NJEF0Y(comma)VG5/Q9ZH
# 8. KMRSUAPTLOWI(period)NJEF0Y(comma)VG5/Q9ZH38B?
# 9  KMRSUAPTLOWI(period)NJEF0Y(comma)VG5/Q9ZH38B?427C
# 10 KMRSUAPTLOWI(period)NJEF0Y(comma)VG5/Q9ZH38B?427C1D6X

my @lessons = (
    ['K','M','R','S'],
    ['K','M','R','S','U','A','P','T'],
    ['K','M','R','S','U','A','P','T','L','O','W','I'],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E'],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E','F','0','Y',','],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E','F','0','Y',',','V','G','5','/'],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E','F','0','Y',',','V','G','5','/','Q','9','Z','H'],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E','F','0','Y',',','V','G','5','/','Q','9','Z','H','3','8','B','?'],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E','F','0','Y',',','V','G','5','/','Q','9','Z','H','3','8','B','?','4','2','7','C'],
    ['K','M','R','S','U','A','P','T','L','O','W','I','.','N','J','E','F','0','Y',',','V','G','5','/','Q','9','Z','H','3','8','B','?','4','2','7','C','1','D','6','X'],
);

my %prononciation = (
    '.'    => 'period',
    ','    => 'comma',
    '?'    => 'question mark',
    '/'    => 'stroke',
    '<BT>' => 'B T',
    '<HH>' => 'correction',
    '<KN>' => 'K N',
    '<SK>' => 'S K',
    '<AR>' => 'A R',
    'P'    => 'P.',
    'K'    => 'K.',
    'T'    => 'T.',
    'U'    => 'U.',
    'V'    => 'V.'
);

my $previous_character = "";
my $random_character = "";
for(my $lesson_num=0; $lesson_num<(scalar @lessons); $lesson_num++) {
    #open(LESSON_FH, '>', 'licw-course-lesson-'.(sprintf '%02d', ($lesson_num+1)).'.txt') or die $!;
    open(LESSON_FH, '>', 'licw-course-lesson-'.(sprintf '%02d', ($lesson_num+1)).'-speed-racing.txt') or die $!;

    for(my $i=0; $i<$number_of_runs_in_lesson; $i++) {

        while($random_character eq "" || $random_character eq $previous_character) {
            $random_character = $lessons[$lesson_num][int rand scalar(@{$lessons[$lesson_num]})];
        }
        $previous_character = $random_character;

        my $random_letter_safe = $random_character;
        $random_letter_safe =~ s/(\.|\?)/\\$1/;
        if(defined $prononciation{$random_character}) {
            my $random_safe_pronunciation = $prononciation{$random_character};
            $random_safe_pronunciation =~ s/\./\\./;
            print LESSON_FH "$random_letter_safe [$random_safe_pronunciation]^\n";
        } else {
            print LESSON_FH "$random_letter_safe [$random_letter_safe]^\n";
        }
    }

    close(LESSON_FH);
}
