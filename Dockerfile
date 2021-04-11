FROM debian:jessie

RUN dpkg --add-architecture i386
RUN apt-get update -y && \
    apt-get install build-essential gdb mtools nasm file -y \
    && apt-get install libc6-dev-i386 libstdc++6:i386 -y

RUN echo Etc/GMT-1 > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

VOLUME /root/env 
WORKDIR /root/env
USER root

# docker run -it --rm -v `pwd`:/root/env docker-tag
# docker run -it --rm -v %cd%:/root/env docker-tag
# make 