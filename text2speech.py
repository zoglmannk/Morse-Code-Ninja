#!/usr/bin/env python

import boto3
import sys
import re
import hashlib
import os.path
from os import environ
import shutil
import subprocess

sentence_filename = sys.argv[1]
engine_type = sys.argv[2].lower()  # needs to be: standard | neural
language = sys.argv[3]
#cache_directory = 'cache/'
cache_directory = sys.argv[4]

# ERROR return codes (coordinate with render.pl for intelligent error handling)
ioError = 2

working_directory = os.path.split(sentence_filename)[0]
print("Engine:" + engine_type)
print("Processing sentence filename: " + sentence_filename + ".txt")
print("Working directory:" + working_directory)
print("Cache directory: " + cache_directory)

separator = "="
aws_properties = {}

if "AWS_ACCESS_KEY_ID" in environ and "AWS_SECRET_ACCESS_KEY" in environ:
    aws_properties['aws_access_key_id'] = environ['AWS_ACCESS_KEY_ID']
    aws_properties['aws_secret_access_key'] = environ['AWS_SECRET_ACCESS_KEY']
else:
    try:
        with open('aws.properties') as property_file:

            for line in property_file:
                if separator in line:
                    name, value = line.split(separator, 1)
                    aws_properties[name.strip()] = value.strip()
    except IOError as e:
        print(f"I/O error reading aws.properties: {e.errno}, {e.strerror}")

        print("text2speech script does not have AWS credentials.")
        sys.exit(ioError)

if aws_properties['aws_access_key_id'] == 'CHANGE_ME' or aws_properties['aws_secret_access_key'] == 'CHANGE ME':
    print("**********************************************************************************")
    print("text2speech script does NOT have AWS credentials. Set properties in aws.properties")
    print("**********************************************************************************")
    sys.exit(ioError)

sha256_hash = hashlib.sha256()

with open(sentence_filename + ".txt", "r") as sentence_file:
    sentence = sentence_file.readlines()[0]

hex_digest = hashlib.sha256(sentence.encode('utf-8')).hexdigest()
base_filename = engine_type + '-' + hex_digest + ".mp3"
temp_filename = cache_directory + engine_type + "-" + hex_digest + "-temp.mp3"
cache_filename = cache_directory + hex_digest + ".mp3"

def render(cache_filename, voice_id, text_type, text):
    if not os.path.exists(cache_filename):
        polly_client = boto3.Session(aws_access_key_id=aws_properties['aws_access_key_id'],
                                     aws_secret_access_key=aws_properties['aws_secret_access_key'],
                                     region_name='us-east-1').client('polly')
        if text_type is None:
            response = polly_client.synthesize_speech(Engine=engine_type, VoiceId=voice_id, OutputFormat='mp3', Text=text)
        else:
            response = polly_client.synthesize_speech(Engine=engine_type, VoiceId=voice_id, OutputFormat='mp3',
                                                      TextType=text_type, Text=text)

        file = open(temp_filename, 'wb')
        file.write(response['AudioStream'].read())
        file.close()

        subprocess.run(['lame', '--resample', '44.1', '-a', '-b', '256',
                        temp_filename,
                        cache_filename],
                        stdout=subprocess.PIPE,
                        universal_newlines=True)
        
        os.remove(temp_filename)

    print("Cached filename:" + cache_filename)


# Warning: if you update this logic, you must update get_text2speech_cached_filename in
#          render.pl
if language == "ENGLISH":
    # short individual words are easier to understand spoken more slowly
    if re.match(r"\s*<speak>.*?</speak>\s*", sentence):
        print("Pronouncing exactly as specified")
        ssml = sentence
        cache_filename = cache_directory + "Mathew-exact-" + base_filename
        render(cache_filename, 'Matthew', 'ssml', ssml)
    elif re.match(r"^\s*([A-Za-z]{1,4})\s*$", sentence):
        print("Pronouncing slowly: " + sentence)
        ssml = "<speak><prosody rate=\"x-slow\">" + sentence + "</prosody></speak>"
        cache_filename = cache_directory + "Mathew-slowly-" + base_filename
        render(cache_filename, 'Matthew', 'ssml', ssml)
    else:
        print("Pronouncing normal speed: " + sentence)
        cache_filename = cache_directory + "Mathew-standard-" + base_filename
        render(cache_filename, voice_id='Matthew', text_type=None, text=sentence)
        print("sentence" + sentence)
else:
    voice_id = "Matthew"

    if language == "SWEDISH":
        if engine_type == "neural":
            voice_id = "Elin"
        else:
            voice_id = "Astrid"

    if language == "GERMAN":
        voice_id = "Vicki"

    print("Using Voice: " + voice_id)
    cache_filename = cache_directory + language + "-standard-" + base_filename
    render(cache_filename, voice_id=voice_id, text_type=None, text=sentence)
    print("sentence" + sentence)


