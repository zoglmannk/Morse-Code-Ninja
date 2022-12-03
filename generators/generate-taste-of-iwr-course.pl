#!/usr/bin/perl

use strict;
use Cwd;

## ./generate-taste-of-iwr-course.pl
## mv *Lesson\ -\ *.txt ../
## on mac - brew install findutils
## ls -1 | grep Lesson | grep txt | grep -v Sentence | gxargs -IXX ./render.pl -i 'XX' -s 40

#./render.pl -i '101 Lesson - Sentences - 8x Word Spacing.txt' -s 40 -x 8 --sm 1.5
#./render.pl -i '102 Lesson - Sentences - 6x Word Spacing.txt' -s 40 -x 6 --sm 1.5
#./render.pl -i '103 Lesson - Sentences - 4x Word Spacing.txt' -s 40 -x 4 --sm 1.5
#./render.pl -i '104 Lesson - Sentences - 3x Word Spacing.txt' -s 40 -x 3 --sm 1.5
#./render.pl -i '105 Lesson - Sentences - 2x Word Spacing.txt' -s 40 -x 2 --sm 1.5
#./render.pl -i '106 Lesson - Sentences - Standard Spacing.txt' -s 40

# fix filenames
# ls -1 *.mp3 | perl -e 'while(<>) { $in = $_; chomp($in); $in =~ m/(.*?)-40wpm.mp3/; $new_filename = "$1 - 40wpm.mp3"; print "mv \"$in\" \"$new_filename\"\n"; }' > runme.bash; chmod a+rx runme.bash; ./runme.bash



##
# Order of words from shortest to longest
##
# is = di-dit di-di-dit = (2*30)+90+(3*30) = 240ms
# it = di-dit dah = (2*30)+90+(90) = 240ms
# me = dah-dah dit = (2*90)+90+(30) = 300ms
# she = di-di-dit di-di-di-dit dit = (3*30)+90+(4*30)+90+(30) = 420ms
# to = dah dah-dah-dah = (90)+90+(3*90) = 450ms
# her = di-di-di-dit dit di-dah-dit = (4*30)+90+(30)+90+(30+90+30) = 480ms
# get = dah-dah-dit dit dah = (2*90+30)+90+(30)+90+(90) = 510ms
# do = dah-di-dit dah-dah-dah = (90+2*30)+90+(3*90) = 510ms
# did = dah-di-dit di-dit dah-di-dit = (90+2*30)+90+(30*2)+90+(90+2*30) = 540ms
# here = di-di-di-dit dit di-dah-dit dit = (4*30)+90+(30)+90+(30+90+30)+90+(30) = 600ms
# bad = dah-di-di-dit di-dah dah-di-dit = (90+3*30)+90+(30+90)+90+(90+30+30) = 630ms
# can = dah-di-dah-dit di-dah dah-dit = (90*2+30*2)+90+(30+90)+90+(90+30) = 660ms
# not = dah-dit dah-dah-dah dah = (90+30)+90+(3*90)+90+(90) = 660ms
# how = di-di-di-dit dah-dah-dah di-dah-dah = (4*30)+90+(3*90)+90+(30+2*90) = 780ms
# there = dah di-di-di-dit dit di-dah-dit dit = (90)+90+(4*30)+90+(30)+90+(2*30+90)+90+(30) = 780ms
# more = dah-dah dah-dah-dah di-dah-dit dit = (2*90)+90+(3*90)+(2*30+90)+90+(30) = 810ms
# like = di-dah-di-dit di-dit dah-di-dah dit = (2*30+2*90)+90+(2*30)+90+(2*90+30)+90+(30) = 810ms
# what = di-dah-dah di-di-di-dit di-dah dah = (30+2*90)+90+(4*30)+90+(30+90)+90+(90) = 810ms
# tell = dah dit di-dah-di-dit di-dah-di-dit = (90)+90+(30)+90+(2*30+2*90)+90+(2*30+2*90) = 870ms
# you = dah-di-dah-dah dah-dah-dah di-di-dah = (3*90+30)+90+(3*90)+90+(2*30+90) = 900ms
# will = di-dah-dah di-dit di-dah-di-dit di-dah-di-dit = (30+2*90)+90+(2*30)+90+(3*30+90)+90+(3*30+90) = 900ms
# where = di-dah-dah di-di-di-dit dit di-dah-dit dit = (30+2*90)+90+(4*30)+90+(30)+90+(2*30+90)+90+(30) = 900ms
# know = dah-di-dah dah-dit dah-dah-dah di-dah-dah = (90+30+90)+90+(90+30)+90+(3*90)+90+(30+2*90) = 1080ms
# would = di-dah-dah dah-dah-dah di-di-dah di-dah-di-dit dah-di-dit = (30+2*90)+90+(3*90)+90+(3*30+90)+90+(90+2*30) = 1,080ms
# about = di-dah dah-di-di-dit dah-dah-dah di-di-dah dah = (30+90)+90+(90+3*30)+90+(90*3)+90+(30+30+90)+90+(90) = 1,170ms
# average = (240+240+300+420+450+480+510+510+540+600+630+660+660+780+780+810+810+870+900+900+900+1080+1080+1170)/25 = 653ms


