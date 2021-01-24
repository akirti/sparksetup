From ubuntu:20.10
LABEL author="Akirti" email="ak@ak.com"
LABEL version="0.1"


RUN apt-get update && \
        apt-get install -y python3

# Set for current session
ENV LC_ALL="en_US.UTF-8" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TZ="UTC-5"

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates jq

RUN apt-get update \
 && apt-get install -y curl unzip \
 python3 python3-setuptools \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && apt-get clean \

RUN pip install py4j

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashs>
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
RUN apt-get update \
 && apt-get install -y openjdk-8-jre \
 && apt-get clean \
