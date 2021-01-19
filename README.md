# Morse-Code-Ninja
The software used to generate Morse Code Ninja practice sets as found on 
[Morse Code Ninja](https://morsecode.ninja/practice/index.html) and 
[Kurt Zoglmann's YouTube Channel](https://www.youtube.com/channel/UCXrTMfMEhkC9rVyQNU5aZlA).

# Required Software
These must be installed and available in your Shell's PATH.
* [ebook2cw](https://fkurz.net/ham/ebook2cw.html)
* [ffmpeg](https://ffmpeg.org)
* [lame](https://ffmpeg.org)
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
   
3. Edit the aws.properties file. Set the **key ID** and **secret access key**.


# Usage

1. Review and change as necessary the hardcoded configuration options at the top of the render.pl script.

2. Execute within the checkout directory.
```
./render example.txt
```

# General Notes
Do not invoke more than one render.pl script at a time. The script would collide with itself if
multiple copies were executing at the same time.

The software has been used extensively to build the Morse Code Ninja Library,
but it is far from user-friendly. There are many opportunities to improve it.

This set of scripts _should_ work on Windows, Linux, and MacOS, but it has only 
been used on MacOS.