##
# Order to learn word sound patterns = start with average length words and progressively work on shorter and longer words alternating between the two
##
# can = dah-di-dah-dit di-dah dah-dit = (90*2+30*2)+90+(30+90)+90+(90+30) = 660ms
# not = dah-dit dah-dah-dah dah = (90+30)+90+(3*90)+90+(90) = 660ms
# here = di-di-di-dit dit di-dah-dit dit = (4*30)+90+(30)+90+(30+90+30)+90+(30) = 600ms
# bad = dah-di-di-dit di-dah dah-di-dit = (90+3*30)+90+(30+90)+90+(90+30+30) = 630ms
# how = di-di-di-dit dah-dah-dah di-dah-dah = (4*30)+90+(3*90)+90+(30+2*90) = 780ms
# there = dah di-di-di-dit dit di-dah-dit dit = (90)+90+(4*30)+90+(30)+90+(2*30+90)+90+(30) = 780ms
# do = dah-di-dit dah-dah-dah = (90+2*30)+90+(3*90) = 510ms
# did = dah-di-dit di-dit dah-di-dit = (90+2*30)+90+(30*2)+90+(90+2*30) = 540ms
# more = dah-dah dah-dah-dah di-dah-dit dit = (2*90)+90+(3*90)+(2*30+90)+90+(30) = 810ms
# like = di-dah-di-dit di-dit dah-di-dah dit = (2*30+2*90)+90+(2*30)+90+(2*90+30)+90+(30) = 810ms
# her = di-di-di-dit dit di-dah-dit = (4*30)+90+(30)+90+(30+90+30) = 480ms
# get = dah-dah-dit dit dah = (2*90+30)+90+(30)+90+(90) = 510ms
# what = di-dah-dah di-di-di-dit di-dah dah = (30+2*90)+90+(4*30)+90+(30+90)+90+(90) = 810ms
# tell = dah dit di-dah-di-dit di-dah-di-dit = (90)+90+(30)+90+(2*30+2*90)+90+(2*30+2*90) = 870ms
# she = di-di-dit di-di-di-dit dit = (3*30)+90+(4*30)+90+(30) = 420ms
# to = dah dah-dah-dah = (90)+90+(3*90) = 450ms
# you = dah-di-dah-dah dah-dah-dah di-di-dah = (3*90+30)+90+(3*90)+90+(2*30+90) = 900ms
# will = di-dah-dah di-dit di-dah-di-dit di-dah-di-dit = (30+2*90)+90+(2*30)+90+(3*30+90)+90+(3*30+90) = 900ms
# me = dah-dah dit = (2*90)+90+(30) = 300ms
# where = di-dah-dah di-di-di-dit dit di-dah-dit dit = (30+2*90)+90+(4*30)+90+(30)+90+(2*30+90)+90+(30) = 900ms
# it = di-dit dah = (2*30)+90+(90) = 240ms
# is = di-dit di-di-dit = (2*30)+90+(3*30) = 240ms
# know = dah-di-dah dah-dit dah-dah-dah di-dah-dah = (90+30+90)+90+(90+30)+90+(3*90)+90+(30+2*90) = 1080ms
# would = di-dah-dah dah-dah-dah di-di-dah di-dah-di-dit dah-di-dit = (30+2*90)+90+(3*90)+90+(3*30+90)+90+(90+2*30) = 1,080ms
# about = di-dah dah-di-di-dit dah-dah-dah di-di-dah dah = (30+90)+90+(90+3*30)+90+(90*3)+90+(30+30+90)+90+(90) = 1,170ms

