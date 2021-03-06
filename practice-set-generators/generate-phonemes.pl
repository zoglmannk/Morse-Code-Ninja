#!/usr/bin/perl
use strict;
use Cwd;

# Usage:
# ./generate-phonemes.pl > multi-letter-phonemes.txt
#
# Set $repeat, $num_random_phonemes, and $quick_run as appropriate
# Rendered with: Pause 1 second except 0.7 for both pauses on fast rendition

my $repeat = 1; # number between 1 and 3
my $num_random_phonemes = 1500;
my $quick_run = 1; # phoneme spoken and repeated as sent

#  The source for this came from:
#  http://ingles-americano.blogspot.com/2013/09/clusters-digraph-blends-and-diphthongs.html
#  And
#  https://www.boardman.k12.oh.us/userfiles/363/Phonological%20Awareness/44Phonemes.pdf
#
# Word finder -- https://www.thefreedictionary.com/words-containing-er
my @phonemes = (
    # consonant digraphs
    ['ch', 'c h, as in, chicken.', 'chicken'],
    ['ck', 'c k, as in, jacket.', 'jacket'],
    ['ff', 'f, f, as in, cliff.', 'cliff'],
    ['gh', 'g h, as in, ghost.', 'ghost'],
    ['gn', 'g n, as in, gnome.', 'gnome'],
    ['kn', 'k n, as in, knife.', 'knife'],
    ['ll', 'l, l, as in, wall.', 'wall'],
    ['lm', 'l m, as in, palm.', 'palm'],
    ['mb', 'm b, as in, thumb.', 'thumb'],
    ['ng', 'n g, as in, bring.', 'bring'],
    ['ng', 'n g, as in, lounge.', 'lounge'],
    ['nk', 'n k, as in, sink.', 'sink'],
    ['ph', 'p h, as in, phone.', 'phone'],
    ['qu', 'q u, as in, quick.', 'quick'],
    ['sh', 's h, as in, shark.', 'shark'],
    ['ss', 's, s, as in, floss.', 'floss'],
    ['ss', 's, s, as in, pressure.', 'pressure'],
    ['th', 't h, as in, this.', 'this'],
    ['th', 't h, as in, bath.', 'bath'],
    ['wr', 'w h, as in, write.', 'write'],
    ['zz', 'z, z, as in, fuzz.', 'fuzz'],

    # consonant blends
    ['bl', 'b l, as in, blend.', 'blend'],
    ['br', 'b r, as in, break.', 'break'],
    ['cl', 'c l, as in, class.', 'class'],
    ['cr', 'c r, as in, crash.', 'crash'],
    ['dr', 'd r, as in, drive.', 'drive'],
    ['fl', 'f l, as in, flake.', 'flake'],
    ['fr', 'f r, as in, frost.', 'frost'],
    ['gl', 'g l, as in, glad.', 'glad'],
    ['gr', 'g r, as in, grade.', 'grade'],
    ['nd', 'n d, as in, send.', 'send'],
    ['pl', 'p l, as in, play.', 'play'],
    ['pr', 'p r, as in, prime.', 'prime'],
    ['sl', 's l, as in, slope.', 'slope'],
    ['sm', 's m, as in, small.', 'small'],
    ['sn', 's n, as in, snow.', 'snow'],
    ['sp', 's p, as in, space.', 'space'],
    ['st', 's t, as in, stop.', 'stop'],

    # vowel diagraphs
    ['ai', 'a, i, as in, rain.', 'rain'],
    ['au', 'a, u, as in, auto.', 'aunt'],
    ['aw', 'a, w, as in, saw.', 'saw'],
    ['ay', 'a, y, as in, say.', 'say'],
    ['ea', 'e, a, as in, eat.', 'eat'],
    ['ea', 'e, a, as in, dead.', 'dead'],
    ['ea', 'e, a, as in, break.', 'break'],
    ['ee', 'e, e, as in, see.', 'see'],
    ['ei', 'e, i, as in, veil.', 'veil'],
    ['ei', 'e, i, as in, seize.', 'seize'],
    ['eo', 'e, o, as in, people.', 'people'],
    ['eu', 'e, u, as in, Europe.', 'europe'],
    ['ew', 'e, w, as in, few.', 'few'],
    ['ey', 'e, y, as in, money.', 'money'],
    ['ey', 'e, y, as in, they.', 'they'],
    ['ie', 'i, e, as in, brief.', 'brief'],
    ['oa', 'o, a, as in, boat.', 'boat'],
    ['oe', 'o, e, as in, joe.', 'joe'],
    ['oo', 'o, o, as in, book.', 'book'],
    ['oo', 'o, o, as in, food.', 'food'],
    ['ou', 'o, u, as in, you.', 'you'],
    ['ow', 'o, w, as in, how.', 'how'],
    ['ue', 'u, e, as in, blue.', 'blue'],
    ['ui', 'u, i, as in, fruit.', 'fruit'],

    # Diphthongs
    ['ei', 'e, i, as in, feisty.', 'feisty'],
    ['ey', 'e, y, as in, eye.', 'eye'],
    ['ie', 'i, e, as in, tie.', 'tie'],
    ['ye', 'y, e, as in, rye.', 'rye'],
    ['fy', 'f, y, as in, notify.', 'notify'],
    ['ky', 'k, y, as in, sky.', 'sky'],

    # Diphthongs special cases
    ['ou', 'o, u, as in, round.', 'round'],
    ['oi', 'o, i, as in, oil.', 'oil'],
    ['oy', 'o, y, as in, boy.', 'boy'],


    # Three-letter Consonant Trigraphs
    ['chr', 'c h r, as in chrome.', 'chrome'],
    ['dge', 'd g e, as in dodge.', 'dodge'],
    ['tch', 't c h, as in catch.', 'catch'],

    # Three-Letter Blends
    ['shr', 's h r, as in, shroud.', 'shroud'],
    ['spl', 's p l, as in, splash.', 'splash'],
    ['spr', 's p r, as in, spray.', 'spray'],
    ['squ', 's q u, as in, square.', 'square'],
    ['str', 's t r, as in, string.', 'string'],
    ['thr', 't h r, as in, throw.', 'throw'],
    ['ity', 'i t y, as in, quality.', 'quality'],

    # Diphthongs
    ['igh', 'i g h, as in, night.', 'night'],
    ['ign', 'i g n, as in, sign.', 'sign'],
    ['ind', 'i n d, as in, kind.', 'kind'],

    # Four-Letter Diphthongs
    ['eigh', 'e, i, g, h, as in, height.', 'height'],

    # Vowel and Consonant Combination Trigraphs
    ['augh', 'a, u, g, h, as in, caught.', 'caught'],
    ['al', 'a, l, as in, talk.', 'talk'],
    ['wa', 'w a, as in, want.', 'want'],
    ['wa', 'w a, as in, wax.', 'wax'],
    ['ua', 'u, a, as in, quack.', 'quack'],
    ['oll', 'o, l, l, as in, doll.', 'doll'],
    ['ost', 'o, s, t, as in, cost.', 'cost'],
    ['oul', 'o, u, l, as in, soul.', 'soul'],
    ['old', 'o, l, d, as in, gold.', 'gold'],
    ['olk', 'o, l, k, as in, folk.', 'fold'],
    ['oll', 'o, l, l, as in, roll.', 'roll'],
    ['olt', 'o, l, t, as in, bolt.', 'bolt'],
    ['ost', 'o, s, t, as in, most.', 'most'],
    ['cy', 'c y, as in, fancy.', 'fancy'],
    ['ity', 'i, t, y, as in, quality.', 'quality'],
    ['logy', 'l, o, g, y, as in apology.', 'apology'],
    ['graphy', 'g r a p h y, as in photography.', 'photography'],

    # Miscellaneous - graphemes 2-letter or longer - not specified so far
    ['bb', 'b, b, as in, Bobby.', 'bobby'],
    ['dd', 'd, d, as in, add.', 'add'],
    ['ed', 'e, d, as in, filled.', 'filled'],
    ['gg', 'g, g, as in, egg.', 'egg'],
    ['ge', 'g, e, as in, germ.', 'germ'],
    ['cc', 'c, c, as in, occur.', 'occur'],
    ['que', 'q, u, e, as in, unique.', 'unique'],
    ['mm', 'm, m, as in, Jimmy.', 'Jimmy'],
    ['nn', 'n, n, as in, dinner.', 'dinner'],
    ['pp', 'p, p, as in, apple.', 'apple'],
    ['rr', 'r, r, as in, marry.', 'marry'],
    ['se', 's e, as in, sex.', 'sex'],
    ['ce', 'c e, as in, ice.', 'ice'],
    ['sc', 's c, as in, science.', 'science'],
    ['tt', 't, t, as in, letter.', 'letter'],
    ['ve', 'v e, as in, give.', 'give'],
    ['zz', 'z, z, as in, fizz.', 'fizz'],
    ['ze', 'z, e, as in, zero.', 'zero'],
    ['se', 's, e, as in, please.', 'please'],
    ['ti', 't, i, as in, motion.', 'motion'],
    ['ci', 'c i, as in, special.', 'special'],
    ['ge', 'g, e, as in, garage.', 'garage'],
    ['wh', 'w h, as in, what.', 'what'],
    ['ough', 'o u g h, as in, bought.', 'bought'],
    ['air', 'a, i, r, as in, chair.', 'chair'],
    ['ear', 'e, a, r, as in, bear.', 'bear'],
    ['are', 'a, r, e, as in, care.', 'care'],
    ['irr', 'i, r, r, as in, mirror.', 'mirror'],
    ['ere', 'e, r, e, as in, here.', 'here'],
    ['eer', 'e, e, r, as in, cheer.', 'cheer'],
    ['or', 'o, r, as in, for.', 'for'],
    ['ore', 'o, r, e, as in, more.', 'more'],
    ['oor', 'o, o, r, as in, door.', 'door'],
    ['ur', 'u, r, as in, burn.', 'burn'],
    ['ir', 'i, r, as in, first.', 'first'],
    ['er', 'e, r, as in, her.', 'her'],
    ['ear', 'e, a, r, as in, heard.', 'heard'],
    ['or', 'o, r, as in, work.', 'work'],
    ['ar', 'a, r, as in, dollar.', 'dollar']
);


