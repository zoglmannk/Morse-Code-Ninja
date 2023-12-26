FROM python:3

RUN apt update
RUN apt -y install lame ffmpeg ebook2cw
RUN pip install boto3

RUN mkdir -p /opt/morse-code-ninja
WORKDIR /opt/morse-code-ninja