my $working_delay = 1000;
my $probability_of_selecting_new_word = 40; # out of 100
my $num_of_runs = 600;
my $max_repeats = 3;

my @working_words = ();
my @words = (
    'can', 'not', 'here', 'bad', 'how', 'there', 'do', 'did', 'more', 'like', 'her',
    'get', 'what', 'tell', 'she', 'to', 'you', 'will', 'me', 'where', 'it', 'is',
    'know', 'would', 'about'
);

my @sentences = (
    'can you tell me more',
    'can you tell me about her',
    'can you tell me',
    'can you tell me about it',
    'tell me more',
    'tell me more about her',
    'tell me about her',
    'tell me about it',
    'she will tell me',
    'tell her about it',
    'tell her more about it',
    'tell me more about it',
    'what is it about',
    'what about it',
    'what about her',
    'is it about her',
    'it is about her',
    'she would like to know more',
    'she will know about it',
    'what more would she like to know',
    'what more would you like to know',
    'she would like to know',
    'would she like to know',
    'would she like to know more',
    'can she know more about it',
    'will she know more about it',
    'she will know',
    'do you know her',
    'is she there',
    'there she is',
    'she is not here',
    'she is here',
    'not bad',
    'she is not bad',
    'she is bad',
    'is she bad',
    'how bad is it',
    'how did she get here',
    'how did she get there',
    'she will get here',
    'she will get there',
    'will she get here',
    'will she get there',
    'here she is',
    'there she is',
    'where is she',
    'she is where',
    'is she there',
    'how do you know her',
    'how do you know',
    'do you like her',
    'do you like it here',
    'do you like it',
    'she will like you',
    'she will like it there',
    'will she like it there',
    'you will like it there',
    'will you like it there',
    'what will she do',
    'what will you do',
    'she will do it',
    'do what you will',
    'you will know',
    'she will know',
    'what more do you know',
    'what do you know',
    'what do you know about it',
    'what do you know about her',
    'what do you know about me',
    'can she do it',
    'she can do it',
    'you can do it',
    'can you do it',
    'what more can you do',
    'what more can she do',
    'did she get it',
    'did you get it',
    'she did it',
    'you will like her',
    'will you like her',
    'she will like it here',
    'you will like it here',
    'will she get it',
    'will you get it',
    'tell me what you would do',
    'tell me what she would do',
    'would she tell me',
    'would she tell her',
    'how about it',
    'how about here',
    'how do you know about it',
    'how do you know about her',
    'what is it like there',
    'what is it like',
    'what is she like',
    'what do you like about her',
    'what do you like about it',
    'what do you like about me',
    'will she do it',
    'will you do it',
    'it is bad',
    'is it bad'
);



my $last_pick = "";
my $num_repeated = 0;
sub pick_random_word {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];

    while(1 == 1) {
        my $ret = "";

        if(int(rand(100)) <= $probability_of_selecting_new_word) {
            $ret = $new_word;
        } else {
            my $next_pick = @working_words[int(rand(scalar @working_words))];
            $ret = $next_pick;
        }

        if( ($allow_repeat == 1 && $num_repeated+1 < $max_repeats) || $ret ne $last_pick) {
            if($last_pick eq $ret) {
                $num_repeated += 1;
            } else {
                $num_repeated = 0;
            }
            $last_pick = $ret;
            return $ret;
        }
    }
}

my $last_pick_sentence = "";
sub pick_random_sentence {
    while(1 == 1) {

        my $next_pick_sentence = @sentences[int(rand(scalar @sentences))];
        if($next_pick_sentence ne $last_pick_sentence) {
            $last_pick_sentence = $next_pick_sentence;
            return $next_pick_sentence;
        }

    }
}