sub pick_uniq_letter_combination {
    my $last_pick = $_[0];

    while(1) {
        my $next_pick = int(rand(scalar(@phonemes)));

        if($next_pick != $last_pick) {
            return $next_pick;
        }
    }
}


my $last_random_phoneme_index = -1;
for (my $i=0; $i < $num_random_phonemes; $i++) {
    my $random_phoneme_index = pick_uniq_letter_combination($last_random_phoneme_index);

    my $phoneme = $phonemes[$random_phoneme_index]->[0];
    my $spoken_part = $phonemes[$random_phoneme_index]->[1];
    $spoken_part=~ s/(\.|\?)/\\$1/g;
    my $repeat_part = $phonemes[$random_phoneme_index]->[2];

    if($quick_run == 1) {
        $spoken_part = $phoneme;
        my $spoken_part = join ', ', split(//, $spoken_part);
        chomp($spoken_part);
        if ($spoken_part eq 'e, e') { #this overcomes a weird spoken issue
            $spoken_part = 'e \. e';
        }

        if($repeat == 1) {
            print "$phoneme [$spoken_part|$phoneme]^\n";
        } else {
            my $phoneme_repeated = "$phoneme " x 3;
            print "${phoneme_repeated}[$spoken_part|$phoneme]^\n";
        }
    } else {
        if($repeat == 1) {
            print "$phoneme [$spoken_part|$repeat_part]^\n";
        } else {
            my $phoneme_repeated = "$phoneme " x 3;
            print "${phoneme_repeated}[$spoken_part|$repeat_part]^\n";
        }
    }


    $last_random_phoneme_index = $random_phoneme_index;
}


