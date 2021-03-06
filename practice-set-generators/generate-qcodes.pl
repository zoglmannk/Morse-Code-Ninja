#!/usr/bin/perl
use strict;
use Cwd;

# Usage: ./generate-qcodes.pl  > qcodes-repeated.txt
#
# Morse Code Ninja sets:
#
# Q-Codes with repeat - Set repeat=3, num_random_qcode=600, $prounce_exact=1
# Silence 1 second
#
# Q-Codes no repeat - Set repeat=1, num_random_qcode=600, $prounce_exact=1
# Silence 1 second
#
# Q-Codes no repeat - meaning spoken - Set repeat=1, num_random_qcode=600, $prounce_exact=0
# Silence 2.5/1.5 second

my $repeat = 1; # number between 1 and 3
my $num_random_qcodes = 1000;
my $pronounce_exact = 0; # number 0 or 1

my @qcode_pronunciation_as_question = (
    'What is the name, or call sign of your station?',
    'What is the exact frequency?',
    'Does my frequency vary?',
    'How is the tone of my transmission?',
    'Are you receiving me badly?',
    'What is the intelligibility of my signals, or those of blank?',
    'Are you busy?',
    'Is my transmission being interfered with?',
    'Are you troubled with static?',
    'Should I increase power?',
    'Should I decrease power?',
    'Should I send faster?',
    'Should I send slower?',
    'Should I stop sending?',
    'Have you anything for me?',
    'Are you ready?',
    'Should I inform, blank, that you are calling on, X, kilohertz?',
    'Should I standby? Or when will you call me again?',
    'What number if my turn?',
    'Who is calling me?',
    'What is the strength of my signals, or those of, blank?',
    'Are my signals fading?',
    'Is my keying defective?',
    'Should I send, blank, messages at a time?',
    'Can you hear me between your signals, and if so, can I break in on your transmission?',
    'Did you copy my message?',
    'Should I repeat the last message I sent you? Or some previous message?',
    'Did you hear me, or blank, on X, kilohertz?',
    'Can you communicate with, blank, direct or by relay?',
    'Will you relay to, blank?',
    'What working frequency will you use?',
    'Should I send on this frequency, or on X, kilohertz?',
    "Should I send a series of V's on this frequency, or on, X, kilohertz?",
    'Will you send on this frequency, or on X, kilohertz?',
    'Will you listen to, blank, on X, kilohertz?',
    'Should I change my transmission to another frequency?',
    'Should I send each word or group more than once?',
    'Should I cancel message number X?',
    'Do you agree with my counting of words?',
    'How many messages do you have?',
    'What is your location?',
    'What is the correct time?',
    'Will you keep your station open for further communication with me?',
    'Do you have news of, blank?'
);

my @qcode_pronunciation_as_statement = (
    'The name, or call sign of your station is, blank.',
    'Your exact frequency, or that of, blank, is X, kilohertz.',
    'Your frequency varies.',
    'The tone of your transmission is, X.',
    'I cannot receive you. Your signals are too weak.',
    'The intelligibility of your signals, or that of, blank, is X.',
    'I am busy, or busy with blank. Please do not interfere.',
    'Your transmission is being interfered by, X.',
    'I am troubled with static by, X.',
    'Increase power.',
    'Decrease power.',
    'Send faster, or by, X, words per minute.',
    'Send more slowly, or by, X, words per minute.',
    'I will stop sending.',
    'I have nothing for you.',
    'I am ready.',
    'Please inform, blank, that I am calling on, X, kilohertz',
    'I will call you again at, blank, hours, on X kilohertz.',
    'Your turn is number, X.',
    'You are being called by, blank, on X kilohertz.',
    'The strength of your signals, or those of, blank, is X.',
    'Your signals are fading.',
    'Your keying is defective.',
    'Send, X, messages at a time.',
    'I can hear you between my signals. You may break in on my transmission.',
    'I copied your message.',
    'Repeat the last message you sent me, or specifically messages numbered X, and X.',
    'I heard you, or blank, on X kilohertz.',
    'I can communicate with, blank, directly, or by relay through, blank.',
    'I will relay to, blank.',
    'I will use, X, kilohertz.',
    'Send on this frequency, or, X kilohertz.',
    "Send a series of V's on this frequency, or on X, kilohertz.",
    'I will send on this frequency, or on, X kilohertz.',
    'I am listening to, blank, on, X kilohertz.',
    'Change your transmission to another frequency, or on, X kilohertz.',
    'Send each word or group twice. Or, X, times.',
    'Cancel message number, X.',
    'I do not agree with your counting of words. I will repeat the first letter or digit of each word or group.',
    'I have, X, messages for you, or blank.',
    'My location is, blank.',
    'The correct time is, blank.',
    'Keep your station open to me.',
    'I have news of, blank.'
);