sub right_pad {
    my $str = $_[0];
    my $len = $_[1];
    my $chr = $_[2];

    return substr($str . ($chr x $len), 0, $len);
}

sub generate_introduction {
    my $word = $_[0];
    my $lesson_num = $_[1];

    my $write_file_name = (sprintf '%03d', $lesson_num) . " Lesson - " . right_pad(uc($word),5,' ') . " - Introduce New Word.txt";
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..20) {
        print $WRITE_FH "$word |S$working_delay $word |S$working_delay $word |S$working_delay $word [$word|$word]^\n";
    }

    close($WRITE_FH);

}

sub generate_single_word_repeated_3x {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_words = $_[3];

    my $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - " . right_pad(uc($new_word),5,' ') . " - Single Word Repeated 3x.txt";
    if($is_review_all_words == 1) {
        $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - Review All Words - Single Word Repeated 3x.txt";
    }
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_word = pick_random_word($new_word, $allow_repeat);
        print $WRITE_FH "$rand_word |S$working_delay $rand_word |S$working_delay $rand_word [$rand_word|$rand_word]^\n";
    }

}

sub generate_single_word {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_words = $_[3];

    my $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - " . right_pad(uc($new_word),5,' ') . " - Single Word.txt";
    if($is_review_all_words == 1) {
        $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - Review All Words - Single Word.txt";
    }
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_word = pick_random_word($new_word, $allow_repeat);
        print $WRITE_FH "$rand_word^\n";
    }

}

sub generate_two_words {
    my $new_word = $_[0];
    my $allow_repeat = $_[1];
    my $lesson_num = $_[2];
    my $is_review_all_words = $_[3];

    my $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - " . right_pad(uc($new_word),5,' ') . " - Two Words.txt";
    if($is_review_all_words == 1) {
        $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - Review All Words - Two Words.txt";
    }
    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_word1 = pick_random_word($new_word, $allow_repeat);
        my $rand_word2 = pick_random_word($new_word, $allow_repeat);
        print $WRITE_FH "$rand_word1 |S$working_delay $rand_word2 [$rand_word1, $rand_word2]^\n";
    }

}

sub generate_sentences {
    my $lesson_num = $_[0];
    my $extra_word_spacing = $_[1];

    my $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - Sentences - ". $extra_word_spacing ."x Word Spacing.txt";
    if ($extra_word_spacing == 1) {
        $write_file_name = (sprintf '%03d', $lesson_num)." Lesson - Sentences - Standard Spacing.txt";
    }

    open(my $WRITE_FH, '>', $write_file_name) or die $!;

    for(1..$num_of_runs) {
        my $rand_sentence = pick_random_sentence();
        print $WRITE_FH "$rand_sentence^\n";
    }
}

my $lesson_num=1;
for(my $i=0; $i < scalar(@words); $i++) {
    my $word = $words[$i];
    generate_introduction($word, $lesson_num);
    $lesson_num += 1;
    my $is_review_all_words = 0;

    if($i > 0) {
        my $allow_back_to_back_repeats = 1;
        if ($i >= 4) {
            $allow_back_to_back_repeats = 0;
        }
        generate_single_word_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
        $lesson_num += 1;

        generate_single_word($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
        $lesson_num += 1;

        generate_two_words($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
        $lesson_num += 1;
    }
    push(@working_words, $word);

}

my $word = $words[scalar(@words)-1];
my $allow_back_to_back_repeats = 0;
my $is_review_all_words = 1;
$probability_of_selecting_new_word = -1; #disables boosting probability of selecting new word. This is a review after all. :)
generate_single_word_repeated_3x($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
$lesson_num += 1;

generate_single_word($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
$lesson_num += 1;

generate_two_words($word, $allow_back_to_back_repeats, $lesson_num, $is_review_all_words);
$lesson_num += 1;

generate_sentences($lesson_num, 8);
$lesson_num += 1;
generate_sentences($lesson_num, 6);
$lesson_num += 1;
generate_sentences($lesson_num, 4);
$lesson_num += 1;
generate_sentences($lesson_num, 3);
$lesson_num += 1;
generate_sentences($lesson_num, 2);
$lesson_num += 1;
generate_sentences($lesson_num, 1);
$lesson_num += 1;