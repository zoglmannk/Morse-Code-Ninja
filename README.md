# Morse-Code-Ninja
The software used to generate Morse Code Ninja practice sets as found on 
[Morse Code Ninja](https://morsecode.ninja/practice/index.html) and 
[Kurt Zoglmann's YouTube Channel](https://www.youtube.com/channel/UCXrTMfMEhkC9rVyQNU5aZlA).

# Required Software
These must be installed and available in your Shell's PATH.
* [ebook2cw](https://fkurz.net/ham/ebook2cw.html)
* [ffmpeg](https://ffmpeg.org)
* [sox](https://sourceforge.net/projects/sox/)
* [lame](https://lame.sourceforge.io/)
* [Perl 5](https://www.perl.org)
* [Python 3](https://www.python.org)
* [Boto3](https://aws.amazon.com/sdk-for-python/)

# Cloud Setup
1. Set up an AWS Account. Feel free to follow these 
[instructions](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/).

2. Create an [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html). 
For ease, I recommend using the "console" for this. During creation, give 
the IAM user "Programmatic access." When prompted save the **key ID** and **secret access key**.
During the creation, attach the **AmazonPollyFullAccess** policy to the user.
   
3. Edit the aws.properties file. Set the **key ID** and **secret access key**. As an alternative, 
you may define AWS_KEY_ID and AWS_SECRET_ACCESS_KEY as environmental variables.

4. Run this command to make sure that you don't accidentally check in your key! `git update-index --assume-unchanged aws.properties`


# Usage
#### EXAMPLE:
    perl render.pl -i example.txt
    
#### NAME:
    render.pl -- create mp3 audio files defined by an text file.

#### SYNOPSIS:
    perl render.pl -i file [-o directory] [-c directory] [-s speeds] [-p pitch] [-pr]
                   [-m max processes] [-z 1] [-rr 1] [--test] [-l word limit]
                   [--norepeat] [--nospoken] [--nocourtesytone] [-e NEURAL | STANDARD] 
                   [--sm] [--ss] [--sv] [-x] [--lang ENGLISH | SWEDISH]

Uses AWS Polly and requires valid credentials in the aws.properties file.<br/><br/>

#### OPTIONS:

##### Required:
    -i, --input           name of the text file containing the script to render

#### Optional:
    -i, --input           name of the text file containing the script to render
    -o, --output          directory to use for temporary files and output mp3 files
    -c, --cache           directory to use for cache specific files
    -s, --speeds          list of speeds in WPM. example -s 15 17 20 25/10 (Farnsworth specified as character_speed/overall_speed)
    -p, --pitchtone       tone in Hz for pitch. Default 700
    -pr, --pitchrandom    random pitch tone from range [500-900] Hz with step 50 Hz for every practice trial
    -m, --maxprocs        maximum number of parallel processes to run
    -z, --racing          speed racing format
    -rr, --racingrepeat   repeat final repeat. Use with -z (Speed Racing format).
    --test                don't render audio -- just show what will be rendered -- useful when encoding text
    -l, --limit           word limit. 14 works great... 15 word limit for long sentences; -1 disables it
    --norepeat            exclude repeat morse after speech
    --nospoken            exclude spoken
    --nocourtesytone      exclude the courtesy tone
    --tone                include the courtesy tone
    -e, --engine          name of Polly speech engine to use: NEURAL or STANDARD
    -sm, --silencemorse  length of silence between Morse code and spoken voice. Default 1 second.
    -ss, --silencesets   length of silence between courtesy tone and next practice set. Default 1 second.
    -sv, --silencevoice  length of silence between spoken voice and repeated morse code. Default 1 second.
    -sc, --silencecontext length of silence between spoken context and morse code. Default 1 second.
    -st, --silencemanualcourtesytone length of silence between Morse code and manually specified courtesy tone <courtesyTone>. Default 1 second.
    -x, --extraspace      0 is no extra spacing. 0.5 is half word extra spacing. 1 is twice the word space. 1.5 is 2.5x the word space. etc
    --precise             trim AWS Polly and ebook2cw audio -- useful when specifying very short time with -sm, --silencemorse length of silence between Morse code and spoken voice.
                          ****Be sure*** to clear the cache directory if you are switching between precise and non-precise timing.\n";
    -l, --lang            language: ENGLISH or SWEDISH

# General Notes
The software has been used extensively to build the [Morse Code Ninja Library](https://morsecode.ninja/practice/index.html).
There are many opportunities to improve it.

Do not invoke more than one render.pl script at a time without specifying unique output directories. The script will collide with itself if
multiple copies are executing at the same time using the same output directory.

Be aware that the script can create a huge number of temporary files, which is proportional to the input file. Some types of filesystems will deal with this better than others.

This set of scripts works on Linux and macOS.

# Docker Usage
This usage limits the required software to:
- [Docker](https://www.docker.com/get-started/) 
- [AWS Cloud Setup](#cloud-setup)

To run
```
./morse-code-ninja.sh -i example.txt
```

The script `morse-code-ninja.sh` wraps the docker compose command passing all arguments to the dockerized `render.pl` 
