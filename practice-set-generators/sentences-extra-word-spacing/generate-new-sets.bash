#!/bin/bash


# Rendered with the following settings
# my $max_processes = 10;
# my $test = 0; # 1 = don't render audio -- just show what will be rendered -- useful when encoding text
# my $word_limit = -1; # 14 works great... 15 word limit for long sentences; -1 disables it
# my $repeat_morse = 1;
# my $courtesy_tone = 1;
# my $text_to_speech_engine = "neural"; # neural | standard
# my $silence_between_morse_code_and_spoken_voice = "1.5";
# my $silence_between_sets = "1"; # typically "1" sec ##### SET THIS BACK
# my $silence_between_voice_and_repeat = "1"; # $silence_between_sets; # has typically been set the same as $silence_between_sets which has been 1 second
# my $extra_word_spacing = 1; # 0 is no extra spacing. 0.5 is half word extra spacing. 1 is twice the word space. 1.5 is 2.5x the word space. etc
# my $lang = "ENGLISH"; # ENGLISH | SWEDISH


# 191 unique sentences - 380 total sentences
echo Top 100 Words
cat 'Sentences from Top 100 words.txt' | sort | uniq | wc
cat 'Sentences from Top 100 words.txt' | wc

rm render.bash
echo '#!/bin/bash' > render.bash

#Run from directory with all the audio files
for speed in 15 17 20 22 25 28 30 35 40 45 50; do
  for word_spacing in 4 3 2; do
    extra_word_spacing=$(($word_spacing-1))
    while true; do
      cat 'Sentences from Top 100 words.txt' | sort | uniq | gshuf > sentences-from-top-100-words-${word_spacing}x-word-spacing-${speed}wpm.txt
      cat 'Sentences from Top 100 words.txt' | sort | uniq | gshuf >> sentences-from-top-100-words-${word_spacing}x-word-spacing-${speed}wpm.txt
      echo sentences-from-top-100-words-${word_spacing}x-word-spacing-${speed}wpm.txt
      cat sentences-from-top-100-words-${word_spacing}x-word-spacing-${speed}wpm.txt | ../../check-for-back-to-back-dup-lines.pl
      if [ $? -eq 0 ]; then
        echo ./render.pl -i practice-set-generators/sentences-extra-word-spacing/sentences-from-top-100-words-${word_spacing}x-word-spacing-${speed}wpm.txt -s $speed -sm 1.5 -x $extra_word_spacing >> render.bash
        break
      fi
    done
  done
done

#Run from directory with all the audio files
for top_words in 200 300 400 500; do

  echo Top ${top_words} Words
  cat "Sentences from Top ${top_words} words.txt" | sort | uniq | wc
  cat "Sentences from Top ${top_words} words.txt" | wc

  for speed in 15 17 20 22 25 28 30 35 40 45 50; do
    for word_spacing in 4 3 2; do
      extra_word_spacing=$(($word_spacing-1))
      while true; do
        cat "Sentences from Top ${top_words} words.txt" | sort | uniq | gshuf > sentences-from-top-${top_words}-words-${word_spacing}x-word-spacing-${speed}wpm.txt
        echo sentences-from-top-${top_words}-words-${word_spacing}x-word-spacing-${speed}wpm.txt
        cat sentences-from-top-${top_words}-words-${word_spacing}x-word-spacing-${speed}wpm.txt | ../../check-for-back-to-back-dup-lines.pl
        if [ $? -eq 0 ]; then
          echo ./render.pl -i practice-set-generators/sentences-extra-word-spacing/sentences-from-top-${top_words}-words-${word_spacing}x-word-spacing-${speed}wpm.txt -s $speed -sm 1.5 -x $extra_word_spacing >> render.bash
          break
        fi
      done
    done
  done
done


chmod a+x render.bash