#!/usr/bin/env python

import boto3
import os
import fnmatch
import time
from os import environ
from botocore.exceptions import ClientError


def get_aws_creds():
    aws_properties = {}

    if "AWS_KEY_ID" in environ and "AWS_SECRET_ACCESS_KEY" in environ:
        aws_properties['aws_access_key_id'] = environ['AWS_KEY_ID']
        aws_properties['aws_secret_access_key'] = environ['AWS_SECRET_ACCESS_KEY']
    else:
        try:
            with open('aws.properties') as property_file:

                for line in property_file:
                    if '=' in line:
                        name, value = line.split('=', 1)
                        aws_properties[name.strip()] = value.strip()
        except IOError as e:
            printf("I/O error reading aws.properties: {e.errno}, {e.strerror}")

            print("text2speech script does not have AWS credentials.")

    return aws_properties


def upload_file_to_s3(s3_client, filename, bucket, prefix=None):
    if prefix is not None:
        full_path = str(prefix) + "/" + filename
    else:
        full_path = filename

    try:
        response = s3_client.upload_file(filename, bucket, full_path)
    except ClientError as e:
        print("An error occurred uploading " + filename)
        print(e)

    print(response)


creds = get_aws_creds()
prefix = int(time.time())
s3_client = boto3.client('s3', aws_access_key_id=creds['aws_access_key_id'], aws_secret_access_key=creds['aws_secret_access_key'])
current_directory = os.listdir('.')
mp3_file_pattern = "*.mp3"
for mp3_file in current_directory:
    if fnmatch.fnmatch(mp3_file, mp3_file_pattern):
        upload_file_to_s3(s3_client, mp3_file, 'your-valid-bucket-name', prefix)