my @qcode = qw (
    QRA QRG QRH QRI QRJ QRK QRL QRM QRN QRO QRP QRQ QRS QRT QRU QRV QRW QRX QRY QRZ QSA
    QSB QSD QSG QSK QSL QSM QSN QSO QSP QSS QSU QSV QSW QSX QSY QSZ QTA QTB QTC QTH QTR
    QTX QUA
);



sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@qcode)));

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_qcode_index = -1;
for (my $i=0; $i < $num_random_qcodes; $i++) {
    my $random_qcode_index = pick_uniq_letter_combination($last_random_qcode_index);

    my $qcode_as_question = int(rand(100));
    if($qcode_as_question >= 50 ) {
        $qcode_as_question = 1;
    } else {
        $qcode_as_question = 0;
    }

    if($repeat == 1) {
        if($pronounce_exact == 1) {
            my $safe_pronouciation = join ' ', split(//, $qcode[$random_qcode_index]);

            if($qcode_as_question == 1) {
                print "$qcode[$random_qcode_index]\\? [$safe_pronouciation \\?|$qcode[$random_qcode_index]\\?]^\n";
            } else {
                print "$qcode[$random_qcode_index] [$safe_pronouciation|$qcode[$random_qcode_index]]^\n";
            }

        } else {

            if($qcode_as_question == 1) {
                my $safe_pronunciation_as_question = $qcode_pronunciation_as_question[$random_qcode_index];
                $safe_pronunciation_as_question=~ s/(\.|\?)/\\$1/g;
                print "$qcode[$random_qcode_index]\\? [$safe_pronunciation_as_question]^\n";
            } else {
                my $safe_pronunciation_as_statement = $qcode_pronunciation_as_statement[$random_qcode_index];
                $safe_pronunciation_as_statement =~ s/(\.|\?)/\\$1/g;
                print "$qcode[$random_qcode_index] [$safe_pronunciation_as_statement]^\n";
            }
        }

    } else {

        if($pronounce_exact == 1) {
            my $safe_pronouciation = join ' ', split(//, $qcode[$random_qcode_index]);

            if($qcode_as_question == 1) {
                my $repeated_abbreviation = "$qcode[$random_qcode_index]\\? " x $repeat;
                print "${repeated_abbreviation}[$safe_pronouciation \\?|$qcode[$random_qcode_index]\\?]^\n";
            } else {
                my $repeated_abbreviation = "$qcode[$random_qcode_index] " x $repeat;
                print "${repeated_abbreviation}[$safe_pronouciation|$qcode[$random_qcode_index]]^\n";
            }


        } else {

            if($qcode_as_question == 1) {
                my $repeated_abbreviation = "$qcode[$random_qcode_index]\\? " x $repeat;
                my $safe_pronunciation_as_question = $qcode_pronunciation_as_question[$random_qcode_index];
                $safe_pronunciation_as_question=~ s/(\.|\?)/\\$1/g;
                print "${repeated_abbreviation}[$safe_pronunciation_as_question|$qcode[$random_qcode_index]\\?]^\n";
            } else {
                my $repeated_abbreviation = "$qcode[$random_qcode_index] " x $repeat;
                my $safe_pronunciation_as_statement = $qcode_pronunciation_as_statement[$random_qcode_index];
                $safe_pronunciation_as_statement =~ s/(\.|\?)/\\$1/g;
                print "${repeated_abbreviation}[$safe_pronunciation_as_statement|$qcode[$random_qcode_index]]^\n";
            }
        }


    }

    $last_random_qcode_index = $random_qcode_index;
}


