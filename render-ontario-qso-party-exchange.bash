#!/bin/bash

cp practice-sets/Ontario\ QSO\ Party\ Exchange.txt ./ontario-qso-party-exchange.txt

rm ontario-qso-party-exchange-15wpm.mp3 ontario-qso-party-exchange-17wpm.mp3 ontario-qso-party-exchange-20wpm.mp3 ontario-qso-party-exchange-22wpm.mp3 ontario-qso-party-exchange-25wpm.mp3 ontario-qso-party-exchange-28wpm.mp3 ontario-qso-party-exchange-30wpm.mp3 ontario-qso-party-exchange-35wpm.mp3 ontario-qso-party-exchange-40wpm.mp3 ontario-qso-party-exchange-45wpm.mp3 ontario-qso-party-exchange-50wpm.mp3
./render.pl -i ontario-qso-party-exchange.txt -s 15 17 20 22 25 28 30 35 40 45 50

rm -f Ontario-introduction.mp3 silence.mp3 ontario-introduction.txt combine15.txt combine17.txt combine20.txt combine22.txt combine25.txt combine28.txt combine30.txt combine35.txt combine40.txt combine45.txt combine50.txt ontario-qso-party-exchange-15wpm2.mp3 ontario-qso-party-exchange-17wpm2.mp3 ontario-qso-party-exchange-20wpm2.mp3 ontario-qso-party-exchange-22wpm2.mp3 ontario-qso-party-exchange-25wpm2.mp3 ontario-qso-party-exchange-28wpm2.mp3 ontario-qso-party-exchange-30wpm2.mp3 ontario-qso-party-exchange-35wpm2.mp3 ontario-qso-party-exchange-40wpm2.mp3 ontario-qso-party-exchange-45wpm2.mp3 ontario-qso-party-exchange-50wpm2.mp3

echo Please note that only the first few practice rounds will include the, R, S, T, report when the answer is spoken. It is always 5 9 9 and sent as 5, N, N. > ontario-introduction.txt
./text2speech.py ontario-introduction neural ENGLISH cache/

ffmpeg -i cache/Mathew-standard-neural-73c607539cbf85f1b5e00badc456f2170e82f09fd8d7da76fe3aac1cde12c361.mp3 -ar 44100 Ontario-introduction.mp3
ffmpeg -f lavfi -i anullsrc=channel_layout=5.1:sample_rate=44100 -t 1 -codec:a libmp3lame -b:a 256k -ac 1 silence.mp3

cat << EOF > combine15.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-15wpm.mp3'
EOF

cat << EOF > combine17.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-17wpm.mp3'
EOF

cat << EOF > combine20.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-20wpm.mp3'
EOF

cat << EOF > combine22.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-22wpm.mp3'
EOF

cat << EOF > combine25.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-25wpm.mp3'
EOF

cat << EOF > combine28.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-28wpm.mp3'
EOF

cat << EOF > combine30.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-30wpm.mp3'
EOF

cat << EOF > combine35.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-35wpm.mp3'
EOF

cat << EOF > combine40.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-40wpm.mp3'
EOF

cat << EOF > combine45.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-45wpm.mp3'
EOF

cat << EOF > combine50.txt
file 'silence.mp3'
file 'Ontario-introduction.mp3'
file 'silence.mp3'
file 'sounds/plink.mp3'
file 'ontario-qso-party-exchange-50wpm.mp3'
EOF

ffmpeg -f concat -safe 0 -i combine15.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-15wpm2.mp3
ffmpeg -f concat -safe 0 -i combine17.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-17wpm2.mp3
ffmpeg -f concat -safe 0 -i combine20.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-20wpm2.mp3
ffmpeg -f concat -safe 0 -i combine22.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-22wpm2.mp3
ffmpeg -f concat -safe 0 -i combine25.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-25wpm2.mp3
ffmpeg -f concat -safe 0 -i combine28.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-28wpm2.mp3
ffmpeg -f concat -safe 0 -i combine30.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-30wpm2.mp3
ffmpeg -f concat -safe 0 -i combine35.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-35wpm2.mp3
ffmpeg -f concat -safe 0 -i combine40.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-40wpm2.mp3
ffmpeg -f concat -safe 0 -i combine45.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-45wpm2.mp3
ffmpeg -f concat -safe 0 -i combine50.txt -codec:a libmp3lame -c copy ontario-qso-party-exchange-50wpm2.mp3

mv ontario-qso-party-exchange-15wpm2.mp3 ontario-qso-party-exchange-15wpm.mp3
mv ontario-qso-party-exchange-17wpm2.mp3 ontario-qso-party-exchange-17wpm.mp3
mv ontario-qso-party-exchange-20wpm2.mp3 ontario-qso-party-exchange-20wpm.mp3
mv ontario-qso-party-exchange-22wpm2.mp3 ontario-qso-party-exchange-22wpm.mp3
mv ontario-qso-party-exchange-25wpm2.mp3 ontario-qso-party-exchange-25wpm.mp3
mv ontario-qso-party-exchange-28wpm2.mp3 ontario-qso-party-exchange-28wpm.mp3
mv ontario-qso-party-exchange-30wpm2.mp3 ontario-qso-party-exchange-30wpm.mp3
mv ontario-qso-party-exchange-35wpm2.mp3 ontario-qso-party-exchange-35wpm.mp3
mv ontario-qso-party-exchange-40wpm2.mp3 ontario-qso-party-exchange-40wpm.mp3
mv ontario-qso-party-exchange-45wpm2.mp3 ontario-qso-party-exchange-45wpm.mp3
mv ontario-qso-party-exchange-50wpm2.mp3 ontario-qso-party-exchange-50wpm.mp3

rm -f Ontario-introduction.mp3 silence.mp3 ontario-introduction.txt combine15.txt combine17.txt combine20.txt combine22.txt combine25.txt combine28.txt combine30.txt combine35.txt combine40.txt combine45.txt combine50.txt ontario-qso-party-exchange.txt
